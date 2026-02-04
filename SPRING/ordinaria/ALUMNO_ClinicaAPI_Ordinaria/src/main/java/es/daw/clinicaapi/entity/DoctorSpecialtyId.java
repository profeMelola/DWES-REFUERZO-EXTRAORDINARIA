package es.daw.clinicaapi.entity;


import es.daw.clinicaapi.enums.Specialty;
import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;

@Embeddable
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class DoctorSpecialtyId implements Serializable {

    private Long doctorId;

    @Enumerated(EnumType.STRING)
    @Column(length = 30)
    private Specialty specialty;
}

