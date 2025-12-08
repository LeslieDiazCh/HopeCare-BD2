package com.hopecare.model;

import java.time.LocalDateTime;

/**
 * Donor Entity
 * Represents a donor in the system
 */
public class Donor {
    private Long donorId;
    private String donorCode;
    private String fullName;
    private String email;
    private String phone;
    private String donorType; // INDIVIDUAL, CORPORATE, GOVERNMENT
    private String address;
    private String isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Statistics (from view)
    private Integer totalDonations;
    private Double totalValuePen;
    private LocalDateTime lastDonationDate;

    // Constructors
    public Donor() {}

    public Donor(Long donorId, String donorCode, String fullName, String email, 
                 String phone, String donorType, String address) {
        this.donorId = donorId;
        this.donorCode = donorCode;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.donorType = donorType;
        this.address = address;
        this.isActive = "Y";
    }

    // Getters and Setters
    public Long getDonorId() { return donorId; }
    public void setDonorId(Long donorId) { this.donorId = donorId; }

    public String getDonorCode() { return donorCode; }
    public void setDonorCode(String donorCode) { this.donorCode = donorCode; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getDonorType() { return donorType; }
    public void setDonorType(String donorType) { this.donorType = donorType; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getIsActive() { return isActive; }
    public void setIsActive(String isActive) { this.isActive = isActive; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Integer getTotalDonations() { return totalDonations; }
    public void setTotalDonations(Integer totalDonations) { this.totalDonations = totalDonations; }

    public Double getTotalValuePen() { return totalValuePen; }
    public void setTotalValuePen(Double totalValuePen) { this.totalValuePen = totalValuePen; }

    public LocalDateTime getLastDonationDate() { return lastDonationDate; }
    public void setLastDonationDate(LocalDateTime lastDonationDate) { this.lastDonationDate = lastDonationDate; }
}