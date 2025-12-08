-- ================================================================
-- HOPECARE PROJECT - 09_PKG_PROGRAMS.SQL
-- Package for social program management
-- ================================================================

-- ============================================================
-- PACKAGE SPECIFICATION
-- ============================================================

CREATE OR REPLACE PACKAGE pkg_programs AS
    
    -- Create a new program
    PROCEDURE create_program(
        p_program_name IN VARCHAR2,
        p_description IN VARCHAR2,
        p_program_type IN VARCHAR2,
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_program_id OUT NUMBER
    );
    
    -- Update program information
    PROCEDURE update_program(
        p_program_id IN NUMBER,
        p_program_name IN VARCHAR2,
        p_description IN VARCHAR2,
        p_program_type IN VARCHAR2,
        p_start_date IN DATE,
        p_end_date IN DATE
    );
    
    -- Deactivate a program
    PROCEDURE deactivate_program(
        p_program_id IN NUMBER
    );
    
    -- Get all active programs
    PROCEDURE get_all_programs(
        p_cursor OUT SYS_REFCURSOR
    );
    
    -- Get program details by ID
    PROCEDURE get_program_by_id(
        p_program_id IN NUMBER,
        p_cursor OUT SYS_REFCURSOR
    );
    
    -- Get program statistics (donations, deliveries, inventory)
    PROCEDURE get_program_statistics(
        p_program_id IN NUMBER,
        p_cursor OUT SYS_REFCURSOR
    );
    
    -- Search programs by name or type
    PROCEDURE search_programs(
        p_search_term IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    );
    
END pkg_programs;
/

PROMPT 'Package specification created: PKG_PROGRAMS';

-- ============================================================
-- PACKAGE BODY
-- ============================================================

CREATE OR REPLACE PACKAGE BODY pkg_programs AS

    -- ========================================================
    -- Create a new program
    -- ========================================================
    PROCEDURE create_program(
        p_program_name IN VARCHAR2,
        p_description IN VARCHAR2,
        p_program_type IN VARCHAR2,
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_program_id OUT NUMBER
    ) IS
        v_program_code VARCHAR2(20);
    BEGIN
        -- Validate inputs
        IF p_program_name IS NULL OR TRIM(p_program_name) = '' THEN
            RAISE_APPLICATION_ERROR(-20401, 'Program name is required');
        END IF;
        
        IF p_end_date IS NOT NULL AND p_end_date < NVL(p_start_date, SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20402, 'End date cannot be before start date');
        END IF;
        
        -- Generate program code
        v_program_code := 'PROG' || LPAD(seq_programs.NEXTVAL, 3, '0');
        
        -- Insert program
        INSERT INTO tbl_programs (
            program_id,
            program_code,
            program_name,
            description,
            program_type,
            start_date,
            end_date,
            is_active,
            created_at,
            updated_at
        ) VALUES (
            seq_programs.CURRVAL,
            v_program_code,
            TRIM(p_program_name),
            p_description,
            p_program_type,
            NVL(p_start_date, SYSDATE),
            p_end_date,
            'Y',
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        ) RETURNING program_id INTO p_program_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Program created successfully!');
        DBMS_OUTPUT.PUT_LINE('Program ID: ' || p_program_id);
        DBMS_OUTPUT.PUT_LINE('Program Code: ' || v_program_code);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20403, 'Error creating program: ' || SQLERRM);
    END create_program;

    -- ========================================================
    -- Update program information
    -- ========================================================
    PROCEDURE update_program(
        p_program_id IN NUMBER,
        p_program_name IN VARCHAR2,
        p_description IN VARCHAR2,
        p_program_type IN VARCHAR2,
        p_start_date IN DATE,
        p_end_date IN DATE
    ) IS
        v_program_exists NUMBER;
    BEGIN
        -- Validate program exists
        SELECT COUNT(*) INTO v_program_exists
        FROM tbl_programs
        WHERE program_id = p_program_id AND is_active = 'Y';
        
        IF v_program_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20404, 'Program not found or inactive');
        END IF;
        
        -- Validate inputs
        IF p_program_name IS NULL OR TRIM(p_program_name) = '' THEN
            RAISE_APPLICATION_ERROR(-20401, 'Program name is required');
        END IF;
        
        IF p_end_date IS NOT NULL AND p_end_date < NVL(p_start_date, SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20402, 'End date cannot be before start date');
        END IF;
        
        -- Update program
        UPDATE tbl_programs
        SET program_name = TRIM(p_program_name),
            description = p_description,
            program_type = p_program_type,
            start_date = NVL(p_start_date, start_date),
            end_date = p_end_date,
            updated_at = CURRENT_TIMESTAMP
        WHERE program_id = p_program_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Program updated successfully!');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20405, 'Error updating program: ' || SQLERRM);
    END update_program;

    -- ========================================================
    -- Deactivate a program
    -- ========================================================
    PROCEDURE deactivate_program(
        p_program_id IN NUMBER
    ) IS
        v_program_exists NUMBER;
        v_active_deliveries NUMBER;
    BEGIN
        -- Validate program exists
        SELECT COUNT(*) INTO v_program_exists
        FROM tbl_programs
        WHERE program_id = p_program_id AND is_active = 'Y';
        
        IF v_program_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20404, 'Program not found or already inactive');
        END IF;
        
        -- Check for pending deliveries
        SELECT COUNT(*) INTO v_active_deliveries
        FROM tbl_deliveries
        WHERE program_id = p_program_id
        AND status = 'PENDING';
        
        IF v_active_deliveries > 0 THEN
            RAISE_APPLICATION_ERROR(-20406, 
                'Cannot deactivate program with pending deliveries (' || 
                v_active_deliveries || ' pending)');
        END IF;
        
        -- Deactivate program
        UPDATE tbl_programs
        SET is_active = 'N',
            updated_at = CURRENT_TIMESTAMP
        WHERE program_id = p_program_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Program deactivated successfully!');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20407, 'Error deactivating program: ' || SQLERRM);
    END deactivate_program;

    -- ========================================================
    -- Get all active programs
    -- ========================================================
    PROCEDURE get_all_programs(
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                program_id,
                program_code,
                program_name,
                description,
                program_type,
                start_date,
                end_date,
                created_at,
                (SELECT COUNT(*) FROM tbl_donation_assignments WHERE program_id = p.program_id) AS total_donations,
                (SELECT COUNT(*) FROM tbl_deliveries WHERE program_id = p.program_id) AS total_deliveries,
                (SELECT COUNT(*) FROM tbl_program_inventory WHERE program_id = p.program_id) AS inventory_items
            FROM tbl_programs p
            WHERE is_active = 'Y'
            ORDER BY program_code;
    END get_all_programs;

    -- ========================================================
    -- Get program details by ID
    -- ========================================================
    PROCEDURE get_program_by_id(
        p_program_id IN NUMBER,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                p.program_id,
                p.program_code,
                p.program_name,
                p.description,
                p.program_type,
                p.start_date,
                p.end_date,
                p.is_active,
                p.created_at,
                p.updated_at,
                (SELECT COUNT(*) FROM tbl_donation_assignments WHERE program_id = p.program_id) AS total_donations,
                (SELECT SUM(assigned_value) FROM tbl_donation_assignments WHERE program_id = p.program_id) AS total_donation_value,
                (SELECT COUNT(*) FROM tbl_deliveries WHERE program_id = p.program_id) AS total_deliveries,
                (SELECT SUM(total_value) FROM tbl_deliveries WHERE program_id = p.program_id AND status = 'COMPLETED') AS total_delivery_value,
                (SELECT COUNT(*) FROM tbl_program_inventory WHERE program_id = p.program_id) AS inventory_items
            FROM tbl_programs p
            WHERE p.program_id = p_program_id;
    END get_program_by_id;

    -- ========================================================
    -- Get program statistics
    -- ========================================================
    PROCEDURE get_program_statistics(
        p_program_id IN NUMBER,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                'Donations Received' AS metric,
                COUNT(*) AS count_value,
                SUM(da.assigned_value) AS total_value
            FROM tbl_donation_assignments da
            WHERE da.program_id = p_program_id
            
            UNION ALL
            
            SELECT 
                'Deliveries Made' AS metric,
                COUNT(*) AS count_value,
                SUM(d.total_value) AS total_value
            FROM tbl_deliveries d
            WHERE d.program_id = p_program_id
            AND d.status = 'COMPLETED'
            
            UNION ALL
            
            SELECT 
                'Unique Beneficiaries' AS metric,
                COUNT(DISTINCT d.beneficiary_id) AS count_value,
                NULL AS total_value
            FROM tbl_deliveries d
            WHERE d.program_id = p_program_id
            
            UNION ALL
            
            SELECT 
                'Inventory Items' AS metric,
                COUNT(*) AS count_value,
                SUM(i.available_quantity * NVL(i.unit_value, 0)) AS total_value
            FROM tbl_program_inventory i
            WHERE i.program_id = p_program_id;
    END get_program_statistics;

    -- ========================================================
    -- Search programs by name or type
    -- ========================================================
    PROCEDURE search_programs(
        p_search_term IN VARCHAR2,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                program_id,
                program_code,
                program_name,
                description,
                program_type,
                start_date,
                end_date,
                (SELECT COUNT(*) FROM tbl_donation_assignments WHERE program_id = p.program_id) AS total_donations,
                (SELECT COUNT(*) FROM tbl_deliveries WHERE program_id = p.program_id) AS total_deliveries
            FROM tbl_programs p
            WHERE is_active = 'Y'
            AND (
                UPPER(program_name) LIKE '%' || UPPER(p_search_term) || '%'
                OR UPPER(program_code) LIKE '%' || UPPER(p_search_term) || '%'
                OR UPPER(program_type) LIKE '%' || UPPER(p_search_term) || '%'
            )
            ORDER BY program_name;
    END search_programs;

END pkg_programs;
/

PROMPT 'Package body created: PKG_PROGRAMS';

-- ============================================================
-- SUCCESS MESSAGE
-- ============================================================

BEGIN
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('PKG_PROGRAMS CREATED SUCCESSFULLY!');
  DBMS_OUTPUT.PUT_LINE('Procedures:');
  DBMS_OUTPUT.PUT_LINE('  - create_program');
  DBMS_OUTPUT.PUT_LINE('  - update_program');
  DBMS_OUTPUT.PUT_LINE('  - deactivate_program');
  DBMS_OUTPUT.PUT_LINE('  - get_all_programs');
  DBMS_OUTPUT.PUT_LINE('  - get_program_by_id');
  DBMS_OUTPUT.PUT_LINE('  - get_program_statistics');
  DBMS_OUTPUT.PUT_LINE('  - search_programs');
  DBMS_OUTPUT.PUT_LINE('========================================');
END;
/