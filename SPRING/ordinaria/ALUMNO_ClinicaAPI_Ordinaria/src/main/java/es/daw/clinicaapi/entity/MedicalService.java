package es.daw.clinicaapi.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "medical_services")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class MedicalService {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false, unique=true, length=30)
    private String code;

    @Column(nullable=false, length=120)
    private String name;

    @Column(nullable=false, precision=12, scale=2)
    private BigDecimal basePrice;

    @Column(nullable=false)
    private boolean active = true;
}

