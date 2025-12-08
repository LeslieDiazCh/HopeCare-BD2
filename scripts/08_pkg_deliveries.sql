-- ================================================================
-- HOPECARE PROJECT - 08_PKG_BENEFICIARIES.SQL
-- Package for beneficiary management
-- ================================================================

-- ============================================================
-- PACKAGE SPECIFICATION
-- ============================================================

CREATE OR REPLACE PACKAGE pkg_beneficiaries AS
    
    -- Register a new beneficiary
    PROCEDURE register_beneficiary(
        p_full_name IN VARCHAR2,
        p_family_size IN NUMBER,
        p_phone IN VARCHAR2,
        p_address IN VARCHAR2,
        p_district IN VARCHAR2,
        p_city IN VARCHAR2,
        p_notes IN VARCHAR2,
        p_beneficiary_id OUT NUMBER
    );
    
    -- Update beneficiary information
    PROCEDURE update_beneficiary(
        p_beneficiary_id IN NUMBER,
        p_full_name IN VARCHAR2,
        p_family_size IN NUMBER,
        p_phone IN VARCHAR2,
        p_address IN VARCHAR2,
        p_district IN VARCHAR2,
        p_city IN VARCHAR2,
        p_notes IN VARCHAR2
    );
    
    -- Deactivate a beneficiary
    PROCEDURE deactivate_beneficiary(
        p_beneficiary_id IN NUMBER
    );
    
    -- Search beneficiaries by name or code
    PROCEDURE search_beneficiaries(
        p_search_term IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    );
    
    -- Get all active beneficiaries
    PROCEDURE get_all_beneficiaries(
        p_cursor OUT SYS_REFCURSOR
    );
    
    -- Get beneficiary details by ID
    PROCEDURE get_beneficiary_by_id(
        p_beneficiary_id IN NUMBER,
        p_cursor OUT SYS_REFCURSOR
    );
    
    -- Get beneficiaries by district
    PROCEDURE get_beneficiaries_by_district(
        p_district IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    );
    
END pkg_beneficiaries;
/

PROMPT 'Package specification created: PKG_BENEFICIARIES';

-- ============================================================
-- PACKAGE BODY
-- ============================================================

CREATE OR REPLACE PACKAGE BODY pkg_beneficiaries AS

    -- ========================================================
    -- Register a new beneficiary
    -- ========================================================
    PROCEDURE register_beneficiary(
        p_full_name IN VARCHAR2,
        p_family_size IN NUMBER,
        p_phone IN VARCHAR2,
        p_address IN VARCHAR2,
        p_district IN VARCHAR2,
        p_city IN VARCHAR2,
        p_notes IN VARCHAR2,
        p_beneficiary_id OUT NUMBER
    ) IS
        v_beneficiary_code VARCHAR2(20);
    BEGIN
        -- Validate inputs
        IF p_full_name IS NULL OR TRIM(p_full_name) = '' THEN
            RAISE_APPLICATION_ERROR(-20301, 'Beneficiary name is required');
        END IF;
        
        IF p_address IS NULL OR TRIM(p_address) = '' THEN
            RAISE_APPLICATION_ERROR(-20302, 'Address is required');
        END IF;
        
        IF p_family_size IS NOT NULL AND p_family_size < 1 THEN
            RAISE_APPLICATION_ERROR(-20303, 'Family size must be at least 1');
        END IF;
        
        -- Generate beneficiary code
        v_beneficiary_code := 'BEN' || LPAD(seq_beneficiaries.NEXTVAL, 3, '0');
        
        -- Insert beneficiary
        INSERT INTO tbl_beneficiaries (
            beneficiary_id,
            beneficiary_code,
            full_name,
            family_size,
            phone,
            address,
            district,
            city,
            notes,
            is_active,
            created_at,
            updated_at
        ) VALUES (
            seq_beneficiaries.CURRVAL,
            v_beneficiary_code,
            TRIM(p_full_name),
            NVL(p_family_size, 1),
            p_phone,
            TRIM(p_address),
            p_district,
            p_city,
            p_notes,
            'Y',
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        ) RETURNING beneficiary_id INTO p_beneficiary_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Beneficiary registered successfully!');
        DBMS_OUTPUT.PUT_LINE('Beneficiary ID: ' || p_beneficiary_id);
        DBMS_OUTPUT.PUT_LINE('Beneficiary Code: ' || v_beneficiary_code);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20304, 'Error registering beneficiary: ' || SQLERRM);
    END register_beneficiary;

    -- ========================================================
    -- Update beneficiary information
    -- ========================================================
    PROCEDURE update_beneficiary(
        p_beneficiary_id IN NUMBER,
        p_full_name IN VARCHAR2,
        p_family_size IN NUMBER,
        p_phone IN VARCHAR2,
        p_address IN VARCHAR2,
        p_district IN VARCHAR2,
        p_city IN VARCHAR2,
        p_notes IN VARCHAR2
    ) IS
        v_beneficiary_exists NUMBER;
    BEGIN
        -- Validate beneficiary exists
        SELECT COUNT(*) INTO v_beneficiary_exists
        FROM tbl_beneficiaries
        WHERE beneficiary_id = p_beneficiary_id AND is_active = 'Y';
        
        IF v_beneficiary_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20305, 'Beneficiary not found or inactive');
        END IF;
        
        -- Validate inputs
        IF p_full_name IS NULL OR TRIM(p_full_name) = '' THEN
            RAISE_APPLICATION_ERROR(-20301, 'Beneficiary name is required');
        END IF;
        
        IF p_address IS NULL OR TRIM(p_address) = '' THEN
            RAISE_APPLICATION_ERROR(-20302, 'Address is required');
        END IF;
        
        IF p_family_size IS NOT NULL AND p_family_size < 1 THEN
            RAISE_APPLICATION_ERROR(-20303, 'Family size must be at least 1');
        END IF;
        
        -- Update beneficiary
        UPDATE tbl_beneficiaries
        SET full_name = TRIM(p_full_name),
            family_size = NVL(p_family_size, 1),
            phone = p_phone,
            address = TRIM(p_address),
            district = p_district,
            city = p_city,
            notes = p_notes,
            updated_at = CURRENT_TIMESTAMP
        WHERE beneficiary_id = p_beneficiary_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Beneficiary updated successfully!');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20306, 'Error updating beneficiary: ' || SQLERRM);
    END update_beneficiary;

    -- ========================================================
    -- Deactivate a beneficiary
    -- ========================================================
    PROCEDURE deactivate_beneficiary(
        p_beneficiary_id IN NUMBER
    ) IS
        v_beneficiary_exists NUMBER;
    BEGIN
        -- Validate beneficiary exists
        SELECT COUNT(*) INTO v_beneficiary_exists
        FROM tbl_beneficiaries
        WHERE beneficiary_id = p_beneficiary_id AND is_active = 'Y';
        
        IF v_beneficiary_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20305, 'Beneficiary not found or already inactive');
        END IF;
        
        -- Deactivate beneficiary
        UPDATE tbl_beneficiaries
        SET is_active = 'N',
            updated_at = CURRENT_TIMESTAMP
        WHERE beneficiary_id = p_beneficiary_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Beneficiary deactivated successfully!');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20307, 'Error deactivating beneficiary: ' || SQLERRM);
    END deactivate_beneficiary;

    -- ========================================================
    -- Search beneficiaries by name or code
    -- ========================================================
    PROCEDURE search_beneficiaries(
        p_search_term IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                beneficiary_id,
                beneficiary_code,
                full_name,
                family_size,
                phone,
                address,
                district,
                city,
                notes,
                created_at,
                (SELECT COUNT(*) FROM tbl_deliveries WHERE beneficiary_id = b.beneficiary_id) AS total_deliveries
            FROM tbl_beneficiaries b
            WHERE is_active = 'Y'
            AND (
                UPPER(full_name) LIKE '%' || UPPER(p_search_term) || '%'
                OR UPPER(beneficiary_code) LIKE '%' || UPPER(p_search_term) || '%'
                OR UPPER(district) LIKE '%' || UPPER(p_search_term) || '%'
            )
            ORDER BY full_name;
    END search_beneficiaries;

    -- ========================================================
    -- Get all active beneficiaries
    -- ========================================================
    PROCEDURE get_all_beneficiaries(
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                beneficiary_id,
                beneficiary_code,
                full_name,
                family_size,
                phone,
                address,
                district,
                city,
                notes,
                created_at,
                (SELECT COUNT(*) FROM tbl_deliveries WHERE beneficiary_id = b.beneficiary_id) AS total_deliveries,
                (SELECT MAX(delivery_date) FROM tbl_deliveries WHERE beneficiary_id = b.beneficiary_id) AS last_delivery_date
            FROM tbl_beneficiaries b
            WHERE is_active = 'Y'
            ORDER BY full_name;
    END get_all_beneficiaries;

    -- ========================================================
    -- Get beneficiary details by ID
    -- ========================================================
    PROCEDURE get_beneficiary_by_id(
        p_beneficiary_id IN NUMBER,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                b.beneficiary_id,
                b.beneficiary_code,
                b.full_name,
                b.family_size,
                b.phone,
                b.address,
                b.district,
                b.city,
                b.notes,
                b.is_active,
                b.created_at,
                b.updated_at,
                (SELECT COUNT(*) FROM tbl_deliveries WHERE beneficiary_id = b.beneficiary_id) AS total_deliveries,
                (SELECT MAX(delivery_date) FROM tbl_deliveries WHERE beneficiary_id = b.beneficiary_id) AS last_delivery_date,
                (SELECT SUM(total_value) FROM tbl_deliveries WHERE beneficiary_id = b.beneficiary_id AND status = 'COMPLETED') AS total_value_received
            FROM tbl_beneficiaries b
            WHERE b.beneficiary_id = p_beneficiary_id;
    END get_beneficiary_by_id;

    -- ========================================================
    -- Get beneficiaries by district
    -- ========================================================
    PROCEDURE get_beneficiaries_by_district(
        p_district IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                beneficiary_id,
                beneficiary_code,
                full_name,
                family_size,
                phone,
                address,
                district,
                city,
                (SELECT COUNT(*) FROM tbl_deliveries WHERE beneficiary_id = b.beneficiary_id) AS total_deliveries
            FROM tbl_beneficiaries b
            WHERE is_active = 'Y'
            AND UPPER(district) = UPPER(p_district)
            ORDER BY full_name;
    END get_beneficiaries_by_district;

END pkg_beneficiaries;
/

PROMPT 'Package body created: PKG_BENEFICIARIES';

-- ============================================================
-- SUCCESS MESSAGE
-- ============================================================

BEGIN
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('PKG_BENEFICIARIES CREATED SUCCESSFULLY!');
  DBMS_OUTPUT.PUT_LINE('Procedures:');
  DBMS_OUTPUT.PUT_LINE('  - register_beneficiary');
  DBMS_OUTPUT.PUT_LINE('  - update_beneficiary');
  DBMS_OUTPUT.PUT_LINE('  - deactivate_beneficiary');
  DBMS_OUTPUT.PUT_LINE('  - search_beneficiaries');
  DBMS_OUTPUT.PUT_LINE('  - get_all_beneficiaries');
  DBMS_OUTPUT.PUT_LINE('  - get_beneficiary_by_id');
  DBMS_OUTPUT.PUT_LINE('  - get_beneficiaries_by_district');
  DBMS_OUTPUT.PUT_LINE('========================================');
END;
/