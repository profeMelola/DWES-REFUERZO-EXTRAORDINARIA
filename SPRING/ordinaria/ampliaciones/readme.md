# API REST - Ampliación 1: catálogo de especialidades + relación N:M con atributos

Esta ampliación cambia el modelo para que las especialidades no sean un `VARCHAR/enum` embebido en la tabla intermedia, sino un **catálogo persistente** (`specialties`).  
La relación `Doctor` ↔ `Specialty` es **N:M** en base de datos, y se implementa mediante una **entidad intermedia con atributos** (`doctor_specialties`).

---

## Qué cambia

### Antes (modelo antiguo)
- `doctor_specialties.specialty` era `VARCHAR(30)` (valor tipo enum).
- No existía tabla de catálogo de especialidades.

### Ahora (modelo nuevo)
- Nueva tabla `specialties`:
  - `id`, `code` (único), `name`, `active`
- `doctor_specialties` pasa a tener:
  - `doctor_id` + `specialty_id` como **PK compuesta**
  - Atributos propios de la relación: `level`, `active`, `since_date`, `consultation_fee_override`
  - FK a `doctors(id)` y FK a `specialties(id)`

---

## DDL (H2)

- Se adjunt archivo: `schema-h2.sql`  
- Contiene los `DROP TABLE` en orden correcto y el `CREATE TABLE` del esquema completo actualizado.

---

## Trabajo a realizar (JPA)

Debes adaptar el mapeo JPA para reflejar el modelo nuevo:

### 1) `Specialty` (entidad nueva)
- Tabla: `specialties`
- Campos mínimos: `id`, `code`, `name`, `active`
- `code` debe ser único.

### 2) `Doctor` (ajustar entidad existente)
- Debe tener una colección de `DoctorSpecialty` (no `@ManyToMany` directo al tener la tabla intermedia campos propios).
- Mantener bidireccionalidad con helpers (p. ej. `addSpecialty/removeSpecialty`).

### 3) `DoctorSpecialty` (entidad intermedia)
- Tabla: `doctor_specialties`
- Debe tener:
  - `ManyToOne` a `Doctor`
  - `ManyToOne` a `Specialty`
  - Atributos propios: `level`, `active`, `sinceDate`, `consultationFeeOverride`
- La PK es compuesta: (`doctor_id`, `specialty_id`)
  - Se recomienda `@EmbeddedId` + `@MapsId` (opción más limpia para este esquema).

---

## Reglas del modelo (para comprobar que lo has hecho bien)

- Un doctor puede tener **varias** especialidades.
- Un doctor **no puede repetir** la misma especialidad.
- Varios doctores pueden compartir la misma especialidad.
- La tabla intermedia existe porque hay **atributos propios** de la relación (nivel, fecha, override, etc.).

---

## Qué NO hacer

- No usar `@ManyToMany` con `@JoinTable` directamente: **no aplica** porque la tabla intermedia tiene columnas extra.
- No eliminar los atributos de la relación (deben seguir en `doctor_specialties`).

