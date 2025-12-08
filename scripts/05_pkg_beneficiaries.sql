-- ================================================================
-- HOPECARE PROJECT - 05_PKG_DELIVERIES.SQL
-- Package for delivery management with stock validation
-- ================================================================

-- ============================================================
-- PACKAGE SPECIFICATION
-- ============================================================

CREATE OR REPLACE PACKAGE pkg_deliveries AS
    
    -- Perform delivery to beneficiary with stock validation
    PROCEDURE perform_delivery(
        p_beneficiary_id IN NUMBER,
        p_program_id IN NUMBER,
        p_product_description IN VARCHAR2,
        p_quantity IN NUMBER,
        p_notes IN VARCHAR2,
        p_created_by IN NUMBER,
        p_delivery_id OUT NUMBER
    );
    
    -- Validate if enough stock is available
    FUNCTION validate_stock(
        p_program_id IN NUMBER,
        p_product_description IN VARCHAR2,
        p_quantity IN NUMBER
    ) RETURN BOOLEAN;
    
    -- Get available stock for a product in a program
    FUNCTION get_available_stock(
        p_program_id IN NUMBER,
        p_product_description IN VARCHAR2
    ) RETURN NUMBER;
    
    -- Get delivery history for a beneficiary
    PROCEDURE get_beneficiary_history(
        p_beneficiary_id IN NUMBER,
        p_cursor OUT SYS_REFCURSOR
    );
    
    -- Cancel a delivery (returns stock)
    PROCEDURE cancel_delivery(
        p_delivery_id IN NUMBER,
        p_cancelled_by IN NUMBER
    );
    
END pkg_deliveries;
/

PROMPT 'Package specification created: PKG_DELIVERIES';

-- ============================================================
-- PACKAGE BODY
-- ============================================================

CREATE OR REPLACE PACKAGE BODY pkg_deliveries AS

    -- ========================================================
    -- Perform delivery to beneficiary with stock validation
    -- ========================================================
    PROCEDURE perform_delivery(
        p_beneficiary_id IN NUMBER,
        p_program_id IN NUMBER,
        p_product_description IN VARCHAR2,
        p_quantity IN NUMBER,
        p_notes IN VARCHAR2,
        p_created_by IN NUMBER,
        p_delivery_id OUT NUMBER
    ) IS
        v_delivery_code VARCHAR2(20);
        v_available_stock NUMBER;
        v_unit_value NUMBER;
        v_total_value NUMBER;
        v_inventory_id NUMBER;
    BEGIN
        -- Validate inputs
        IF p_quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20101, 'Quantity must be greater than zero');
        END IF;
        
        -- Validate beneficiary exists
        DECLARE
            v_beneficiary_exists NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_beneficiary_exists
            FROM tbl_beneficiaries
            WHERE beneficiary_id = p_beneficiary_id AND is_active = 'Y';
            
            IF v_beneficiary_exists = 0 THEN
                RAISE_APPLICATION_ERROR(-20102, 'Beneficiary not found or inactive');
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
                RAISE_APPLICATION_ERROR(-20103, 'Program not found or inactive');
            END IF;
        END;
        
        -- CRITICAL: Validate stock availability
        IF NOT validate_stock(p_program_id, p_product_description, p_quantity) THEN
            v_available_stock := get_available_stock(p_program_id, p_product_description);
            RAISE_APPLICATION_ERROR(-20104, 
                'Insufficient stock. Available: ' || v_available_stock || 
                ', Requested: ' || p_quantity);
        END IF;
        
        -- Get inventory details
        BEGIN
            SELECT inventory_id, available_quantity, unit_value
            INTO v_inventory_id, v_available_stock, v_unit_value
            FROM tbl_program_inventory
            WHERE program_id = p_program_id
            AND UPPER(product_description) = UPPER(p_product_description);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20105, 'Product not found in program inventory');
        END;
        
        -- Calculate total value
        v_total_value := p_quantity * NVL(v_unit_value, 0);
        
        -- Generate delivery code
        v_delivery_code := 'DEL-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || 
                          LPAD(seq_deliveries.CURRVAL + 1, 3, '0');
        
        -- Insert delivery record
        INSERT INTO tbl_deliveries (
            delivery_id,
            delivery_code,
            beneficiary_id,
            program_id,
            delivery_date,
            product_description,
            quantity_delivered,
            unit_value,
            total_value,
            status,
            notes,
            created_by,
            approved_by,
            created_at
        ) VALUES (
            seq_deliveries.NEXTVAL,
            v_delivery_code,
            p_beneficiary_id,
            p_program_id,
            SYSDATE,
            p_product_description,
            p_quantity,
            v_unit_value,
            v_total_value,
            'COMPLETED',
            p_notes,
            p_created_by,
            p_created_by,
            CURRENT_TIMESTAMP
        ) RETURNING delivery_id INTO p_delivery_id;
        
        -- Update inventory: decrease available, increase delivered
        UPDATE tbl_program_inventory
        SET available_quantity = available_quantity - p_quantity,
            delivered_quantity = delivered_quantity + p_quantity,
            last_updated = CURRENT_TIMESTAMP
        WHERE inventory_id = v_inventory_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Delivery completed successfully!');
        DBMS_OUTPUT.PUT_LINE('Delivery ID: ' || p_delivery_id);
        DBMS_OUTPUT.PUT_LINE('Delivery Code: ' || v_delivery_code);
        DBMS_OUTPUT.PUT_LINE('Remaining stock: ' || (v_available_stock - p_quantity));
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20106, 'Error performing delivery: ' || SQLERRM);
    END perform_delivery;

    -- ========================================================
    -- Validate if enough stock is available
    -- ========================================================
    FUNCTION validate_stock(
        p_program_id IN NUMBER,
        p_product_description IN VARCHAR2,
        p_quantity IN NUMBER
    ) RETURN BOOLEAN IS
        v_available_quantity NUMBER := 0;
    BEGIN
        -- Get available quantity from inventory
        BEGIN
            SELECT available_quantity INTO v_available_quantity
            FROM tbl_program_inventory
            WHERE program_id = p_program_id
            AND UPPER(product_description) = UPPER(p_product_description);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN FALSE; -- Product not in inventory
        END;
        
        -- Check if enough stock
        IF v_available_quantity >= p_quantity THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
        
    END validate_stock;

    -- ========================================================
    -- Get available stock for a product in a program
    -- ========================================================
    FUNCTION get_available_stock(
        p_program_id IN NUMBER,
        p_product_description IN VARCHAR2
    ) RETURN NUMBER IS
        v_available_quantity NUMBER := 0;
    BEGIN
        SELECT NVL(available_quantity, 0) INTO v_available_quantity
        FROM tbl_program_inventory
        WHERE program_id = p_program_id
        AND UPPER(product_description) = UPPER(p_product_description);
        
        RETURN v_available_quantity;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
    END get_available_stock;

    -- ========================================================
    -- Get delivery history for a beneficiary
    -- ========================================================
    PROCEDURE get_beneficiary_history(
        p_beneficiary_id IN NUMBER,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                d.delivery_id,
                d.delivery_code,
                d.delivery_date,
                p.program_name,
                d.product_description,
                d.quantity_delivered,
                d.unit_value,
                d.total_value,
                d.status,
                d.notes,
                u.full_name AS created_by_name
            FROM tbl_deliveries d
            JOIN tbl_programs p ON d.program_id = p.program_id
            JOIN tbl_users u ON d.created_by = u.user_id
            WHERE d.beneficiary_id = p_beneficiary_id
            ORDER BY d.delivery_date DESC;
            
    END get_beneficiary_history;

    -- ========================================================
    -- Cancel a delivery (returns stock to inventory)
    -- ========================================================
    PROCEDURE cancel_delivery(
        p_delivery_id IN NUMBER,
        p_cancelled_by IN NUMBER
    ) IS
        v_program_id NUMBER;
        v_product_description VARCHAR2(300);
        v_quantity NUMBER;
        v_current_status VARCHAR2(20);
    BEGIN
        -- Get delivery details
        BEGIN
            SELECT program_id, product_description, quantity_delivered, status
            INTO v_program_id, v_product_description, v_quantity, v_current_status
            FROM tbl_deliveries
            WHERE delivery_id = p_delivery_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20107, 'Delivery not found');
        END;
        
        -- Check if already cancelled
        IF v_current_status = 'CANCELLED' THEN
            RAISE_APPLICATION_ERROR(-20108, 'Delivery is already cancelled');
        END IF;
        
        -- Update delivery status
        UPDATE tbl_deliveries
        SET status = 'CANCELLED',
            notes = notes || ' | CANCELLED by user ' || p_cancelled_by || ' on ' || 
                   TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
        WHERE delivery_id = p_delivery_id;
        
        -- Return stock to inventory
        UPDATE tbl_program_inventory
        SET available_quantity = available_quantity + v_quantity,
            delivered_quantity = delivered_quantity - v_quantity,
            last_updated = CURRENT_TIMESTAMP
        WHERE program_id = v_program_id
        AND UPPER(product_description) = UPPER(v_product_description);
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Delivery cancelled successfully!');
        DBMS_OUTPUT.PUT_LINE('Stock returned: ' || v_quantity || ' units');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20109, 'Error cancelling delivery: ' || SQLERRM);
    END cancel_delivery;

END pkg_deliveries;
/

PROMPT 'Package body created: PKG_DELIVERIES';

-- ============================================================
-- SUCCESS MESSAGE
-- ============================================================

BEGIN
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('PKG_DELIVERIES CREATED SUCCESSFULLY!');
  DBMS_OUTPUT.PUT_LINE('Procedures:');
  DBMS_OUTPUT.PUT_LINE('  - perform_delivery');
  DBMS_OUTPUT.PUT_LINE('  - get_beneficiary_history');
  DBMS_OUTPUT.PUT_LINE('  - cancel_delivery');
  DBMS_OUTPUT.PUT_LINE('Functions:');
  DBMS_OUTPUT.PUT_LINE('  - validate_stock');
  DBMS_OUTPUT.PUT_LINE('  - get_available_stock');
  DBMS_OUTPUT.PUT_LINE('========================================');
END;
/