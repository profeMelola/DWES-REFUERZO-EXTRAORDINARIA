package es.daw.clinicaapi.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "patients")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class Patient {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false, unique=true, length=20)
    private String dni;

    @Column(nullable=false, length=120)
    private String fullName;

    @Column(nullable=false, length=150)
    private String email;

    @Column(length=30)
    private String phone;

    private LocalDate dateOfBirth;

    @Column(nullable=false)
    private boolean active = true;

    @OneToMany(mappedBy = "patient", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Appointment> appointments = new ArrayList<>();

    public void addAppointment(Appointment a) {
        appointments.add(a);
        a.setPatient(this);
    }

    public void removeAppointment(Appointment a) {
        appointments.remove(a);
        a.setPatient(null);
    }
}
