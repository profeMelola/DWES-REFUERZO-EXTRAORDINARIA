package es.daw.clinicaapi.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Entity
@Table(name = "app_users")
@Getter
@Setter
public class AppUser implements UserDetails {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false, length=60)
    private String username;

    @Column(nullable=false, length=100)
    private String password; // BCrypt

    @Column(nullable=false)
    private boolean enabled = true;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "user_roles",
            joinColumns = @JoinColumn(name="user_id", foreignKey = @ForeignKey(name="fk_user_roles_user")),
            inverseJoinColumns = @JoinColumn(name="role_id", foreignKey = @ForeignKey(name="fk_user_roles_role"))
    )
    private Set<Role> roles = new HashSet<>();


    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        if (roles == null) return List.of();

        return roles.stream()
                .map(role -> role.getName())
                .map(name -> "ROLE_" + name)
                .map(SimpleGrantedAuthority::new)
                .toList();
    }


    /**
     * Indica si la cuenta del usuario ha expirado.
     * Devuelve true si la cuenta no ha expirado.
     */
    @Override
    public boolean isAccountNonExpired() {
        return true;
        // // Devuelve true si la fecha actual es anterior o igual a la de expiración
        //    return !LocalDate.now().isAfter(accountExpirationDate);
    }

    /**
     * Indica si la cuenta del usuario está bloqueada.
     * Devuelve true si la cuenta no está bloqueada.
     */
    @Override
    public boolean isAccountNonLocked() { return true; }

    /**
     * Indica si las credenciales del usuario (contraseña) han expirado.
     * Devuelve true si las credenciales no han expirado.
     */
    @Override
    public boolean isCredentialsNonExpired() { return true; }

    /**
     * Indica si la cuenta del usuario está habilitada.
     * Devuelve true si la cuenta está activa.
     */
    @Override
    public boolean isEnabled() { return true; }


}
