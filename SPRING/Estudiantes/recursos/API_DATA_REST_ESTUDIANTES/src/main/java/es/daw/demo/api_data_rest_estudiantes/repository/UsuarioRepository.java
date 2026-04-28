package es.daw.demo.api_data_rest_estudiantes.repository;

import es.daw.demo.api_data_rest_estudiantes.entities.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    Optional<Usuario> findByUsername(String username);
}
