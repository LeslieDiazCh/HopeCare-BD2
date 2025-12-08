-- ================================================================
-- HOPECARE PROJECT - 13_SECURITY.SQL
-- Security policies, roles and permissions
-- ================================================================

SET SERVEROUTPUT ON;

BEGIN
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('HOPECARE - SECURITY CONFIGURATION');
  DBMS_OUTPUT.PUT_LINE('Setting up roles and permissions');
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================
-- CREATE DATABASE ROLES
-- ============================================================

-- Note: These are application-level roles stored in tbl_roles
-- Already created in initial data load

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== APPLICATION ROLES ===');
    DBMS_OUTPUT.PUT_LINE('Roles are defined in tbl_roles table:');
END;
/

SELECT role_code, role_name, description 
FROM tbl_roles 
WHERE is_active = 'Y'
ORDER BY role_id;

-- ============================================================
-- CREATE READ-ONLY USER FOR REPORTS
-- ============================================================

DECLARE
    v_user_exists NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== CREATING READ-ONLY USER ===');
    
    -- Check if user exists
    SELECT COUNT(*) INTO v_user_exists
    FROM dba_users
    WHERE username = 'HOPECARE_READONLY';
    
    IF v_user_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP USER hopecare_readonly CASCADE';
        DBMS_OUTPUT.PUT_LINE('Existing read-only user dropped');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- User doesn't exist or no permission to check
END;
/

-- Create read-only user (run as SYSTEM if needed)
-- This part might need to be run separately with SYSTEM privileges
BEGIN
    DBMS_OUTPUT.PUT_LINE('Read-only user configuration prepared');
    DBMS_OUTPUT.PUT_LINE('Note: Run the following as SYSTEM user if needed:');
    DBMS_OUTPUT.PUT_LINE('  CREATE USER hopecare_readonly IDENTIFIED BY readonly123;');
    DBMS_OUTPUT.PUT_LINE('  GRANT CONNECT TO hopecare_readonly;');
END;
/

-- ============================================================
-- GRANT PERMISSIONS ON VIEWS (for read-only access)
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== GRANTING VIEW PERMISSIONS ===');
END;
/

-- Grant SELECT on all views to public (within hopecare schema context)
GRANT SELECT ON vw_donor_summary TO PUBLIC;
GRANT SELECT ON vw_beneficiary_summary TO PUBLIC;
GRANT SELECT ON vw_program_summary TO PUBLIC;
GRANT SELECT ON vw_donation_details TO PUBLIC;
GRANT SELECT ON vw_delivery_details TO PUBLIC;
GRANT SELECT ON vw_inventory_status TO PUBLIC;
GRANT SELECT ON vw_recent_activity TO PUBLIC;
GRANT SELECT ON vw_dashboard_metrics TO PUBLIC;

BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ View permissions granted');
END;
/

-- ============================================================
-- CREATE SECURITY POLICIES
-- ============================================================

-- Policy 1: Prevent deletion of completed deliveries
CREATE OR REPLACE TRIGGER trg_prevent_delivery_delete
BEFORE DELETE ON tbl_deliveries
FOR EACH ROW
BEGIN
    IF :OLD.status = 'COMPLETED' THEN
        RAISE_APPLICATION_ERROR(-20501, 
            'Cannot delete completed deliveries. Use status update instead.');
    END IF;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== SECURITY POLICIES ===');
    DBMS_OUTPUT.PUT_LINE('✓ Trigger created: trg_prevent_delivery_delete');
END;
/

-- Policy 2: Prevent modification of audit records
CREATE OR REPLACE TRIGGER trg_protect_audit_donations
BEFORE UPDATE OR DELETE ON tbl_audit_donations
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20502, 
        'Audit records cannot be modified or deleted');
END;
/

CREATE OR REPLACE TRIGGER trg_protect_audit_deliveries
BEFORE UPDATE OR DELETE ON tbl_audit_deliveries
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20503, 
        'Audit records cannot be modified or deleted');
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Trigger created: trg_protect_audit_donations');
    DBMS_OUTPUT.PUT_LINE('✓ Trigger created: trg_protect_audit_deliveries');
END;
/

-- Policy 3: Validate donation amounts
CREATE OR REPLACE TRIGGER trg_validate_donation_amount
BEFORE INSERT OR UPDATE ON tbl_donations
FOR EACH ROW
DECLARE
    v_type_code VARCHAR2(20);
BEGIN
    -- Get donation type
    SELECT type_code INTO v_type_code
    FROM tbl_donation_types
    WHERE donation_type_id = :NEW.donation_type_id;
    
    -- Validate money donations
    IF v_type_code = 'MONEY' THEN
        IF :NEW.amount IS NULL OR :NEW.amount <= 0 THEN
            RAISE_APPLICATION_ERROR(-20504, 
                'Money donation amount must be greater than zero');
        END IF;
        IF :NEW.currency_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20505, 
                'Currency is required for money donations');
        END IF;
    END IF;
    
    -- Validate product donations
    IF v_type_code = 'PRODUCT' THEN
        IF :NEW.quantity IS NULL OR :NEW.quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20506, 
                'Product donation quantity must be greater than zero');
        END IF;
        IF :NEW.product_description IS NULL THEN
            RAISE_APPLICATION_ERROR(-20507, 
                'Product description is required for product donations');
        END IF;
    END IF;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Trigger created: trg_validate_donation_amount');
END;
/

-- ============================================================
-- PASSWORD POLICY HELPER FUNCTIONS
-- ============================================================

CREATE OR REPLACE FUNCTION fn_hash_password(p_password VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    -- Simple MD5 hash (in production, use stronger encryption)
    RETURN LOWER(RAWTOHEX(DBMS_OBFUSCATION_TOOLKIT.MD5(
        INPUT => UTL_RAW.CAST_TO_RAW(p_password)
    )));
EXCEPTION
    WHEN OTHERS THEN
        -- Fallback to standard hash if DBMS_OBFUSCATION_TOOLKIT not available
        RETURN LOWER(RAWTOHEX(DBMS_CRYPTO.HASH(
            UTL_RAW.CAST_TO_RAW(p_password), 
            DBMS_CRYPTO.HASH_MD5
        )));
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== PASSWORD FUNCTIONS ===');
    DBMS_OUTPUT.PUT_LINE('✓ Function created: fn_hash_password');
END;
/

CREATE OR REPLACE FUNCTION fn_validate_password(
    p_username VARCHAR2,
    p_password VARCHAR2
)
RETURN BOOLEAN
IS
    v_stored_hash VARCHAR2(200);
    v_is_active CHAR(1);
BEGIN
    -- Get stored password hash
    SELECT password_hash, is_active
    INTO v_stored_hash, v_is_active
    FROM tbl_users
    WHERE UPPER(username) = UPPER(p_username);
    
    -- Check if user is active
    IF v_is_active = 'N' THEN
        RETURN FALSE;
    END IF;
    
    -- Validate password
    IF fn_hash_password(p_password) = v_stored_hash THEN
        -- Update last login
        UPDATE tbl_users
        SET last_login = CURRENT_TIMESTAMP
        WHERE UPPER(username) = UPPER(p_username);
        COMMIT;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        RETURN FALSE;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Function created: fn_validate_password');
END;
/

-- ============================================================
-- USER MANAGEMENT PROCEDURES
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_create_user(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_full_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_role_code IN VARCHAR2,
    p_user_id OUT NUMBER
)
IS
    v_role_id NUMBER;
    v_username_exists NUMBER;
    v_email_exists NUMBER;
BEGIN
    -- Validate username is unique
    SELECT COUNT(*) INTO v_username_exists
    FROM tbl_users
    WHERE UPPER(username) = UPPER(p_username);
    
    IF v_username_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20508, 'Username already exists');
    END IF;
    
    -- Validate email is unique
    SELECT COUNT(*) INTO v_email_exists
    FROM tbl_users
    WHERE UPPER(email) = UPPER(p_email);
    
    IF v_email_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20509, 'Email already exists');
    END IF;
    
    -- Get role ID
    SELECT role_id INTO v_role_id
    FROM tbl_roles
    WHERE UPPER(role_code) = UPPER(p_role_code)
    AND is_active = 'Y';
    
    -- Create user
    INSERT INTO tbl_users (
        user_id,
        username,
        password_hash,
        full_name,
        email,
        role_id,
        is_active,
        created_at,
        updated_at
    ) VALUES (
        seq_users.NEXTVAL,
        LOWER(p_username),
        fn_hash_password(p_password),
        p_full_name,
        LOWER(p_email),
        v_role_id,
        'Y',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) RETURNING user_id INTO p_user_id;
    
    COMMIT;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20510, 'Invalid role code');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Procedure created: sp_create_user');
END;
/

CREATE OR REPLACE PROCEDURE sp_change_password(
    p_username IN VARCHAR2,
    p_old_password IN VARCHAR2,
    p_new_password IN VARCHAR2
)
IS
    v_valid BOOLEAN;
BEGIN
    -- Validate old password
    v_valid := fn_validate_password(p_username, p_old_password);
    
    IF NOT v_valid THEN
        RAISE_APPLICATION_ERROR(-20511, 'Invalid current password');
    END IF;
    
    -- Update password
    UPDATE tbl_users
    SET password_hash = fn_hash_password(p_new_password),
        updated_at = CURRENT_TIMESTAMP
    WHERE UPPER(username) = UPPER(p_username);
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Procedure created: sp_change_password');
END;
/

-- ============================================================
-- ROLE-BASED ACCESS CONTROL FUNCTIONS
-- ============================================================

CREATE OR REPLACE FUNCTION fn_user_has_role(
    p_username IN VARCHAR2,
    p_role_code IN VARCHAR2
)
RETURN BOOLEAN
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM tbl_users u
    JOIN tbl_roles r ON u.role_id = r.role_id
    WHERE UPPER(u.username) = UPPER(p_username)
    AND UPPER(r.role_code) = UPPER(p_role_code)
    AND u.is_active = 'Y'
    AND r.is_active = 'Y';
    
    RETURN v_count > 0;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== ACCESS CONTROL ===');
    DBMS_OUTPUT.PUT_LINE('✓ Function created: fn_user_has_role');
END;
/

-- ============================================================
-- TEST SECURITY FEATURES
-- ============================================================

DECLARE
    v_user_id NUMBER;
    v_is_valid BOOLEAN;
    v_has_role BOOLEAN;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== TESTING SECURITY FEATURES ===');
    
    -- Test 1: Password hashing
    DECLARE
        v_hash VARCHAR2(200);
    BEGIN
        v_hash := fn_hash_password('test123');
        DBMS_OUTPUT.PUT_LINE('✓ Password hashing works: ' || SUBSTR(v_hash, 1, 20) || '...');
    END;
    
    -- Test 2: Password validation (existing user)
    v_is_valid := fn_validate_password('admin', 'admin123');
    IF v_is_valid THEN
        DBMS_OUTPUT.PUT_LINE('✓ Password validation works for admin user');
    ELSE
        DBMS_OUTPUT.PUT_LINE('⚠ Admin password validation failed');
    END IF;
    
    -- Test 3: Role checking
    v_has_role := fn_user_has_role('admin', 'ADMIN');
    IF v_has_role THEN
        DBMS_OUTPUT.PUT_LINE('✓ Role checking works: admin has ADMIN role');
    ELSE
        DBMS_OUTPUT.PUT_LINE('⚠ Role checking failed');
    END IF;
    
    -- Test 4: Try to modify audit record (should fail)
    BEGIN
        UPDATE tbl_audit_donations SET action_type = 'TEST' WHERE ROWNUM = 1;
        DBMS_OUTPUT.PUT_LINE('✗ Audit protection FAILED - modification was allowed');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('✓ Audit protection works: ' || SUBSTR(SQLERRM, 1, 50));
            ROLLBACK;
    END;
    
END;
/

-- ============================================================
-- SECURITY DOCUMENTATION
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('SECURITY CONFIGURATION COMPLETED');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('SECURITY FEATURES IMPLEMENTED:');
    DBMS_OUTPUT.PUT_LINE('------------------------------');
    DBMS_OUTPUT.PUT_LINE('1. Password hashing (MD5)');
    DBMS_OUTPUT.PUT_LINE('2. User authentication');
    DBMS_OUTPUT.PUT_LINE('3. Role-based access control');
    DBMS_OUTPUT.PUT_LINE('4. Audit record protection');
    DBMS_OUTPUT.PUT_LINE('5. Completed delivery protection');
    DBMS_OUTPUT.PUT_LINE('6. Donation validation');
    DBMS_OUTPUT.PUT_LINE('7. View-level permissions');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('DEFAULT USERS:');
    DBMS_OUTPUT.PUT_LINE('--------------');
    DBMS_OUTPUT.PUT_LINE('Username: admin    | Password: admin123    | Role: ADMIN');
    DBMS_OUTPUT.PUT_LINE('Username: assistant | Password: assist123  | Role: ASSISTANT');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('AVAILABLE PROCEDURES:');
    DBMS_OUTPUT.PUT_LINE('--------------------');
    DBMS_OUTPUT.PUT_LINE('- sp_create_user(username, password, full_name, email, role_code)');
    DBMS_OUTPUT.PUT_LINE('- sp_change_password(username, old_password, new_password)');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('AVAILABLE FUNCTIONS:');
    DBMS_OUTPUT.PUT_LINE('-------------------');
    DBMS_OUTPUT.PUT_LINE('- fn_hash_password(password) RETURN VARCHAR2');
    DBMS_OUTPUT.PUT_LINE('- fn_validate_password(username, password) RETURN BOOLEAN');
    DBMS_OUTPUT.PUT_LINE('- fn_user_has_role(username, role_code) RETURN BOOLEAN');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- ============================================================
-- SHOW CURRENT USERS AND ROLES
-- ============================================================

SELECT 
    u.username,
    u.full_name,
    r.role_name,
    u.is_active,
    u.last_login,
    u.created_at
FROM tbl_users u
JOIN tbl_roles r ON u.role_id = r.role_id
ORDER BY u.user_id;