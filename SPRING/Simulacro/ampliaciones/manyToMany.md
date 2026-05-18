# RETO — Relación Many-to-Many con atributos propios: Directores

El API REST de películas necesita incorporar la gestión de directores. 

Una película puede tener varios directores y un director puede haber dirigido varias películas. 

La relación entre película y director tiene atributos propios.

## Script DDL de referencia

```sql
CREATE TABLE directors (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name   VARCHAR(120) NOT NULL,
    nationality VARCHAR(60),
    active      BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE movie_director (
    movie_id    BIGINT NOT NULL,
    director_id BIGINT NOT NULL,
    role        VARCHAR(30) NOT NULL,  -- valores: DIRECTOR, CO_DIRECTOR, ASSISTANT
    credited    BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (movie_id, director_id),
    CONSTRAINT fk_md_movie    FOREIGN KEY (movie_id)    REFERENCES movies(id),
    CONSTRAINT fk_md_director FOREIGN KEY (director_id) REFERENCES directors(id)
);
```

## Enumerado de roles

```java
public enum DirectorRole {
    DIRECTOR,
    CO_DIRECTOR,
    ASSISTANT
}
```

## Lo que debes implementar siguiendo la arquitectura del proyecto

### 1. Entidades y relación JPA

- Entidad `Director` con sus anotaciones JPA y Lombok coherentes con el resto del proyecto.
- Clave compuesta `MovieDirectorId` como `@Embeddable` — reflexiona qué anotación Lombok es imprescindible y por qué.
- Entidad `MovieDirector` como tabla intermedia con `@EmbeddedId` y `@MapsId` — lado propietario de la relación.
- Relación inversa en `Movie` — decide quién gestiona el ciclo de vida y por qué.
- Helpers bidireccionales en la entidad gestora.

### 2. Endpoint: POST /movies/{id}/directors

Request body:
```json
{
  "directorId": 1,
  "role": "CO_DIRECTOR",
  "credited": true
}
```

Comportamiento esperado:

- Si la película no existe → 404 Not Found
- Si el director no existe → 404 Not Found
- Si el director ya está asignado a esa película → 409 Conflict
- Si la operación es correcta → 201 Created

### 3. Endpoint: GET /movies/{id}/directors

Devuelve la lista de directores de una película con sus datos y el rol que ejercieron.

Response body:
```json
[
  {
    "directorId": 1,
    "fullName": "Christopher Nolan",
    "nationality": "British",
    "role": "DIRECTOR",
    "credited": true
  }
]
```

- Si la película no existe → 404 Not Found
- Si la película no tiene directores → lista vacía, 200 OK

## Restricciones

- Sigue estrictamente la arquitectura Controller → Service → Repository.
- Usa excepciones propias del proyecto para los errores.
- No uses `ResponseStatusException`.
- El mapper debe ser manual, sin librerías de mapeo automático.
- La detección de duplicados debe realizarse sobre la colección en memoria, no mediante consulta al repositorio.
- El campo `role` debe ser un enumerado `DirectorRole`. Gestiona correctamente el caso de que llegue un valor inválido.