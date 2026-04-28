# `@Transactional` a nivel de clase vs. método en Spring MVC

## ¿Qué implica ponerlo en la clase?

Cuando anotas la **clase** con `@Transactional`, todos los métodos públicos de esa clase heredan esa configuración automáticamente. Es equivalente a poner `@Transactional` en cada método individualmente con los mismos parámetros.

---

## Analizando el código específico

```
@Service
@Transactional // en observación????
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    @Override
    public User findByUsername(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(
                        () -> new UsernameNotFoundException("Username not found")
                );
    }

    @Override
    public User updateProfile(Long userId, UserProfileUpdateRequest request) {

        // Cargo el usuario de BD con el id
        User user = userRepository.findById(userId)
                .orElseThrow(
                        () -> new UsernameNotFoundException("Username not found")
                );

        // Email único excepto el propio usuario
        // select * from users where email = request.email() and id != userId
        if (userRepository.existsByEmailAndIdNot(request.email(), userId)) {
            throw new EmailAlreadyExistsException(request.email());
        }

        // Actualizar el usuario con los nuevos datos
        user.setFullName(request.fullname());
        user.setEmail(request.email());

        // Salvar en la BD el usuario actualizado
        return userRepository.save(user);
    }
}

```

### `findByUsername` — solo lectura

```java
public User findByUsername(String username) {
    return userRepository.findByUsername(username)  // solo una lectura
            .orElseThrow(...);
}
```

Este método **no necesita transacción** (o si acaso, una de solo lectura con `@Transactional(readOnly = true)`).  
Si pones `@Transactional` en la clase, este método abre y cierra una transacción innecesariamente, añadiendo overhead.

### `updateProfile` — aquí sí tiene sentido

```java
public User updateProfile(...) {
    User user = userRepository.findById(userId)...   // lectura
    if (userRepository.existsByEmailAndIdNot(...))   // segunda lectura
        throw ...;
    user.setFullName(...);
    user.setEmail(...);
    return userRepository.save(user);                // escritura
}
```

Aquí la transacción es importante porque agrupa **dos lecturas + una escritura** en una unidad atómica. Si algo falla a mitad, hace rollback.

---

## La práctica recomendada

```java
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    @Override
    @Transactional(readOnly = true)   // optimiza lecturas
    public User findByUsername(String username) { ... }

    @Override
    @Transactional                    // necesita transacción completa
    public User updateProfile(...) { ... }
}
```

---

