package com.hopecare.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Donation Entity
 * Represents a donation (money or product)
 */
public class Donation {
    private Long donationId;
    private String donationCode;
    private Long donorId;
    private Long donationTypeId;
    private LocalDate donationDate;
    
    // Money donation fields
    private Double amount;
    private Long currencyId;
    
    // Product donation fields
    private String productDescription;
    private Integer quantity;
    private Double unitValue;
    
    private String notes;
    private Long createdBy;
    private LocalDateTime createdAt;
    
    // Join fields (from view)
    private String donorCode;
    private String donorName;
    private String donorType;
    private String donationTypeName;
    private String currencyCode;
    private String currencySymbol;
    private Double amountInPen;
    private String programCode;
    private String programName;
    private String createdByName;

    // Constructors
    public Donation() {}

    public Donation(Long donationId, String donationCode, Long donorId, 
                    Long donationTypeId, LocalDate donationDate) {
        this.donationId = donationId;
        this.donationCode = donationCode;
        this.donorId = donorId;
        this.donationTypeId = donationTypeId;
        this.donationDate = donationDate;
    }

    // Getters and Setters
    public Long getDonationId() { return donationId; }
    public void setDonationId(Long donationId) { this.donationId = donationId; }

    public String getDonationCode() { return donationCode; }
    public void setDonationCode(String donationCode) { this.donationCode = donationCode; }

    public Long getDonorId() { return donorId; }
    public void setDonorId(Long donorId) { this.donorId = donorId; }

    public Long getDonationTypeId() { return donationTypeId; }
    public void setDonationTypeId(Long donationTypeId) { this.donationTypeId = donationTypeId; }

    public LocalDate getDonationDate() { return donationDate; }
    public void setDonationDate(LocalDate donationDate) { this.donationDate = donationDate; }

    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }

    public Long getCurrencyId() { return currencyId; }
    public void setCurrencyId(Long currencyId) { this.currencyId = currencyId; }

    public String getProductDescription() { return productDescription; }
    public void setProductDescription(String productDescription) { 
        this.productDescription = productDescription; 
    }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public Double getUnitValue() { return unitValue; }
    public void setUnitValue(Double unitValue) { this.unitValue = unitValue; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Long getCreatedBy() { return createdBy; }
    public void setCreatedBy(Long createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    // Join fields getters/setters
    public String getDonorCode() { return donorCode; }
    public void setDonorCode(String donorCode) { this.donorCode = donorCode; }

    public String getDonorName() { return donorName; }
    public void setDonorName(String donorName) { this.donorName = donorName; }

    public String getDonorType() { return donorType; }
    public void setDonorType(String donorType) { this.donorType = donorType; }

    public String getDonationTypeName() { return donationTypeName; }
    public void setDonationTypeName(String donationTypeName) { 
        this.donationTypeName = donationTypeName; 
    }

    public String getCurrencyCode() { return currencyCode; }
    public void setCurrencyCode(String currencyCode) { this.currencyCode = currencyCode; }

    public String getCurrencySymbol() { return currencySymbol; }
    public void setCurrencySymbol(String currencySymbol) { this.currencySymbol = currencySymbol; }

    public Double getAmountInPen() { return amountInPen; }
    public void setAmountInPen(Double amountInPen) { this.amountInPen = amountInPen; }

    public String getProgramCode() { return programCode; }
    public void setProgramCode(String programCode) { this.programCode = programCode; }

    public String getProgramName() { return programName; }
    public void setProgramName(String programName) { this.programName = programName; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }
}