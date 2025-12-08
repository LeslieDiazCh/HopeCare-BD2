-- ================================================================
-- HOPECARE PROJECT - 04_PKG_DONATIONS.SQL
-- Package for donation management and currency conversion
-- ================================================================

-- ============================================================
-- PACKAGE SPECIFICATION
-- ============================================================

CREATE OR REPLACE PACKAGE pkg_donations AS
    
    -- Register a monetary donation
    PROCEDURE register_money_donation(
        p_donor_id IN NUMBER,
        p_amount IN NUMBER,
        p_currency_id IN NUMBER,
        p_program_id IN NUMBER,
        p_notes IN VARCHAR2,
        p_created_by IN NUMBER,
        p_donation_id OUT NUMBER
    );
    
    -- Register a product donation
    PROCEDURE register_product_donation(
        p_donor_id IN NUMBER,
        p_product_description IN VARCHAR2,
        p_quantity IN NUMBER,
        p_unit_value IN NUMBER,
        p_program_id IN NUMBER,
        p_notes IN VARCHAR2,
        p_created_by IN NUMBER,
        p_donation_id OUT NUMBER
    );
    
    -- Convert currency to base currency (PEN)
    FUNCTION convert_to_base_currency(
        p_amount IN NUMBER,
        p_from_currency_id IN NUMBER
    ) RETURN NUMBER;
    
    -- Get donor's total contributions in PEN
    FUNCTION get_donor_total_contributions(
        p_donor_id IN NUMBER
    ) RETURN NUMBER;
    
    -- Get donation history for a donor
    PROCEDURE get_donor_history(
        p_donor_id IN NUMBER,
        p_cursor OUT SYS_REFCURSOR
    );
    
END pkg_donations;
/

PROMPT 'Package specification created: PKG_DONATIONS';

-- ============================================================
-- PACKAGE BODY
-- ============================================================

CREATE OR REPLACE PACKAGE BODY pkg_donations AS

    -- ========================================================
    -- Register a monetary donation
    -- ========================================================
    PROCEDURE register_money_donation(
        p_donor_id IN NUMBER,
        p_amount IN NUMBER,
        p_currency_id IN NUMBER,
        p_program_id IN NUMBER,
        p_notes IN VARCHAR2,
        p_created_by IN NUMBER,
        p_donation_id OUT NUMBER
    ) IS
        v_donation_code VARCHAR2(20);
        v_donation_type_id NUMBER;
        v_amount_pen NUMBER;
    BEGIN
        -- Validate donor exists
        DECLARE
            v_donor_exists NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_donor_exists
            FROM tbl_donors
            WHERE donor_id = p_donor_id AND is_active = 'Y';
            
            IF v_donor_exists = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Donor not found or inactive');
            END IF;
        END;
        
        -- Validate program exists
        DECLARE
            v_program_exists NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_program_exists
            FROM tbl_programs
            WHERE program_id = p_program_id AND is_active = 'Y';
            
            IF v_program_exists = 0 THEN
                RAISE_APPLICATION_ERROR(-20002, 'Program not found or inactive');
            END IF;
        END;
        
        -- Get donation type ID for MONEY
        SELECT donation_type_id INTO v_donation_type_id
        FROM tbl_donation_types
        WHERE type_code = 'MONEY';
        
        -- Generate donation code
        v_donation_code := 'DON-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || 
                          LPAD(seq_donations.CURRVAL + 1, 3, '0');
        
        -- Convert amount to PEN
        v_amount_pen := convert_to_base_currency(p_amount, p_currency_id);
        
        -- Insert donation
        INSERT INTO tbl_donations (
            donation_id,
            donation_code,
            donor_id,
            donation_type_id,
            donation_date,
            amount,
            currency_id,
            product_description,
            quantity,
            unit_value,
            notes,
            created_by,
            created_at
        ) VALUES (
            seq_donations.NEXTVAL,
            v_donation_code,
            p_donor_id,
            v_donation_type_id,
            SYSDATE,
            p_amount,
            p_currency_id,
            NULL,
            NULL,
            NULL,
            p_notes,
            p_created_by,
            CURRENT_TIMESTAMP
        ) RETURNING donation_id INTO p_donation_id;
        
        -- Assign donation to program
        INSERT INTO tbl_donation_assignments (
            assignment_id,
            donation_id,
            program_id,
            assigned_quantity,
            assigned_value,
            assigned_date,
            assigned_by,
            notes,
            created_at
        ) VALUES (
            seq_donation_assignments.NEXTVAL,
            p_donation_id,
            p_program_id,
            1,
            v_amount_pen,
            SYSDATE,
            p_created_by,
            'Auto-assigned money donation',
            CURRENT_TIMESTAMP
        );
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Money donation registered: ID=' || p_donation_id || 
                            ', Code=' || v_donation_code);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20003, 'Error registering money donation: ' || SQLERRM);
    END register_money_donation;

    -- ========================================================
    -- Register a product donation
    -- ========================================================
    PROCEDURE register_product_donation(
        p_donor_id IN NUMBER,
        p_product_description IN VARCHAR2,
        p_quantity IN NUMBER,
        p_unit_value IN NUMBER,
        p_program_id IN NUMBER,
        p_notes IN VARCHAR2,
        p_created_by IN NUMBER,
        p_donation_id OUT NUMBER
    ) IS
        v_donation_code VARCHAR2(20);
        v_donation_type_id NUMBER;
        v_total_value NUMBER;
        v_inventory_id NUMBER;
    BEGIN
        -- Validate inputs
        IF p_quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Quantity must be greater than zero');
        END IF;
        
        -- Validate donor exists
        DECLARE
            v_donor_exists NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_donor_exists
            FROM tbl_donors
            WHERE donor_id = p_donor_id AND is_active = 'Y';
            
            IF v_donor_exists = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Donor not found or inactive');
            END IF;
        END;
        
        -- Validate program exists
        DECLARE
            v_program_exists NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_program_exists
            FROM tbl_programs
            WHERE program_id = p_program_id AND is_active = 'Y';
            
            IF v_program_exists = 0 THEN
                RAISE_APPLICATION_ERROR(-20002, 'Program not found or inactive');
            END IF;
        END;
        
        -- Get donation type ID for PRODUCT
        SELECT donation_type_id INTO v_donation_type_id
        FROM tbl_donation_types
        WHERE type_code = 'PRODUCT';
        
        -- Generate donation code
        v_donation_code := 'DON-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || 
                          LPAD(seq_donations.CURRVAL + 1, 3, '0');
        
        -- Calculate total value
        v_total_value := p_quantity * NVL(p_unit_value, 0);
        
        -- Insert donation
        INSERT INTO tbl_donations (
            donation_id,
            donation_code,
            donor_id,
            donation_type_id,
            donation_date,
            amount,
            currency_id,
            product_description,
            quantity,
            unit_value,
            notes,
            created_by,
            created_at
        ) VALUES (
            seq_donations.NEXTVAL,
            v_donation_code,
            p_donor_id,
            v_donation_type_id,
            SYSDATE,
            NULL,
            NULL,
            p_product_description,
            p_quantity,
            p_unit_value,
            p_notes,
            p_created_by,
            CURRENT_TIMESTAMP
        ) RETURNING donation_id INTO p_donation_id;
        
        -- Assign donation to program
        INSERT INTO tbl_donation_assignments (
            assignment_id,
            donation_id,
            program_id,
            assigned_quantity,
            assigned_value,
            assigned_date,
            assigned_by,
            notes,
            created_at
        ) VALUES (
            seq_donation_assignments.NEXTVAL,
            p_donation_id,
            p_program_id,
            p_quantity,
            v_total_value,
            SYSDATE,
            p_created_by,
            'Auto-assigned product donation',
            CURRENT_TIMESTAMP
        );
        
        -- Update or insert program inventory
        BEGIN
            SELECT inventory_id INTO v_inventory_id
            FROM tbl_program_inventory
            WHERE program_id = p_program_id 
            AND UPPER(product_description) = UPPER(p_product_description);
            
            -- Update existing inventory
            UPDATE tbl_program_inventory
            SET available_quantity = available_quantity + p_quantity,
                unit_value = p_unit_value,
                last_updated = CURRENT_TIMESTAMP
            WHERE inventory_id = v_inventory_id;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Create new inventory item
                INSERT INTO tbl_program_inventory (
                    inventory_id,
                    program_id,
                    product_description,
                    available_quantity,
                    reserved_quantity,
                    delivered_quantity,
                    unit_value,
                    last_updated
                ) VALUES (
                    seq_program_inventory.NEXTVAL,
                    p_program_id,
                    p_product_description,
                    p_quantity,
                    0,
                    0,
                    p_unit_value,
                    CURRENT_TIMESTAMP
                );
        END;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Product donation registered: ID=' || p_donation_id || 
                            ', Code=' || v_donation_code);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20005, 'Error registering product donation: ' || SQLERRM);
    END register_product_donation;

    -- ========================================================
    -- Convert currency to base currency (PEN)
    -- ========================================================
    FUNCTION convert_to_base_currency(
        p_amount IN NUMBER,
        p_from_currency_id IN NUMBER
    ) RETURN NUMBER IS
        v_exchange_rate NUMBER;
        v_pen_currency_id NUMBER;
        v_converted_amount NUMBER;
    BEGIN
        -- Get PEN currency ID
        SELECT currency_id INTO v_pen_currency_id
        FROM tbl_currencies
        WHERE currency_code = 'PEN';
        
        -- If already in PEN, return as is
        IF p_from_currency_id = v_pen_currency_id THEN
            RETURN p_amount;
        END IF;
        
        -- Get exchange rate
        BEGIN
            SELECT exchange_rate INTO v_exchange_rate
            FROM tbl_exchange_rates
            WHERE from_currency_id = p_from_currency_id
            AND to_currency_id = v_pen_currency_id
            AND is_active = 'Y'
            AND ROWNUM = 1
            ORDER BY effective_date DESC;
            
            v_converted_amount := p_amount * v_exchange_rate;
            RETURN ROUND(v_converted_amount, 2);
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20006, 'Exchange rate not found');
        END;
        
    END convert_to_base_currency;

    -- ========================================================
    -- Get donor's total contributions in PEN
    -- ========================================================
    FUNCTION get_donor_total_contributions(
        p_donor_id IN NUMBER
    ) RETURN NUMBER IS
        v_total NUMBER := 0;
        v_money_total NUMBER := 0;
        v_product_total NUMBER := 0;
    BEGIN
        -- Sum money donations (converted to PEN)
        SELECT NVL(SUM(
            CASE 
                WHEN d.currency_id = (SELECT currency_id FROM tbl_currencies WHERE currency_code = 'PEN')
                THEN d.amount
                ELSE d.amount * (
                    SELECT exchange_rate 
                    FROM tbl_exchange_rates 
                    WHERE from_currency_id = d.currency_id 
                    AND to_currency_id = (SELECT currency_id FROM tbl_currencies WHERE currency_code = 'PEN')
                    AND is_active = 'Y'
                    AND ROWNUM = 1
                )
            END
        ), 0) INTO v_money_total
        FROM tbl_donations d
        JOIN tbl_donation_types dt ON d.donation_type_id = dt.donation_type_id
        WHERE d.donor_id = p_donor_id
        AND dt.type_code = 'MONEY';
        
        -- Sum product donations (quantity * unit_value)
        SELECT NVL(SUM(d.quantity * NVL(d.unit_value, 0)), 0) INTO v_product_total
        FROM tbl_donations d
        JOIN tbl_donation_types dt ON d.donation_type_id = dt.donation_type_id
        WHERE d.donor_id = p_donor_id
        AND dt.type_code = 'PRODUCT';
        
        v_total := v_money_total + v_product_total;
        RETURN ROUND(v_total, 2);
        
    END get_donor_total_contributions;

    -- ========================================================
    -- Get donation history for a donor
    -- ========================================================
    PROCEDURE get_donor_history(
        p_donor_id IN NUMBER,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                d.donation_id,
                d.donation_code,
                d.donation_date,
                dt.type_name AS donation_type,
                d.amount,
                c.currency_code,
                d.product_description,
                d.quantity,
                d.unit_value,
                p.program_name,
                d.notes
            FROM tbl_donations d
            JOIN tbl_donation_types dt ON d.donation_type_id = dt.donation_type_id
            LEFT JOIN tbl_currencies c ON d.currency_id = c.currency_id
            LEFT JOIN tbl_donation_assignments da ON d.donation_id = da.donation_id
            LEFT JOIN tbl_programs p ON da.program_id = p.program_id
            WHERE d.donor_id = p_donor_id
            ORDER BY d.donation_date DESC;
            
    END get_donor_history;

END pkg_donations;
/

PROMPT 'Package body created: PKG_DONATIONS';

-- ============================================================
-- SUCCESS MESSAGE
-- ============================================================

BEGIN
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('PKG_DONATIONS CREATED SUCCESSFULLY!');
  DBMS_OUTPUT.PUT_LINE('Procedures:');
  DBMS_OUTPUT.PUT_LINE('  - register_money_donation');
  DBMS_OUTPUT.PUT_LINE('  - register_product_donation');
  DBMS_OUTPUT.PUT_LINE('  - get_donor_history');
  DBMS_OUTPUT.PUT_LINE('Functions:');
  DBMS_OUTPUT.PUT_LINE('  - convert_to_base_currency');
  DBMS_OUTPUT.PUT_LINE('  - get_donor_total_contributions');
  DBMS_OUTPUT.PUT_LINE('========================================');
END;
/