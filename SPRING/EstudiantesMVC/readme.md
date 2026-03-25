# SPRING MVC - AVELLANEDA

MVC de gestión de estudiantes del IES Alonso de Avellaneda.

# SPRING API REST - EVALUACIONES

## Parte I

[Sigue las instrucciones del pdf](./REFUERZO-Api%20Rest%20Evaluaciones.pdf)

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

- Curso
- TipoEvaluacion
    - Primera Evaluación
    - Segunda Evaluación
    - Tercera Evaluación
    - Ordinaria
    - Extraordinaria 
- Evaluacion
- Nota

### Adaptación de datos iniciales

Rehad el import.sql para cargar datos conforme al nuevo esquema.

- Insertar los cursos.
- Insertar los tipos de evaluación.
- Insertar las evaluaciones vinculando cada una a su curso y a su tipo.
- Insertar las notas vinculándolas a la evaluación correspondiente.

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