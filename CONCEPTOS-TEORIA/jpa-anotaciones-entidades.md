# JPA: Anotaciones de columna y su comportamiento con base de datos física

## Introducción

Cuando definimos un `@Entity` en JPA, podemos decorar sus atributos con la anotación
`@Column` para especificar propiedades detalladas de la columna correspondiente en base
de datos: si admite nulos, su longitud máxima, la precisión de un decimal, etc.

```java
@Column(nullable = false, length = 80)
private String characterName;

@Column(nullable = false)
private int screenMinutes;

@Column(precision = 12, scale = 2)
private BigDecimal salaryOverride;

@Column(nullable = false)
private boolean active = true;
```

La pregunta natural que surge es: **¿qué ocurre con estas anotaciones cuando trabajamos
contra una base de datos física ya existente?** ¿Dará error si la columna real no coincide
con lo declarado?

---

## El parámetro que lo controla: `ddl-auto`

El comportamiento de Hibernate respecto al esquema de base de datos se configura en
`application.properties` mediante:

```properties
spring.jpa.hibernate.ddl-auto=<valor>
```

| Valor         | Comportamiento                                                                 |
|---------------|--------------------------------------------------------------------------------|
| `create`      | Elimina y recrea las tablas al arrancar. Usa las anotaciones como definición.  |
| `create-drop` | Como `create`, pero además elimina las tablas al cerrar la aplicación.         |
| `update`      | Intenta modificar el esquema existente para que coincida con los entities.     |
| `validate`    | Compara el esquema real con los entities y lanza error si hay discrepancias.   |
| `none`        | No hace nada. La aplicación arranca aunque haya diferencias.                   |

> En proyectos con **H2 en memoria** el valor habitual es `create-drop`, por lo que las
> tablas se generan íntegramente a partir de las anotaciones en cada arranque. Por eso en
> este contexto las anotaciones de detalle tienen un efecto directo e inmediato.

---

## ¿Qué ocurre con una BD física y discrepancias?

Supongamos que `salaryOverride` está anotada con `precision = 12, scale = 2` pero en la
base de datos real la columna es `DECIMAL(10, 2)`.

### Con `none` (habitual en producción)

- La aplicación **arranca sin ningún error**.
- El problema aparece en **tiempo de ejecución**, cuando se intenta persistir un valor que
  supera los 10 dígitos que admite la columna real. La base de datos rechazará la
  operación con un error de truncamiento.
- Si los datos del sistema nunca superan esa magnitud, la discrepancia puede pasar
  **completamente desapercibida**.

### Con `validate`

- Hibernate compara el esquema real con el definido en los entities al arrancar.
- Detecta con fiabilidad: columnas inexistentes, tipos incompatibles, tablas que faltan.
- **No garantiza** detectar diferencias de `precision` o `scale`, ya que depende del
  dialecto de base de datos utilizado.

### Resumen de escenarios

| Configuración       | Discrepancia de precisión | ¿Error al arrancar? | ¿Error en runtime?       |
|---------------------|---------------------------|---------------------|--------------------------|
| `none`              | `DECIMAL(10,2)` vs `(12,2)` | ❌                 | ✅ si el valor es grande |
| `none`              | `DECIMAL(10,2)` vs `(12,2)` | ❌                 | ❌ si los datos son pequeños (silencioso) |
| `validate`          | Tipo incompatible         | ✅                  | —                        |
| `validate`          | Solo precisión distinta   | ⚠️ Depende del dialecto | —                   |
| `update`            | Cualquiera                | ❌ (intenta corregir) | Poco probable          |

---

## ¿Para qué sirven entonces las anotaciones de detalle con BD física?

Es una pregunta completamente válida. Con una base de datos física y `ddl-auto=none`,
las anotaciones `nullable`, `length`, `precision`, etc. **no tienen efecto directo sobre
la BD ni sobre la validación en la capa Java**. Sin embargo, no carecen de utilidad:

### 1. Documentación del diseño

Son la forma más inmediata de conocer la intención del diseño sin tener que consultar la
base de datos o los scripts externos. Al leer el entity, el desarrollador sabe qué se
esperaba de cada columna.

### 2. Generación del esquema en entornos de desarrollo y pruebas

Con `ddl-auto=create` o usando H2 en memoria para tests automáticos, Hibernate genera
las tablas a partir de estas anotaciones. Mantenerlas correctas garantiza que los entornos
efímeros reflejen fielmente el esquema de producción.

### 3. Coherencia con herramientas de generación DDL

Herramientas como JPA Buddy o Hibernate Tools pueden generar scripts DDL a partir de los
entities. Si las anotaciones están desactualizadas, el DDL generado será incorrecto.

### 4. Son distintas a las validaciones de Bean Validation

Este es un matiz importante que conviene tener claro:

| Anotación               | Capa        | ¿Valida en Java? | ¿Afecta al DDL? |
|-------------------------|-------------|------------------|-----------------|
| `@Column(nullable=false)` | JPA       | ❌               | ✅ (si Hibernate crea la tabla) |
| `@NotNull`              | Bean Validation | ✅           | ❌              |
| `@Size(max=80)`         | Bean Validation | ✅           | ❌              |

Para que los datos sean validados **antes de llegar a la base de datos**, es necesario
usar las anotaciones de **Jakarta Bean Validation** (`@NotNull`, `@Size`, `@Digits`,
etc.), que actúan en la capa de servicio o controlador.

```java
@NotNull
@Size(max = 80)
@Column(nullable = false, length = 80)
private String characterName;

@Digits(integer = 10, fraction = 2)
@Column(precision = 12, scale = 2)
private BigDecimal salaryOverride;
```

Ambas anotaciones son **complementarias** y tienen responsabilidades distintas.

---

## Gestión del esquema en proyectos reales: mención a Flyway y Liquibase

En proyectos profesionales con base de datos física, el esquema no lo gestiona Hibernate
sino herramientas especializadas de **migración de base de datos**, siendo las más
utilizadas **Flyway** y **Liquibase**.

Estas herramientas mantienen un historial de scripts SQL versionados que se aplican de
forma ordenada y controlada. El esquema real de la base de datos es responsabilidad de
esos scripts, no de las anotaciones JPA.

```
Anotaciones JPA   →  documentación + generación en tests
Flyway/Liquibase  →  fuente de verdad real del esquema en producción
Bean Validation   →  validación en la capa de aplicación
```

> Este tema se abordará en detalle más adelante. Por ahora es suficiente con saber que
> existe y que resuelve el problema de evolucionar el esquema de una BD en producción de
> forma segura y trazable.

---

## Conclusiones

- Con **H2 en memoria**, las anotaciones `@Column` construyen la tabla real: son la
  fuente de verdad y tienen efecto directo.
- Con **BD física** y `ddl-auto=none`, no generan ni validan nada automáticamente. Su
  valor es documental, de coherencia y de soporte a entornos de test.
- `@Column(nullable=false)` y `@NotNull` **no son equivalentes**: la primera afecta al
  DDL, la segunda valida en la capa Java.
- En producción, el esquema se gestiona con herramientas específicas (Flyway/Liquibase),
  y las anotaciones JPA actúan como documentación complementaria.
