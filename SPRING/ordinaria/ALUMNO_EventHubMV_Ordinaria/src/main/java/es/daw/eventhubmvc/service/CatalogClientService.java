package es.daw.eventhubmvc.service;

import es.daw.eventhubmvc.dto.event.EventDTO;
import es.daw.eventhubmvc.dto.event.ResponseEvents;
import es.daw.eventhubmvc.dto.ticket.ResponseTicketTypes;
import es.daw.eventhubmvc.exception.ConnectionApiRestException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatusCode;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class CatalogClientService {

    private final WebClient catalogWebClient;

    public ResponseEvents listEvents(int page, int size, String sort, String dir) {
        return catalogWebClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/events")
                        .queryParam("page", page)
                        .queryParam("size", size)
                        .queryParam("sort", sort + "," + dir)
                        .build())
                .retrieve()
                .onStatus(HttpStatusCode::isError, resp ->
                        resp.bodyToMono(String.class).defaultIfEmpty("")
                                .flatMap(body -> Mono.error(new ConnectionApiRestException("Catalog error: " + resp.statusCode() + " " + body)))
                )
                .bodyToMono(ResponseEvents.class)
                .onErrorMap(ex -> {
                    if (ex instanceof ConnectionApiRestException) return ex;
                    return new ConnectionApiRestException("No se pudo conectar con /events del API DATA REST. Detalle: " + ex.getMessage());
                })
                .block();
    }

    //public ResponseEvents findEventsByLocationCode(String locationCode, int page, int size) {
    public ResponseEvents findEventsByLocationCode(String locationCode, int page, int size, String sort, String dir) {
        return catalogWebClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/events/search/findByLocationCode")
                        .queryParam("locationCode", locationCode)
                        .queryParam("page", page)
                        .queryParam("size", size)
                        .queryParam("sort", sort + "," + dir)
                        .build())
                .retrieve()
                .onStatus(HttpStatusCode::isError, resp ->
                        resp.bodyToMono(String.class).defaultIfEmpty("")
                                .flatMap(body -> Mono.error(new ConnectionApiRestException("Catalog error: " + resp.statusCode() + " " + body)))
                )
                .bodyToMono(ResponseEvents.class)
                .onErrorMap(ex -> {
                    if (ex instanceof ConnectionApiRestException) return ex;
                    return new ConnectionApiRestException("No se pudo conectar con /events/search/findByLocationCode del API DATA REST. Detalle: " + ex.getMessage());
                })
                .block();
    }

    public EventDTO findEventByCode(String eventCode) {
        // GET http://localhost:8081/api/events/search/findByCode?code=EVT_MAD_MUSIC_JAZZ
        EventDTO event = catalogWebClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/events/search/findByCode")
                        .queryParam("code", eventCode)
                        .build())
                .retrieve()
                .onStatus(HttpStatusCode::isError, r ->
                        r.bodyToMono(String.class).defaultIfEmpty("")
                                .flatMap(body -> Mono.error(new ConnectionApiRestException("Catalog error: " + r.statusCode() + " " + body)))
                )
                .bodyToMono(EventDTO.class)
                .onErrorMap(ex -> {
                    if (ex instanceof ConnectionApiRestException) return ex;
                    return new ConnectionApiRestException("No se pudo conectar con /events/search/findByCode del API DATA REST. Detalle: " + ex.getMessage());
                })
                .block();

        if (event == null) {
            throw new RuntimeException("Event not found by code: " + eventCode);
        }

        return event;


    }

    // EXAMEN: implementar el método findTicketTypesByEventCode
//    public ResponseTicketTypes findTicketTypesByEventCode(String eventCode, int page, int size) {
//        throw new UnsupportedOperationException("TODO: implement findTicketTypesByEventCode + DTOs de respuesta");
//    }

    public ResponseTicketTypes findTicketTypesByEventCode(String eventCode) {
    //public ResponseTicketTypes findTicketTypesByEventCode(String eventCode, int page, int size) {
        return catalogWebClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/ticketTypes/search/findByEventCode")
                        .queryParam("eventCode", eventCode)
                        .queryParam("page", 0)
                        .queryParam("size", 100)
                        .build())
                .retrieve()
                .onStatus(HttpStatusCode::isError, r ->
                        r.bodyToMono(String.class).defaultIfEmpty("")
                                .flatMap(body -> Mono.error(new ConnectionApiRestException("Catalog error: " + r.statusCode() + " " + body)))
                )
                .bodyToMono(ResponseTicketTypes.class)
                .onErrorMap(ex -> {
                    if (ex instanceof ConnectionApiRestException) return ex;
                    return new ConnectionApiRestException("No se pudo conectar con /ticketTypes/search/findByEventCode del API DATA REST. Detalle: " + ex.getMessage());
                })
                .block();
    }
}
