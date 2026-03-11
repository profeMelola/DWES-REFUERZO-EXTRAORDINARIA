# Spring MVC — Flash Attributes y el patrón PRG

## Contexto

En Spring MVC, al añadir entradas al carrito mediante un formulario, el mensaje de confirmación:

```
"Added " + qty + " ticket(s) to your cart."
```

aparece en la vista `events/detail` **aunque el endpoint que lo genera es `/cart/add`**, que es un endpoint distinto.

Visto previamente en:

[Evitar F5-doble-submit (Post-Redirect-Get) + FlashAttributes](https://github.com/profeMelola/ProyectoFoodExpress?tab=readme-ov-file#a21-evitar-f5-doble-submit-postredirectget-flashattributes)

---

## El flujo paso a paso

```
[Formulario] POST /cart/add
      │
      │  ra.addFlashAttribute("successMessage", "Added " + qty + " ticket(s) to your cart.")
      │
      └──► return "redirect:/events/" + form.eventCode()
                │
                │  HTTP 302 → navegador hace GET /events/{eventCode}
                │
                └──► @GetMapping("/events/{eventCode}")  ← detail()
                           │
                           └──► model ya tiene "successMessage" ✓
                                return "events/detail"
```

El flujo completo es: **POST → redirect (302) → GET**. Este patrón se conoce como **PRG (Post-Redirect-Get)**.

---

## ¿Qué son los Flash Attributes?

`RedirectAttributes` es un mecanismo especial de Spring MVC. Cuando haces `ra.addFlashAttribute(...)`:

1. Spring guarda el atributo en la **sesión HTTP** (temporalmente).
2. Se produce el redirect (HTTP 302).
3. El navegador hace un nuevo GET.
4. Spring **mueve** esos atributos de la sesión al `Model` del nuevo request.
5. Los elimina de la sesión — son de **un solo uso**.

```
POST /cart/add
  └─ ra.addFlashAttribute("successMessage", "...")
       │
       │  [Spring guarda en sesión]
       │
  └─ redirect:/events/EVT-001
       │
       │  HTTP 302
       │
GET /events/EVT-001        ← nuevo request, nueva instancia del Model
  └─ Spring detecta flash attrs en sesión
  └─ Los inyecta automáticamente en el Model
  └─ detail() los encuentra disponibles
  └─ events/detail los renderiza con th:if="${successMessage}"
```

---

## ¿Por qué no usar `Model` directamente en el POST?

Si en el método `add()` hicieras `model.addAttribute("successMessage", "...")` y luego `return "redirect:..."`, **el mensaje se perdería**.

Los atributos del `Model` no sobreviven a un redirect porque son parte del request HTTP, que termina en ese mismo instante.

