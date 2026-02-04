package es.daw.eventhubmvc.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public record PageInfo(
        int size,
        long totalElements,
        int totalPages,
        int number
) {}

