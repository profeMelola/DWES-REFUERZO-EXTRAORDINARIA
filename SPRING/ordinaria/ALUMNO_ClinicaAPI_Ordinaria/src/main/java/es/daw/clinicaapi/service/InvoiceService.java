package es.daw.clinicaapi.service;

import es.daw.clinicaapi.dto.request.invoice.InvoiceIssueRequest;
import es.daw.clinicaapi.dto.response.invoice.InvoiceResponse;
import es.daw.clinicaapi.mapper.InvoiceMapper;



public class InvoiceService {


    public InvoiceResponse issueInvoiceForAppointment(Long appointmentId, InvoiceIssueRequest req) {


        return InvoiceMapper.toResponse(null);

    }


}
