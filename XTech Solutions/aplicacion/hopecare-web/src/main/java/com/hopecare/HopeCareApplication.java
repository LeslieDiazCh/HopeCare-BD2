package com.hopecare;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * HopeCare Donation Management System
 * Main Application Class
 */
@SpringBootApplication
public class HopeCareApplication {

    public static void main(String[] args) {
        SpringApplication.run(HopeCareApplication.class, args);
        System.out.println("\n" +
            "========================================\n" +
            "  HopeCare System Started Successfully!\n" +
            "  Access at: http://localhost:8080/hopecare\n" +
            "========================================\n");
    }
}