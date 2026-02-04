package es.daw.clinicaapi.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "doctors")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class Doctor {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long ID;

    @Column(nullable=false, unique=true, length=40)
    private String licenseNumber;

    @Column(nullable=false, length=120)
    private String fullName;

    @Column(nullable=false, length=150)
    private String email;

    @Column(nullable=false)
    private boolean active = true;

    @OneToMany(mappedBy = "doctor", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Appointment> appointments = new ArrayList<>();

    public void addAppointment(Appointment a) {
        appointments.add(a);
        a.setDoctor(this);
    }

}
