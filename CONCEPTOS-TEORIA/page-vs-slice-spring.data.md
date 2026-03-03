# Diferencia entre Page y Slice en una API REST con Spring Boot

En **Spring Data (JPA)**, tanto `Page<T>` como `Slice<T>` representan
resultados paginados. Sin embargo, su comportamiento interno y su
impacto en rendimiento son distintos.

------------------------------------------------------------------------

## 1. Page`<T>`--- Paginación con metadatos completos

`Page` extiende `Slice` y añade información global sobre el dataset
completo.

### Qué incluye

-   `getContent()` → lista de elementos de la página
-   `getNumber()` → número de página actual
-   `getSize()` → tamaño de página
-   `getTotalElements()` → total de registros
-   `getTotalPages()` → total de páginas
-   `hasNext()`, `hasPrevious()`

### Qué ocurre en base de datos

Spring ejecuta:

1.  Query principal con `LIMIT / OFFSET`
2.  Query adicional de conteo (`COUNT(*)`)

Esto puede ser costoso cuando: - Hay muchos `JOIN` - Hay `GROUP BY` - El
dataset es grande

### Cuándo usar Page

-   Cuando necesitas mostrar algo como:\
    \> "Página 3 de 12"
-   Cuando necesitas el total exacto de registros
-   En paneles administrativos con tablas clásicas

### Ejemplo

``` java
Page<Invoice> findByStatus(InvoiceStatus status, Pageable pageable);
```

------------------------------------------------------------------------

## 2. Slice`<T>` --- Paginación ligera

`Slice` solo permite saber si existe una página siguiente, pero no
conoce el total global.

### Qué incluye

-   `getContent()`
-   `getNumber()`
-   `getSize()`
-   `hasNext()`
-   `hasPrevious()`

No incluye: - `getTotalElements()` - `getTotalPages()`

### Qué ocurre en base de datos

Spring:

-   Ejecuta solo la query principal
-   Solicita `size + 1` registros
-   Si viene uno extra → `hasNext = true`

No se ejecuta `COUNT(*)`.

### Cuándo usar Slice

-   Infinite scroll
-   APIs móviles
-   Cuando el total no es relevante
-   Consultas complejas con `GROUP BY`

------------------------------------------------------------------------

## 3. Comparativa rápida

  Característica               Page          Slice
  ---------------------------- ------------- ---------------
  Query adicional COUNT        Sí            No
  Total de elementos           Sí            No
  Total de páginas             Sí            No
  Rendimiento                  Más costoso   Más eficiente
  Ideal para admin panel       Sí            No ideal
  Ideal para infinite scroll   No óptimo     Sí

------------------------------------------------------------------------

## 4. Impacto en reporting complejo

Si usas consultas con `GROUP BY` y `DTO projection`, `Page` suele
requerir `countQuery` manual.

Ejemplo:

``` java
@Query("select new TopServiceReport(...) from InvoiceLine l join l.invoice i group by ...")
Page<TopServiceReport> topServices(...)
```

En este caso, cambiar a:

``` java
Slice<TopServiceReport>
```

Permite:

-   Evitar `countQuery`
-   Reducir coste en base de datos
-   Simplificar el repositorio

------------------------------------------------------------------------

## 5. Regla práctica de arquitectura

-   Si el frontend necesita conocer el total → usa `Page`
-   Si solo navega hacia adelante → usa `Slice`
-   En reporting complejo → normalmente `Slice` es mejor opción

------------------------------------------------------------------------

## Conclusión

`Page` implica conocimiento global del dataset y requiere una query de
conteo.\
`Slice` es una estrategia más ligera orientada a navegación incremental.

La elección no es solo de API, sino de estrategia de acceso a datos y
rendimiento.
