# 1. PAGINACIÓN: paginar películas

Añade a **data.sql** nuevas películas:

```
INSERT INTO movies (title, release_year, genre, active) VALUES
    ('Inception',              2010, 'SCI_FI',   true),
    ('The Dark Knight',        2008, 'ACTION',   true),
    ('Interstellar',           2014, 'SCI_FI',   true),
    ('The Prestige',           2006, 'DRAMA',    true),
    ('Dunkirk',                2017, 'WAR',      true),
    ('Batman Begins',          2005, 'ACTION',   false),
    ('Arrival',                2016, 'SCI_FI',   true),
    ('Blade Runner 2049',      2017, 'SCI_FI',   true),
    ('Dune',                   2021, 'SCI_FI',   true),
    ('The Matrix',             1999, 'SCI_FI',   true),
    ('Alien',                  1979, 'SCI_FI',   false),
    ('The Godfather',          1972, 'DRAMA',    true),
    ('Schindlers List',        1993, 'DRAMA',    true),
    ('Parasite',               2019, 'DRAMA',    true),
    ('The Shawshank Redemption', 1994, 'DRAMA',  true),
    ('Pulp Fiction',           1994, 'THRILLER', true),
    ('Se7en',                  1995, 'THRILLER', true),
    ('Joker',                  2019, 'THRILLER', true),
    ('Gone Girl',              2014, 'THRILLER', true),
    ('John Wick',              2014, 'ACTION',   true),
    ('Mad Max Fury Road',      2015, 'ACTION',   true),
    ('Die Hard',               1988, 'ACTION',   false),
    ('Top Gun Maverick',       2022, 'ACTION',   true),
    ('Saving Private Ryan',    1998, 'WAR',      true),
    ('1917',                   2019, 'WAR',      true),
    ('Hacksaw Ridge',          2016, 'WAR',      true),
    ('Hereditary',             2018, 'HORROR',   true),
    ('Get Out',                2017, 'HORROR',   true),
    ('Midsommar',              2019, 'HORROR',   true),
    ('A Quiet Place',          2018, 'HORROR',   true);
```

## Casos de prueba

### Bloque 1 — Happy path básico

#### Prueba 1 · Página 0 con size por defecto

```
GET http://localhost:8080/api/movies
```

- Status `200`
- `"number": 0` — primera página
- `"size": 10` — valor del `@PageableDefault`
- `"totalElements": 30` — todas las películas
- `"totalPages": 3` — ceil(30/10)
- `"first": true`, `"last": false`
- `"content"` tiene exactamente 10 elementos
- Ordenado por `title` A→Z (default del `@PageableDefault`)

---

#### Prueba 2 · Última página

```
GET http://localhost:8080/api/movies?page=2
```

- `"number": 2`
- `"last": true`, `"first": false`
- `"numberOfElements": 10`
- `"content"` tiene exactamente 10 elementos

---

### Bloque 2 — Parámetros de paginación

#### Prueba 3 · Size personalizado

```
GET http://localhost:8080/api/movies?size=5
```

- `"size": 5`, `"totalPages": 6` — ceil(30/5)
- `"content"` tiene 5 elementos

---

#### Prueba 4 · Ordenar por año descendente

```
GET http://localhost:8080/api/movies?sort=release_year,desc
```

- El primer elemento de `"content"` es la película más reciente
- El año va decreciendo elemento a elemento

---

#### Prueba 5 · Combinar page + size + sort

```
GET http://localhost:8080/api/movies?page=1&size=5&sort=title,asc
```

- `"number": 1`, `"size": 5`
- Los títulos siguen orden alfabético (continúa desde donde dejó la página 0)
- `"first": false`, `"last": false`

---

### Bloque 3 — Filtro por género + paginación

#### Prueba 6 · Género con varios resultados

```
GET http://localhost:8080/api/movies?genre=SCI_FI
```

- `"totalElements": 5` — las películas SCI_FI activas
- Todos los elementos de `"content"` tienen `"genre": "SCI_FI"`

---

#### Prueba 7 · Género + ordenación explícita

```
GET http://localhost:8080/api/movies?genre=DRAMA&sort=release_year,asc
```

- Los DRAMA ordenados del más antiguo al más reciente
- `"totalElements": 4`

---

#### Prueba 8 · Navegación entre páginas del filtro

```
GET http://localhost:8080/api/movies?genre=SCI_FI&page=1&size=3
```

- `"number": 1`, `"totalPages": 2`
- `"content"` tiene los elementos restantes, todos SCI_FI
- `"last": true`

---

### Bloque 4 — Casos límite

#### Prueba 9 · Página que no existe

```
GET http://localhost:8080/api/movies?page=99
```

- Status `200` — Spring no lanza error
- `"content": []` — array vacío
- `"empty": true`
- `"totalElements"` sigue siendo 30 — la BD no cambia

---

#### Prueba 10 · Género inexistente

```
GET http://localhost:8080/api/movies?genre=MUSICAL
```

- Status `200`
- `"totalElements": 0`, `"totalPages": 0`
- `"content": []`, `"empty": true`

---

#### Prueba 11 · Size = 1 (paginación extrema)

```
GET http://localhost:8080/api/movies?size=1&sort=title,asc
```

- `"totalPages": 30`
- `"content"` tiene exactamente 1 elemento
- Es la película cuyo título va primero alfabéticamente

---

### Bloque 5 — Verificar metadatos de la respuesta

#### Prueba 12 · Comprobar que se devuelve DTO, no entidad

```
GET http://localhost:8080/api/movies?size=1
```

- El primer elemento de `"content"` tiene solo los campos del DTO
- No aparecen campos internos de la entidad que no estén en el DTO

---

#### Prueba 13 · Consistencia entre páginas

```
GET http://localhost:8080/api/movies?page=0&size=5&sort=title,asc
GET http://localhost:8080/api/movies?page=1&size=5&sort=title,asc
GET http://localhost:8080/api/movies?page=2&size=5&sort=title,asc
```

- Ninguna película aparece en dos páginas distintas
- El orden alfabético es continuo entre páginas
- Sumando los `"numberOfElements"` de las 3 páginas da 15

# 2. Enumerados

Vamos a usar las nacionalidades del actor como enumerado:

Tomamos como referencia las nacionalidades de BD:

```
INSERT INTO actors (stage_name, full_name, nationality, active) VALUES
                                                                    ('DiCaprio',   'Leonardo DiCaprio', 'American',   true),
                                                                    ('Caine',      'Michael Caine',     'British',    true),
                                                                    ('Nolan',      'Christian Bale',    'British',    true),
                                                                    ('Murphy',     'Cillian Murphy',    'Irish',      true),
                                                                    ('Cotillard',  'Marion Cotillard',  'French',     true),
                                                                    ('Oldman',     'Gary Oldman',       'British',    false); -- inactivo para filtros

``` 

Modificaciones en ActorController:
    - endpoints: post y put / patch (modificar la nacionalidad el actor)

# 3. Añadir nuevas tablas al modelo. Nuevas relaciones

## 3.1. Relación ManyToMany

¿Qué relación @ManyToMany podríamos implementar?

[Propuesta ManyToMany](manyToMany.md)

# 4. Añadir imágenes. Integración de carteles de películas con TMDB API

Añadimos carteles oficiales al listado de películas usando [The Movie Database (TMDB)](https://www.themoviedb.org),
sin modificar el API REST. El MVC consulta TMDB directamente y cachea los resultados en memoria.

---

## 1. Obtener la API key de TMDB

1. Regístrate en [themoviedb.org](https://www.themoviedb.org/signup) — es gratuito
2. Ve a **Settings → API** (en tu avatar, arriba a la derecha)
3. Clica **Create → Developer**
4. Rellena el formulario (uso personal/educativo; en URL puedes poner `http://localhost`)
5. Copia el **API Read Access Token** (un JWT largo) — es el que usaremos

---

## 2. Configuración — `application.properties`

```properties
tmdb.api.token=Bearer eyJhbGc...   # pega aquí el token completo, con "Bearer "
tmdb.api.base-url=https://api.themoviedb.org/3
tmdb.image.base-url=https://image.tmdb.org/t/p/w200
```

---

## 3. `PosterService.java`

Busca el cartel en TMDB por título y lo cachea en un `ConcurrentHashMap`
para no repetir llamadas en cada paginación.

```java
@Service
public class PosterService {

    private static final String FALLBACK = "/images/no-poster.png";

    private final WebClient tmdbClient;
    private final String imageBaseUrl;

    // Caché en memoria: movieId → posterUrl
    private final Map<Long, String> cache = new ConcurrentHashMap<>();

    public PosterService(
            @Value("${tmdb.api.base-url}")   String apiBaseUrl,
            @Value("${tmdb.api.token}")      String token,
            @Value("${tmdb.image.base-url}") String imageBaseUrl) {

        this.imageBaseUrl = imageBaseUrl;
        this.tmdbClient = WebClient.builder()
                .baseUrl(apiBaseUrl)
                .defaultHeader("Authorization", token)
                .defaultHeader("Accept", "application/json")
                .build();
    }

    /**
     * Devuelve un mapa movieId → posterUrl para todas las películas de la página.
     * Las que ya están en caché no generan llamada a TMDB.
     */
    public Map<Long, String> getPosterUrls(List<MovieResponseDto> movies) {
        Map<Long, String> result = new HashMap<>();
        for (MovieResponseDto movie : movies) {
            String url = cache.computeIfAbsent(movie.id(), id -> fetchPoster(movie.title()));
            result.put(movie.id(), url);
        }
        return result;
    }

    private String fetchPoster(String title) {
        try {
            TmdbSearchResponse response = tmdbClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/search/movie")
                            .queryParam("query", title)
                            .queryParam("language", "es-ES")
                            .queryParam("page", 1)
                            .build())
                    .retrieve()
                    .bodyToMono(TmdbSearchResponse.class)
                    .block();

            if (response == null || response.results().isEmpty()) return FALLBACK;

            String posterPath = response.results().get(0).poster_path();
            return posterPath != null ? imageBaseUrl + posterPath : FALLBACK;

        } catch (Exception e) {
            return FALLBACK;
        }
    }

    // ── Records internos para deserializar la respuesta de TMDB ──

    private record TmdbSearchResponse(List<TmdbMovie> results) {}

    private record TmdbMovie(String poster_path) {}
}
```

---

## 4. Controlador — añadir los posters al modelo

```java
@GetMapping
public String list(
        @RequestParam(defaultValue = "0")     int page,
        @RequestParam(defaultValue = "10")    int size,
        @RequestParam(defaultValue = "title") String sort,
        @RequestParam(defaultValue = "asc")   String dir,
        Model model) {

    PageResponse<MovieResponseDto> movies = movieService.getAllMovies(page, size, sort, dir);

    model.addAttribute("page",    movies);
    model.addAttribute("size",    size);
    model.addAttribute("sort",    sort);
    model.addAttribute("dir",     dir);
    model.addAttribute("posters", posterService.getPosterUrls(movies.content())); // ← nuevo

    return "list";
}
```

---

## 5. Vista `list.html` — columna del cartel

Añade la columna en `<thead>` y la imagen en cada fila de `<tbody>`:

```html
<thead>
    <tr>
        <th class="col-poster"></th>   <!-- ← nueva columna -->
        <th class="col-id">ID</th>
        <th>Título</th>
        <th class="col-year">Año</th>
        <th class="col-genre">Género</th>
        <th class="col-state">Estado</th>
        <th class="col-action"></th>
    </tr>
</thead>
<tbody>
    <tr th:each="movie : ${page.content}">
        <td>
            <img th:src="${posters[movie.id]}"
                 alt="Cartel"
                 class="movie-poster"/>
        </td>
        <td th:text="${movie.id}">1</td>
        <td class="film-title" th:text="${movie.title}">Inception</td>
        <td th:text="${movie.releaseYear}">2010</td>
        <td><span class="badge badge-genre" th:text="${movie.genre}">SCI_FI</span></td>
        <td><span class="badge badge-active"
                  th:text="${movie.active} ? 'Activa' : 'Inactiva'">Activa</span></td>
        <td style="text-align:right">
            <a th:href="@{/movies/{id}(id=${movie.id})}" class="btn btn-primary btn-sm">Ver</a>
            <div th:if="${#authorization.expression('hasRole(''USER'')')}">
                <form th:action="@{/favorites/add/{id}(id=${movie.id})}" method="post">
                    <button type="submit" class="btn btn-sm">⭐</button>
                </form>
            </div>
        </td>
    </tr>
</tbody>
```

---

## 6. Estilos — añadir en `layout.html`

```css
/* ── POSTER ── */
.col-poster { width: 54px; }

.movie-poster {
    height: 60px;
    width: 40px;
    object-fit: cover;
    border-radius: var(--radius);
    display: block;
}
```

---

## 7. Imagen de fallback

Crea la carpeta y añade una imagen genérica para cuando TMDB no encuentre el cartel:

```
src/main/resources/static/images/no-poster.png
```

Puede ser cualquier imagen neutra de ~40×60 px.

---

## Flujo completo

```
GET /movies
  │
  ├─→ MovieService      llama a tu API REST → PageResponse<MovieResponseDto>
  │
  ├─→ PosterService     para cada película:
  │       ├─ ¿está en caché?  → devuelve URL directamente
  │       └─ no está         → llama a TMDB /search/movie?query={title}
  │                              └─ guarda en caché y devuelve URL
  │
  └─→ Model: page + size + sort + dir + posters
        │
        └─→ list.html: <img th:src="${posters[movie.id]}">
```

---

## Notas

- La caché (`ConcurrentHashMap`) es **en memoria**: se pierde al reiniciar la aplicación,
  pero evita llamar a TMDB en cada cambio de página para películas ya vistas.
- TMDB devuelve el primer resultado de búsqueda por título. Si hay títulos ambiguos
  o en español, puede no coincidir; en ese caso se muestra el fallback.
- El token de TMDB **no debe subirse a Git**. Usa variables de entorno o un
  `application-local.properties` ignorado en `.gitignore`.

