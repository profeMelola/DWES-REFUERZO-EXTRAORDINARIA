package es.daw.eventhubmvc.dto.ticket;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import es.daw.eventhubmvc.dto.PageInfo;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public record ResponseTicketTypes(
        @JsonProperty("_embedded") EmbeddedTicketTypes embedded,
        PageInfo page
) {
    public List<TicketTypeDTO> content() {
        return (embedded == null || embedded.ticketTypes() == null) ? List.of() : embedded.ticketTypes();
    }
}
