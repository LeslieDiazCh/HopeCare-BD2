-- ================================================================
-- HOPECARE PROJECT - 07_PKG_DONORS.SQL
-- Package for donor management
-- ================================================================

-- ============================================================
-- PACKAGE SPECIFICATION
-- ============================================================

CREATE OR REPLACE PACKAGE pkg_donors AS
    
    -- Register a new donor
    PROCEDURE register_donor(
        p_full_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone IN VARCHAR2,
        p_donor_type IN VARCHAR2,
        p_address IN VARCHAR2,
        p_donor_id OUT NUMBER
    );
    
    -- Update donor information
    PROCEDURE update_donor(
        p_donor_id IN NUMBER,
        p_full_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone IN VARCHAR2,
        p_address IN VARCHAR2
    );
    
    -- Deactivate a donor
    PROCEDURE deactivate_donor(
        p_donor_id IN NUMBER
    );
    
    -- Search donors by name or code
    PROCEDURE search_donors(
        p_search_term IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    );
    
    -- Get all active donors
    PROCEDURE get_all_donors(
        p_cursor OUT SYS_REFCURSOR
    );
    
    -- Get donor details by ID
    PROCEDURE get_donor_by_id(
        p_donor_id IN NUMBER,
        p_cursor OUT SYS_REFCURSOR
    );
    
END pkg_donors;
/

PROMPT 'Package specification created: PKG_DONORS';

-- ============================================================
-- PACKAGE BODY
-- ============================================================

CREATE OR REPLACE PACKAGE BODY pkg_donors AS

    -- ========================================================
    -- Register a new donor
    -- ========================================================
    PROCEDURE register_donor(
        p_full_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone IN VARCHAR2,
        p_donor_type IN VARCHAR2,
        p_address IN VARCHAR2,
        p_donor_id OUT NUMBER
    ) IS
        v_donor_code VARCHAR2(20);
        v_email_exists NUMBER;
    BEGIN
        -- Validate inputs
        IF p_full_name IS NULL OR TRIM(p_full_name) = '' THEN
            RAISE_APPLICATION_ERROR(-20201, 'Donor name is required');
        END IF;
        
        IF p_donor_type NOT IN ('INDIVIDUAL', 'CORPORATE', 'GOVERNMENT') THEN
            RAISE_APPLICATION_ERROR(-20202, 'Invalid donor type. Must be: INDIVIDUAL, CORPORATE, or GOVERNMENT');
        END IF;
        
        -- Check if email already exists (if provided)
        IF p_email IS NOT NULL THEN
            SELECT COUNT(*) INTO v_email_exists
            FROM tbl_donors
            WHERE UPPER(email) = UPPER(p_email)
            AND is_active = 'Y';
            
            IF v_email_exists > 0 THEN
                RAISE_APPLICATION_ERROR(-20203, 'Email already exists for another active donor');
            END IF;
        END IF;
        
        -- Generate donor code
        v_donor_code := 'DON' || LPAD(seq_donors.NEXTVAL, 3, '0');
        
        -- Insert donor
        INSERT INTO tbl_donors (
            donor_id,
            donor_code,
            full_name,
            email,
            phone,
            donor_type,
            address,
            is_active,
            created_at,
            updated_at
        ) VALUES (
            seq_donors.CURRVAL,
            v_donor_code,
            TRIM(p_full_name),
            p_email,
            p_phone,
            p_donor_type,
            p_address,
            'Y',
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        ) RETURNING donor_id INTO p_donor_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Donor registered successfully!');
        DBMS_OUTPUT.PUT_LINE('Donor ID: ' || p_donor_id);
        DBMS_OUTPUT.PUT_LINE('Donor Code: ' || v_donor_code);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20204, 'Error registering donor: ' || SQLERRM);
    END register_donor;

    -- ========================================================
    -- Update donor information
    -- ========================================================
    PROCEDURE update_donor(
        p_donor_id IN NUMBER,
        p_full_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone IN VARCHAR2,
        p_address IN VARCHAR2
    ) IS
        v_donor_exists NUMBER;
        v_email_exists NUMBER;
    BEGIN
        -- Validate donor exists
        SELECT COUNT(*) INTO v_donor_exists
        FROM tbl_donors
        WHERE donor_id = p_donor_id AND is_active = 'Y';
        
        IF v_donor_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20205, 'Donor not found or inactive');
        END IF;
        
        -- Validate inputs
        IF p_full_name IS NULL OR TRIM(p_full_name) = '' THEN
            RAISE_APPLICATION_ERROR(-20201, 'Donor name is required');
        END IF;
        
        -- Check if email already exists for another donor
        IF p_email IS NOT NULL THEN
            SELECT COUNT(*) INTO v_email_exists
            FROM tbl_donors
            WHERE UPPER(email) = UPPER(p_email)
            AND donor_id != p_donor_id
            AND is_active = 'Y';
            
            IF v_email_exists > 0 THEN
                RAISE_APPLICATION_ERROR(-20203, 'Email already exists for another donor');
            END IF;
        END IF;
        
        -- Update donor
        UPDATE tbl_donors
        SET full_name = TRIM(p_full_name),
            email = p_email,
            phone = p_phone,
            address = p_address,
            updated_at = CURRENT_TIMESTAMP
        WHERE donor_id = p_donor_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Donor updated successfully!');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20206, 'Error updating donor: ' || SQLERRM);
    END update_donor;

    -- ========================================================
    -- Deactivate a donor
    -- ========================================================
    PROCEDURE deactivate_donor(
        p_donor_id IN NUMBER
    ) IS
        v_donor_exists NUMBER;
    BEGIN
        -- Validate donor exists
        SELECT COUNT(*) INTO v_donor_exists
        FROM tbl_donors
        WHERE donor_id = p_donor_id AND is_active = 'Y';
        
        IF v_donor_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20205, 'Donor not found or already inactive');
        END IF;
        
        -- Deactivate donor
        UPDATE tbl_donors
        SET is_active = 'N',
            updated_at = CURRENT_TIMESTAMP
        WHERE donor_id = p_donor_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Donor deactivated successfully!');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20207, 'Error deactivating donor: ' || SQLERRM);
    END deactivate_donor;

    -- ========================================================
    -- Search donors by name or code
    -- ========================================================
    PROCEDURE search_donors(
        p_search_term IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                donor_id,
                donor_code,
                full_name,
                email,
                phone,
                donor_type,
                address,
                created_at,
                (SELECT COUNT(*) FROM tbl_donations WHERE donor_id = d.donor_id) AS total_donations
            FROM tbl_donors d
            WHERE is_active = 'Y'
            AND (
                UPPER(full_name) LIKE '%' || UPPER(p_search_term) || '%'
                OR UPPER(donor_code) LIKE '%' || UPPER(p_search_term) || '%'
                OR UPPER(email) LIKE '%' || UPPER(p_search_term) || '%'
            )
            ORDER BY full_name;
    END search_donors;

    -- ========================================================
    -- Get all active donors
    -- ========================================================
    PROCEDURE get_all_donors(
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                donor_id,
                donor_code,
                full_name,
                email,
                phone,
                donor_type,
                address,
                created_at,
                (SELECT COUNT(*) FROM tbl_donations WHERE donor_id = d.donor_id) AS total_donations,
                (SELECT MAX(donation_date) FROM tbl_donations WHERE donor_id = d.donor_id) AS last_donation_date
            FROM tbl_donors d
            WHERE is_active = 'Y'
            ORDER BY full_name;
    END get_all_donors;

    -- ========================================================
    -- Get donor details by ID
    -- ========================================================
    PROCEDURE get_donor_by_id(
        p_donor_id IN NUMBER,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                d.donor_id,
                d.donor_code,
                d.full_name,
                d.email,
                d.phone,
                d.donor_type,
                d.address,
                d.is_active,
                d.created_at,
                d.updated_at,
                (SELECT COUNT(*) FROM tbl_donations WHERE donor_id = d.donor_id) AS total_donations,
                (SELECT MAX(donation_date) FROM tbl_donations WHERE donor_id = d.donor_id) AS last_donation_date,
                pkg_donations.get_donor_total_contributions(d.donor_id) AS total_contributions_pen
            FROM tbl_donors d
            WHERE d.donor_id = p_donor_id;
    END get_donor_by_id;

END pkg_donors;
/

PROMPT 'Package body created: PKG_DONORS';

-- ============================================================
-- SUCCESS MESSAGE
-- ============================================================

BEGIN
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('PKG_DONORS CREATED SUCCESSFULLY!');
  DBMS_OUTPUT.PUT_LINE('Procedures:');
  DBMS_OUTPUT.PUT_LINE('  - register_donor');
  DBMS_OUTPUT.PUT_LINE('  - update_donor');
  DBMS_OUTPUT.PUT_LINE('  - deactivate_donor');
  DBMS_OUTPUT.PUT_LINE('  - search_donors');
  DBMS_OUTPUT.PUT_LINE('  - get_all_donors');
  DBMS_OUTPUT.PUT_LINE('  - get_donor_by_id');
  DBMS_OUTPUT.PUT_LINE('========================================');
END;
/