package es.daw.eventhubmvc.controller;

import es.daw.eventhubmvc.entity.Purchase;
import es.daw.eventhubmvc.repository.PurchaseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class PurchasesController {

    private final PurchaseRepository purchaseRepository;

    @GetMapping("/purchases")
    public String list(Authentication authentication, Model model) {

        List<Purchase> purchases =
                purchaseRepository.findByUsernameOrderByCreatedAtDesc(
                        authentication.getName()
                );

        model.addAttribute("purchases", purchases);
        return "purchases/list";
    }

    @GetMapping("/purchases/{id}")
    public String detail(
            @PathVariable Long id,
            Authentication authentication,
            Model model
    ) {

        Purchase purchase = purchaseRepository
                .findByIdAndUsername(id, authentication.getName())
                .orElseThrow(() ->
                        new RuntimeException("Purchase not found")
                );

        model.addAttribute("purchase", purchase);
        return "purchases/detail";
    }
}
