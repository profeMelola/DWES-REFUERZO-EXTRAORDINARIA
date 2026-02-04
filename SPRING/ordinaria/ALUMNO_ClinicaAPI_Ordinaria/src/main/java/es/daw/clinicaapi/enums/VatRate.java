package es.daw.clinicaapi.enums;

import lombok.Getter;

import java.math.BigDecimal;
import java.math.RoundingMode;

@Getter
public enum VatRate {
    VAT_0(new BigDecimal("0.00")),
    VAT_10(new BigDecimal("0.10")),
    VAT_21(new BigDecimal("0.21"));

    private final BigDecimal rate;

    VatRate(BigDecimal rate) { this.rate = rate; }

    public BigDecimal taxOf(BigDecimal base) {
        if (base == null) return BigDecimal.ZERO;
        return base.multiply(rate).setScale(2, RoundingMode.HALF_UP);
    }
}
