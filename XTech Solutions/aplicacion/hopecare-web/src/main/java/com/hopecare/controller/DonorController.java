package com.hopecare.controller;

import com.hopecare.model.Donor;
import com.hopecare.service.DonorService;
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
 * Donor Controller
 * Handles donor management operations
 */
@Controller
@RequestMapping("/donors")
public class DonorController {

    @Autowired
    private DonorService donorService;

    /**
     * Show donors page
     */
    @GetMapping
    public String donorsPage(Model model) {
        try {
            List<Donor> donors = donorService.getAllDonors();
            model.addAttribute("donors", donors);
        } catch (Exception e) {
            model.addAttribute("error", "Error loading donors: " + e.getMessage());
        }
        return "donors";
    }

    /**
     * Get all donors (AJAX)
     */
    @GetMapping("/api/list")
    @ResponseBody
    public ResponseEntity<?> getAllDonors() {
        try {
            List<Donor> donors = donorService.getAllDonors();
            return ResponseEntity.ok(donors);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse(e.getMessage()));
        }
    }

    /**
     * Get donor by ID (AJAX)
     */
    @GetMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<?> getDonorById(@PathVariable Long id) {
        try {
            Donor donor = donorService.getDonorById(id);
            if (donor == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(createErrorResponse("Donor not found"));
            }
            return ResponseEntity.ok(donor);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse(e.getMessage()));
        }
    }

    /**
     * Register new donor (AJAX)
     */
    @PostMapping("/api/register")
    @ResponseBody
    public ResponseEntity<?> registerDonor(@RequestBody Donor donor) {
        try {
            Long donorId = donorService.registerDonor(donor);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Donor registered successfully");
            response.put("donorId", donorId);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Error registering donor: " + e.getMessage()));
        }
    }

    /**
     * Update donor (AJAX)
     */
    @PutMapping("/api/update")
    @ResponseBody
    public ResponseEntity<?> updateDonor(@RequestBody Donor donor) {
        try {
            donorService.updateDonor(donor);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Donor updated successfully");
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Error updating donor: " + e.getMessage()));
        }
    }

    /**
     * Search donors (AJAX)
     */
    @GetMapping("/api/search")
    @ResponseBody
    public ResponseEntity<?> searchDonors(@RequestParam String term) {
        try {
            List<Donor> donors = donorService.searchDonors(term);
            return ResponseEntity.ok(donors);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse(e.getMessage()));
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