package es.daw.clinicaapi.enums;

import java.math.BigDecimal;
import java.math.RoundingMode;

public enum DiscountType {
    NONE,
    PERCENT,
    FIXED;

    public BigDecimal apply(BigDecimal amount, BigDecimal discountValue) {
        if (amount == null) return BigDecimal.ZERO;
        if (this == NONE || discountValue == null) return amount;

        return switch (this) {
            case PERCENT -> amount.subtract(amount.multiply(discountValue).setScale(2, RoundingMode.HALF_UP));
            case FIXED -> amount.subtract(discountValue);
            default -> amount;
        };
    }
}
