package es.daw.eventhubmvc.dto.ticket;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public record EmbeddedTicketTypes(List<TicketTypeDTO> ticketTypes) {
}
