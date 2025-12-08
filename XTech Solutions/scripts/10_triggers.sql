-- ================================================================
-- HOPECARE PROJECT - 10_TRIGGERS.SQL
-- Audit triggers for donations and deliveries
-- ================================================================

-- ============================================================
-- TRIGGER 1: AUDIT DONATIONS
-- ============================================================

CREATE OR REPLACE TRIGGER trg_audit_donations
AFTER INSERT OR UPDATE OR DELETE ON tbl_donations
FOR EACH ROW
DECLARE
    v_action_type VARCHAR2(20);
    v_old_values VARCHAR2(1000);
    v_new_values VARCHAR2(1000);
    v_changed_by NUMBER;
BEGIN
    -- Determine action type
    IF INSERTING THEN
        v_action_type := 'INSERT';
        v_old_values := NULL;
        v_new_values := 'ID:' || :NEW.donation_id || 
                       ',CODE:' || :NEW.donation_code || 
                       ',DONOR:' || :NEW.donor_id || 
                       ',TYPE:' || :NEW.donation_type_id || 
                       ',AMOUNT:' || :NEW.amount || 
                       ',PRODUCT:' || :NEW.product_description ||
                       ',QTY:' || :NEW.quantity;
        v_changed_by := :NEW.created_by;
        
    ELSIF UPDATING THEN
        v_action_type := 'UPDATE';
        v_old_values := 'ID:' || :OLD.donation_id || 
                       ',CODE:' || :OLD.donation_code || 
                       ',DONOR:' || :OLD.donor_id || 
                       ',TYPE:' || :OLD.donation_type_id || 
                       ',AMOUNT:' || :OLD.amount || 
                       ',PRODUCT:' || :OLD.product_description ||
                       ',QTY:' || :OLD.quantity;
        v_new_values := 'ID:' || :NEW.donation_id || 
                       ',CODE:' || :NEW.donation_code || 
                       ',DONOR:' || :NEW.donor_id || 
                       ',TYPE:' || :NEW.donation_type_id || 
                       ',AMOUNT:' || :NEW.amount || 
                       ',PRODUCT:' || :NEW.product_description ||
                       ',QTY:' || :NEW.quantity;
        v_changed_by := :NEW.created_by;
        
    ELSIF DELETING THEN
        v_action_type := 'DELETE';
        v_old_values := 'ID:' || :OLD.donation_id || 
                       ',CODE:' || :OLD.donation_code || 
                       ',DONOR:' || :OLD.donor_id || 
                       ',TYPE:' || :OLD.donation_type_id || 
                       ',AMOUNT:' || :OLD.amount || 
                       ',PRODUCT:' || :OLD.product_description ||
                       ',QTY:' || :OLD.quantity;
        v_new_values := NULL;
        v_changed_by := :OLD.created_by;
    END IF;
    
    -- Insert audit record
    INSERT INTO tbl_audit_donations (
        audit_id,
        donation_id,
        action_type,
        old_values,
        new_values,
        changed_by,
        changed_at
    ) VALUES (
        seq_audit_donations.NEXTVAL,
        COALESCE(:NEW.donation_id, :OLD.donation_id),
        v_action_type,
        v_old_values,
        v_new_values,
        v_changed_by,
        CURRENT_TIMESTAMP
    );
    
EXCEPTION
    WHEN OTHERS THEN
        -- Don't fail the main operation if audit fails
        DBMS_OUTPUT.PUT_LINE('Audit trigger error: ' || SQLERRM);
END;
/

PROMPT 'Trigger created: TRG_AUDIT_DONATIONS';

-- ============================================================
-- TRIGGER 2: AUDIT DELIVERIES
-- ============================================================

CREATE OR REPLACE TRIGGER trg_audit_deliveries
AFTER INSERT OR UPDATE OR DELETE ON tbl_deliveries
FOR EACH ROW
DECLARE
    v_action_type VARCHAR2(20);
    v_old_values VARCHAR2(1000);
    v_new_values VARCHAR2(1000);
    v_changed_by NUMBER;
BEGIN
    -- Determine action type
    IF INSERTING THEN
        v_action_type := 'INSERT';
        v_old_values := NULL;
        v_new_values := 'ID:' || :NEW.delivery_id || 
                       ',CODE:' || :NEW.delivery_code || 
                       ',BENEF:' || :NEW.beneficiary_id || 
                       ',PROG:' || :NEW.program_id || 
                       ',PRODUCT:' || :NEW.product_description ||
                       ',QTY:' || :NEW.quantity_delivered ||
                       ',STATUS:' || :NEW.status;
        v_changed_by := :NEW.created_by;
        
    ELSIF UPDATING THEN
        v_action_type := 'UPDATE';
        v_old_values := 'ID:' || :OLD.delivery_id || 
                       ',CODE:' || :OLD.delivery_code || 
                       ',BENEF:' || :OLD.beneficiary_id || 
                       ',PROG:' || :OLD.program_id || 
                       ',PRODUCT:' || :OLD.product_description ||
                       ',QTY:' || :OLD.quantity_delivered ||
                       ',STATUS:' || :OLD.status;
        v_new_values := 'ID:' || :NEW.delivery_id || 
                       ',CODE:' || :NEW.delivery_code || 
                       ',BENEF:' || :NEW.beneficiary_id || 
                       ',PROG:' || :NEW.program_id || 
                       ',PRODUCT:' || :NEW.product_description ||
                       ',QTY:' || :NEW.quantity_delivered ||
                       ',STATUS:' || :NEW.status;
        v_changed_by := :NEW.created_by;
        
    ELSIF DELETING THEN
        v_action_type := 'DELETE';
        v_old_values := 'ID:' || :OLD.delivery_id || 
                       ',CODE:' || :OLD.delivery_code || 
                       ',BENEF:' || :OLD.beneficiary_id || 
                       ',PROG:' || :OLD.program_id || 
                       ',PRODUCT:' || :OLD.product_description ||
                       ',QTY:' || :OLD.quantity_delivered ||
                       ',STATUS:' || :OLD.status;
        v_new_values := NULL;
        v_changed_by := :OLD.created_by;
    END IF;
    
    -- Insert audit record
    INSERT INTO tbl_audit_deliveries (
        audit_id,
        delivery_id,
        action_type,
        old_values,
        new_values,
        changed_by,
        changed_at
    ) VALUES (
        seq_audit_deliveries.NEXTVAL,
        COALESCE(:NEW.delivery_id, :OLD.delivery_id),
        v_action_type,
        v_old_values,
        v_new_values,
        v_changed_by,
        CURRENT_TIMESTAMP
    );
    
EXCEPTION
    WHEN OTHERS THEN
        -- Don't fail the main operation if audit fails
        DBMS_OUTPUT.PUT_LINE('Audit trigger error: ' || SQLERRM);
END;
/

PROMPT 'Trigger created: TRG_AUDIT_DELIVERIES';

-- ============================================================
-- TRIGGER 3: AUTO UPDATE TIMESTAMP (DONORS)
-- ============================================================

CREATE OR REPLACE TRIGGER trg_donors_update_timestamp
BEFORE UPDATE ON tbl_donors
FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

PROMPT 'Trigger created: TRG_DONORS_UPDATE_TIMESTAMP';

-- ============================================================
-- TRIGGER 4: AUTO UPDATE TIMESTAMP (BENEFICIARIES)
-- ============================================================

CREATE OR REPLACE TRIGGER trg_beneficiaries_update_timestamp
BEFORE UPDATE ON tbl_beneficiaries
FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

PROMPT 'Trigger created: TRG_BENEFICIARIES_UPDATE_TIMESTAMP';

-- ============================================================
-- TRIGGER 5: AUTO UPDATE TIMESTAMP (PROGRAMS)
-- ============================================================

CREATE OR REPLACE TRIGGER trg_programs_update_timestamp
BEFORE UPDATE ON tbl_programs
FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

PROMPT 'Trigger created: TRG_PROGRAMS_UPDATE_TIMESTAMP';

-- ============================================================
-- SUCCESS MESSAGE
-- ============================================================

BEGIN
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('ALL TRIGGERS CREATED SUCCESSFULLY!');
  DBMS_OUTPUT.PUT_LINE('Audit Triggers:');
  DBMS_OUTPUT.PUT_LINE('  - trg_audit_donations');
  DBMS_OUTPUT.PUT_LINE('  - trg_audit_deliveries');
  DBMS_OUTPUT.PUT_LINE('Utility Triggers:');
  DBMS_OUTPUT.PUT_LINE('  - trg_donors_update_timestamp');
  DBMS_OUTPUT.PUT_LINE('  - trg_beneficiaries_update_timestamp');
  DBMS_OUTPUT.PUT_LINE('  - trg_programs_update_timestamp');
  DBMS_OUTPUT.PUT_LINE('========================================');
END;
/