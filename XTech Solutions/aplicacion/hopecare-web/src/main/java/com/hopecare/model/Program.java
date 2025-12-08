package com.hopecare.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Program Entity
 * Represents a social program
 */
public class Program {
    private Long programId;
    private String programCode;
    private String programName;
    private String description;
    private String programType;
    private LocalDate startDate;
    private LocalDate endDate;
    private String isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Statistics (from view)
    private Integer totalDonationsReceived;
    private Double totalDonationValuePen;
    private Integer totalDeliveriesMade;
    private Double totalDeliveryValuePen;
    private Integer uniqueBeneficiariesServed;
    private Integer inventoryItems;

    // Constructors
    public Program() {}

    public Program(Long programId, String programCode, String programName,
                   String description, String programType, LocalDate startDate) {
        this.programId = programId;
        this.programCode = programCode;
        this.programName = programName;
        this.description = description;
        this.programType = programType;
        this.startDate = startDate;
        this.isActive = "Y";
    }

    // Getters and Setters
    public Long getProgramId() { return programId; }
    public void setProgramId(Long programId) { this.programId = programId; }

    public String getProgramCode() { return programCode; }
    public void setProgramCode(String programCode) { this.programCode = programCode; }

    public String getProgramName() { return programName; }
    public void setProgramName(String programName) { this.programName = programName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getProgramType() { return programType; }
    public void setProgramType(String programType) { this.programType = programType; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }

    public String getIsActive() { return isActive; }
    public void setIsActive(String isActive) { this.isActive = isActive; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Integer getTotalDonationsReceived() { return totalDonationsReceived; }
    public void setTotalDonationsReceived(Integer totalDonationsReceived) { 
        this.totalDonationsReceived = totalDonationsReceived; 
    }

    public Double getTotalDonationValuePen() { return totalDonationValuePen; }
    public void setTotalDonationValuePen(Double totalDonationValuePen) { 
        this.totalDonationValuePen = totalDonationValuePen; 
    }

    public Integer getTotalDeliveriesMade() { return totalDeliveriesMade; }
    public void setTotalDeliveriesMade(Integer totalDeliveriesMade) { 
        this.totalDeliveriesMade = totalDeliveriesMade; 
    }

    public Double getTotalDeliveryValuePen() { return totalDeliveryValuePen; }
    public void setTotalDeliveryValuePen(Double totalDeliveryValuePen) { 
        this.totalDeliveryValuePen = totalDeliveryValuePen; 
    }

    public Integer getUniqueBeneficiariesServed() { return uniqueBeneficiariesServed; }
    public void setUniqueBeneficiariesServed(Integer uniqueBeneficiariesServed) { 
        this.uniqueBeneficiariesServed = uniqueBeneficiariesServed; 
    }

    public Integer getInventoryItems() { return inventoryItems; }
    public void setInventoryItems(Integer inventoryItems) { this.inventoryItems = inventoryItems; }
}