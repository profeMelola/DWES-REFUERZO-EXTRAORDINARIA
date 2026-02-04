package es.daw.clinicaapi.mapper;

import es.daw.clinicaapi.dto.response.invoice.InvoiceLineResponse;
import es.daw.clinicaapi.dto.response.invoice.InvoiceResponse;
import es.daw.clinicaapi.entity.Invoice;
import es.daw.clinicaapi.entity.InvoiceLine;

public final class InvoiceMapper {

    private InvoiceMapper() {}

    public static InvoiceResponse toResponse(Invoice inv) {

        return new InvoiceResponse(

        );
    }

    public static InvoiceLineResponse toLineResponse(InvoiceLine l) {
        return new InvoiceLineResponse(

        );
    }
}
