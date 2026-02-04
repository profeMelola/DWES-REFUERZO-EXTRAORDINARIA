package es.daw.eventhubmvc.repository;

import es.daw.eventhubmvc.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByUsername(String username);

    boolean existsByUsername(String username);

    Optional<User> findByUsernameOrEmail(String username, String email);

    boolean existsByEmailAndIdNot(String email, Long id);

}

