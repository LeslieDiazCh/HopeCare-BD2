package com.hopecare.service;

import com.hopecare.model.Delivery;
import com.hopecare.repository.DatabaseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * Delivery Service
 * Business logic for delivery management
 */
@Service
public class DeliveryService {

    @Autowired
    private DatabaseRepository repository;

    /**
     * Get all deliveries
     */
    public List<Delivery> getAllDeliveries() {
        return repository.getAllDeliveries();
    }

    /**
     * Get inventory status
     */
    public List<Map<String, Object>> getInventoryStatus() {
        return repository.getInventoryStatus();
    }

    /**
     * Get dashboard metrics
     */
    public Map<String, Object> getDashboardMetrics() {
        return repository.getDashboardMetrics();
    }

    /**
     * Perform delivery to beneficiary
     */
    public Long performDelivery(Long beneficiaryId, Long programId, 
                               String productDescription, Integer quantity,
                               String notes, Long createdBy) {
        // Validate inputs
        if (beneficiaryId == null || beneficiaryId <= 0) {
            throw new IllegalArgumentException("Valid beneficiary is required");
        }
        if (programId == null || programId <= 0) {
            throw new IllegalArgumentException("Program is required");
        }
        if (productDescription == null || productDescription.trim().isEmpty()) {
            throw new IllegalArgumentException("Product description is required");
        }
        if (quantity == null || quantity <= 0) {
            throw new IllegalArgumentException("Quantity must be greater than zero");
        }
        if (createdBy == null || createdBy <= 0) {
            createdBy = 2L; // Default to assistant user
        }

        // Repository will call PL/SQL which validates stock availability
        return repository.performDelivery(beneficiaryId, programId, 
                                         productDescription, quantity, 
                                         notes, createdBy);
    }
}