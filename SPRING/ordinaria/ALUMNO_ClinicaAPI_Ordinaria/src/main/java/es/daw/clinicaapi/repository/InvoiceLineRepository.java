package es.daw.clinicaapi.repository;

import es.daw.clinicaapi.dto.report.TopServiceReport;
import es.daw.clinicaapi.entity.InvoiceLine;
import es.daw.clinicaapi.enums.InvoiceStatus;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.List;

public interface InvoiceLineRepository extends JpaRepository<InvoiceLine, Long> {

    @Query("""
    select l
    from InvoiceLine l
    """)
    List<TopServiceReport> topServicesByIssuedAt(
            LocalDateTime from,
            LocalDateTime to,
            InvoiceStatus status,
            Pageable pageable
    );


}