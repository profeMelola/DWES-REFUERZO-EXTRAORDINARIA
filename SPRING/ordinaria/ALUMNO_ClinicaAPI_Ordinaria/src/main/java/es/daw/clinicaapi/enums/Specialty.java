package es.daw.clinicaapi.enums;

import lombok.Getter;
import java.math.BigDecimal;

@Getter
public enum Specialty {
    GENERAL_MED("GEN", "Medicina general", new BigDecimal("1.00")),
    DERMATOLOGY("DERM", "Dermatología", new BigDecimal("1.20")),
    CARDIOLOGY("CARD", "Cardiología", new BigDecimal("1.35"));

    private final String code;
    private final String label;
    private final BigDecimal revenueMultiplier;

    Specialty(String code, String label, BigDecimal revenueMultiplier) {
        this.code = code;
        this.label = label;
        this.revenueMultiplier = revenueMultiplier;
    }

    public BigDecimal applyMultiplier(BigDecimal base) {
        if (base == null) return null;
        return base.multiply(revenueMultiplier);
    }
}
