package es.daw.demo.api_data_rest_estudiantes.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.Period;

@Getter
@Setter
@Entity
@Table(name = "estudiantes")
public class Estudiante {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String nia;

    @Column(nullable = false)
    private String nombre;

    @Column(nullable = false)
    private String primerApellido;

    @Column(nullable = false)
    private String segundoApellido;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String movil;

    @Column(length = 255)
    private String direccion;

    @Column(nullable = false)
    private LocalDate fechaNacimiento;

    @Transient
    private Integer edad;

    public Integer getEdad() {
        return (fechaNacimiento != null) ? Period.between(fechaNacimiento, LocalDate.now()).getYears() : null;
    }
}
