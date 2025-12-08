package com.hopecare.controller;

import com.hopecare.model.Delivery;
import com.hopecare.service.BeneficiaryService;
import com.hopecare.service.DeliveryService;
import com.hopecare.service.ProgramService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Delivery Controller
 * Handles delivery operations
 */
@Controller
@RequestMapping("/deliveries")
public class DeliveryController {

    @Autowired
    private DeliveryService deliveryService;

    @Autowired
    private BeneficiaryService beneficiaryService;

    @Autowired
    private ProgramService programService;

    /**
     * Show deliveries page
     */
    @GetMapping
    public String deliveriesPage(Model model) {
        try {
            List<Delivery> deliveries = deliveryService.getAllDeliveries();
            model.addAttribute("deliveries", deliveries);
            model.addAttribute("beneficiaries", beneficiaryService.getAllBeneficiaries());
            model.addAttribute("programs", programService.getAllPrograms());
            model.addAttribute("inventory", deliveryService.getInventoryStatus());
        } catch (Exception e) {
            model.addAttribute("error", "Error loading deliveries: " + e.getMessage());
        }
        return "deliveries";
    }

    /**
     * Get all deliveries (AJAX)
     */
    @GetMapping("/api/list")
    @ResponseBody
    public ResponseEntity<?> getAllDeliveries() {
        try {
            List<Delivery> deliveries = deliveryService.getAllDeliveries();
            return ResponseEntity.ok(deliveries);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse(e.getMessage()));
        }
    }

    /**
     * Get inventory status (AJAX)
     */
    @GetMapping("/api/inventory")
    @ResponseBody
    public ResponseEntity<?> getInventoryStatus() {
        try {
            List<Map<String, Object>> inventory = deliveryService.getInventoryStatus();
            return ResponseEntity.ok(inventory);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse(e.getMessage()));
        }
    }

    /**
     * Perform delivery (AJAX)
     */
    @PostMapping("/api/perform")
    @ResponseBody
    public ResponseEntity<?> performDelivery(@RequestBody Map<String, Object> request) {
        try {
            Long beneficiaryId = Long.valueOf(request.get("beneficiaryId").toString());
            Long programId = Long.valueOf(request.get("programId").toString());
            String productDescription = request.get("productDescription").toString();
            Integer quantity = Integer.valueOf(request.get("quantity").toString());
            String notes = request.get("notes") != null ? request.get("notes").toString() : "";
            Long createdBy = 2L; // Default to assistant

            Long deliveryId = deliveryService.performDelivery(
                    beneficiaryId, programId, productDescription, quantity, notes, createdBy);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Delivery performed successfully");
            response.put("deliveryId", deliveryId);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            // Check if it's a stock validation error from PL/SQL
            String errorMessage = e.getMessage();
            if (errorMessage != null && errorMessage.contains("Insufficient stock")) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(createErrorResponse(errorMessage));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Error performing delivery: " + errorMessage));
        }
    }

    /**
     * Helper method to create error response
     */
    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> error = new HashMap<>();
        error.put("success", false);
        error.put("message", message);
        return error;
    }
}