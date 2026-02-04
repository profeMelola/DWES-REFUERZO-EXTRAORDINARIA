package es.daw.eventhubmvc.dto.event;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public record EmbeddedEvents(List<EventDTO> events) { }

