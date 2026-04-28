import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.*;
import java.util.stream.Collectors;

@Entity
@Table(name = "users")
@Data
@AllArgsConstructor
@Builder
public class User implements UserDetails {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "user_roles",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles;

    // ---------- ??? ------------
    @Transient // No se almacena en la BD
    private String selectedRole;
    // ----------

    public User(){
        roles = new HashSet<>();
    }

    public void addRole(Role role) {
        roles.add(role);
        //role.getUsers().add(this);
    }

    public void removeRole(Role role) {
        roles.remove(role);
        //role.getUsers().remove(this);
    }

    // ---------------------------------------------------------------------
    // ???????????
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return roles.stream()
                .map(role -> (GrantedAuthority) role::getName)
                .collect(Collectors.toSet());
    }

    /**
     * Indica si la cuenta del usuario ha expirado.
     * A true: la cuenta nunca expira
     * @return
     */
    @Override
    public boolean isAccountNonExpired() { return true; }

    /**
     * Indica si la cuenta está bloqueada.
     * A true: la cuenta no está bloqueada.
     * @return
     */
    @Override
    public boolean isAccountNonLocked() { return true; }

    /**
     * Indica si las credenciales (contraseña) han expirado.
     * A true: la contraseña nunca expira
     * @return
     */
    @Override
    public boolean isCredentialsNonExpired() { return true; }

    /**
     * Indica si la cuenta está habilitada.
     * A true: la cuenta está activa
     * @return
     */
    @Override
    public boolean isEnabled() { return true; }


    // ------------ SOBREESCRITURA DE MÉTODOS ------------------------
    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        User user = (User) o;
        return Objects.equals(id, user.id);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(id);
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", password='" + password + '\'' +
                '}';
    }
}

