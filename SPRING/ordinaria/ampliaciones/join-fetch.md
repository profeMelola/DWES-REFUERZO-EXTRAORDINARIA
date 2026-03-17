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