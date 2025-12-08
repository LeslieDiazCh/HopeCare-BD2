package com.hopecare.controller;

import com.hopecare.model.Donation;
import com.hopecare.service.DonationService;
import com.hopecare.service.DonorService;
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
 * Donation Controller
 * Handles donation operations
 */
@Controller
@RequestMapping("/donations")
public class DonationController {

    @Autowired
    private DonationService donationService;

    @Autowired
    private DonorService donorService;

    @Autowired
    private ProgramService programService;

    /**
     * Show donations page
     */
    @GetMapping
    public String donationsPage(Model model) {
        try {
            List<Donation> donations = donationService.getAllDonations();
            model.addAttribute("donations", donations);
            model.addAttribute("donors", donorService.getAllDonors());
            model.addAttribute("programs", programService.getAllPrograms());
            model.addAttribute("currencies", donationService.getCurrencies());
        } catch (Exception e) {
            model.addAttribute("error", "Error loading donations: " + e.getMessage());
        }
        return "donations";
    }

    /**
     * Get all donations (AJAX)
     */
    @GetMapping("/api/list")
    @ResponseBody
    public ResponseEntity<?> getAllDonations() {
        try {
            List<Donation> donations = donationService.getAllDonations();
            return ResponseEntity.ok(donations);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse(e.getMessage()));
        }
    }

    /**
     * Get currencies (AJAX)
     */
    @GetMapping("/api/currencies")
    @ResponseBody
    public ResponseEntity<?> getCurrencies() {
        try {
            List<Map<String, Object>> currencies = donationService.getCurrencies();
            return ResponseEntity.ok(currencies);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse(e.getMessage()));
        }
    }

    /**
     * Register money donation (AJAX)
     */
    @PostMapping("/api/money")
    @ResponseBody
    public ResponseEntity<?> registerMoneyDonation(@RequestBody Map<String, Object> request) {
        try {
            Long donorId = Long.valueOf(request.get("donorId").toString());
            Double amount = Double.valueOf(request.get("amount").toString());
            Long currencyId = Long.valueOf(request.get("currencyId").toString());
            Long programId = Long.valueOf(request.get("programId").toString());
            String notes = request.get("notes") != null ? request.get("notes").toString() : "";
            Long createdBy = 1L; // Default to admin

            Long donationId = donationService.registerMoneyDonation(
                    donorId, amount, currencyId, programId, notes, createdBy);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Money donation registered successfully");
            response.put("donationId", donationId);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Error registering money donation: " + e.getMessage()));
        }
    }

    /**
     * Register product donation (AJAX)
     */
    @PostMapping("/api/product")
    @ResponseBody
    public ResponseEntity<?> registerProductDonation(@RequestBody Map<String, Object> request) {
        try {
            Long donorId = Long.valueOf(request.get("donorId").toString());
            String productDescription = request.get("productDescription").toString();
            Integer quantity = Integer.valueOf(request.get("quantity").toString());
            Double unitValue = request.get("unitValue") != null ? 
                    Double.valueOf(request.get("unitValue").toString()) : 0.0;
            Long programId = Long.valueOf(request.get("programId").toString());
            String notes = request.get("notes") != null ? request.get("notes").toString() : "";
            Long createdBy = 1L; // Default to admin

            Long donationId = donationService.registerProductDonation(
                    donorId, productDescription, quantity, unitValue, programId, notes, createdBy);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Product donation registered successfully");
            response.put("donationId", donationId);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Error registering product donation: " + e.getMessage()));
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