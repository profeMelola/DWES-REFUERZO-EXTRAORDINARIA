# Concurrencia en Spring Boot — Qué pasa cuando varios usuarios usan la aplicación a la vez

## El punto de partida: el servidor de aplicaciones

Cuando desplegamos una aplicación Spring Boot, Tomcat (el servidor embebido) arranca con un **pool de hilos**. Cada petición HTTP que llega al servidor se asigna a un hilo disponible de ese pool. Cuando la petición termina, el hilo vuelve al pool para atender la siguiente.

```
Usuario A → GET /movies     →  Hilo 1  →  Controller → Service → Repository → BD
Usuario B → POST /movies/1/cast →  Hilo 2  →  Controller → Service → Repository → BD
Usuario C → GET /reports/top-grossing →  Hilo 3  →  Controller → Service → Repository → BD
```

Las tres peticiones se procesan **en paralelo**, cada una en su propio hilo. Spring Boot gestiona esto automáticamente — nosotros no escribimos ningún código de concurrencia y la aplicación ya es multiusuario.

---

## Concepto 1 — El modelo de hilos de Spring MVC

Cada petición HTTP tiene su propio hilo desde que entra en el `Controller` hasta que sale la respuesta. Eso significa que:

- Dos usuarios pueden llamar al mismo endpoint al mismo tiempo sin bloquearse
- El mismo método del mismo `@Service` puede estar ejecutándose en dos hilos a la vez
- Spring gestiona el pool de hilos de Tomcat automáticamente

Por defecto Tomcat arranca con **200 hilos** disponibles. Si llegan 201 peticiones simultáneas, la 201 espera a que se libere un hilo. Esto se puede configurar en `application.properties`:

```properties
server.tomcat.threads.max=200
server.tomcat.threads.min-spare=10
```

> **En clase ya tenemos esto funcionando** — cuando probamos la API con Postman y dos ventanas abiertas a la vez, cada petición va en su propio hilo sin que nosotros hayamos escrito nada especial.

---

## Concepto 2 — `@Transactional` y los hilos

Cada hilo que atiende una petición tiene su **propia transacción** — su propia conexión a la base de datos y su propio contexto de persistencia de Hibernate.

```
Hilo 1 (Usuario A añade actor a Inception)    → Transacción 1 → Conexión BD 1
Hilo 2 (Usuario B borra actor de Dunkirk)     → Transacción 2 → Conexión BD 2
Hilo 3 (Usuario C consulta el report)         → Transacción 3 → Conexión BD 3
```

Esto garantiza que las operaciones de un usuario no interfieren con las de otro. Es el principio de **aislamiento de transacciones** (la I de ACID).

### ¿Qué pasa si dos usuarios modifican el mismo dato a la vez?

Ejemplo: Usuario A y Usuario B intentan añadir el mismo actor a la misma película al mismo tiempo.

```
Hilo 1: comprueba duplicado → no existe → va a insertar...
Hilo 2: comprueba duplicado → no existe → va a insertar...
Hilo 1: inserta (movie_id=1, actor_id=5) ✅
Hilo 2: inserta (movie_id=1, actor_id=5) ❌ → violación de PK → excepción de BD
```

La base de datos actúa como árbitro final gracias a la restricción de **PK única**. La aplicación recibe una excepción que puede gestionar. Por eso las restricciones en BD (`PRIMARY KEY`, `UNIQUE`, `NOT NULL`) son imprescindibles — son la última línea de defensa.

### El pool de conexiones

Hibernate no abre una conexión a BD por cada petición — eso sería muy costoso. Usa un **pool de conexiones** (HikariCP por defecto en Spring Boot) que mantiene un conjunto de conexiones abiertas y las reutiliza.

```properties
spring.datasource.hikari.maximum-pool-size=10  # máximo 10 conexiones simultáneas a BD
```

Si hay más hilos que conexiones disponibles, los hilos esperan a que se libere una conexión.

---

## Concepto 3 — El problema del estado compartido

Este es el concepto más importante para no cometer errores de concurrencia.

Cuando Spring crea un `@Service`, crea **una sola instancia** que comparten todos los hilos. Esto se llama **singleton** (el scope por defecto de los beans de Spring).

```
Hilo 1  ─┐
Hilo 2  ──┼──→  misma instancia de MovieService
Hilo 3  ─┘
```

Si esa instancia tiene **campos de instancia con estado**, todos los hilos comparten ese estado y pueden modificarlo a la vez — condición de carrera.

### ❌ Peligroso — estado compartido entre hilos

```java
@Service
public class MovieService {
    
    private final MovieRepository movieRepository;
    
    // ❌ PELIGROSO — campo con estado compartido entre todos los hilos
    private int totalConsultas = 0;
    
    public List<MovieResponseDto> getAllMovies() {
        totalConsultas++; // Hilo 1 lee 5, Hilo 2 lee 5, ambos escriben 6 → se pierde un incremento
        return movieRepository.findAll()...
    }
}
```

Dos hilos pueden leer el valor al mismo tiempo, incrementarlo cada uno por su cuenta y escribir el mismo resultado — se pierde un incremento. Esto se llama **race condition** (condición de carrera).

### ✅ Correcto — servicio stateless

```java
@Service
@RequiredArgsConstructor
public class MovieService {
    
    // ✅ Solo dependencias inyectadas — inmutables una vez inyectadas
    private final MovieRepository movieRepository;
    private final MovieMapper movieMapper;
    
    // No hay ningún campo de instancia con estado mutable
    
    public List<MovieResponseDto> getAllMovies() {
        return movieRepository.findAll()
                .stream()
                .map(movieMapper::toResponseDto)
                .toList();
    }
}
```

Las dependencias inyectadas (`final`) se asignan una sola vez en el constructor y nunca cambian — son **inmutables** desde el punto de vista de la concurrencia. Cada llamada al método trabaja con sus propias variables locales (que viven en el stack del hilo, no en el heap compartido).

### La regla de oro

> **Los `@Service`, `@Repository` y `@Controller` de Spring deben ser stateless.**
> Solo pueden tener como campos de instancia las dependencias inyectadas (que son `final` e inmutables).
> El estado de cada operación vive en las variables locales del método o en la base de datos, nunca en campos de instancia.

---

## Resumen visual

```
                    ┌─────────────────────────────────────┐
                    │         Tomcat Thread Pool           │
                    │  Hilo 1 │ Hilo 2 │ Hilo 3 │ ...     │
                    └────┬────┴────┬───┴────┬────┴─────────┘
                         │         │         │
                    ┌────▼─────────▼─────────▼────┐
                    │   MovieController (singleton) │  ← stateless ✅
                    └────┬─────────┬─────────┬────┘
                         │         │         │
                    ┌────▼─────────▼─────────▼────┐
                    │   MovieService (singleton)    │  ← stateless ✅
                    └────┬─────────┬─────────┬────┘
                         │         │         │
                    ┌────▼─────────▼─────────▼────┐
                    │  MovieRepository (singleton)  │  ← stateless ✅
                    └────┬─────────┬─────────┬────┘
                         │         │         │
                    ┌────▼─────────▼─────────▼────┐
                    │      HikariCP Connection Pool │
                    │   Conn 1  │  Conn 2  │  ...  │
                    └────┬──────┴────┬─────┴───────┘
                         │           │
                    ┌────▼───────────▼────┐
                    │   Base de datos      │  ← árbitro final (PK, UNIQUE, FK)
                    └─────────────────────┘
```

Cada hilo atraviesa las mismas instancias singleton de Controller → Service → Repository, pero trabaja con sus propias variables locales y su propia conexión a BD. El estado compartido peligroso no existe si los beans son stateless.

---

## ¿Cuándo necesitamos programación concurrente explícita?

Con la arquitectura de Spring MVC que trabajamos en clase, **no necesitamos escribir código de concurrencia**. Spring y Tomcat lo gestionan.

La programación concurrente explícita (`@Async`, `CompletableFuture`, `synchronized`) aparece cuando:

- Una operación tarda mucho (llamada a API externa, procesamiento de ficheros grandes) y no queremos bloquear el hilo de la petición
- Queremos ejecutar varias operaciones en paralelo y combinar los resultados
- Implementamos arquitecturas de mensajería o eventos asíncronos

Esos son conceptos avanzados para cuando se trabaje con microservicios o arquitecturas reactivas.

---

## Lo que ya tenemos bien hecho en el proyecto

| Buena práctica | Dónde la aplicamos |
|---|---|
| Servicios stateless | Todos los `@Service` solo tienen dependencias `final` inyectadas |
| Transacciones por hilo | `@Transactional` en cada método de servicio que accede a BD |
| Pool de conexiones | HikariCP configurado automáticamente por Spring Boot |
| Árbitro final en BD | PK, UNIQUE y FK en todas las tablas |
| Lectura optimizada | `@Transactional(readOnly = true)` en métodos de solo lectura |
