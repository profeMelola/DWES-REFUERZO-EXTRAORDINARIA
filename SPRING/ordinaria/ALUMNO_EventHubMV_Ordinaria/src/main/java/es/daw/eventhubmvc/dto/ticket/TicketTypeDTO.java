package es.daw.eventhubmvc.dto.ticket;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import es.daw.eventhubmvc.enums.TicketCategory;

import java.math.BigDecimal;

// Ignora capos que NO existen en el JSON
@JsonIgnoreProperties(ignoreUnknown = true)
public record TicketTypeDTO(
        String code,
        //String name,
        @JsonProperty("name") // En el Json existe un campo que se llama name y se mapea a category
        TicketCategory category,
        BigDecimal basePrice,
        Integer quota,
        String saleStart,
        String saleEnd
) {}

