package es.daw.eventhubmvc.dto.cart;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record AddToCartForm(
        @NotBlank String eventCode,
        @NotBlank String ticketTypeCode,
        @NotNull @Min(1) Integer qty
) {}
