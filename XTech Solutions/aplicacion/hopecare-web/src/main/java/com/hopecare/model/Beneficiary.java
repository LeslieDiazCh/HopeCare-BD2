package com.hopecare.model;

import java.time.LocalDateTime;

/**
 * Beneficiary Entity
 * Represents a beneficiary family/person
 */
public class Beneficiary {
    private Long beneficiaryId;
    private String beneficiaryCode;
    private String fullName;
    private Integer familySize;
    private String phone;
    private String address;
    private String district;
    private String city;
    private String notes;
    private String isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Statistics (from view)
    private Integer totalDeliveries;
    private Integer totalQuantityReceived;
    private Double totalValueReceivedPen;
    private LocalDateTime lastDeliveryDate;

    // Constructors
    public Beneficiary() {}

    public Beneficiary(Long beneficiaryId, String beneficiaryCode, String fullName,
                       Integer familySize, String phone, String address, 
                       String district, String city) {
        this.beneficiaryId = beneficiaryId;
        this.beneficiaryCode = beneficiaryCode;
        this.fullName = fullName;
        this.familySize = familySize;
        this.phone = phone;
        this.address = address;
        this.district = district;
        this.city = city;
        this.isActive = "Y";
    }

    // Getters and Setters
    public Long getBeneficiaryId() { return beneficiaryId; }
    public void setBeneficiaryId(Long beneficiaryId) { this.beneficiaryId = beneficiaryId; }

    public String getBeneficiaryCode() { return beneficiaryCode; }
    public void setBeneficiaryCode(String beneficiaryCode) { this.beneficiaryCode = beneficiaryCode; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public Integer getFamilySize() { return familySize; }
    public void setFamilySize(Integer familySize) { this.familySize = familySize; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getIsActive() { return isActive; }
    public void setIsActive(String isActive) { this.isActive = isActive; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Integer getTotalDeliveries() { return totalDeliveries; }
    public void setTotalDeliveries(Integer totalDeliveries) { this.totalDeliveries = totalDeliveries; }

    public Integer getTotalQuantityReceived() { return totalQuantityReceived; }
    public void setTotalQuantityReceived(Integer totalQuantityReceived) { 
        this.totalQuantityReceived = totalQuantityReceived; 
    }

    public Double getTotalValueReceivedPen() { return totalValueReceivedPen; }
    public void setTotalValueReceivedPen(Double totalValueReceivedPen) { 
        this.totalValueReceivedPen = totalValueReceivedPen; 
    }

    public LocalDateTime getLastDeliveryDate() { return lastDeliveryDate; }
    public void setLastDeliveryDate(LocalDateTime lastDeliveryDate) { 
        this.lastDeliveryDate = lastDeliveryDate; 
    }
}