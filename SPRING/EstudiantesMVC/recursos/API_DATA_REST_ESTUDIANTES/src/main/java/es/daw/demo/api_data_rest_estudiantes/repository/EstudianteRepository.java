package es.daw.demo.api_data_rest_estudiantes.repository;

import es.daw.demo.api_data_rest_estudiantes.entities.Estudiante;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import java.util.List;
import java.util.Optional;

@RepositoryRestResource(path = "estudiantes")
public interface EstudianteRepository extends JpaRepository<Estudiante, Long> {
    Optional<List<Estudiante>> findByNombreAndPrimerApellido(String nombre, String primerApellido);

    Optional<List<Estudiante>> findByDireccionContaining(String direccion);

    Optional<Estudiante> findByNia(String nia);

    Optional<Estudiante> findByNombreAndPrimerApellidoAndSegundoApellido(String nombre, String primerApellido, String segundoApellido);

}
