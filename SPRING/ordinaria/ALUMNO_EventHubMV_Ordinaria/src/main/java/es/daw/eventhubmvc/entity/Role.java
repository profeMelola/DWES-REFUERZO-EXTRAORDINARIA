package es.daw.eventhubmvc.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "roles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Role {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Guardar con prefijo ROLE_ (ej: ROLE_USER, ROLE_ADMIN)
     */
    @Column(unique = true, nullable = false, length = 40)
    private String name;

    @Column(length = 100)
    private String description;

    /**
     * Relación inversa opcional (no es estrictamente necesaria, pero útil).
     * No uses ManyToMany: ahora el user tiene un solo role.
     */
    @OneToMany(mappedBy = "role")
    @Builder.Default
    private Set<User> users = new HashSet<>();

    public void addUser(User user) {
        users.add(user);
        user.setRole(this);
    }

    public void removeUser(User user) {
        users.remove(user);
        user.setRole(null);
    }

    @Override
    public String toString() {
        return "Role{" +
               "id=" + id +
               ", name='" + name + '\'' +
               '}';
    }
}
