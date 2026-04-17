# Protección CSRF (Cross-Site Request Forgery)

<img width="815" height="626" alt="imagen" src="https://github.com/user-attachments/assets/e5b99ed1-ba59-457a-859c-9eeaaab8ed2a" />

## El problema raíz: HTTP sin estado + cookies automáticas

HTTP no recuerda quién eres entre peticiones. Para solucionarlo, el servidor crea una sesión y te entrega una cookie. 

El navegador, por diseño, adjunta automáticamente esa cookie a toda petición al dominio correspondiente, venga de donde venga. Ahí está el problema.

CSRF explota exactamente ese comportamiento: si el navegador envía la cookie automáticamente, cualquier página puede construir una petición que el servidor considerará legítima.

La falsificación de peticiones en sitios cruzados es un ataque donde un sitio malicioso engaña a tu navegador para que envíe una petición a nuestra app sin tu consentimiento (ej. un POST a /productos/eliminar/5).


## Por qué afecta a MVC y no a REST

En una API REST el cliente debe escribir código para incluir el token en cada petición. Una página maliciosa no puede hacerlo sin acceso al token (bloqueado por CORS y por la propia política del navegador). 

La cookie, en cambio, viaja sola.

## La defensa: el token CSRF

La solución clásica es el Synchronizer Token Pattern:

1. El servidor genera un token aleatorio y lo mete en la sesión
2. Lo incluye también en cada formulario HTML como campo oculto
3. En cada petición que modifica estado (POST, PUT, DELETE), verifica que el token del form coincide con el de la sesión
4. El sitio malicioso no puede leer ese token (política de mismo origen) → no puede reproducirlo

Spring Security nos protege de esto automáticamente por defecto.

    - Cómo funciona: Spring genera un token único y secreto (el "token CSRF") y lo guarda en la sesión del usuario.
    - Requisito: Todos los formularios POST, PUT, DELETE deben incluir este token secreto. Si no lo incluyen, Spring Security rechazará la petición (Error 403 Forbidden).

## Configuración en Spring Security

Spring Security activa CSRF por defecto en MVC. Para REST suele desactivarse:

```
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    // ── Configuración MVC (CSRF activo) ──────────────────────────
    @Bean
    public SecurityFilterChain mvcSecurityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf
                // Por defecto usa CookieCsrfTokenRepository o HttpSessionCsrfTokenRepository
                .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
                // Podemos excluir rutas si fuera necesario (ej: webhooks)
                .ignoringRequestMatchers("/webhooks/**")
            )
            .authorizeHttpRequests(auth -> auth
                .anyRequest().authenticated()
            );
        return http.build();
    }

    // ── Configuración REST (CSRF desactivado — stateless) ─────────
    @Bean
    public SecurityFilterChain restSecurityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())   // Sin sesión → sin riesgo CSRF
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .authorizeHttpRequests(auth -> auth
                .anyRequest().authenticated()
            );
        return http.build();
    }
}
```

## Implicaciones en Thymeleaf

Thymeleaf con Spring Security lo hace automático:

```
<!-- Thymeleaf inyecta el campo oculto automáticamente en cualquier <form> -->
<form th:action="@{/transferir}" method="post">
    <!-- <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/> -->
    <!-- ↑ Thymeleaf añade esto solo si usas th:action — no hace falta escribirlo -->
    
    <input type="text" name="destino"/>
    <button type="submit">Transferir</button>
</form>
```

El atributo th:action es la clave: cuando Thymeleaf ve th:action en un form, automáticamente incluye el token CSRF. 

Si usas action (HTML puro), no lo incluye — ese es el error típico del alumno.

Partiendo de la vista de Thymeleaf:

```
<form th:action="@{/transferir}" method="post">
    <input type="text" name="destino"/>
    <button type="submit">Transferir</button>
</form>
```

Se genera automáticamente esto:

```
<form action="/transferir" method="post">
    <input type="hidden" name="_csrf" value="a1b2c3d4e5f6..."/>  <!-- añadido por Thymeleaf -->
    <input type="text" name="destino"/>
    <button type="submit">Transferir</button>
</form>
```

Ese input hidden nunca lo ves en tu código fuente, pero sí aparece si inspeccionas el HTML desde el navegador.

Usa siempre th:action en tus formularios, y la protección CSRF viene gratis.
