package es.daw.eventhubmvc.exception;

public class ConnectionApiRestException
        extends RuntimeException{
    public ConnectionApiRestException(String message){
        super(message);
    }
}
