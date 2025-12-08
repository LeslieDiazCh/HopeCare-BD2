package com.hopecare.config;

import com.hopecare.model.User;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Security Interceptor
 * Controls access based on user roles
 */
@Component
public class SecurityInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {

        String requestPath = request.getRequestURI();
        HttpSession session = request.getSession(false);

        System.out.println("🔒 Security Check: " + requestPath);

        // URLs públicas (sin protección)
        if (requestPath.contains("/login") || 
            requestPath.contains("/css/") || 
            requestPath.contains("/js/") ||
            requestPath.contains("/images/")) {
            System.out.println("   ✅ Public URL - Access granted");
            return true;
        }

        // Verificar sesión activa
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (user == null) {
            System.out.println("   ❌ No session - Redirect to login");
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }

        System.out.println("   👤 User: " + user.getUsername() + " (" + user.getRoleName() + ")");

        // URLs SOLO para ADMIN
        String[] adminOnlyPaths = {"/donors", "/beneficiaries", "/programs"};
        
        for (String adminPath : adminOnlyPaths) {
            if (requestPath.contains(adminPath)) {
                if (!"Administrator".equals(user.getRoleName())) {
                    System.out.println("   ❌ FORBIDDEN: Assistant trying to access ADMIN area");
                    response.sendRedirect(request.getContextPath() + "/");
                    return false;
                }
            }
        }

        System.out.println("   ✅ Access granted");
        return true;
    }
}