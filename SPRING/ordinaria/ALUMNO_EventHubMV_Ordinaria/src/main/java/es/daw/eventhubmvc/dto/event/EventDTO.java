package es.daw.eventhubmvc.dto.event;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.time.LocalDateTime;


// Si en el JSON vienen campos que no existen en este DTO, ignóralos en lugar de lanzar una excepción
@JsonIgnoreProperties(ignoreUnknown = true)
public record EventDTO(
        String code,
        String title,
        String description,
        String category,
        LocalDateTime startDateTime,
        Boolean active
) {
        public String startDateTimeFormatted() {
                if (startDateTime == null) return "";
                return startDateTime.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
        }
}


