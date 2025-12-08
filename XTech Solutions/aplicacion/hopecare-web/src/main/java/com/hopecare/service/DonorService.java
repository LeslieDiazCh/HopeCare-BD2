package com.hopecare.service;

import com.hopecare.model.Donor;
import com.hopecare.repository.DatabaseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Donor Service
 * Business logic for donor management
 */
@Service
public class DonorService {

    @Autowired
    private DatabaseRepository repository;

    /**
     * Get all active donors
     */
    public List<Donor> getAllDonors() {
        return repository.getAllDonors();
    }

    /**
     * Get donor by ID
     */
    public Donor getDonorById(Long id) {
        return repository.getDonorById(id);
    }

    /**
     * Register new donor
     */
    public Long registerDonor(Donor donor) {
        validateDonor(donor);
        return repository.registerDonor(donor);
    }

    /**
     * Update existing donor
     */
    public void updateDonor(Donor donor) {
        validateDonor(donor);
        if (donor.getDonorId() == null) {
            throw new IllegalArgumentException("Donor ID is required for update");
        }
        repository.updateDonor(donor);
    }

    /**
     * Search donors by term
     */
    public List<Donor> searchDonors(String searchTerm) {
        if (searchTerm == null || searchTerm.trim().isEmpty()) {
            return getAllDonors();
        }
        return repository.searchDonors(searchTerm);
    }

    /**
     * Validate donor data
     */
    private void validateDonor(Donor donor) {
        if (donor.getFullName() == null || donor.getFullName().trim().isEmpty()) {
            throw new IllegalArgumentException("Donor name is required");
        }
        if (donor.getDonorType() == null || donor.getDonorType().trim().isEmpty()) {
            throw new IllegalArgumentException("Donor type is required");
        }
        if (!donor.getDonorType().matches("INDIVIDUAL|CORPORATE|GOVERNMENT")) {
            throw new IllegalArgumentException("Invalid donor type. Must be: INDIVIDUAL, CORPORATE, or GOVERNMENT");
        }
    }
}