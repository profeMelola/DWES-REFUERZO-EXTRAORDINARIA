package es.daw.eventhubmvc.controller;

import es.daw.eventhubmvc.dto.cart.AddToCartForm;
import es.daw.eventhubmvc.entity.Purchase;
import es.daw.eventhubmvc.model.Cart;
import es.daw.eventhubmvc.model.CartItem;
import es.daw.eventhubmvc.service.CatalogClientService;
import es.daw.eventhubmvc.service.PurchaseService;
import es.daw.eventhubmvc.dto.ticket.TicketTypeDTO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class CartController {

    private final Cart cart;
    private final CatalogClientService catalogClientService;
    private final PurchaseService purchaseService;

    @GetMapping("/cart")
    public String view(Model model) {
        model.addAttribute("items", cart.getItems());
        model.addAttribute("total", cart.getTotal());
        return "cart/view";
    }

    @PostMapping("/cart/add")
    public String add(
            @Valid @ModelAttribute("addToCart") AddToCartForm form,
            RedirectAttributes ra
    ) {
        List<TicketTypeDTO> ticketTypes =
                catalogClientService.findTicketTypesByEventCode(form.eventCode())
                        .content();

        TicketTypeDTO ticketType = ticketTypes.stream()
                .filter(t -> form.ticketTypeCode().equals(t.code()))
                .findFirst()
                .orElse(null);

        BigDecimal unitPrice = ticketType.basePrice() != null
                ? ticketType.basePrice()
                : BigDecimal.ZERO;

        CartItem item = new CartItem(
                ticketType.code(),
                ticketType.category().name(),
                unitPrice,
                form.qty()
        );

        cart.addOrIncrement(item);

        return "redirect:/events/" + form.eventCode();
    }

    @PostMapping("/cart/update")
    public String update(
            @RequestParam String ticketTypeCode,
            @RequestParam int qty
    ) {
        cart.updateQty(ticketTypeCode, qty);
        return "redirect:/cart";
    }

    @PostMapping("/cart/remove")
    public String remove(@RequestParam String ticketTypeCode) {
        cart.remove(ticketTypeCode);
        return "redirect:/cart";
    }

    @PostMapping("/cart/checkout")
    public String checkout(Authentication authentication) {

        Purchase purchase = purchaseService
                .createPurchaseFromCart(authentication.getName(), cart);

        cart.clear();

        return "redirect:/purchases/" + purchase.getId();
    }
}
