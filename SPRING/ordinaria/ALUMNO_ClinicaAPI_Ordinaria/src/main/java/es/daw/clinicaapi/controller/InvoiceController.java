package es.daw.clinicaapi.controller;

import es.daw.clinicaapi.dto.request.invoice.InvoiceIssueRequest;
import es.daw.clinicaapi.dto.response.invoice.InvoiceResponse;
import es.daw.clinicaapi.service.InvoiceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
public class InvoiceController {

    private final InvoiceService invoiceService;

    public ResponseEntity<InvoiceResponse> issueInvoice(
            Long appointmentId,
            InvoiceIssueRequest request
    ) {
        InvoiceResponse created = invoiceService.issueInvoiceForAppointment(appointmentId, request);
        return null;
    }
}
