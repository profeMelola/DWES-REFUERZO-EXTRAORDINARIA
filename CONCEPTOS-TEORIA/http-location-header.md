# El header `Location` en HTTP

## ¿Qué es?

`Location` es un **header de respuesta HTTP** que indica la URL donde se puede encontrar un recurso. Forma parte del estándar HTTP (RFC 9110) y su función principal es orientar al cliente sobre dónde localizar algo: un recurso recién creado, o una nueva URL tras una redirección.

---

## Uso en APIs REST: respuesta 201 Created

El caso más habitual en una API REST es acompañar una respuesta **201 Created**, indicando la URL del recurso que se acaba de crear.

### Ejemplo

Petición:
```http
POST /movies/5/cast-complete
Content-Type: application/json

{ "actorId": 12, "characterName": "Dom Cobb" }
```

Respuesta:
```http
HTTP/1.1 201 Created
Location: http://localhost:8080/movies/5/cast/12
Content-Type: application/json

{
  "movieId": 5,
  "title": "Inception",
  "releaseYear": 2010,
  "genre": "SCI_FI",
  "active": true,
  "actorId": 12,
  "actorName": "Leonardo DiCaprio"
}
```

El header `Location` le dice al cliente: **"el recurso que acabas de crear vive en esta URL"**.

---

## ¿Para qué sirve en la práctica?

Sin `Location`, el cliente tiene que "adivinar" la URL del recurso creado o hacer una llamada adicional para buscarlo. Con `Location`, puede navegar directamente:

```
POST /movies/5/cast-complete   →  201 + Location: /movies/5/cast/12
         ↓
GET  /movies/5/cast/12         →  200 + datos del cast
         ↓
DELETE /movies/5/cast/12       →  204 No Content
```

---

## En qué tipos de endpoints se usa normalmente

### 1. `POST` — Creación de un recurso (201 Created)
El uso más frecuente y recomendado por el estándar REST.

```http
POST   /users                →  201 Created + Location: /users/42
POST   /movies/5/cast        →  201 Created + Location: /movies/5/cast/12
POST   /orders               →  201 Created + Location: /orders/980
```

### 2. `PUT` o `PATCH` — Cuando el recurso se crea si no existe (upsert)
Si el servidor crea el recurso al no encontrarlo, responde con 201 e incluye `Location`.

```http
PUT    /settings/theme       →  201 Created + Location: /settings/theme
```

Si el recurso ya existía y solo se actualizó, la respuesta es **200 OK** o **204 No Content**, sin `Location`.

### 3. Redirecciones — 3xx
`Location` también se usa en respuestas de redirección para indicar la nueva URL:

| Código | Significado | Ejemplo de uso |
|--------|-------------|----------------|
| 301 | Moved Permanently | El endpoint ha cambiado de URL de forma permanente |
| 302 | Found (temporal) | Redirección temporal |
| 307 | Temporary Redirect | Redirección temporal conservando el método HTTP |
| 308 | Permanent Redirect | Igual que 301 pero conservando el método HTTP |

```http
GET /api/v1/movies   →  301 Moved Permanently
                         Location: /api/v2/movies
```

---

## Cómo se construye en Spring Boot

Spring proporciona `ServletUriComponentsBuilder` para construir la URL de forma automática, respetando host, puerto y context path:

```java
URI location = ServletUriComponentsBuilder
        .fromCurrentRequest()                            // URL actual: /movies/5/cast-complete
        .replacePath("/movies/{movieId}/cast/{actorId}") // URL del recurso creado
        .buildAndExpand(castDto.movieId(), castDto.actorId())
        .toUri();
// Resultado: http://localhost:8080/movies/5/cast/12

return ResponseEntity
        .created(location)  // 201 + header Location
        .body(castDto);     // body con el DTO
```

La ventaja frente a hardcodear un string es que funciona correctamente en cualquier entorno (local, staging, producción) sin cambiar el código.

---

## Resumen

| Código HTTP | Método | ¿Lleva Location? |
|-------------|--------|-----------------|
| 201 Created | POST, PUT (upsert) | ✅ Sí, siempre recomendado |
| 200 OK | PUT, PATCH | ❌ No (el recurso ya existía) |
| 204 No Content | PUT, PATCH, DELETE | ❌ No |
| 301, 302, 307, 308 | Cualquiera | ✅ Sí, es obligatorio |

`Location` es el mecanismo que convierte una API REST en **navegable**: el cliente no necesita construir URLs manualmente, las recibe directamente del servidor.

Location es un paso en la dirección correcta, porque proporciona una URL al cliente en lugar de que este la construya manualmente. Pero HATEOAS exige bastante más.

--- 

## Location vs HATEOAS

**HATEOAS (Hypermedia As The Engine Of Application State)** requiere que cada respuesta incluya los enlaces a las acciones posibles desde ese estado. El cliente no debe conocer las URLs de antemano, sino descubrirlas en cada respuesta.
Una respuesta verdaderamente HATEOAS tras añadir un actor al cast sería:

```
{
  "movieId": 5,
  "title": "Inception",
  "actorId": 12,
  "actorName": "Leonardo DiCaprio",
  "_links": {
    "self":       { "href": "/movies/5/cast/12" },
    "movie":      { "href": "/movies/5" },
    "actor":      { "href": "/actors/12" },
    "cast":       { "href": "/movies/5/cast" },
    "remove":     { "href": "/movies/5/cast/12", "method": "DELETE" }
  }
}
```

Spring ofrece el módulo Spring HATEOAS.

El DTO extendería RepresentationModel:

```
public class MovieCastResponseDto extends RepresentationModel<MovieCastResponseDto> {
    private Long movieId;
    private String title;
    private Long actorId;
    private String actorName;
    // ...
}
```

Y en el controller añadirías los enlaces:

```
movieCastResponseDto.add(
    linkTo(methodOn(MovieController.class).getById(castDto.movieId())).withRel("movie"),
    linkTo(methodOn(ActorController.class).getById(castDto.actorId())).withRel("actor"),
    linkTo(methodOn(MovieCastController.class).getCast(castDto.movieId())).withRel("cast")
);
```

En la práctica, HATEOAS completo es poco adoptado porque añade complejidad tanto al servidor como al cliente, y la mayoría de clientes (móviles, SPAs) tienen las URLs hardcodeadas igualmente. 

Lo más habitual hoy en día es:

- Usar Location en los 201 Created → cubre el caso más importante.
- Documentar la API con OpenAPI/Swagger → el cliente conoce los endpoints desde la documentación, no desde los enlaces de la respuesta.

HATEOAS tiene más sentido en APIs públicas de gran escala donde el cliente necesita ser completamente agnóstico de la estructura de URLs.