package com.hopecare.controller;

import com.hopecare.model.User;
import com.hopecare.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpSession;

/**
 * Login Controller
 * Handles login/logout
 */
@Controller
public class LoginController {

    @Autowired
    private AuthService authService;

    /**
     * Show login page
     */
    @GetMapping("/login")
    public String showLoginPage(HttpSession session, Model model) {
        // Si ya hay sesión, redirigir a home
        User user = (User) session.getAttribute("user");
        if (user != null) {
            return "redirect:/";
        }
        return "login";
    }

    /**
     * Process login
     */
    @PostMapping("/login")
    public String processLogin(
            @RequestParam("username") String username,
            @RequestParam("password") String password,
            HttpSession session,
            Model model) {
        
        System.out.println("📝 Login attempt: " + username);
        
        // Validar usuario
        User user = authService.authenticate(username, password);
        
        if (user != null) {
            // Crear sesión
            session.setAttribute("user", user);
            System.out.println("✅ Session created for: " + user.getFullName());
            return "redirect:/";
        } else {
            // Login fallido
            model.addAttribute("error", "Invalid username or password");
            System.out.println("❌ Login failed");
            return "login";
        }
    }

    /**
     * Logout
     */
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        System.out.println("🚪 User logged out");
        return "redirect:/login";
    }
}