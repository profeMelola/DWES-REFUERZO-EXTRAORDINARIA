# Simulador de borrado — Movie & Actor API

Efecto de cada operación DELETE sobre las tres tablas del modelo.

> 🔴 Se borra · 🟠 Error FK / bloqueado · 🟢 Intacto

---

## DELETE /movies/1 — Borrar película Inception

`cascade ALL + orphanRemoval = true` en `Movie.cast` elimina automáticamente los roles asociados. Los actores no se tocan.

| Tabla | Fila | Estado |
|---|---|---|
| MOVIES | id=1 Inception | 🔴 Borrada |
| MOVIES | id=2 Dark Knight | 🟢 Intacta |
| MOVIES | id=3 Interstellar | 🟢 Intacta |
| ACTORS | DiCaprio, Caine, Nolan, Oldman | 🟢 Intactos |
| MOVIE_CAST | (1,1) Cobb | 🔴 Borrado por cascade |
| MOVIE_CAST | (1,2) Miles | 🔴 Borrado por cascade |
| MOVIE_CAST | resto | 🟢 Intactos |

---

## DELETE /movies/6 — Borrar película Batman Begins (inactiva)

Mismo comportamiento que el caso anterior. La película estaba inactiva pero el mecanismo de cascade es idéntico.

| Tabla | Fila | Estado |
|---|---|---|
| MOVIES | id=6 Batman Begins | 🔴 Borrada |
| MOVIES | resto | 🟢 Intactas |
| ACTORS | todos | 🟢 Intactos |
| MOVIE_CAST | (6,3) Bruce Wayne | 🔴 Borrado por cascade |
| MOVIE_CAST | (6,6) Gordon | 🔴 Borrado por cascade |
| MOVIE_CAST | resto | 🟢 Intactos |

---

## DELETE /actors/1 — Borrar DiCaprio **SIN** cascade en Actor.cast

Sin `cascade` en `Actor.cast`, la BD lanza un error de FK porque `movie_cast` tiene filas con `actor_id=1`. La operación se bloquea completamente. **Nada se borra.**

| Tabla | Fila | Estado |
|---|---|---|
| MOVIES | todas | 🟢 Intactas |
| ACTORS | id=1 DiCaprio | 🟠 Bloqueado por FK |
| MOVIE_CAST | (1,1) Cobb | 🟠 Bloqueado por FK |
| MOVIE_CAST | (3,1) Cooper | 🟠 Bloqueado por FK |
| MOVIE_CAST | resto | 🟢 Intactos |

---

## DELETE /actors/1 — Borrar DiCaprio **CON** cascade en Actor.cast

Si se añade `cascade = CascadeType.ALL` en `Actor.cast`, se borran sus roles en `MOVIE_CAST`. Las películas no se borran.

| Tabla | Fila | Estado |
|---|---|---|
| MOVIES | todas | 🟢 Intactas |
| ACTORS | id=1 DiCaprio | 🔴 Borrado |
| MOVIE_CAST | (1,1) Cobb | 🔴 Borrado por cascade |
| MOVIE_CAST | (3,1) Cooper | 🔴 Borrado por cascade |
| MOVIE_CAST | resto | 🟢 Intactos |

---

## DELETE /movies/1/cast/2 — Borrar solo el rol de Caine en Inception

`orphanRemoval = true` borra únicamente esa fila de `MOVIE_CAST`. Inception sigue existiendo. Caine sigue existiendo.

| Tabla | Fila | Estado |
|---|---|---|
| MOVIES | todas | 🟢 Intactas |
| ACTORS | todos | 🟢 Intactos |
| MOVIE_CAST | (1,2) Miles | 🔴 Borrado por orphanRemoval |
| MOVIE_CAST | resto | 🟢 Intactos |

---

## DELETE /actors/2 — Borrar Caine **SIN** cascade

Caine tiene roles en Inception e Interstellar → FK bloquea la operación. Nada se borra.

| Tabla | Fila | Estado |
|---|---|---|
| MOVIES | todas | 🟢 Intactas |
| ACTORS | id=2 Caine | 🟠 Bloqueado por FK |
| MOVIE_CAST | (1,2) Miles | 🟠 Bloqueado por FK |
| MOVIE_CAST | (3,2) Professor | 🟠 Bloqueado por FK |
| MOVIE_CAST | resto | 🟢 Intactos |

---

## Resumen de reglas

| Configuración JPA | Efecto al borrar |
|---|---|
| `cascade ALL + orphanRemoval` en `Movie.cast` | Borra los roles automáticamente al borrar la película |
| Sin `cascade` en `Actor.cast` | FK bloquea si el actor tiene roles activos |
| `cascade ALL` en `Actor.cast` | Borra los roles automáticamente al borrar el actor |
| `orphanRemoval = true` | Borra solo la fila intermedia al eliminar un rol del Set |
