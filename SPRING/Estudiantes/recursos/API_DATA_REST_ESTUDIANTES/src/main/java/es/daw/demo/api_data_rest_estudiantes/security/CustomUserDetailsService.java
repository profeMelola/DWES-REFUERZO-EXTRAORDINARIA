package es.daw.demo.api_data_rest_estudiantes.security;

import es.daw.demo.api_data_rest_estudiantes.entities.Usuario;
import es.daw.demo.api_data_rest_estudiantes.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;


@Service
public class CustomUserDetailsService implements UserDetailsService {

    //@Autowired
    private final UsuarioRepository userRepository; // Tu repositorio para acceder a los usuarios
    @Autowired
    public CustomUserDetailsService(UsuarioRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // Lógica para cargar el usuario desde la base de datos
        Usuario user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException(username));

        System.out.println("*************** LOAD USER BY USERNAME *****************");
        System.out.println("Usuario: " + user.getUsername());
        System.out.println("Roles: " + user.getRoles()); // Verificar que los rols existen
        System.out.println("********************************************************");


        // Retorna un objeto UserDetails con la información del usuario
        //return new org.springframework.security.core.userdetails.Usuario(user.getUsername(), user.getPassword(), new ArrayList<>());

        return new org.springframework.security.core.userdetails.User(
                user.getUsername(),
                user.getPassword(),
                user.getAuthorities());

    }
}

