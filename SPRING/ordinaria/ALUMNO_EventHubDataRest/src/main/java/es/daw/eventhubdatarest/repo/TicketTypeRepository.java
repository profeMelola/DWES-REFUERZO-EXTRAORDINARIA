package es.daw.eventhubdatarest.repo;

import es.daw.eventhubdatarest.entity.TicketType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import java.time.LocalDateTime;
import java.util.Optional;

@RepositoryRestResource(path = "ticketTypes")
public interface TicketTypeRepository extends JpaRepository<TicketType, Long> {

    Optional<TicketType> findByCode(@Param("code") String code);

    Page<TicketType> findByEventCode(@Param("eventCode") String eventCode, Pageable pageable);

    // opcional si quieres:
    Page<TicketType> findBySaleStartLessThanEqualAndSaleEndGreaterThanEqual(
            @Param("now1") LocalDateTime now1,
            @Param("now2") LocalDateTime now2,
            Pageable pageable
    );
}

