# Spring Data JPA — Generación de consultas por nombre de método

## ¿Cómo funciona?

Spring Data JPA analiza el nombre del método en tiempo de arranque y genera automáticamente la consulta JPQL equivalente. No se escribe SQL ni JPQL: el nombre del método **es** la consulta.

El framework divide el nombre en dos partes:
- **Prefijo** → `find…By`, `exists…By`, `count…By`, `delete…By`
- **Criterio** → el nombre de la propiedad (o cadena de propiedades) que viene después de `By`

```
existsByDoctorId
────────┬──────── ─────┬─────
     prefijo        criterio
```

---

## La diferencia entre `existsByDoctorId` y `existsByDoctor_Id`

Ambos métodos producen **exactamente la misma consulta SQL**. La diferencia es únicamente sintáctica y afecta a cómo Spring Data JPA resuelve el path de navegación.

### Resolución sin guion bajo: `existsByDoctorId`

Spring Data intenta resolver `DoctorId` de forma **ambigua**:

1. Primero busca una propiedad llamada `doctorId` directamente en `Appointment`. ❌ No existe.
2. Al fallar, aplica una heurística: divide el nombre en `Doctor` + `Id` y navega la asociación `doctor.id`. ✅

Funciona, pero si existiera una propiedad `doctorId` en la entidad (columna directa), habría **ambigüedad** y Spring Data resolvería la propiedad directa en lugar de la asociación.

### Resolución con guion bajo: `existsByDoctor_Id`

El guion bajo actúa como **separador explícito** de la navegación:

- `Doctor` → navega la asociación `doctor`
- `Id` → accede a la propiedad `id` dentro de `Doctor`

Elimina toda ambigüedad y hace el path inequívoco.

### Regla práctica

| Situación | Recomendación |
|-----------|---------------|
| No hay ambigüedad posible | Cualquiera de los dos |
| Podría haber una propiedad con el mismo nombre concatenado | Usar `_` para forzar la navegación |
| Legibilidad / claridad de intención | Preferir `_` en asociaciones anidadas |

```java
// Equivalentes en este caso concreto:
boolean existsByDoctorId(Long doctorId);
boolean existsByDoctor_Id(Long doctorId);
```

---

## Anatomía de un método de consulta

```
[prefijo]By[Propiedad][Operador][And/Or][Propiedad][Operador]…
```

### Prefijos disponibles

| Prefijo | Tipo de retorno habitual |
|---------|--------------------------|
| `findBy` / `getBy` / `readBy` | `Optional<T>`, `List<T>`, `T` |
| `existsBy` | `boolean` |
| `countBy` | `long` |
| `deleteBy` / `removeBy` | `void`, `long` |

### Operadores de condición más comunes

| Keyword | JPQL generado |
|---------|--------------|
| `Is`, `Equals` (implícito) | `= :x` |
| `Not` | `<> :x` |
| `IsNull` | `IS NULL` |
| `IsNotNull` | `IS NOT NULL` |
| `Like` | `LIKE :x` |
| `Containing` | `LIKE %:x%` |
| `StartingWith` | `LIKE :x%` |
| `EndingWith` | `LIKE %:x` |
| `LessThan` / `LessThanEqual` | `< :x` / `<= :x` |
| `GreaterThan` / `GreaterThanEqual` | `> :x` / `>= :x` |
| `Between` | `BETWEEN :x AND :y` |
| `In` | `IN (:x)` |
| `True` / `False` | `= true` / `= false` |
| `Before` / `After` | `< :x` / `> :x` (fechas) |
| `OrderBy…Asc/Desc` | `ORDER BY …` |

---

## Ejemplos con las entidades del proyecto Clinica API Rest

https://github.com/profeMelola/DWES-REFUERZO-EXTRAORDINARIA/blob/main/SPRING/ordinaria/api.md

Las entidades involucradas son:

```
Appointment ──ManyToOne──> Doctor
Appointment ──ManyToOne──> Patient
Appointment ──OneToOne──>  Invoice
Invoice     ──OneToMany──> InvoiceLine
```

### AppointmentRepository

```java
public interface AppointmentRepository extends JpaRepository<Appointment, Long> {

    // ¿Existe alguna cita para un doctor concreto? (los dos son equivalentes)
    boolean existsByDoctorId(Long doctorId);
    boolean existsByDoctor_Id(Long doctorId);

    // Citas de un doctor ordenadas por fecha de inicio descendente
    List<Appointment> findByDoctorIdOrderByStartAtDesc(Long doctorId);

    // Citas de un paciente con un estado concreto
    List<Appointment> findByPatientIdAndStatus(Long patientId, AppointmentStatus status);

    // Citas de un doctor en un rango de fechas
    List<Appointment> findByDoctor_IdAndStartAtBetween(
        Long doctorId, LocalDateTime from, LocalDateTime to);

    // Citas activas (no canceladas) de un doctor
    List<Appointment> findByDoctor_IdAndStatusNot(Long doctorId, AppointmentStatus status);

    // Citas que tienen motivo registrado (campo no nulo)
    List<Appointment> findByReasonIsNotNull();

    // Número de citas de un doctor
    long countByDoctorId(Long doctorId);

    // Citas de un doctor cuyo nombre completo contenga un texto (navega la relación)
    List<Appointment> findByDoctor_FullNameContaining(String text);

    // ¿Existe cita solapada para ese doctor en ese instante?
    boolean existsByDoctor_IdAndStartAtLessThanAndEndAtGreaterThan(
        Long doctorId, LocalDateTime end, LocalDateTime start);
}
```

### DoctorRepository

```java
public interface DoctorRepository extends JpaRepository<Doctor, Long> {

    // Buscar por número de colegiado
    Optional<Doctor> findByLicenseNumber(String licenseNumber);

    // Doctores activos
    List<Doctor> findByActiveTrue();

    // Doctores cuyo email termine en un dominio concreto
    List<Doctor> findByEmailEndingWith(String domain);

    // Doctores activos ordenados por nombre
    List<Doctor> findByActiveTrueOrderByFullNameAsc();

    // ¿Existe doctor con ese email?
    boolean existsByEmail(String email);

    // ¿Existe otro doctor con ese email excluyendo un id?
    boolean existsByEmailAndIdNot(String email, Long id);
}
```

### InvoiceRepository

```java
public interface InvoiceRepository extends JpaRepository<Invoice, Long> {

    // Factura de una cita concreta
    Optional<Invoice> findByAppointmentId(Long appointmentId);

    // Facturas por estado
    List<Invoice> findByStatus(InvoiceStatus status);

    // Facturas pagadas de un doctor (navegando appointment.doctor)
    List<Invoice> findByAppointment_Doctor_IdAndStatus(Long doctorId, InvoiceStatus status);

    // Facturas emitidas en un rango de fechas
    List<Invoice> findByIssuedAtBetween(LocalDateTime from, LocalDateTime to);

    // Facturas pendientes cuyo total supere un umbral
    List<Invoice> findByStatusAndTotalGreaterThan(InvoiceStatus status, BigDecimal amount);

    // Número de facturas pagadas de un doctor
    long countByAppointment_Doctor_IdAndStatus(Long doctorId, InvoiceStatus status);
}
```

---

## Limitaciones y cuándo usar `@Query`

Los métodos por nombre se vuelven **inmanejables** cuando:

- La consulta tiene más de 3-4 condiciones (el nombre se hace ilegible).
- Se necesitan `JOIN FETCH` para evitar N+1.
- Se requieren proyecciones, funciones de agregación o subconsultas.
- La lógica es condicional (filtros opcionales → usar `Specification` o `@Query`).

```java
// Mejor con @Query que con nombre de método
@Query("SELECT a FROM Appointment a JOIN FETCH a.doctor JOIN FETCH a.patient " +
       "WHERE a.doctor.id = :doctorId AND a.status = :status")
List<Appointment> findWithDetailsByDoctorAndStatus(
    @Param("doctorId") Long doctorId,
    @Param("status") AppointmentStatus status);
```

---

## Resumen

| Concepto | Clave |
|----------|-------|
| `_` en el nombre | Separador explícito de navegación entre asociaciones |
| Sin `_` | Spring deduce el path; puede haber ambigüedad |
| Prefijo `existsBy` | Devuelve `boolean`; Spring optimiza con `SELECT 1` |
| Navegación anidada | `findByDoctor_FullNameContaining` → `doctor.fullName LIKE %x%` |
| Límite práctico | Usar `@Query` cuando el nombre supera ~3 condiciones |
