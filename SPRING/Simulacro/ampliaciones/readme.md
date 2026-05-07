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
