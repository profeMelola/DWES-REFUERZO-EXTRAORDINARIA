package es.daw.eventhubmvc.model;

import org.springframework.stereotype.Component;
import org.springframework.web.context.annotation.SessionScope;

import java.math.BigDecimal;
import java.util.*;

@Component
@SessionScope
public class Cart {

    private final Map<String, CartItem> items = new LinkedHashMap<>();

    public Collection<CartItem> getItems() {
        return items.values();
    }

    public int getItemCount() {
        return items.values().stream().mapToInt(CartItem::qty).sum();
    }

    public BigDecimal getTotal() {
        return items.values().stream()
                .map(CartItem::lineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public boolean isEmpty() {
        return items.isEmpty();
    }

    public void clear() {
        items.clear();
    }

    public void addOrIncrement(CartItem incoming) {
        if (incoming == null || incoming.ticketTypeCode() == null) return;

        CartItem existing = items.get(incoming.ticketTypeCode());
        if (existing == null) {
            items.put(incoming.ticketTypeCode(), incoming);
        } else {
            items.put(incoming.ticketTypeCode(),
                    new CartItem(existing.ticketTypeCode(), existing.ticketName(), existing.unitPrice(), existing.qty() + incoming.qty()));
        }
    }

    public void updateQty(String ticketTypeCode, int qty) {
        CartItem existing = items.get(ticketTypeCode);
        if (existing == null) return;

        if (qty <= 0) {
            items.remove(ticketTypeCode);
        } else {
            items.put(ticketTypeCode, new CartItem(existing.ticketTypeCode(), existing.ticketName(), existing.unitPrice(), qty));
        }
    }

    public void remove(String ticketTypeCode) {
        items.remove(ticketTypeCode);
    }


}
