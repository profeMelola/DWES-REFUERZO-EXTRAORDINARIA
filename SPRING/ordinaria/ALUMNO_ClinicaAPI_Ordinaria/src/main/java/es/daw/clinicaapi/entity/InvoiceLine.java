package es.daw.clinicaapi.entity;

import es.daw.clinicaapi.enums.DiscountType;
import es.daw.clinicaapi.enums.VatRate;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name="invoice_lines")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class InvoiceLine {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long ID;

    @ManyToOne(fetch=FetchType.LAZY, optional=false)
    private MedicalService service;

    @Column(nullable=false)
    private int quantity;

    @Column(nullable=false, precision=12, scale=2)
    private BigDecimal unitPrice;

    @Enumerated(EnumType.STRING)
    @Column(nullable=false, length=10)
    private VatRate vatRate;

    @Enumerated(EnumType.STRING)
    @Column(nullable=false, length=10)
    private DiscountType discountType;

    @Column(precision=12, scale=2)
    private BigDecimal discountValue;

    @Column(nullable=false, precision=12, scale=2)
    private BigDecimal lineTotal;

    // ------------
    // En JPA el lado propietario de la relación es el que tiene la FK
    @ManyToOne(fetch=FetchType.LAZY, optional=false)
    // Si no se pone @JoinColumn, JPA crea una columna invoice_id por convención
    // Recomendación poner @JoinColumn explícito para controlar el nombre de la FK y su constraint
    @JoinColumn(name="invoice_id", nullable=false)
    private Invoice invoice;
}

