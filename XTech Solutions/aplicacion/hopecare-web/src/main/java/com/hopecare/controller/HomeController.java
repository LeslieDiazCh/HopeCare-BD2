package com.hopecare.controller;

import com.hopecare.model.User;
import com.hopecare.service.DeliveryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import jakarta.servlet.http.HttpSession;
import java.util.Map;

/**
 * Home Controller
 * Handles dashboard and main page
 */
@Controller
public class HomeController {

    @Autowired
    private DeliveryService deliveryService;

    /**
     * Dashboard / Home page
     */
    @GetMapping("/")
    public String index(Model model, HttpSession session) {
        try {
            // Get current user from session
            User user = (User) session.getAttribute("user");
            
            // Debug log
            if (user != null) {
                System.out.println("👤 Dashboard loaded by: " + user.getFullName() + " (" + user.getRoleName() + ")");
            }
            
            // Get dashboard metrics
            Map<String, Object> metrics = deliveryService.getDashboardMetrics();
            model.addAttribute("metrics", metrics);
            
        } catch (Exception e) {
            model.addAttribute("error", "Error loading dashboard: " + e.getMessage());
        }
        return "index";
    }
}