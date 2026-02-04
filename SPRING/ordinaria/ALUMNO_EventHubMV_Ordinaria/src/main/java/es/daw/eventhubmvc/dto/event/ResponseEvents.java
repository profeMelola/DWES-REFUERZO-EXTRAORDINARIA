package es.daw.eventhubmvc.dto.event;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import es.daw.eventhubmvc.dto.PageInfo;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public record ResponseEvents(
        @JsonProperty("_embedded") EmbeddedEvents embedded,
        PageInfo page
) {
    public List<EventDTO> content() {
        return (embedded == null || embedded.events() == null) ? List.of() : embedded.events();
    }
}
