# Java Moderno — Guía Práctica

> Características introducidas desde **Java 10 hasta Java 21** que cambian la forma de escribir código más limpio, expresivo y seguro.

---

## 1. `var` — Inferencia de tipos locales (Java 10+)

`var` permite que el compilador deduzca el tipo de una variable local. **No es tipado dinámico**: el tipo se resuelve en tiempo de compilación.

```java
// Antes
ArrayList<String> nombres = new ArrayList<>();
Map<String, List<Integer>> mapa = new HashMap<>();

// Con var
var nombres = new ArrayList<String>();
var mapa = new HashMap<String, List<Integer>>();

// En bucles
var lista = List.of("Java", "Kotlin", "Scala");
for (var elemento : lista) {
    System.out.println(elemento.toUpperCase()); // el compilador sabe que es String
}

// En bloques try-with-resources
try (var lector = new BufferedReader(new FileReader("archivo.txt"))) {
    var linea = lector.readLine();
    System.out.println(linea);
}
```

> ⚠️ `var` **no puede usarse** en atributos de clase, parámetros de método ni como tipo de retorno.

---

## 2. Métodos con argumentos variables — Varargs

Con `...` un método acepta cero o más argumentos del mismo tipo, que internamente se tratan como un array.

```java
public static int sumar(int... numeros) {
    int total = 0;
    for (int n : numeros) total += n;
    return total;
}

// Uso
System.out.println(sumar());           // 0
System.out.println(sumar(5));          // 5
System.out.println(sumar(1, 2, 3, 4)); // 10

// También acepta un array directamente
int[] valores = {10, 20, 30};
System.out.println(sumar(valores));    // 60
```

**Combinado con otros parámetros** (varargs debe ir siempre al final):

```java
public static void log(String nivel, String... mensajes) {
    for (var msg : mensajes) {
        System.out.printf("[%s] %s%n", nivel, msg);
    }
}

log("INFO", "Servidor iniciado", "Puerto: 8080");
log("ERROR", "Conexión fallida");
```

---

## 3. `record` — Clases de datos inmutables (Java 16+)

Un `record` genera automáticamente constructor, getters, `equals()`, `hashCode()` y `toString()`. Ideal para DTOs, Value Objects y datos estructurados.

```java
// Declaración — una sola línea
record Persona(String nombre, int edad) {}

// Uso
var p = new Persona("Ana", 30);
System.out.println(p.nombre());   // Ana  (getter automático)
System.out.println(p.edad());     // 30
System.out.println(p);            // Persona[nombre=Ana, edad=30]

// equals y hashCode automáticos
var p2 = new Persona("Ana", 30);
System.out.println(p.equals(p2)); // true
```

**Records con validación en el constructor compacto:**

```java
record Temperatura(double valor, String unidad) {
    // Constructor compacto: valida sin repetir los parámetros
    Temperatura {
        if (!unidad.equals("C") && !unidad.equals("F") && !unidad.equals("K")) {
            throw new IllegalArgumentException("Unidad no válida: " + unidad);
        }
        if (unidad.equals("K") && valor < 0) {
            throw new IllegalArgumentException("Kelvin no puede ser negativo");
        }
    }

    // Métodos adicionales
    public double aCelsius() {
        return switch (unidad) {
            case "C" -> valor;
            case "F" -> (valor - 32) * 5 / 9;
            case "K" -> valor - 273.15;
            default  -> throw new IllegalStateException();
        };
    }
}

var t = new Temperatura(100.0, "C");
System.out.println(t.aCelsius()); // 100.0
```

**Records genéricos:**

```java
record Par<A, B>(A primero, B segundo) {}

var par = new Par<>("clave", 42);
System.out.println(par.primero());  // clave
System.out.println(par.segundo());  // 42
```

---

## 4. Sealed Classes — Jerarquías cerradas (Java 17+)

Permiten controlar exactamente qué clases pueden extender o implementar un tipo. Perfectas junto a `switch` con pattern matching.

```java
sealed interface Forma permits Circulo, Rectangulo, Triangulo {}

record Circulo(double radio)                    implements Forma {}
record Rectangulo(double ancho, double alto)   implements Forma {}
record Triangulo(double base, double altura)   implements Forma {}

// Pattern matching exhaustivo en switch
double area(Forma f) {
    return switch (f) {
        case Circulo c       -> Math.PI * c.radio() * c.radio();
        case Rectangulo r    -> r.ancho() * r.alto();
        case Triangulo t     -> (t.base() * t.altura()) / 2;
    };
    // No necesita default: el compilador sabe que los casos son completos
}
```

---

## 5. Pattern Matching para `instanceof` (Java 16+)

Elimina el cast manual tras comprobar el tipo.

```java
// Antes
Object obj = "Hola mundo";
if (obj instanceof String) {
    String s = (String) obj; // cast redundante
    System.out.println(s.length());
}

// Con pattern matching
if (obj instanceof String s) {
    System.out.println(s.length()); // s ya está disponible y casteado
}

// Combinado con condición adicional (Java 21)
if (obj instanceof String s && s.length() > 5) {
    System.out.println("Cadena larga: " + s);
}
```

---

## 6. Switch Expressions (Java 14+)

El `switch` ahora puede usarse como **expresión** que devuelve un valor, y usa `->` en lugar de `case ... break`.

```java
int dia = 3;

// Switch expression con ->
String tipoDia = switch (dia) {
    case 1, 7 -> "Fin de semana";
    case 2, 3, 4, 5, 6 -> "Laborable";
    default -> "Inválido";
};

// Con yield (cuando se necesita lógica en el bloque)
String descripcion = switch (dia) {
    case 1, 7 -> "Fin de semana";
    default -> {
        var base = "Día " + dia;
        yield base + " de la semana";
    }
};

// Con enums (exhaustivo, sin default necesario)
enum Estacion { PRIMAVERA, VERANO, OTOÑO, INVIERNO }

Estacion e = Estacion.VERANO;
String actividad = switch (e) {
    case PRIMAVERA -> "Senderismo";
    case VERANO    -> "Playa";
    case OTOÑO     -> "Leer";
    case INVIERNO  -> "Esquí";
};
```

---

## 7. Text Blocks — Cadenas multilínea (Java 15+)

Permiten escribir JSON, SQL, HTML o cualquier texto estructurado sin escapes ni concatenaciones.

```java
// Antes
String json = "{\n" +
              "  \"nombre\": \"Ana\",\n" +
              "  \"edad\": 30\n" +
              "}";

// Con text block
String json = """
        {
          "nombre": "Ana",
          "edad": 30
        }
        """;

// SQL legible
String query = """
        SELECT u.nombre, u.email
        FROM usuarios u
        JOIN pedidos p ON u.id = p.usuario_id
        WHERE p.fecha > '2024-01-01'
        ORDER BY u.nombre
        """;

// Con interpolación usando formatted()
String html = """
        <html>
          <body>
            <h1>%s</h1>
            <p>Edad: %d</p>
          </body>
        </html>
        """.formatted("Ana", 30);
```

---

## 8. Optional — Evitar NullPointerException (Java 8+, mejorado en Java 9-11)

```java
import java.util.Optional;

// Crear
Optional<String> vacio   = Optional.empty();
Optional<String> presente = Optional.of("Hola");
Optional<String> nullable = Optional.ofNullable(null); // no lanza excepción

// Consumir de forma segura
presente.ifPresent(s -> System.out.println(s.toLowerCase()));

// Con valor por defecto
String resultado = vacio.orElse("valor por defecto");
String calculado = vacio.orElseGet(() -> "calculado: " + System.currentTimeMillis());

// Lanzar excepción si vacío
String valor = presente.orElseThrow(() -> new RuntimeException("No encontrado"));

// Transformar
Optional<Integer> longitud = presente.map(String::length); // Optional[5]

// Encadenar llamadas que pueden devolver Optional
Optional<String> emailMayus = buscarUsuario("ana")
        .flatMap(u -> Optional.ofNullable(u.email()))
        .map(String::toUpperCase);
```

---

## 9. Records + Sealed + Switch: combinación poderosa

Ejemplo completo que muestra cómo se usan juntas estas características:

```java
sealed interface Resultado<T> permits Exito, Fallo {}

record Exito<T>(T valor)      implements Resultado<T> {}
record Fallo<T>(String error) implements Resultado<T> {}

// Función que devuelve un Resultado
Resultado<Integer> dividir(int a, int b) {
    if (b == 0) return new Fallo<>("División por cero");
    return new Exito<>(a / b);
}

// Procesamiento exhaustivo y seguro
void procesar(Resultado<Integer> res) {
    var mensaje = switch (res) {
        case Exito<Integer> e -> "Resultado: " + e.valor();
        case Fallo<Integer> f -> "Error: " + f.error();
    };
    System.out.println(mensaje);
}

procesar(dividir(10, 2)); // Resultado: 5
procesar(dividir(10, 0)); // Error: División por cero
```

---

## 10. Resumen rápido de versiones

| Característica              | Versión estable |
|-----------------------------|-----------------|
| `var`                       | Java 10         |
| Switch expressions          | Java 14         |
| Text blocks                 | Java 15         |
| `record`                    | Java 16         |
| Pattern matching instanceof | Java 16         |
| Sealed classes              | Java 17         |
| Pattern matching en switch  | Java 21         |
| Virtual Threads (Loom)      | Java 21         |

---

> 📌 **Recomendación**: usa **Java 21 LTS** para proyectos nuevos. Incluye todas estas características de forma estable y con soporte a largo plazo.
