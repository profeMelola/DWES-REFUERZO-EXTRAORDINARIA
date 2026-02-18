# Creación de un proyecto Spring

En IntelliJ esa pantalla es, básicamente, un “cliente” de Spring Initializr (start.spring.io) con un par de opciones extra propias del IDE.

<img width="1099" height="797" alt="imagen" src="https://github.com/user-attachments/assets/f66d5f7f-01cf-42d3-9c06-c4a8dd4eaf54" />


- **Project SDK (JDK):** JDK instalado localmente que usa IntelliJ para compilar y ejecutar.
- **Java (versión del proyecto):** versión objetivo para la que se compila el código (compatibilidad/bytecode). Debe ser compatible con la versión de Spring Boot elegida.
- **Packaging JAR:** recomendado en Spring Boot (jar ejecutable con servidor embebido). Ideal para Docker.
- **Packaging WAR:** solo si se necesita desplegar en un Tomcat/servidor externo.

## JDK vs Java

JDK indica el java con el que compilo/ejecuto en mi máquina de desarrollo.

Java indica para qué versión de Java genero el proyecto (mínimo compatible / bytecode target)

Elegir la misma LTS en ambos (p.ej. 17 o 21) para evitar confusión. De todas formas, podemos poner un JDK superior al Java porque habrá compatibilidad.


## Packaging: JAR vs WAR (y por qué casi siempre JAR con Spring Boot)

**JAR (lo habitual con Spring Boot)**
- Genera un “bootable jar”: un jar ejecutable con java -jar app.jar.
- Incluye el servidor embebido (Tomcat/Jetty/Undertow) y arranca como proceso.
- Perfecto para:
  - Docker (un proceso, un contenedor)
  - Cloud (Heroku-like, Kubernetes, etc.)
  - Microservicios
  - Deploy simple

**WAR (caso más “tradicional”)**

- Pensado para desplegar en un application server externo (Tomcat externo, WildFly, etc.).
- Con Boot se puede, pero normalmente implica:
  - Marcar el packaging como war
  - Extender SpringBootServletInitializer
  - Configurar dependencias para que el contenedor aporte el servlet container.

**Se usa JAR por defecto en Boot, salvo requisito explícito de despliegue en servidor externo.**

## Maven vs Gradle 

Si eliges Gradle-Groovy en un proyecto Java el build script es build.gradle.

Alternativa: Gradle-Kotlin (scripts en Kotlin).

Maven es más “estándar académico” y Gradle es más flexible y rápido en builds grandes.
