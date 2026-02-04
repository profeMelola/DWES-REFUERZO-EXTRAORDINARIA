package es.daw.eventhubmvc.model;

import lombok.*;

import java.math.BigDecimal;

import java.math.BigDecimal;

public record CartItem(
        String ticketTypeCode,
        String ticketName,
        BigDecimal unitPrice,
        int qty
) {
    public BigDecimal lineTotal() {
        if (unitPrice == null) return BigDecimal.ZERO;
        return unitPrice.multiply(BigDecimal.valueOf(qty));
    }
}


