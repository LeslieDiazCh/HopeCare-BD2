package com.hopecare.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Delivery Entity
 * Represents a delivery to a beneficiary
 */
public class Delivery {
    private Long deliveryId;
    private String deliveryCode;
    private Long beneficiaryId;
    private Long programId;
    private LocalDate deliveryDate;
    private String productDescription;
    private Integer quantityDelivered;
    private Double unitValue;
    private Double totalValue;
    private String status; // PENDING, COMPLETED, CANCELLED
    private String notes;
    private Long createdBy;
    private Long approvedBy;
    private LocalDateTime createdAt;
    
    // Join fields (from view)
    private String beneficiaryCode;
    private String beneficiaryName;
    private Integer familySize;
    private String district;
    private String city;
    private String programCode;
    private String programName;
    private String programType;
    private String createdByName;
    private String approvedByName;

    // Constructors
    public Delivery() {}

    public Delivery(Long deliveryId, String deliveryCode, Long beneficiaryId,
                    Long programId, LocalDate deliveryDate, String productDescription,
                    Integer quantityDelivered, Double totalValue) {
        this.deliveryId = deliveryId;
        this.deliveryCode = deliveryCode;
        this.beneficiaryId = beneficiaryId;
        this.programId = programId;
        this.deliveryDate = deliveryDate;
        this.productDescription = productDescription;
        this.quantityDelivered = quantityDelivered;
        this.totalValue = totalValue;
        this.status = "COMPLETED";
    }

    // Getters and Setters
    public Long getDeliveryId() { return deliveryId; }
    public void setDeliveryId(Long deliveryId) { this.deliveryId = deliveryId; }

    public String getDeliveryCode() { return deliveryCode; }
    public void setDeliveryCode(String deliveryCode) { this.deliveryCode = deliveryCode; }

    public Long getBeneficiaryId() { return beneficiaryId; }
    public void setBeneficiaryId(Long beneficiaryId) { this.beneficiaryId = beneficiaryId; }

    public Long getProgramId() { return programId; }
    public void setProgramId(Long programId) { this.programId = programId; }

    public LocalDate getDeliveryDate() { return deliveryDate; }
    public void setDeliveryDate(LocalDate deliveryDate) { this.deliveryDate = deliveryDate; }

    public String getProductDescription() { return productDescription; }
    public void setProductDescription(String productDescription) { 
        this.productDescription = productDescription; 
    }

    public Integer getQuantityDelivered() { return quantityDelivered; }
    public void setQuantityDelivered(Integer quantityDelivered) { 
        this.quantityDelivered = quantityDelivered; 
    }

    public Double getUnitValue() { return unitValue; }
    public void setUnitValue(Double unitValue) { this.unitValue = unitValue; }

    public Double getTotalValue() { return totalValue; }
    public void setTotalValue(Double totalValue) { this.totalValue = totalValue; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Long getCreatedBy() { return createdBy; }
    public void setCreatedBy(Long createdBy) { this.createdBy = createdBy; }

    public Long getApprovedBy() { return approvedBy; }
    public void setApprovedBy(Long approvedBy) { this.approvedBy = approvedBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    // Join fields getters/setters
    public String getBeneficiaryCode() { return beneficiaryCode; }
    public void setBeneficiaryCode(String beneficiaryCode) { 
        this.beneficiaryCode = beneficiaryCode; 
    }

    public String getBeneficiaryName() { return beneficiaryName; }
    public void setBeneficiaryName(String beneficiaryName) { 
        this.beneficiaryName = beneficiaryName; 
    }

    public Integer getFamilySize() { return familySize; }
    public void setFamilySize(Integer familySize) { this.familySize = familySize; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getProgramCode() { return programCode; }
    public void setProgramCode(String programCode) { this.programCode = programCode; }

    public String getProgramName() { return programName; }
    public void setProgramName(String programName) { this.programName = programName; }

    public String getProgramType() { return programType; }
    public void setProgramType(String programType) { this.programType = programType; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

    public String getApprovedByName() { return approvedByName; }
    public void setApprovedByName(String approvedByName) { 
        this.approvedByName = approvedByName; 
    }
}