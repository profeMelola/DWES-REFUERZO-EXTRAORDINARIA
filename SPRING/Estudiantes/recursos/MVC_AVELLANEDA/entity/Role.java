import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "roles")
@Data
@AllArgsConstructor
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String name;

    // Relación inversa con 'User'
    @ManyToMany(mappedBy = "roles")  // 'roles' es el nombre del atributo en la entidad User
    private Set<User> users;

    public Role() {
        users = new HashSet<User>();
    }

    public Role(Long id, String name) {
        this();
        this.id = id;
        this.name = name;

    }

    @Override
    public String toString() {
        return "Role{" +
                "id=" + id +
                ", name='" + name + '\'' +
                '}';
    }


//    // --------------- error java.util.ConcurrentModificationException
//
//    @Override
//    public boolean equals(Object o) {
//        if (o == null || getClass() != o.getClass()) return false;
//        Role role = (Role) o;
//        return Objects.equals(name, role.name);
//    }
//
//    @Override
//    public int hashCode() {
//        return Objects.hashCode(name);
//    }
}
