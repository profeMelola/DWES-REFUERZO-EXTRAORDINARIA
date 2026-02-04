package es.daw.eventhubdatarest.repo;

import es.daw.eventhubdatarest.entity.Location;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import java.util.Optional;

@RepositoryRestResource(path = "locations")
public interface LocationRepository extends JpaRepository<Location, Long> {

    Optional<Location> findByCode(@Param("code") String code);

    Page<Location> findByActiveTrue(Pageable pageable);

    Page<Location> findByCityIgnoreCase(@Param("city") String city, Pageable pageable);
}

