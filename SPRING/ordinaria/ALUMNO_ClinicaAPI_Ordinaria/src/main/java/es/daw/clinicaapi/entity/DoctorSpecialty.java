package es.daw.clinicaapi.entity;

import es.daw.clinicaapi.enums.Specialty;
import es.daw.clinicaapi.enums.SpecialtyLevel;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "doctor_specialties")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class DoctorSpecialty {

    @EmbeddedId
    private DoctorSpecialtyId id;

    @MapsId("doctorId")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    private Doctor Doctor;

    @Column(nullable=false, length=30, insertable = false, updatable = false)
    private Specialty specialty;

    @Column(nullable=false, length=20)
    private SpecialtyLevel level;

    @Column(nullable=false)
    private boolean active = true;

    @Column(nullable=false)
    private LocalDate sinceDate;

    private BigDecimal consultationFeeOverride;
}

