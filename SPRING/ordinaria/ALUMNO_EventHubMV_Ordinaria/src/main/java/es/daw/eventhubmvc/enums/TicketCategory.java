package es.daw.eventhubmvc.enums;

import lombok.Getter;

@Getter
public enum TicketCategory {

    GENERAL("General", 10),
    VIP("VIP", 4),
    STUDENT("Student", 2);

    private final String label;
    private final int maxPerPurchase;

    TicketCategory(String label, int maxPerPurchase) {
        this.label = label;
        this.maxPerPurchase = maxPerPurchase;
    }
}
