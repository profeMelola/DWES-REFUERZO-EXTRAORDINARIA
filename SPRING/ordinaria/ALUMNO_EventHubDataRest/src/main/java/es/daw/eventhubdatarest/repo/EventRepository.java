package es.daw.eventhubdatarest.repo;

import es.daw.eventhubdatarest.entity.Event;
import es.daw.eventhubdatarest.enums.EventCategory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import java.time.LocalDateTime;
import java.util.Optional;

@RepositoryRestResource(path = "events")
public interface EventRepository extends JpaRepository<Event, Long> {

    Optional<Event> findByCode(@Param("code") String code);

    Page<Event> findByActiveTrue(Pageable pageable);

    Page<Event> findByCategory(@Param("category") EventCategory category, Pageable pageable);

    Page<Event> findByLocationCode(@Param("locationCode") String locationCode, Pageable pageable);

    Page<Event> findByStartDateTimeBetween(
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to,
            Pageable pageable
    );
}

