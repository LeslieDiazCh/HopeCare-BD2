package com.hopecare.service;

import com.hopecare.model.Donation;
import com.hopecare.repository.DatabaseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * Donation Service
 * Business logic for donation management
 */
@Service
public class DonationService {

    @Autowired
    private DatabaseRepository repository;

    /**
     * Get all donations
     */
    public List<Donation> getAllDonations() {
        return repository.getAllDonations();
    }

    /**
     * Get available currencies
     */
    public List<Map<String, Object>> getCurrencies() {
        return repository.getCurrencies();
    }

    /**
     * Register money donation
     */
    public Long registerMoneyDonation(Long donorId, Double amount, Long currencyId,
                                      Long programId, String notes, Long createdBy) {
        // Validate inputs
        if (donorId == null || donorId <= 0) {
            throw new IllegalArgumentException("Valid donor is required");
        }
        if (amount == null || amount <= 0) {
            throw new IllegalArgumentException("Amount must be greater than zero");
        }
        if (currencyId == null || currencyId <= 0) {
            throw new IllegalArgumentException("Currency is required");
        }
        if (programId == null || programId <= 0) {
            throw new IllegalArgumentException("Program is required");
        }
        if (createdBy == null || createdBy <= 0) {
            createdBy = 1L; // Default to admin user
        }

        return repository.registerMoneyDonation(donorId, amount, currencyId, 
                                                programId, notes, createdBy);
    }

    /**
     * Register product donation
     */
    public Long registerProductDonation(Long donorId, String productDescription,
                                        Integer quantity, Double unitValue,
                                        Long programId, String notes, Long createdBy) {
        // Validate inputs
        if (donorId == null || donorId <= 0) {
            throw new IllegalArgumentException("Valid donor is required");
        }
        if (productDescription == null || productDescription.trim().isEmpty()) {
            throw new IllegalArgumentException("Product description is required");
        }
        if (quantity == null || quantity <= 0) {
            throw new IllegalArgumentException("Quantity must be greater than zero");
        }
        if (programId == null || programId <= 0) {
            throw new IllegalArgumentException("Program is required");
        }
        if (createdBy == null || createdBy <= 0) {
            createdBy = 1L; // Default to admin user
        }

        return repository.registerProductDonation(donorId, productDescription, 
                                                  quantity, unitValue, programId, 
                                                  notes, createdBy);
    }
}