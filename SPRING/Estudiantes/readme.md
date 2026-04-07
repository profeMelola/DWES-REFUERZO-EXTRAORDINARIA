# SPRING MVC - AVELLANEDA

MVC de gestión de estudiantes del IES Alonso de Avellaneda.

[Sigue las instrucciones del pdf](./REFUERZO-EstudiantesMVC.pdf)

Utiliza los recursos proporcionados en la carpeta recursos.

Tendrás que crear un proyecto desde cero.


# SPRING API REST - EVALUACIONES

## Parte I

[Sigue las instrucciones del pdf](./REFUERZO-Api%20Rest%20Evaluaciones.pdf)

Utiliza los recursos proporcionados en la carpeta recursos.

Tendrás que crear un proyecto desde cero.

## Parte II: normalización de la BD y refactorización completa de la API REST

En la versión actual de la práctica, la entidad Evaluacion contiene un campo codigo con valores como 1ev_1, 2ev_1, ordinaria_2, etc. 

Ese código incorpora información del tipo de evaluación y del curso en un único atributo de texto. 

El modelo funciona, pero no está correctamente normalizado, ya que parte de la información se almacena de forma redundante y codificada en una cadena en lugar de expresarse mediante relaciones y restricciones del modelo relacional. 

El enunciado original y los endpoints ya implementados parten de ese diseño.

### Objetivo

A partir de la API REST ya desarrollada, el alumnado deberá realizar una refactorización completa del modelo de datos, la persistencia, la lógica de negocio y la capa de controladores para obtener una solución normalizada, consistente y mantenible.

No se trata de crear una API nueva desde cero, sino de evolucionar la API existente hacia un diseño mejor.

La nueva API deberá seguir ofreciendo, como mínimo, la misma funcionalidad que el ejercicio original:

- Obtener todos los cursos.
- Obtener las evaluaciones con sus notas.
- Obtener el promedio de calificaciones de una evaluación.
- Modificar la calificación de un estudiante en una evaluación.

Lo que cambia es el modelo interno, la forma de identificar los recursos y la estructura de las respuestas.

### Normalización del modelo


Actualmente existe:

- una entidad Curso,
- una entidad Evaluacion con un codigo textual único,
- una entidad Nota asociada a Evaluacion,
- y las evaluaciones de distintos cursos se distinguen por el texto del código.


El alumnado deberá rediseñar el modelo para que:

- El curso no forme parte de un código textual.
- El tipo de evaluación quede representado de forma explícita y no embebido en una cadena.
- No se repitan datos que puedan deducirse por relaciones.
- La base de datos exprese las reglas del dominio mediante claves y restricciones.

Propuesta de normalización. Opción recomendada:

- Curso [id (PK), nombre, descripción]
- TipoEvaluacion [id (PK), nombre]
    - Primera Evaluación
    - Segunda Evaluación
    - Tercera Evaluación
    - Ordinaria
    - Extraordinaria 
- Evaluacion [id (PK), curso_id (FK), tipo_evaluacion_id (FK)]
- Alumno [nia (PK), nombre, apellidos] (* nuevo)
- Nota [id (PK), nia (FK)]

```
Curso ──< Evaluacion >── TipoEvaluacion
                │
               Nota
                │
            Alumno (nia)
```

### Adaptación de datos iniciales

Rehad el import.sql para cargar datos conforme al nuevo esquema.

- Insertar los cursos.
- Insertar los tipos de evaluación.
- Insertar las evaluaciones vinculando cada una a su curso y a su tipo.
- Insertar las notas vinculándolas a la evaluación correspondiente.

```
-- Tipos de evaluación (catálogo)
INSERT INTO tipo_evaluacion (nombre) VALUES ('Primera Evaluación');
INSERT INTO tipo_evaluacion (nombre) VALUES ('Segunda Evaluación');
INSERT INTO tipo_evaluacion (nombre) VALUES ('Tercera Evaluación');
INSERT INTO tipo_evaluacion (nombre) VALUES ('Ordinaria');
INSERT INTO tipo_evaluacion (nombre) VALUES ('Extraordinaria');

-- Cursos
INSERT INTO curso (nombre, descripcion) VALUES ('1DAW', '1º curso de Desarrollo de Aplicaciones Web');
INSERT INTO curso (nombre, descripcion) VALUES ('2DAW', '2º curso de Desarrollo de Aplicaciones Web');

-- Evaluaciones (curso x tipo, sin código textual)
-- 1DAW: 5 tipos
INSERT INTO evaluacion (curso_id, tipo_evaluacion_id) VALUES (1, 1);
INSERT INTO evaluacion (curso_id, tipo_evaluacion_id) VALUES (1, 2);
INSERT INTO evaluacion (curso_id, tipo_evaluacion_id) VALUES (1, 3);
INSERT INTO evaluacion (curso_id, tipo_evaluacion_id) VALUES (1, 4);
INSERT INTO evaluacion (curso_id, tipo_evaluacion_id) VALUES (1, 5);
-- 2DAW: sin Tercera Evaluación
INSERT INTO evaluacion (curso_id, tipo_evaluacion_id) VALUES (2, 1);
INSERT INTO evaluacion (curso_id, tipo_evaluacion_id) VALUES (2, 2);
INSERT INTO evaluacion (curso_id, tipo_evaluacion_id) VALUES (2, 4);
INSERT INTO evaluacion (curso_id, tipo_evaluacion_id) VALUES (2, 5);

-- Alumnos
INSERT INTO alumno (nia, nombre, apellidos) VALUES ('12345', 'Ana', 'García López');
INSERT INTO alumno (nia, nombre, apellidos) VALUES ('12346', 'Luis', 'Martínez Ruiz');
INSERT INTO alumno (nia, nombre, apellidos) VALUES ('12347', 'Marta', 'Sánchez Díaz');
INSERT INTO alumno (nia, nombre, apellidos) VALUES ('12348', 'Pedro', 'Jiménez Mora');
INSERT INTO alumno (nia, nombre, apellidos) VALUES ('12400', 'Sofía', 'Fernández Gil');
INSERT INTO alumno (nia, nombre, apellidos) VALUES ('12401', 'Carlos', 'Romero Vega');
INSERT INTO alumno (nia, nombre, apellidos) VALUES ('12402', 'Laura', 'Torres Blanco');

-- Notas (nia → alumno, evaluacion_id según orden del INSERT anterior)
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12345', 1, 8);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12346', 1, 7);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12347', 1, 6);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12348', 2, 9);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12345', 2, 5);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12346', 3, 4);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12348', 4, 8);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12345', 5, 7);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12346', 5, 6);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12347', 5, 5);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12400', 6, 7);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12401', 6, 9);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12402', 6, 6);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12400', 7, 8);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12401', 7, 7);
INSERT INTO nota (nia, evaluacion_id, calificacion) VALUES ('12402', 7, 5);
``` 

### Refactorización de la API REST

Se deberá rediseñar la API para trabajar con el nuevo modelo normalizado.

La API debe dejar de depender de códigos artificiales como 1ev_1 o 2ev_2.

Los endpoints deberán identificar una evaluación de manera coherente con el modelo relacional. Para ello, se admite cualquiera de estas dos estrategias:

Ejemplos de rutas:

```
GET /cursos
GET /cursos/{cursoId}/evaluaciones
GET /cursos/{cursoId}/evaluaciones/{tipoEvaluacionId}
GET /cursos/{cursoId}/evaluaciones/{tipoEvaluacionId}/promedio
PATCH /cursos/{cursoId}/evaluaciones/{tipoEvaluacionId}/notas/{nia}

GET /evaluaciones
GET /evaluaciones/{evaluacionId}
GET /evaluaciones/{evaluacionId}/promedio
PATCH /evaluaciones/{evaluacionId}/notas/{nia}

```

--- 
# Refuerzo JPA: Cascade y orphanRemoval en relaciones OneToMany. Relación entre curso y evaluaciones

## 1. Definición de la relación

```java
@OneToMany(mappedBy = "curso", cascade = CascadeType.ALL, orphanRemoval = true)
private List<Evaluacion> evaluaciones;
```

Esto implica:
- Un `Curso` tiene muchas `Evaluacion`
- La FK está en `Evaluacion` (`curso_id`)
- `Evaluacion` es el lado propietario

---

## 2. cascade = CascadeType.ALL

Propaga operaciones del padre (`Curso`) al hijo (`Evaluacion`).

Incluye:
- PERSIST
- MERGE
- REMOVE
- REFRESH
- DETACH

### Ejemplo: persistencia
```java
cursoRepository.save(curso);
```
Guarda también las evaluaciones asociadas.

### Ejemplo: borrado
```java
cursoRepository.delete(curso);
```
Elimina el curso y todas sus evaluaciones.

---

## 3. orphanRemoval = true

Elimina entidades hijas cuando dejan de pertenecer al padre.

### Ejemplo:
```java
curso.getEvaluaciones().remove(ev);
cursoRepository.save(curso);
```

Resultado:
```sql
DELETE FROM evaluacion WHERE id = ?
```

Sin orphanRemoval:
```sql
UPDATE evaluacion SET curso_id = NULL
```

---

## 4. Diferencia clave

| Concepto | Comportamiento |
|----------|--------------|
| cascade REMOVE | Borra hijos al borrar el padre |
| orphanRemoval | Borra hijos al quitarlos de la colección |

---

## 5. Buenas prácticas

### Mantener ambos lados sincronizados
```java
public void addEvaluacion(Evaluacion ev) {
    evaluaciones.add(ev);
    ev.setCurso(this);
}

public void removeEvaluacion(Evaluacion ev) {
    evaluaciones.remove(ev);
    ev.setCurso(null);
}
```

---

## 6. Conclusión

- `cascade = ALL` → gestiona automáticamente operaciones CRUD
- `orphanRemoval = true` → evita registros huérfanos
- Juntos indican que `Curso` controla el ciclo de vida de `Evaluacion`
