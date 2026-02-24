# Criterios de Evaluación de Endpoints REST (Spring Boot)

> Que el endpoint "funcione" no es suficiente.\
> Debe cumplir contrato HTTP, arquitectura, separación de
> responsabilidades y reglas de negocio exactamente como se exige.
> 
> No se califica si no cumple con los siguientes criterios

------------------------------------------------------------------------

# Contrato HTTP y Mapping 

## Requisitos

-   Ruta exactamente igual al enunciado.
-   Método HTTP correcto (`GET`, `POST`, `PUT`, `DELETE`, etc.).
-   Uso correcto de:
    -   `@PathVariable`
    -   `@RequestParam`
    -   `@RequestBody`
-   Si procede:
    -  `@Valid` en el DTO de entrada.
    -   Bean Validation (`@NotNull`, `@Positive`, `@NotBlank`, etc.).



------------------------------------------------------------------------

# Uso obligatorio de DTOs y separación del dominio

## Requisitos

-   Existe un **Request DTO** (entrada).
-   Existe un **Response DTO** (salida).
-   No se exponen entidades JPA directamente.
-   El mapeo se hace en un **Mapper** (clase dedicada).
-   El DTO solo contiene los campos requeridos por el enunciado.

------------------------------------------------------------------------

# Códigos HTTP correctos

## Uso adecuado

``` 
  Caso                    Código
  ----------------------- -------------------
  Creación correcta       `201 Created`
  Operación correcta      `200 OK`
  Sin contenido           `204 No Content`
  Validación incorrecta   `400 Bad Request`
  Recurso inexistente     `404 Not Found`
  Conflicto de negocio    `409 Conflict`
  No autorizado           `401/403`
```

## Incorrecto si:

-   Se devuelve `200` ante errores.
-   Se usa `500` para errores previsibles de negocio.
-   No se gestionan excepciones correctamente con `@ControllerAdvice`).

------------------------------------------------------------------------

# Arquitectura por capas 

## Estructura mínima exigida

Controller → Service → Repository

## Reglas

### Controller

-   Solo gestiona HTTP.
-   No contiene lógica de negocio.
-   No accede directamente al repository.

### Service

-   Contiene reglas de negocio.
-   Marca `@Transactional` cuando corresponda.
-   Orquesta el caso de uso.

### Repository

-   Solo acceso a datos.
-   Sin lógica de negocio.

------------------------------------------------------------------------

# Inyección de dependencias

## Correcto

-   Inyección por constructor.
-   Uso de `@RequiredArgsConstructor` (porque usamos Lombok).
-   Dependencias `final`.

------------------------------------------------------------------------

# Reglas de negocio del enunciado

Cada requisito funcional del enunciado debe:

1.  Estar implementado.
2.  Estar en la capa correcta (Service).
3.  Lanzar la excepción adecuada.

  
------------------------------------------------------------------------

# Paginación y filtros

## Requisitos

-   Uso correcto de `Pageable` si el endpoint es paginado.
-   No paginar en memoria.
-   Filtros opcionales aplicados correctamente.
-   Metadatos de paginación incluidos en la respuesta (si se exige).


------------------------------------------------------------------------

# Seguridad

## Requisitos

-   Uso correcto de `@PreAuthorize` o configuración equivalente.
-   Respuesta adecuada ante acceso no autorizado (`403/401`).


------------------------------------------------------------------------
