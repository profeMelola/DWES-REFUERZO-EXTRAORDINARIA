# JOIN FETCH y el problema N+1 — Relación N:M Doctor ↔ Specialty

## Contexto

En la relación N:M entre `Doctor` y `Specialty`, la tabla intermedia `DoctorSpecialty`
tiene atributos propios (`level`, `sinceDate`, `consultationFeeOverride`) y dos asociaciones
`@ManyToOne` con `FetchType.LAZY`:

```java
@ManyToOne(fetch = FetchType.LAZY, optional = false)
@JoinColumn(name = "doctor_id")
private Doctor doctor;

@ManyToOne(fetch = FetchType.LAZY, optional = false)
@JoinColumn(name = "specialty_id")
private Specialty specialty;
```

El problema aparece en los endpoints que necesitan navegar esas asociaciones para construir
el DTO de respuesta.

---

## El problema N+1

Sin ningún fetch explícito, al intentar acceder al nombre de la especialidad en el mapper:

```java
List<DoctorSpecialty> list = doctorSpecialtyRepository.findByDoctorId(doctorId);

for (DoctorSpecialty ds : list) {
    ds.getSpecialty().getName(); // ← Hibernate lanza una query por cada fila
}
```

Hibernate genera:

```sql
-- 1 query para la lista
SELECT * FROM doctor_specialties WHERE doctor_id = 1;

-- 1 query POR CADA fila (N queries)
SELECT * FROM specialties WHERE id = 1;
SELECT * FROM specialties WHERE id = 3;
SELECT * FROM specialties WHERE id = 5;
-- ...
```

Con 5 especialidades son **6 queries** en lugar de 1. Con 100 filas, 101. Esto es el
**problema N+1**.

---

## La solución: `JOIN FETCH`

`JOIN FETCH` le indica a Hibernate que traiga la asociación en la **misma query**, haciendo
el JOIN en base de datos.

### Repositorio

```java
public interface DoctorSpecialtyRepository extends JpaRepository<DoctorSpecialty, DoctorSpecialtyId> {

    // GET /doctors/{id}/specialties
    // Trae doctor_specialties + specialties en una sola query
    @Query("""
        SELECT ds FROM DoctorSpecialty ds
        JOIN FETCH ds.specialty
        WHERE ds.doctor.id = :doctorId
    """)
    List<DoctorSpecialty> findByDoctorIdWithSpecialty(@Param("doctorId") Long doctorId);


    // GET /specialties/{id}/doctors
    // Trae doctor_specialties + doctors en una sola query
    @Query("""
        SELECT ds FROM DoctorSpecialty ds
        JOIN FETCH ds.doctor
        WHERE ds.specialty.id = :specialtyId
    """)
    List<DoctorSpecialty> findBySpecialtyIdWithDoctor(@Param("specialtyId") Long specialtyId);
}
```

### SQL generado por Hibernate

Para `findByDoctorIdWithSpecialty`:

```sql
SELECT ds.*, s.*
FROM doctor_specialties ds
INNER JOIN specialties s ON s.id = ds.specialty_id
WHERE ds.doctor_id = 1
```

Para `findBySpecialtyIdWithDoctor`:

```sql
SELECT ds.*, d.*
FROM doctor_specialties ds
INNER JOIN doctors d ON d.id = ds.doctor_id
WHERE ds.specialty_id = 1
```

En ambos casos: **una sola query**, sin importar cuántas filas devuelva.

---

## Uso en el mapper

Una vez ejecutado el `JOIN FETCH`, los objetos asociados ya están cargados en memoria.
Acceder a ellos **no genera ninguna query adicional**:

```java
// GET /doctors/1/specialties
List<DoctorSpecialty> rows = repo.findByDoctorIdWithSpecialty(doctorId);

for (DoctorSpecialty ds : rows) {
    ds.getSpecialty().getName();          // ✅ ya en memoria, sin query
    ds.getSpecialty().getCode();          // ✅
    ds.getLevel();                        // ✅ de la tabla intermedia
    ds.getSinceDate();                    // ✅ de la tabla intermedia
    ds.getConsultationFeeOverride();      // ✅ de la tabla intermedia
}
```

```java
// GET /specialties/1/doctors
List<DoctorSpecialty> rows = repo.findBySpecialtyIdWithDoctor(specialtyId);

for (DoctorSpecialty ds : rows) {
    ds.getDoctor().getFullName();         // ✅ ya en memoria, sin query
    ds.getDoctor().getLicenseNumber();    // ✅
    ds.getLevel();                        // ✅ de la tabla intermedia
}
```

---

## Comparativa de queries generadas

| Situación | Queries a BD |
|---|---|
| `findByDoctorId` + acceso a `specialty` en mapper | 1 + N (problema N+1) |
| `findByDoctorIdWithSpecialty` con `JOIN FETCH` | 1 |

---

## ¿Cuándo usar método por nombre y cuándo JPQL?

| Caso | Solución |
|---|---|
| Solo necesitas filtrar, sin navegar asociaciones `LAZY` en el mapper | Método por nombre |
| Necesitas navegar una asociación `LAZY` en el mapper | JPQL con `JOIN FETCH` |

> **Regla general:** si en el mapper tocas `ds.getSpecialty()` o `ds.getDoctor()`,
> necesitas `JOIN FETCH`. Si solo usas campos de la propia entidad, un método por nombre es suficiente.

---

## JOIN con y sin FETCH

### Sin JOIN FETCH

**Caso 1:**

```
@Query("SELECT ds FROM DoctorSpecialty ds WHERE ds.doctor.id = :doctorId")
List<DoctorSpecialty> findByDoctorId(Long doctorId);
```

Hibernate genera una query para la lista:
```
SELECT ds.*
FROM doctor_specialties ds
WHERE ds.doctor_id = 1
```

**Caso 2:**

```
@Query("SELECT ds FROM DoctorSpecialty ds JOIN ds.specialty WHERE ds.doctor.id = :doctorId")
List<DoctorSpecialty> findByDoctorId(Long doctorId);
```

Hibernate genera:

```
SELECT ds.*
FROM doctor_specialties ds
INNER JOIN specialties s ON s.id = ds.specialty_id  -- solo para filtrar/navegar
WHERE ds.doctor_id = 1
```

En ambos casos, Hibernate devuelve las filas de doctor_specialties, pero ds.specialty queda como proxy sin inicializar. 

En el momento en que el mapper accede a ds.getSpecialty().getName(), Hibernate lanza una query por cada fila:

```
SELECT * FROM specialties WHERE id = 1;  -- fila 1
SELECT * FROM specialties WHERE id = 3;  -- fila 2
SELECT * FROM specialties WHERE id = 5;  -- fila 3
```

### Con JOIN FETCH

```
@Query("SELECT ds FROM DoctorSpecialty ds JOIN FETCH ds.specialty WHERE ds.doctor.id = :doctorId")
List<DoctorSpecialty> findByDoctorIdWithSpecialty(Long doctorId);
```

Hibernate genera una sola query con el JOIN incluido:

```
SELECT ds.*, s.*
FROM doctor_specialties ds
INNER JOIN specialties s ON s.id = ds.specialty_id
WHERE ds.doctor_id = 1
```

`ds.specialty` ya está completamente inicializado en memoria. El mapper accede a `ds.getSpecialty().getName()` **sin tocar base de datos**.

Con 3 especialidades → **1 query** en total.

```
Sin JOIN FETCH                                                      Con JOIN FETCH
──────────────────────────────                                      ──────────────────────────────
Query 1: SELECT ds.*                        →                       Query 1: SELECT ds.*, s.*
         WHERE doctor_id = 1                                        JOIN specialties s
                                                                    WHERE doctor_id = 1
Query 2: SELECT * FROM specialties WHERE id = 1   (mapper toca fila 1)
Query 3: SELECT * FROM specialties WHERE id = 3   (mapper toca fila 2)
Query 4: SELECT * FROM specialties WHERE id = 5   (mapper toca fila 3)

Total: 4 queries                  Total: 1 query

```

La diferencia parece pequeña con 3 filas, pero con 50 doctores cada uno con 4 especialidades estás hablando de 201 queries vs 1.

--- 


# Fetch por defecto en JPA — LAZY vs EAGER

## `@OneToMany` es `LAZY` por defecto

Cuando cargas un `Doctor`, el `Set<DoctorSpecialty>` **no se carga** hasta que accedes
a él explícitamente:

```java
Doctor doctor = doctorRepository.findById(1L).get();
// En este punto: doctor.specialties NO está cargado (es un proxy vacío)

doctor.getSpecialties(); // ← AQUÍ Hibernate lanza la query
// SELECT * FROM doctor_specialties WHERE doctor_id = 1
```

---

## Defaults de JPA que conviene memorizar

| Anotación | Fetch por defecto |
|---|---|
| `@OneToMany` | `LAZY` |
| `@ManyToMany` | `LAZY` |
| `@ManyToOne` | **`EAGER`** |
| `@OneToOne` | **`EAGER`** |

> Los que apuntan a **colecciones** son `LAZY`.
> Los que apuntan a **una sola entidad** son `EAGER`.

---

## La regla general en producción

Aunque `@ManyToOne` sea `EAGER` por defecto, en proyectos reales se recomienda
**forzar `LAZY` en todos** y controlar la carga explícitamente con `JOIN FETCH`
cuando la necesitas:

```java
@ManyToOne(fetch = FetchType.LAZY, optional = false)
private Doctor doctor;
```

Así evitas cargas innecesarias y tienes control total sobre cuándo va a base de datos,
que es exactamente lo que se hace en los repositorios con `JOIN FETCH`.

---

## Relación con `JOIN FETCH`

Forzar `LAZY` en todas las asociaciones y usar `JOIN FETCH` explícito en los repositorios
es el patrón recomendado porque:

- **Sin `JOIN FETCH`** → Hibernate carga la asociación de forma perezosa, generando
  una query extra por cada objeto que toques en el mapper (problema N+1).
- **Con `JOIN FETCH`** → Hibernate trae la asociación en la misma query, sin queries adicionales.

```java
// Repositorio controlando explícitamente la carga
@Query("""
    SELECT ds FROM DoctorSpecialty ds
    JOIN FETCH ds.specialty
    WHERE ds.doctor.id = :doctorId
""")
List<DoctorSpecialty> findByDoctorIdWithSpecialty(@Param("doctorId") Long doctorId);
```

--- 

# Estrategias de borrado en JPA: CascadeType.ALL vs Validación por código

## El modelo de entidades

```
Doctor
  └── Appointment  (@OneToMany)
        └── Invoice  (@OneToOne)
              └── InvoiceLine  (@OneToMany)
```

---

## Opción A: Sin `CascadeType.ALL` (solo PERSIST y MERGE)

```java
@OneToMany(mappedBy = "doctor", cascade = {CascadeType.PERSIST, CascadeType.MERGE})
private List<Appointment> appointments = new ArrayList<>();
```

Al intentar borrar un `Doctor`, la base de datos lanza una **violación de restricción de integridad** porque existen `Appointment` que referencian ese doctor. JPA no propaga el `DELETE` y el error es técnico (excepción JDBC), sin ningún mensaje de negocio claro para el cliente.

---

## Opción B: `CascadeType.ALL`

```java
@OneToMany(mappedBy = "doctor", cascade = CascadeType.ALL, orphanRemoval = true)
private List<Appointment> appointments = new ArrayList<>();
```

Hibernate propaga el `DELETE` en cascada a través de toda la jerarquía:

```
deleteById(doctorId)
  → DELETE Appointment
      → DELETE Invoice
          → DELETE InvoiceLine
```

### Cómo actúa Hibernate internamente

Hibernate trabaja **en memoria**: antes de ejecutar ningún `DELETE`, carga todos los `Appointment` del doctor, luego por cada uno carga su `Invoice`, y por cada factura carga sus `InvoiceLine`. Solo entonces lanza los `DELETE` en el orden correcto.

Esto implica:

- **Queries N+1 de carga** antes de borrar, potencialmente costosas con volumen alto de datos.
- **Borrado silencioso en producción**: si un doctor tiene 500 citas con 500 facturas, se borran 1.000+ filas sin ningún aviso al usuario.
- Con `orphanRemoval = true`, también se borran entidades al hacer simplemente `appointments.remove(a)`, lo que puede sorprender.

---

## Opción C: Validación por código (recomendada para este dominio)

```java
public void deleteDoctor(Long doctorId) {
    if (appointmentRepository.existsByDoctorId(doctorId)) {
        throw new BusinessRuleException("El doctor tiene citas asociadas. Imposible borrar.");
    }
    doctorRepository.deleteById(doctorId);
}
```

La validación previa ofrece un **mensaje de error controlado** en vez de una excepción técnica de JDBC.

La relación queda configurada solo con `PERSIST` y `MERGE`:

```java
@OneToMany(mappedBy = "doctor", cascade = {CascadeType.PERSIST, CascadeType.MERGE})
private List<Appointment> appointments = new ArrayList<>();
```

### Consideraciones adicionales

Si en algún momento la regla de negocio *sí* permite el borrado del doctor, hay que gestionar las entidades huérfanas explícitamente. Las opciones son:

- **Soft delete**: añadir un campo `active = false` al doctor en vez de borrarlo físicamente.
- **Reasignación**: asignar las citas a otro doctor antes de borrar.
- **Borrado manual en el servicio**: borrar en orden correcto desde la capa `@Service`.

---

## Comparativa

| Criterio | CascadeType.ALL | Validación por código |
|---|---|---|
| Consistencia de BD | Automática | Requiere gestión manual |
| Claridad del error | Ninguna (silencioso) | Mensaje de negocio explícito |
| Riesgo en producción | Alto (borrado masivo) | Bajo (datos protegidos) |
| Queries al borrar | N+1 de carga + DELETE | Solo un `existsBy` |
| Código necesario | Mínimo | Explícito en el servicio |

---

## Regla práctica

| Tipo de relación | Estrategia sugerida |
|---|---|
| **Composición** (Invoice → InvoiceLine) | `CascadeType.ALL` + `orphanRemoval = true` |
| **Agregación** (Doctor → Appointment) | Validación en servicio, sin cascade de DELETE |
| Entidad con vida propia y compartida | Nunca cascade, gestión manual |

`Doctor → Appointment` es un caso de **agregación**: las citas tienen vida propia (pertenecen también al paciente, generan facturas), por lo que lo correcto es protegerlas con lógica de negocio explícita, no borrarlas en cascada.

---

## Conclusión

Usar `CascadeType.ALL` en relaciones de agregación traslada decisiones de negocio a la capa de persistencia, haciéndolas invisibles. La validación por código mantiene la **intención explícita** y permite mensajes de error significativos para el cliente, a cambio de algo más de código en la capa de servicio.
