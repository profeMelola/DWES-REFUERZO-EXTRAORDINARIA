# ¿Es necesario `save()` en relaciones `@ManyToMany` con JPA/Spring?

## Contexto

Tenemos una relación `@ManyToMany` entre `User` y `Role`. 

La tabla de unión `user_roles` está definida con `@JoinTable` en `User`, lo que la convierte en el **lado propietario (owning side)** de la relación.


```java


@Entity
@Table(name = "roles")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class Role {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false, length=40)
    private String name;

    @ManyToMany(mappedBy = "roles", fetch = FetchType.LAZY, cascade = {CascadeType.PERSIST, CascadeType.MERGE})
    private Set<User> users = new HashSet<>();

    public void addUser(User user) {
        users.add(user);
        user.getRoles().add(this);
    }

    public void removeUser(User user) {
        users.remove(user);
        user.getRoles().remove(this);
    }

} 

```

```java
@Entity
@Table(name = "users")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false, length=60)
    private String username;

    @Column(nullable=false, length=100)
    private String password; // BCrypt

    @Column(nullable=false)
    private boolean enabled = true;

    @ManyToMany(fetch = FetchType.EAGER, cascade = { CascadeType.PERSIST, CascadeType.MERGE})
    @JoinTable(
            name = "user_roles",
            joinColumns = @JoinColumn(name="user_id", foreignKey = @ForeignKey(name="fk_user_roles_user")),
            inverseJoinColumns = @JoinColumn(name="role_id", foreignKey = @ForeignKey(name="fk_user_roles_role"))
    )
    private Set<Role> roles = new HashSet<>();


    public void addRole(Role role) {
        roles.add(role);
        role.getUsers().add(this);
    }

    public void removerRole(Role role) {
        roles.remove(role);
        role.getUsers().remove(this);
    } 
}
```

---


## No es estrictamente necesario usar save

Cuando una entidad está en estado **managed** (gestionada por el `EntityManager`), Hibernate detecta automáticamente cualquier cambio en sus colecciones a través del mecanismo de **dirty checking**. 

Al finalizar la transacción, se hace un `flush` automático que persiste los cambios sin necesidad de llamar a `save()` explícitamente.

```java
@Transactional
public RoleUserResponse addRoleToUser(RoleRequestId req, Long userId) {

    User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

    for (Long roleId : req.rolesId()) {

        Role role = roleRepository.findById(roleId)
                .orElseThrow(() -> new RuntimeException("Role not found with id: " + roleId));

        for (Role rolesUser : user.getRoles()) {
            if (rolesUser.getId().equals(roleId)) {
                throw new BadRequestException("User already has this role");
            }
        }

        role.addUser(user); // dirty checking detecta el cambio
        // roleRepository.save(role); ← NO es necesario con @Transactional
    }

    // ...
}
```

---

## La clave: el lado propietario de la relación

En una relación `@ManyToMany`, Hibernate solo sincroniza la tabla de unión (`user_roles`) mirando el **owning side**. El lado inverso (`mappedBy`) es ignorado a efectos de persistencia.

| Entidad   | Lado             | Controla `user_roles` |
|-----------|------------------|-----------------------|
| `User` | **Owning** (`@JoinTable`) | ✅ Sí |
| `Role`    | Inverse (`mappedBy`)      | ❌ No |

Por eso lo que realmente importa es que la colección `roles` de `User` esté actualizada. 

El método helper `addUser()` en `Role` hace exactamente eso:

```java
// En Role.java
public void addUser(User user) {
    users.add(user);           // lado inverse → Hibernate lo ignora para la FK
    user.getRoles().add(this); // lado owning  → este ES el que persiste ✅
}
```

---

## ¿Cuándo sí haría falta el `save()`?

| Situación | ¿Necesita `save()`? |
|-----------|---------------------|
| Método con `@Transactional` | ❌ No |
| Método **sin** `@Transactional` | ✅ Sí (la entidad no está en estado *managed*) |
| Solo se actualiza el lado inverse (`Role.users`) sin tocar `User.roles` | ✅ Sí (aunque hagas `save`, no persiste nada útil) |

---

## Recomendación

Si decides hacer el `save()` explícito por claridad o por no depender de `@Transactional`, lo semánticamente correcto es guardarlo sobre el **lado propietario**:

```java
// ✅ Más correcto semánticamente
userRepository.save(user);

// ⚠️ Funciona pero es confuso: Role es el lado inverse
roleRepository.save(role);
```

O bien, confiar en el dirty checking con `@Transactional` y eliminar el `save()` por completo.

