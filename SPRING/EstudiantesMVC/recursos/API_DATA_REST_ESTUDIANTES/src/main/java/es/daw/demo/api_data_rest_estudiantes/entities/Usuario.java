package es.daw.demo.api_data_rest_estudiantes.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

@Entity
@Table(name = "users")
@Data
@AllArgsConstructor
@Builder
public class Usuario implements UserDetails {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(nullable = false)
    private String password;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "users_roles",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Rol> roles;

    public Usuario(){
        roles = new HashSet<>();
    }

    public void addRole(Rol rol) {
        roles.add(rol);
        //rol.getUsers().add(this);
    }

    public void removeRole(Rol rol) {
        roles.remove(rol);
        //rol.getUsers().remove(this);
    }

    // ---------------------------------------------------------------------
    /*
    Este método convierte la lista de rols del usuario (rols) en una colección de autoridades (GrantedAuthority).
    En Spring Security, una autoridad representa un permiso o un rol que se asigna a un usuario.
    Spring Security usa GrantedAuthority para determinar los permisos de un usuario en el sistema.
    El método getAuthorities() es utilizado por Spring Security para autenticar y autorizar al usuario.
    De: rols = [ new Rol("ADMIN"), new Rol("USER") ]
    A: Set<GrantedAuthority> authorities = ["ADMIN", "USER"]
     */
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return roles.stream()
                .map(rol -> (GrantedAuthority) rol::getName)
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


    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", password='" + password + '\'' +
                '}';
    }
}

