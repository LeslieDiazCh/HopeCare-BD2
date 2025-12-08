package com.hopecare.service;

import com.hopecare.model.Beneficiary;
import com.hopecare.repository.DatabaseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Beneficiary Service
 * Business logic for beneficiary management
 */
@Service
public class BeneficiaryService {

    @Autowired
    private DatabaseRepository repository;

    /**
     * Get all active beneficiaries
     */
    public List<Beneficiary> getAllBeneficiaries() {
        return repository.getAllBeneficiaries();
    }

    /**
     * Get beneficiary by ID
     */
    public Beneficiary getBeneficiaryById(Long id) {
        return repository.getBeneficiaryById(id);
    }

    /**
     * Register new beneficiary
     */
    public Long registerBeneficiary(Beneficiary beneficiary) {
        validateBeneficiary(beneficiary);
        return repository.registerBeneficiary(beneficiary);
    }

    /**
     * Update existing beneficiary
     */
    public void updateBeneficiary(Beneficiary beneficiary) {
        validateBeneficiary(beneficiary);
        if (beneficiary.getBeneficiaryId() == null) {
            throw new IllegalArgumentException("Beneficiary ID is required for update");
        }
        repository.updateBeneficiary(beneficiary);
    }

    /**
     * Validate beneficiary data
     */
    private void validateBeneficiary(Beneficiary beneficiary) {
        if (beneficiary.getFullName() == null || beneficiary.getFullName().trim().isEmpty()) {
            throw new IllegalArgumentException("Beneficiary name is required");
        }
        if (beneficiary.getAddress() == null || beneficiary.getAddress().trim().isEmpty()) {
            throw new IllegalArgumentException("Address is required");
        }
        if (beneficiary.getFamilySize() != null && beneficiary.getFamilySize() < 1) {
            throw new IllegalArgumentException("Family size must be at least 1");
        }
    }
}    
