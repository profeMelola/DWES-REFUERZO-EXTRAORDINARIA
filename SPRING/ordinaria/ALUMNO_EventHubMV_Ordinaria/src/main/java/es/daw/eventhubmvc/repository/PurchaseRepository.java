package es.daw.eventhubmvc.repository;

import es.daw.eventhubmvc.entity.Purchase;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PurchaseRepository extends JpaRepository<Purchase, Long> {
    List<Purchase> findByUsernameOrderByCreatedAtDesc(String username);
    Optional<Purchase> findByIdAndUsername(Long id, String username);
}
