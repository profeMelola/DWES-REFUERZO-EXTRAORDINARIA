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


