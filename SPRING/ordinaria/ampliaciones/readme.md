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

---

# Guía de pruebas — Relación N:M Doctor ↔ Specialty

<img src="image.png" height="150px">

## Set de datos nuevos para pruebas

```
-- -------------------------
-- DOCTORS (6)
-- -------------------------
INSERT INTO doctors (license_number, full_name, email, active) VALUES
    ('LIC-100', 'Dra. Marta López',   'marta@demo.com',       true),
    ('LIC-200', 'Dr. Juan Ruiz',      'juan@demo.com',        true),
    ('LIC-300', 'Dra. Sofía Vega',    'sofia@demo.com',       true),
    ('LIC-400', 'Dr. Pablo Santos',   'pablo@demo.com',       true),
    ('LIC-500', 'Dra. Irene Cano',    'irene.cano@demo.com',  true),
    ('LIC-600', 'Dr. Marcos Díaz',    'marcos@demo.com',      false); -- inactivo

-- -------------------------
-- MEDICAL SERVICES (6)
-- -------------------------
INSERT INTO medical_services (code, name, base_price, active) VALUES
    ('CONS-GEN',    'Consulta general',         50.00,  true),
    ('DERM-REV',    'Revisión dermatológica',    80.00,  true),
    ('CARD-ECG',    'ECG / Cardiología',        120.00,  true),
    ('PED-CONT',    'Control pediatría',         45.00,  true),
    ('VAC-FLU',     'Vacuna gripe',              25.00,  true),
    ('NUTRI-PLAN',  'Plan nutrición',            60.00,  true);

-- -------------------------
-- SPECIALTIES — catálogo (antes era enum)
-- IDs esperados: 1=DERMATOLOGY, 2=GENERAL_MED, 3=CARDIOLOGY, 4=PEDIATRICS, 5=NUTRITION
-- -------------------------
INSERT INTO specialties (code, name, active) VALUES
    ('DERMATOLOGY', 'Dermatología',      true),
    ('GENERAL_MED', 'Medicina General',  true),
    ('CARDIOLOGY',  'Cardiología',       true),
    ('PEDIATRICS',  'Pediatría',         true),
    ('NUTRITION',   'Nutrición',         true);

-- -------------------------
-- DOCTOR_SPECIALTIES — tabla intermedia con atributos
-- doctor_id | specialty_id | level      | active | since_date   | consultation_fee_override
-- Mismos datos que antes, specialty reemplazada por su FK numérica
-- -------------------------
INSERT INTO doctor_specialties (doctor_id, specialty_id, level, active, since_date, consultation_fee_override) VALUES
--  Dra. Marta López   → DERMATOLOGY (1) + GENERAL_MED (2)
    (1, 1, 'SENIOR',     true,  '2020-01-01', null),
    (1, 2, 'CONSULTANT', true,  '2017-05-01', 55.00),
--  Dr. Juan Ruiz       → GENERAL_MED (2)
    (2, 2, 'CONSULTANT', true,  '2018-01-01', null),
--  Dra. Sofía Vega     → CARDIOLOGY (3) + GENERAL_MED (2)
    (3, 3, 'SENIOR',     true,  '2016-09-15', 130.00),
    (3, 2, 'JUNIOR',     true,  '2022-02-01', null),
--  Dr. Pablo Santos    → PEDIATRICS (4)
    (4, 4, 'CONSULTANT', true,  '2019-03-10', null),
--  Dra. Irene Cano     → NUTRITION (5)
    (5, 5, 'SENIOR',     true,  '2015-06-20', 70.00),
--  Dr. Marcos Díaz     → GENERAL_MED (2) — inactivo en la relación igual que antes
    (6, 2, 'JUNIOR',     false, '2023-01-01', null);
```


## Entidades involucradas

| Tabla | Entidad JPA |
|---|---|
| `doctors` | `Doctor` |
| `specialties` | `Specialty` |
| `doctor_specialties` | `DoctorSpecialty` (tabla intermedia con atributos) |

---

## Prerequisitos — Datos base (opcional)

Antes de probar la relación, crea al menos 2 doctores y 2 especialidades.

### Crear doctores

```http
POST /doctors
Content-Type: application/json

{
  "licenseNumber": "LIC-001",
  "fullName": "Dr. Ana García",
  "email": "ana.garcia@clinica.com"
}
```

```http
POST /doctors
Content-Type: application/json

{
  "licenseNumber": "LIC-002",
  "fullName": "Dr. Luis Pérez",
  "email": "luis.perez@clinica.com"
}
```

### Crear especialidades

```http
POST /specialties
Content-Type: application/json

{
  "code": "CARDIO",
  "name": "Cardiología"
}
```

```http
POST /specialties
Content-Type: application/json

{
  "code": "NEURO",
  "name": "Neurología"
}
```

---

## Pruebas de la relación

Antes de implementar cada prueba, ten en cuenta la distribución recomendada:

**DoctorController — el doctor es el agregado principal de la relación**

- POST   /doctors/{id}/specialties            → asignar especialidad
- GET    /doctors/{id}/specialties            → listar especialidades del doctor
- PATCH  /doctors/{id}/specialties/{specId}   → actualizar atributos de la relación
- DELETE /doctors/{id}/specialties/{specId}   → eliminar especialidad del doctor

**SpecialtyController — consultas sobre el catálogo**

- GET  /specialties                    → listar catálogo
- GET  /specialties/{id}               → detalle de una especialidad
- GET  /specialties/{id}/doctors       → qué doctores tienen esta especialidad

**¿Por qué no un DoctorSpecialtyController?**

Podrías ver en algunos proyectos con una **URL plana tipo /doctor-specialties, pero rompe la navegabilidad REST.**

Los clientes esperan poder navegar el recurso desde su raíz natural, no tener que conocer el nombre de la tabla intermedia.

La tabla intermedia DoctorSpecialty es un detalle de implementación JPA, no un recurso REST de primer nivel.

### Prueba 1 — Asignar una especialidad a un doctor ✅ 201

Verifica que se crea correctamente la PK compuesta `(doctor_id, specialty_id)` y los atributos propios de la relación.

```http
POST /doctors/1/specialties
Content-Type: application/json

{
  "specialtyId": 1,
  "level": "SENIOR",
  "sinceDate": "2020-03-15",
  "consultationFeeOverride": 85.00
}
```

**Resultado esperado:** `201 Created` con el registro en `doctor_specialties`.

---

### Prueba 2 — Distintos doctores pueden compartir la misma especialidad ✅ 201

El doctor 2 también puede tener la especialidad 1 (Cardiología). Esto prueba que la restricción de unicidad es por par `(doctor_id, specialty_id)`, no por `specialty_id` solo.

```http
POST /doctors/2/specialties
Content-Type: application/json

{
  "specialtyId": 1,
  "level": "JUNIOR",
  "sinceDate": "2022-06-01",
  "consultationFeeOverride": null
}
```

**Resultado esperado:** `201 Created`. Ahora dos doctores comparten Cardiología.

---

### Prueba 3 — Un doctor puede tener varias especialidades ✅ 201

El doctor 1 añade una segunda especialidad (Neurología).

```http
POST /doctors/1/specialties
Content-Type: application/json

{
  "specialtyId": 2,
  "level": "EXPERT",
  "sinceDate": "2019-01-10",
  "consultationFeeOverride": 120.00
}
```

**Resultado esperado:** `201 Created`. El doctor 1 ahora tiene Cardiología y Neurología.

---

### Prueba 4 — Un doctor NO puede repetir la misma especialidad ✅ 409

Intenta asignar de nuevo la especialidad 1 al doctor 1. La PK compuesta debe rechazarlo.

```http
POST /doctors/1/specialties
Content-Type: application/json

{
  "specialtyId": 1,
  "level": "EXPERT",
  "sinceDate": "2024-01-01",
  "consultationFeeOverride": 200.00
}
```

**Resultado esperado:** `409 Conflict`.  
> Esta es la prueba más importante. Si `equals`/`hashCode` están bien implementados en `DoctorSpecialtyId`, el conflicto se detecta correctamente.

---

### Prueba 5 — Listar las especialidades de un doctor ✅ 200

Verifica que el `Set<DoctorSpecialty>` se carga con todos los atributos de la tabla intermedia.

```http
GET /doctors/1/specialties
```

**Resultado esperado:** Lista con Cardiología (SENIOR) y Neurología (EXPERT).

[Join Fetch y el problema N+1 - Estrategias JPA](./join-fetch.md)

---

### Prueba 6 — Listar los doctores de una especialidad ✅ 200

Prueba el lado inverso de la relación desde `Specialty`.

```http
GET /specialties/1/doctors
```

**Resultado esperado:** Lista con Dr. Ana García y Dr. Luis Pérez.

---

### Prueba 7 — Actualizar atributos de la relación ✅ 200

Modifica campos de la tabla intermedia sin tocar las entidades `Doctor` ni `Specialty`.

```http
PATCH /doctors/1/specialties/1
Content-Type: application/json

{
  "level": "EXPERT",
  "consultationFeeOverride": 150.00
}
```

**Resultado esperado:** `200 OK`. Solo cambia la fila en `doctor_specialties`.

---

### Prueba 8 — Eliminar una especialidad de un doctor ✅ 204

Prueba el `orphanRemoval = true`. Solo debe borrarse la fila intermedia, no el doctor ni la especialidad.

```http
DELETE /doctors/1/specialties/2
```

**Resultado esperado:** `204 No Content`.  
Verificación adicional:
- `GET /doctors/1/specialties` → solo devuelve Cardiología.
- `GET /specialties/2` → Neurología sigue existiendo.
- `GET /doctors/1` → Dr. Ana García sigue existiendo.

---

## Orden de ejecución recomendado

```
1.  POST /doctors          → doctor 1 (LIC-001)            ✓ 201
2.  POST /doctors          → doctor 2 (LIC-002)            ✓ 201
3.  POST /specialties      → especialidad 1 (CARDIO)       ✓ 201
4.  POST /specialties      → especialidad 2 (NEURO)        ✓ 201
5.  POST /doctors/1/specialties  → (1, CARDIO, SENIOR)     ✓ 201
6.  POST /doctors/2/specialties  → (2, CARDIO, JUNIOR)     ✓ 201  ← doctores comparten especialidad
7.  POST /doctors/1/specialties  → (1, NEURO, EXPERT)      ✓ 201  ← doctor con varias especialidades
8.  POST /doctors/1/specialties  → (1, CARDIO, EXPERT)     ✓ 409  ← especialidad duplicada bloqueada
9.  GET  /doctors/1/specialties                            ✓ 200  ← devuelve CARDIO + NEURO
10. GET  /specialties/1/doctors                            ✓ 200  ← devuelve doctor 1 y doctor 2
11. PATCH /doctors/1/specialties/1                         ✓ 200  ← solo cambia tabla intermedia
12. DELETE /doctors/1/specialties/2                        ✓ 204  ← orphanRemoval en acción
13. GET  /doctors/1/specialties                            ✓ 200  ← solo CARDIO queda
14. GET  /specialties/2                                    ✓ 200  ← NEURO sigue existiendo
```

---

## Reglas del modelo verificadas

| Regla | Prueba que la verifica |
|---|---|
| Un doctor puede tener varias especialidades | Pruebas 5 y 7 |
| Un doctor NO puede repetir la misma especialidad | Prueba 4 → 409 |
| Varios doctores pueden compartir la misma especialidad | Pruebas 2 y 6 |
| La tabla intermedia tiene atributos propios | Pruebas 1, 7 |
| `orphanRemoval` borra solo la fila intermedia | Prueba 8 |

---

