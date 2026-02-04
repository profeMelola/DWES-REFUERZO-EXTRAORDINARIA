package es.daw.eventhubmvc.exception;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ConnectionApiRestException.class)
    public String handleConnectApiRestException(ConnectionApiRestException e, Model model){
        model.addAttribute("errorMessage", e.getMessage());
        return "api-error";
    }


    /*
        @ExceptionHandler(WebClientRequestException.class)
    public String handleWebClientRequestException(WebClientRequestException e, Model model) {
        String mapping = e.getUri().getPath();

        String detalle = e.getMostSpecificCause().getMessage();

        String mensajeCompleto = String.format(
                "No se pudo conectar con %s del API DATA REST. Detalle: %s",
                mapping, detalle
        );

        model.addAttribute("errorMessage", mensajeCompleto);
        return "api-error";
    }
        */
}
