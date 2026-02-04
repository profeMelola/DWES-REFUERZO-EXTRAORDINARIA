package es.daw.eventhubmvc.service;

import es.daw.eventhubmvc.entity.Purchase;
import es.daw.eventhubmvc.entity.PurchaseLine;
import es.daw.eventhubmvc.model.Cart;
import es.daw.eventhubmvc.model.CartItem;
import es.daw.eventhubmvc.repository.PurchaseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class PurchaseService {

    private final PurchaseRepository purchaseRepository;

    @Transactional
    public Purchase createPurchaseFromCart(String username, Cart cart) {
        if (cart == null || cart.isEmpty()) {
            throw new IllegalArgumentException("Cart is empty");
        }

        Purchase purchase = Purchase.builder()
                .createdAt(LocalDateTime.now())
                .username(username)
                .totalAmount(BigDecimal.ZERO)
                .build();

        BigDecimal total = BigDecimal.ZERO;

        for (CartItem item : cart.getItems()) {
            BigDecimal lineTotal = item.lineTotal();

            PurchaseLine line = PurchaseLine.builder()
                    .ticketTypeCode(item.ticketTypeCode())
                    .ticketNameSnapshot(item.ticketName())
                    .unitPriceSnapshot(item.unitPrice())
                    .qty(item.qty())
                    .lineTotal(lineTotal)
                    .build();

            purchase.addLine(line);
            total = total.add(lineTotal);
        }

        purchase.setTotalAmount(total);
        return purchaseRepository.save(purchase);
    }
}

