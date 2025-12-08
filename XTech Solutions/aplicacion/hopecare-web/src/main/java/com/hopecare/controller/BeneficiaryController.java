package com.hopecare.controller;

import com.hopecare.model.Beneficiary;
import com.hopecare.service.BeneficiaryService;
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
 * Beneficiary Controller
 * Handles beneficiary management operations
 */
@Controller
@RequestMapping("/beneficiaries")
public class BeneficiaryController {

    @Autowired
    private BeneficiaryService beneficiaryService;

    /**
     * Show beneficiaries page
     */
    @GetMapping
    public String beneficiariesPage(Model model) {
        try {
            List<Beneficiary> beneficiaries = beneficiaryService.getAllBeneficiaries();
            model.addAttribute("beneficiaries", beneficiaries);
        } catch (Exception e) {
            model.addAttribute("error", "Error loading beneficiaries: " + e.getMessage());
        }
        return "beneficiaries";
    }

    /**
     * Get all beneficiaries (AJAX)
     */
    @GetMapping("/api/list")
    @ResponseBody
    public ResponseEntity<?> getAllBeneficiaries() {
        try {
            List<Beneficiary> beneficiaries = beneficiaryService.getAllBeneficiaries();
            return ResponseEntity.ok(beneficiaries);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse(e.getMessage()));
        }
    }

    /**
     * Get beneficiary by ID (AJAX)
     */
    @GetMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<?> getBeneficiaryById(@PathVariable Long id) {
        try {
            Beneficiary beneficiary = beneficiaryService.getBeneficiaryById(id);
            if (beneficiary == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(createErrorResponse("Beneficiary not found"));
            }
            return ResponseEntity.ok(beneficiary);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse(e.getMessage()));
        }
    }

    /**
     * Register new beneficiary (AJAX)
     */
    @PostMapping("/api/register")
    @ResponseBody
    public ResponseEntity<?> registerBeneficiary(@RequestBody Beneficiary beneficiary) {
        try {
            Long beneficiaryId = beneficiaryService.registerBeneficiary(beneficiary);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Beneficiary registered successfully");
            response.put("beneficiaryId", beneficiaryId);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Error registering beneficiary: " + e.getMessage()));
        }
    }

    /**
     * Update beneficiary (AJAX)
     */
    @PutMapping("/api/update")
    @ResponseBody
    public ResponseEntity<?> updateBeneficiary(@RequestBody Beneficiary beneficiary) {
        try {
            beneficiaryService.updateBeneficiary(beneficiary);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Beneficiary updated successfully");
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Error updating beneficiary: " + e.getMessage()));
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