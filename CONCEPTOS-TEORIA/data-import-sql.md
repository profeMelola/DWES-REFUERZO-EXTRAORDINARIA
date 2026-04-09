# `data.sql` vs `import.sql` en Spring Boot

La última versión estable es **Spring Boot 4.0.5** (marzo 2026).

---

## ¿Qué nombre debe tener el script de datos?

Desde **Spring Boot 2.5+** (y por tanto en 3.x y 4.x) el comportamiento es:

| Script | Quién lo ejecuta | Cuándo se ejecuta |
|---|---|---|
| `data.sql` | Spring (mecanismo de inicialización) | Después de crear el esquema |
| `schema.sql` | Spring (mecanismo de inicialización) | Antes que `data.sql` |
| `import.sql` | Hibernate directamente | Solo con `ddl-auto=create` o `create-drop` |

Con JPA + H2 en memoria lo más fiable es **`data.sql`**.  
El `import.sql` solo funciona si se lo cedes a Hibernate con `spring.jpa.hibernate.ddl-auto=create`, pero tiene menos control.

Ambos archivos deben colocarse en `src/main/resources/`.

---

## `application.properties`

```properties
# H2 en memoria
spring.datasource.url=jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

# Consola H2 (opcional, útil en desarrollo)
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console

# JPA / Hibernate
spring.jpa.hibernate.ddl-auto=create-drop   # crea al iniciar, destruye al parar
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# Ejecutar data.sql DESPUÉS de que Hibernate cree las tablas
spring.jpa.defer-datasource-initialization=true
spring.sql.init.mode=always
```

---

## Propiedad clave

`spring.jpa.defer-datasource-initialization=true` es **imprescindible** desde Spring Boot 2.5+.

Sin ella, `data.sql` se ejecuta **antes** de que Hibernate cree las tablas y se obtiene un error de tabla no encontrada.
