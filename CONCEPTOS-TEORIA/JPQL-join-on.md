# Por qué no necesitas `ON` en los joins de JPQL

La razón es fundamental: **en JPQL no haces joins entre tablas, sino entre relaciones ya definidas en tus entidades**.

---

## Cómo funciona en SQL tradicional

En SQL puro necesitas `ON` porque el motor no sabe cómo relacionar las tablas:

```sql
-- SQL: el motor no sabe cómo unir, se lo tienes que decir tú
SELECT *
FROM invoice_lines l
JOIN invoices i ON i.id = l.invoice_id
JOIN medical_services s ON s.id = l.service_id
```

---

## Cómo funciona en JPQL

En JPQL navegas por las **asociaciones mapeadas en tus entidades**. La condición de join ya está implícita en el mapeo:

```java
// En tu InvoiceLine ya tienes esto definido:

@ManyToOne(fetch=FetchType.LAZY, optional=false)
@JoinColumn(name="invoice_id", nullable=false)
private Invoice invoice;   // ← esta FK ya define la condición del join

@ManyToOne(fetch=FetchType.LAZY, optional=false)
private MedicalService service;  // ← ídem
```

Entonces cuando escribes:

```java
from InvoiceLine l
    join l.invoice i       // Hibernate ya sabe: ON i.id = l.invoice_id
    join l.service s       // Hibernate ya sabe: ON s.id = l.service_id
```

...estás diciendo *"navega por la relación `invoice` de `l`"*, no *"une dos tablas"*. Hibernate deriva la condición `ON` automáticamente desde el `@JoinColumn` o la convención de nombre.

---

## ¿Cuándo SÍ usarías `ON` en JPQL?

Solo cuando quieres añadir **condiciones adicionales de filtro al propio join** (algo que va más allá de la FK), disponible desde JPA 2.1:

```java
// Join normal → trae todas las líneas de la factura
from Invoice i join i.lines l

// Join con ON adicional → solo líneas con quantity > 1 en el propio join
from Invoice i join i.lines l on l.quantity > 1
```

> **Nota:** Esto es distinto del `WHERE`:
> - El `ON` filtra *durante* el join (afecta especialmente a `LEFT JOIN`s).
> - El `WHERE` filtra *después* del join.

---

**Otro ejemplo:**

```java
-- ❌ CON WHERE: convierte el LEFT JOIN en un INNER JOIN de facto
from MedicalService s
    left join s.lines l
  where l.invoice.issuedAt >= :from   -- los servicios sin líneas tienen l = NULL
  and l.invoice.issuedAt <= :to     -- NULL no pasa ningún filtro → desaparecen
```
- Un servicio sin facturas produce l = NULL tras el LEFT JOIN. 
- En cuanto ese NULL llega al WHERE, la condición falla y la fila desaparece. 
- Has perdido exactamente lo que querías conservar.

```java
-- ✅ CON ON: el filtro ocurre durante el join, el LEFT JOIN sigue siendo LEFT JOIN
from MedicalService s
    left join s.lines l
    on l.invoice.issuedAt is not null
    and l.invoice.issuedAt >= :from and l.invoice.issuedAt <= :to
    and (:status is null or l.invoice.status = :status)
```

- Aquí el motor primero evalúa si una línea cumple la condición para unirse. 
- Todo el bloque ON ... AND ... AND ... es una única condición compuesta que el motor evalúa durante el LEFT JOIN, línea a línea
- Si no cumple, o no existe, el servicio igualmente aparece en el resultado con l = NULL. 
- La línea existe pero no cumple alguna condición (fecha fuera de rango, estado no coincide) → no se une, el servicio aparece con l = NULL.
- El LEFT JOIN hace su trabajo.

---

## Evitar right join. Elige bien tu entidad raíz

Por ejemplo, partir de InvoiceLine pero obtener los MedicalService con el right join:

```java
@Query("""
    select new es.daw.clinicaapi.dto.report.ServiceSummaryReport(
        s.id,
        s.name,
        coalesce(count(l),0L),
        coalesce(sum(l.quantity),0L),
        coalesce(cast(sum(l.unitPrice) as BigDecimal ), 0)
        ) from InvoiceLine l
            join l.invoice i
            right join l.service s
                on i.issuedAt >= :from
                        and i.issuedAt <= :to
                        and (:status is null or i.status = :status)
        group by s.id
            order by s.name asc
    """)
```

Como regla general vamos a seguir estos criterios:

- Los que SÍ tienen relación -> INNER JOIN desde la entidad con la FK
- Todos, tengan o no relación -> LEFT JOIN desde la entidad "padre"
- RIGHT JOIN -> Evítalo en JPQL, da la vuelta y usa LEFT JOIN
    - Evita RIGHT JOIN en JPQL: elige bien tu entidad raíz