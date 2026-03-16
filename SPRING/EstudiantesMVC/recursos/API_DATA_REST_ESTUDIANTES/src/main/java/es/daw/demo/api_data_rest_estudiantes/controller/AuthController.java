package es.daw.demo.api_data_rest_estudiantes.controller;

import es.daw.demo.api_data_rest_estudiantes.dto.AuthRequest;
import es.daw.demo.api_data_rest_estudiantes.dto.AuthResponse;
import es.daw.demo.api_data_rest_estudiantes.dto.RegisterRequest;
import es.daw.demo.api_data_rest_estudiantes.entities.Rol;
import es.daw.demo.api_data_rest_estudiantes.entities.Usuario;
import es.daw.demo.api_data_rest_estudiantes.repository.RolRepository;
import es.daw.demo.api_data_rest_estudiantes.repository.UsuarioRepository;
import es.daw.demo.api_data_rest_estudiantes.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final UsuarioRepository userRepository;
    private final RolRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    /*
        POST /auth/login

        Recibe un usuario y contraseña.
        Autentica al usuario.
        Genera un JWT y lo devuelve en la respuesta.
     */
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody AuthRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String token = jwtService.generateToken((UserDetails) authentication.getPrincipal());

        return ResponseEntity.ok(new AuthResponse(token));
    }
    /*
        POST /auth/register

        Recibe un usuario y contraseña.
        Registra un nuevo usuario en la base de datos.
        Devuelve un mensaje de éxito.
     */

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody RegisterRequest request) {

        if (userRepository.findByUsername(request.getUsername()).isPresent()) {
            return ResponseEntity.badRequest().body("El usuario ya existe");
        }

        // Inicializamos rols
        Set<Rol> rols = new HashSet<>();

        // Asegurar que el rol enviado tenga el prefijo ROLE_
        String roleName = request.getRole() != null ? request.getRole().toUpperCase() : "USER";
        if (!roleName.startsWith("ROLE_")) {
            roleName = "ROLE_" + roleName;
        }

        // Buscamos el rol en la base de datos
        Optional<Rol> roleOptional = roleRepository.findByName(roleName);
        if (roleOptional.isPresent()) {
            rols.add(roleOptional.get());
        } else {
            return ResponseEntity.badRequest().body("Rol inválido. Usa 'ADMIN' o 'USER'.");
        }

        // Creamos el nuevo usuario
        Usuario newUser = new Usuario();
        newUser.setUsername(request.getUsername());
        newUser.setPassword(passwordEncoder.encode(request.getPassword()));
        newUser.setRoles(rols);

        userRepository.save(newUser);

        return ResponseEntity.ok("Usuario registrado con éxito con rol: " + roleName);
    }

}


