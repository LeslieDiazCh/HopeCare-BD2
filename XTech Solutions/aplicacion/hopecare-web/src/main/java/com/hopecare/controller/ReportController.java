package com.hopecare.controller;

import com.hopecare.service.DeliveryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.Map;

/**
 * Report Controller
 * Handles reporting and analytics
 */
@Controller
@RequestMapping("/reports")
public class ReportController {

    @Autowired
    private DeliveryService deliveryService;

    /**
     * Show reports page
     */
    @GetMapping
    public String reportsPage(Model model) {
        try {
            Map<String, Object> metrics = deliveryService.getDashboardMetrics();
            model.addAttribute("metrics", metrics);
            model.addAttribute("inventory", deliveryService.getInventoryStatus());
        } catch (Exception e) {
            model.addAttribute("error", "Error loading reports: " + e.getMessage());
        }
        return "reports";
    }

    /**
     * Get dashboard metrics (AJAX)
     */
    @GetMapping("/api/dashboard")
    @ResponseBody
    public ResponseEntity<?> getDashboardMetrics() {
        try {
            Map<String, Object> metrics = deliveryService.getDashboardMetrics();
            return ResponseEntity.ok(metrics);
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