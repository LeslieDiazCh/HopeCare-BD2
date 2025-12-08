-- ================================================================
-- HOPECARE PROJECT - 02_TABLES.SQL
-- Creates all database tables with sequences
-- ================================================================

-- ============================================================
-- SEQUENCES (Auto-increment IDs)
-- ============================================================

CREATE SEQUENCE seq_currencies START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_donation_types START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_roles START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_donors START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_beneficiaries START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_programs START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_donations START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_deliveries START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_users START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_exchange_rates START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_program_inventory START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_donation_assignments START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_audit_donations START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_audit_deliveries START WITH 1 INCREMENT BY 1;

PROMPT 'Sequences created successfully';

-- ============================================================
-- CATALOG TABLES
-- ============================================================

-- Currencies (PEN, USD, EUR)
CREATE TABLE tbl_currencies (
    currency_id NUMBER PRIMARY KEY,
    currency_code VARCHAR2(3) NOT NULL UNIQUE,
    currency_name VARCHAR2(50) NOT NULL,
    symbol VARCHAR2(5),
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y','N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Donation types (Money, Product)
CREATE TABLE tbl_donation_types (
    donation_type_id NUMBER PRIMARY KEY,
    type_code VARCHAR2(20) NOT NULL UNIQUE,
    type_name VARCHAR2(50) NOT NULL,
    description VARCHAR2(200),
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y','N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User roles (Admin, Assistant)
CREATE TABLE tbl_roles (
    role_id NUMBER PRIMARY KEY,
    role_code VARCHAR2(20) NOT NULL UNIQUE,
    role_name VARCHAR2(50) NOT NULL,
    description VARCHAR2(200),
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y','N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

PROMPT 'Catalog tables created successfully';

-- ============================================================
-- CORE OPERATIONAL TABLES
-- ============================================================

-- Donors (individuals, companies, organizations)
CREATE TABLE tbl_donors (
    donor_id NUMBER PRIMARY KEY,
    donor_code VARCHAR2(20) NOT NULL UNIQUE,
    full_name VARCHAR2(200) NOT NULL,
    email VARCHAR2(100) UNIQUE,
    phone VARCHAR2(20),
    donor_type VARCHAR2(20) CHECK (donor_type IN ('INDIVIDUAL','CORPORATE','GOVERNMENT')),
    address VARCHAR2(300),
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y','N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Beneficiaries (families or individuals receiving help)
CREATE TABLE tbl_beneficiaries (
    beneficiary_id NUMBER PRIMARY KEY,
    beneficiary_code VARCHAR2(20) NOT NULL UNIQUE,
    full_name VARCHAR2(200) NOT NULL,
    family_size NUMBER DEFAULT 1,
    phone VARCHAR2(20),
    address VARCHAR2(300) NOT NULL,
    district VARCHAR2(100),
    city VARCHAR2(100),
    notes VARCHAR2(500),
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y','N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Social programs (Food Program, School Supplies, etc.)
CREATE TABLE tbl_programs (
    program_id NUMBER PRIMARY KEY,
    program_code VARCHAR2(20) NOT NULL UNIQUE,
    program_name VARCHAR2(100) NOT NULL,
    description VARCHAR2(500),
    program_type VARCHAR2(50), -- FOOD, EDUCATION, HEALTH, etc.
    start_date DATE DEFAULT SYSDATE,
    end_date DATE,
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y','N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users (system users: admin, assistants)
CREATE TABLE tbl_users (
    user_id NUMBER PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    password_hash VARCHAR2(200) NOT NULL,
    full_name VARCHAR2(200) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    role_id NUMBER NOT NULL,
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y','N')),
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES tbl_roles(role_id)
);

PROMPT 'Core operational tables created successfully';

-- ============================================================
-- DONATION MANAGEMENT TABLES
-- ============================================================

-- Exchange rates (for multi-currency support)
CREATE TABLE tbl_exchange_rates (
    exchange_rate_id NUMBER PRIMARY KEY,
    from_currency_id NUMBER NOT NULL,
    to_currency_id NUMBER NOT NULL,
    exchange_rate NUMBER(10,4) NOT NULL,
    effective_date DATE DEFAULT SYSDATE,
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y','N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_exrate_from_curr FOREIGN KEY (from_currency_id) REFERENCES tbl_currencies(currency_id),
    CONSTRAINT fk_exrate_to_curr FOREIGN KEY (to_currency_id) REFERENCES tbl_currencies(currency_id)
);

-- Donations (money or products)
CREATE TABLE tbl_donations (
    donation_id NUMBER PRIMARY KEY,
    donation_code VARCHAR2(20) NOT NULL UNIQUE,
    donor_id NUMBER NOT NULL,
    donation_type_id NUMBER NOT NULL,
    donation_date DATE DEFAULT SYSDATE,
    amount NUMBER(12,2),
    currency_id NUMBER,
    product_description VARCHAR2(300),
    quantity NUMBER,
    unit_value NUMBER(12,2),
    notes VARCHAR2(500),
    created_by NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_donations_donor FOREIGN KEY (donor_id) REFERENCES tbl_donors(donor_id),
    CONSTRAINT fk_donations_type FOREIGN KEY (donation_type_id) REFERENCES tbl_donation_types(donation_type_id),
    CONSTRAINT fk_donations_currency FOREIGN KEY (currency_id) REFERENCES tbl_currencies(currency_id),
    CONSTRAINT fk_donations_created_by FOREIGN KEY (created_by) REFERENCES tbl_users(user_id)
);

-- Donation assignments to programs
CREATE TABLE tbl_donation_assignments (
    assignment_id NUMBER PRIMARY KEY,
    donation_id NUMBER NOT NULL,
    program_id NUMBER NOT NULL,
    assigned_quantity NUMBER NOT NULL,
    assigned_value NUMBER(12,2),
    assigned_date DATE DEFAULT SYSDATE,
    assigned_by NUMBER NOT NULL,
    notes VARCHAR2(300),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_assign_donation FOREIGN KEY (donation_id) REFERENCES tbl_donations(donation_id),
    CONSTRAINT fk_assign_program FOREIGN KEY (program_id) REFERENCES tbl_programs(program_id),
    CONSTRAINT fk_assign_user FOREIGN KEY (assigned_by) REFERENCES tbl_users(user_id)
);

-- Program inventory (available resources per program)
CREATE TABLE tbl_program_inventory (
    inventory_id NUMBER PRIMARY KEY,
    program_id NUMBER NOT NULL,
    product_description VARCHAR2(300) NOT NULL,
    available_quantity NUMBER DEFAULT 0,
    reserved_quantity NUMBER DEFAULT 0,
    delivered_quantity NUMBER DEFAULT 0,
    unit_value NUMBER(12,2),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_program FOREIGN KEY (program_id) REFERENCES tbl_programs(program_id)
);

PROMPT 'Donation management tables created successfully';

-- ============================================================
-- DELIVERY MANAGEMENT TABLES
-- ============================================================

-- Deliveries (distribution to beneficiaries)
CREATE TABLE tbl_deliveries (
    delivery_id NUMBER PRIMARY KEY,
    delivery_code VARCHAR2(20) NOT NULL UNIQUE,
    beneficiary_id NUMBER NOT NULL,
    program_id NUMBER NOT NULL,
    delivery_date DATE DEFAULT SYSDATE,
    product_description VARCHAR2(300),
    quantity_delivered NUMBER NOT NULL,
    unit_value NUMBER(12,2),
    total_value NUMBER(12,2),
    status VARCHAR2(20) DEFAULT 'COMPLETED' CHECK (status IN ('PENDING','COMPLETED','CANCELLED')),
    notes VARCHAR2(500),
    created_by NUMBER NOT NULL,
    approved_by NUMBER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_delivery_beneficiary FOREIGN KEY (beneficiary_id) REFERENCES tbl_beneficiaries(beneficiary_id),
    CONSTRAINT fk_delivery_program FOREIGN KEY (program_id) REFERENCES tbl_programs(program_id),
    CONSTRAINT fk_delivery_created_by FOREIGN KEY (created_by) REFERENCES tbl_users(user_id),
    CONSTRAINT fk_delivery_approved_by FOREIGN KEY (approved_by) REFERENCES tbl_users(user_id)
);

PROMPT 'Delivery management tables created successfully';

-- ============================================================
-- AUDIT TABLES
-- ============================================================

-- Audit trail for donations
CREATE TABLE tbl_audit_donations (
    audit_id NUMBER PRIMARY KEY,
    donation_id NUMBER NOT NULL,
    action_type VARCHAR2(20) NOT NULL, -- INSERT, UPDATE, DELETE
    old_values VARCHAR2(1000),
    new_values VARCHAR2(1000),
    changed_by NUMBER,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_don_donation FOREIGN KEY (donation_id) REFERENCES tbl_donations(donation_id),
    CONSTRAINT fk_audit_don_user FOREIGN KEY (changed_by) REFERENCES tbl_users(user_id)
);

-- Audit trail for deliveries
CREATE TABLE tbl_audit_deliveries (
    audit_id NUMBER PRIMARY KEY,
    delivery_id NUMBER NOT NULL,
    action_type VARCHAR2(20) NOT NULL, -- INSERT, UPDATE, DELETE
    old_values VARCHAR2(1000),
    new_values VARCHAR2(1000),
    changed_by NUMBER,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_del_delivery FOREIGN KEY (delivery_id) REFERENCES tbl_deliveries(delivery_id),
    CONSTRAINT fk_audit_del_user FOREIGN KEY (changed_by) REFERENCES tbl_users(user_id)
);

PROMPT 'Audit tables created successfully';

-- ============================================================
-- SUCCESS MESSAGE
-- ============================================================

BEGIN
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('ALL TABLES CREATED SUCCESSFULLY!');
  DBMS_OUTPUT.PUT_LINE('Total: 14 tables + 14 sequences');
  DBMS_OUTPUT.PUT_LINE('========================================');
END;
/