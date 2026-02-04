package es.daw.eventhubmvc.service;


import es.daw.eventhubmvc.dto.UserProfileUpdateRequest;
import es.daw.eventhubmvc.entity.User;

public interface UserService {

    User findByUsername(String username);

    User updateProfile(Long userId, UserProfileUpdateRequest request);
}
