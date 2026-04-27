# Cliente Web MVC con Spring Boot y Thymeleaf

Tecnologías:

- Spring Boot
- Spring MVC
- Thymeleaf
- Spring Security
- JPA
- H2  

---

## Descripción general

En este trabajo construirás una **aplicación web MVC** que actúa como cliente de la API REST de películas desarrollada en clase. La aplicación tendrá su propia base de datos H2 para gestionar usuarios y seguridad, y mostrará los datos de la API mediante vistas Thymeleaf.

El proyecto **arrancamos juntos en clase**, por lo que ya dispones de la estructura base, las dependencias en el `pom.xml` y los DTOs de la API. Tu trabajo consiste en **completar** los módulos que se describen a continuación.

```
┌─────────────────────────────────────┐
│         Navegador (usuario)         │
└──────────────┬──────────────────────┘
               │ HTTP (formularios, links)
┌──────────────▼──────────────────────┐
│     Spring Boot MVC (este proyecto) │
│  ┌──────────┐   ┌─────────────────┐ │
│  │ Security │   │  Thymeleaf Views│ │
│  └──────────┘   └─────────────────┘ │
│  ┌──────────┐   ┌─────────────────┐ │
│  │Controllers│  │  MovieApiClient │ │
│  └──────────┘   └────────┬────────┘ │
│  ┌──────────┐            │          │
│  │  BD H2   │            │ HTTP     │
│  │ (users)  │            │          │
│  └──────────┘            │          │
└─────────────────────────-│----------┘
                           │
             ┌─────────────▼────────────┐
             │   API REST de Películas  │
             │  GET /movies             │
             │  GET /movies/{id}        │
             │  GET /movies/{id}/cast   │
             └──────────────────────────┘
```

---

## Módulo 2 — Consumo de la API REST

### Objetivo

Implementar la clase `MovieApiClient` que encapsula todas las llamadas HTTP a la API REST de películas. Los controladores **nunca llamarán directamente** a la API; siempre lo harán a través de este cliente.

### Qué tienes que completar

Se te proporciona la clase con la firma de los métodos. Debes implementar el cuerpo de cada uno usando `WebClient`:

```java
@Service
public class MovieApiClient {

    // TODO: inyectar RestTemplate y la URL base desde application.properties

    public List<MovieResponseDto> getAllMovies() {
        // TODO
    }

    public MovieResponseDto getMovieById(Long id) {
        // TODO
    }

    public List<CastResponseDto> getCastByMovieId(Long id) {
        // TODO
    }
}
```

### Endpoints de la API que debes consumir

| Método | URL                  | Descripción              | DTO de respuesta    |
|--------|----------------------|--------------------------|---------------------|
| GET    | `/movies`            | Listado de todas         | `List<MovieResponseDto>` |
| GET    | `/movies/{id}`       | Detalle de una película  | `MovieResponseDto`  |
| GET    | `/movies/{id}/cast`  | Reparto de una película  | `List<CastResponseDto>` |

> La URL base de la API se configura en `application.properties` como `api.movies.base-url` e inyecta con `@Value`.



---

## Módulo 3 — Vistas Thymeleaf

### Objetivo

Completar las plantillas HTML proporcionadas para que muestren correctamente los datos que reciben del controlador mediante el modelo de Spring MVC.

### Estructura de plantillas

```
src/main/resources/templates/
├── fragments/
│   └── layout.html          ← YA IMPLEMENTADO (cabecera, nav, footer)
├── movies/
│   ├── list.html            ← A COMPLETAR
│   └── detail.html          ← A COMPLETAR
├── admin/
│   └── users.html           ← A COMPLETAR
├── login.html               ← A COMPLETAR
└── error/
    └── 403.html             ← A COMPLETAR
```

> `layout.html` está completamente implementado. Usa `th:replace` o `th:insert` para incluirlo en tus vistas.

---

### Vista: `movies/list.html`

Muestra una tabla con todas las películas recuperadas de la API.

```
┌─────────────────────────────────────────────────────┐
│  🎬 CineApp            Películas   Admin   [Salir]  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Catálogo de Películas                              │
│                                                     │
│  ┌──────┬────────────────────┬──────┬───────┬────┐  │
│  │  ID  │  Título            │ Año  │ Género│    │  │
│  ├──────┼────────────────────┼──────┼───────┼────┤  │
│  │   1  │ Inception          │ 2010 │ SCI_FI│ 🔍 │  │
│  │   2  │ The Godfather      │ 1972 │ DRAMA │ 🔍 │  │
│  │   3  │ Interstellar       │ 2014 │ SCI_FI│ 🔍 │  │
│  └──────┴────────────────────┴──────┴───────┴────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Lo que debes implementar en la plantilla:**

- Iterar la lista con `th:each` sobre el modelo (`movies`)
- Mostrar cada campo con `th:text`
- El botón 🔍 debe enlazar al detalle con `th:href` usando el id de la película


---

### Vista: `movies/detail.html`

Muestra el detalle completo de una película y su reparto.

```
┌─────────────────────────────────────────────────────┐
│  🎬 CineApp            Películas   Admin   [Salir]  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ◀ Volver al catálogo                              │
│                                                     │
│  Inception  (2010)                                  │
│  Género: SCI_FI   │   Estado: ✅ Activa             │
│                                                     │
│  ─── Reparto ─────────────────────────────────────  │
│                                                     │
│  ┌──────────────────────┬──────────────────────┐   │
│  │  Actor               │  Personaje           │   │
│  ├──────────────────────┼──────────────────────┤   │
│  │  Leonardo DiCaprio   │  Dom Cobb            │   │
│  │  Joseph Gordon-Levitt│  Arthur              │   │
│  │  Elliot Page         │  Ariadne             │   │
│  └──────────────────────┴──────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Lo que debes implementar en la plantilla:**

- Mostrar los campos del DTO `MovieResponseDto` con `th:text`
- Usar un operador ternario en Thymeleaf para mostrar "✅ Activa" o "❌ Inactiva" según el campo `active`
- El enlace "Volver" debe usar `th:href="@{/movies}"`
- Iterar el reparto con `th:each`
- Usar `th:if` para mostrar un mensaje "Sin reparto disponible" si la lista está vacía

---

### Vista: `login.html`

Formulario de inicio de sesión personalizado, integrado con Spring Security.

```
┌─────────────────────────────────────────────────────┐
│  🎬 CineApp                                         │
├─────────────────────────────────────────────────────┤
│                                                     │
│              Iniciar sesión                         │
│                                                     │
│         ┌────────────────────────────┐              │
│  Usuario │                           │              │
│         └────────────────────────────┘              │
│         ┌────────────────────────────┐              │
│  Clave  │                           │              │
│         └────────────────────────────┘              │
│                                                     │
│         ⚠️ Usuario o contraseña incorrectos         │
│            (solo visible si hay error)              │
│                                                     │
│              [ Entrar ]                             │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Lo que debes implementar en la plantilla:**

- El `th:action` del formulario debe apuntar a `@{/login}` (procesa Spring Security)
- Incluir el campo oculto CSRF con `th:name="${_csrf.parameterName}"` y `th:value="${_csrf.token}"`
- Usar `th:if` para mostrar el mensaje de error solo cuando existe el parámetro `error` en la URL

> ⚠️ **Importante:** sin el campo CSRF el formulario devolverá un error 403. Spring Security lo exige en todas las peticiones POST de aplicaciones MVC.

---

### Vista: `admin/users.html`

Lista de usuarios registrados en la BD local. Solo accesible para el rol `ADMIN`.

```
┌─────────────────────────────────────────────────────┐
│  🎬 CineApp            Películas   Admin   [Salir]  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Gestión de Usuarios                 [+ Nuevo]      │
│                                                     │
│  ┌────┬──────────────┬──────────┬──────────┬─────┐  │
│  │ ID │  Username    │  Rol     │ Activo   │     │  │
│  ├────┼──────────────┼──────────┼──────────┼─────┤  │
│  │  1 │ admin        │ ADMIN    │    ✅    │ 🗑  │  │
│  │  2 │ usuario1     │ USER     │    ✅    │ 🗑  │  │
│  │  3 │ usuario2     │ USER     │    ❌    │ 🗑  │  │
│  └────┴──────────────┴──────────┴──────────┴─────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Lo que debes implementar en la plantilla:**

- Iterar la lista de `AppUser` con `th:each`
- El botón 🗑 debe enviar un formulario `POST` a `/admin/users/{id}/delete` con el CSRF correspondiente
- Usar `th:text` con expresiones de Thymeleaf para formatear el rol y el estado

---

### Vista: `error/403.html`

Página mostrada automáticamente cuando un usuario sin permisos intenta acceder a una ruta restringida.

```
┌─────────────────────────────────────────────────────┐
│  🎬 CineApp                                         │
├─────────────────────────────────────────────────────┤
│                                                     │
│                    🚫 403                           │
│                                                     │
│           Acceso denegado                           │
│                                                     │
│   No tienes permisos para acceder a esta página.   │
│                                                     │
│              [ Volver al inicio ]                   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Lo que debes implementar en la plantilla:**

- Mostrar el mensaje de error con `th:text="${message}"` si el modelo lo incluye
- El enlace "Volver al inicio" debe usar `th:href="@{/movies}"`

---

## Módulo 4 — Seguridad con Spring Security

### Objetivo

Configurar la seguridad de la aplicación para que solo usuarios autenticados puedan acceder a las películas, y solo los administradores puedan gestionar usuarios.

### Entidades de la BD local

La aplicación tiene su propia BD H2 independiente de la API. En ella se almacenan los usuarios.

### Reglas de acceso a configurar en `SecurityConfig`

| Ruta               | Acceso                    |
|--------------------|---------------------------|
| `/login`           | Público                   |
| `/css/**`, `/js/**`| Público (recursos estáticos)|
| `/movies/**`       | Cualquier usuario autenticado |
| `/admin/**`        | Solo rol `ADMIN`          |
| Cualquier otra     | Autenticado               |

### Qué tienes que completar

Se te proporciona `SecurityConfig.java` con los `@Bean` vacíos:

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    // TODO: inyectar AppUserDetailsService

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        // TODO: configurar authorizeHttpRequests, formLogin, logout
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        // TODO: devolver BCryptPasswordEncoder
    }
}
```

### Datos de prueba (`data.sql`)

Se incluye un `data.sql` con usuarios precargados para que puedas probar el login antes de implementar el CRUD:

```sql
INSERT INTO app_users (username, password, role, active) VALUES
('admin',    '$2a$10$...hash...', 'ADMIN', true),
('usuario1', '$2a$10$...hash...', 'USER',  true);
```

> Las contraseñas en texto plano son `admin123` y `user123` respectivamente.

---

## Módulo 5 — CRUD de Usuarios (rol ADMIN)

### Objetivo

Implementar la gestión completa de usuarios de la BD local, accesible únicamente para administradores.

### Funcionalidades a implementar

**1. Listado** — `GET /admin/users`
Recupera todos los `AppUser` del repositorio y los pasa al modelo para que la vista `admin/users.html` los muestre.

**2. Formulario de alta** — `GET /admin/users/new` y `POST /admin/users`

```
┌─────────────────────────────────────────────────────┐
│  Nuevo Usuario                                      │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Username  [ _________________ ]                    │
│  Contraseña[ _________________ ]                    │
│  Rol       ( ) USER   ( ) ADMIN                     │
│                                                     │
│  ⚠️ El username ya existe      ← error de validación│
│                                                     │
│              [ Guardar ]  [ Cancelar ]              │
│                                                     │
└─────────────────────────────────────────────────────┘
```

El controlador debe:
- Validar el formulario con `@Valid` y `BindingResult`
- Cifrar la contraseña con `BCryptPasswordEncoder` antes de persistir
- Redirigir a `/admin/users` tras el alta (`redirect:`)

**3. Borrado** — `POST /admin/users/{id}/delete`

Elimina el usuario por id. Usa `POST` en lugar de `DELETE` porque los formularios HTML solo soportan GET y POST.

> ⚠️ Debes evitar que el administrador se borre a sí mismo. Usa `Authentication` para obtener el usuario en sesión y compruébalo antes de borrar.

### Acceso al usuario en sesión

```java
@PostMapping("/{id}/delete")
public String deleteUser(@PathVariable Long id, Authentication authentication) {
    String currentUsername = authentication.getName();
    // TODO: comprobar que no se está borrando a sí mismo
}
```

---

## Módulo 6 — Lista de Favoritos


### Objetivo

Permitir que cada usuario guarde sus películas favoritas. Los favoritos se almacenan en la BD H2 local relacionando el `userId` (local) con el `movieId` (id de la API remota).

### Modelo local

```java
@Entity
@Table(name = "favorites")
public class Favorite {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private AppUser user;

    @Column(nullable = false)
    private Long movieId;   // ID de la película en la API remota
}
```

### Funcionalidades

**Añadir a favoritos** desde la vista de detalle:

```
┌─────────────────────────────────────────────────────┐
│  Inception  (2010)                                  │
│  ...                                                │
│                          [ ⭐ Añadir a favoritos ]  │
└─────────────────────────────────────────────────────┘
```

**Listado de favoritos del usuario** en `GET /favorites`:

```
┌─────────────────────────────────────────────────────┐
│  Mis Favoritos                                      │
├─────────────────────────────────────────────────────┤
│  ⭐ Inception           (2010)  SCI_FI      🔍  ✖  │
│  ⭐ The Godfather       (1972)  DRAMA       🔍  ✖  │
└─────────────────────────────────────────────────────┘
```

> Para mostrar los datos de cada favorito debes recuperar el `MovieResponseDto` de la API usando el `movieId` almacenado localmente.


