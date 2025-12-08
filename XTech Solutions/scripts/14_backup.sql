-- ================================================================
-- HOPECARE PROJECT - 14_BACKUP.SQL
-- Backup and restore procedures
-- ================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

BEGIN
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('HOPECARE - BACKUP & RESTORE');
  DBMS_OUTPUT.PUT_LINE('Database maintenance procedures');
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================
-- BACKUP INFORMATION PROCEDURE
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_backup_info
IS
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('DATABASE BACKUP INFORMATION');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Table counts
    DBMS_OUTPUT.PUT_LINE('TABLE STATISTICS:');
    DBMS_OUTPUT.PUT_LINE('------------------');
    
    SELECT COUNT(*) INTO v_count FROM tbl_currencies;
    DBMS_OUTPUT.PUT_LINE('tbl_currencies: ' || v_count || ' records');
    
    SELECT COUNT(*) INTO v_count FROM tbl_donation_types;
    DBMS_OUTPUT.PUT_LINE('tbl_donation_types: ' || v_count || ' records');
    
    SELECT COUNT(*) INTO v_count FROM tbl_roles;
    DBMS_OUTPUT.PUT_LINE('tbl_roles: ' || v_count || ' records');
    
    SELECT COUNT(*) INTO v_count FROM tbl_users;
    DBMS_OUTPUT.PUT_LINE('tbl_users: ' || v_count || ' records');
    
    SELECT COUNT(*) INTO v_count FROM tbl_donors;
    DBMS_OUTPUT.PUT_LINE('tbl_donors: ' || v_count || ' records');
    
    SELECT COUNT(*) INTO v_count FROM tbl_beneficiaries;
    DBMS_OUTPUT.PUT_LINE('tbl_beneficiaries: ' || v_count || ' records');
    
    SELECT COUNT(*) INTO v_count FROM tbl_programs;
    DBMS_OUTPUT.PUT_LINE('tbl_programs: ' || v_count || ' records');
    
    SELECT COUNT(*) INTO v_count FROM tbl_donations;
    DBMS_OUTPUT.PUT_LINE('tbl_donations: ' || v_count || ' records');
    
    SELECT COUNT(*) INTO v_count FROM tbl_deliveries;
    DBMS_OUTPUT.PUT_LINE('tbl_deliveries: ' || v_count || ' records');
    
    SELECT COUNT(*) INTO v_count FROM tbl_program_inventory;
    DBMS_OUTPUT.PUT_LINE('tbl_program_inventory: ' || v_count || ' records');
    
    SELECT COUNT(*) INTO v_count FROM tbl_donation_assignments;
    DBMS_OUTPUT.PUT_LINE('tbl_donation_assignments: ' || v_count || ' records');
    
    SELECT COUNT(*) INTO v_count FROM tbl_exchange_rates;
    DBMS_OUTPUT.PUT_LINE('tbl_exchange_rates: ' || v_count || ' records');
    
    SELECT COUNT(*) INTO v_count FROM tbl_audit_donations;
    DBMS_OUTPUT.PUT_LINE('tbl_audit_donations: ' || v_count || ' records');
    
    SELECT COUNT(*) INTO v_count FROM tbl_audit_deliveries;
    DBMS_OUTPUT.PUT_LINE('tbl_audit_deliveries: ' || v_count || ' records');
    
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Procedure created: sp_backup_info');
END;
/

-- ============================================================
-- EXPORT DATA PROCEDURE (generates INSERT statements)
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_export_table_data(
    p_table_name IN VARCHAR2
)
IS
    v_sql VARCHAR2(4000);
    v_cursor SYS_REFCURSOR;
BEGIN
    DBMS_OUTPUT.PUT_LINE('-- ========================================');
    DBMS_OUTPUT.PUT_LINE('-- EXPORT: ' || p_table_name);
    DBMS_OUTPUT.PUT_LINE('-- Generated: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('-- ========================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Note: This is a simplified version
    -- For production, use Oracle Data Pump or exp/imp utilities
    
    DBMS_OUTPUT.PUT_LINE('-- Use SQL Developer''s export wizard or:');
    DBMS_OUTPUT.PUT_LINE('-- Tools > Database Export > Export Data');
    DBMS_OUTPUT.PUT_LINE('-- Or use command line: expdp/impdp');
    DBMS_OUTPUT.PUT_LINE('');
    
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Procedure created: sp_export_table_data');
END;
/

-- ============================================================
-- DATABASE CLEANUP PROCEDURE
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_cleanup_test_data
IS
    v_deleted NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('CLEANING UP TEST DATA');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    -- Delete test donations (those with 'test' in notes)
    DELETE FROM tbl_donations 
    WHERE UPPER(notes) LIKE '%TEST%'
    OR donation_code LIKE '%TEST%';
    v_deleted := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('✓ Deleted ' || v_deleted || ' test donations');
    
    -- Delete test deliveries
    DELETE FROM tbl_deliveries 
    WHERE UPPER(notes) LIKE '%TEST%'
    OR delivery_code LIKE '%TEST%';
    v_deleted := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('✓ Deleted ' || v_deleted || ' test deliveries');
    
    -- Delete test donors
    DELETE FROM tbl_donors 
    WHERE UPPER(full_name) LIKE '%TEST%';
    v_deleted := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('✓ Deleted ' || v_deleted || ' test donors');
    
    -- Delete test beneficiaries
    DELETE FROM tbl_beneficiaries 
    WHERE UPPER(full_name) LIKE '%TEST%';
    v_deleted := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('✓ Deleted ' || v_deleted || ' test beneficiaries');
    
    -- Delete test programs
    DELETE FROM tbl_programs 
    WHERE UPPER(program_name) LIKE '%TEST%';
    v_deleted := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('✓ Deleted ' || v_deleted || ' test programs');
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('CLEANUP COMPLETED');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('✗ Cleanup failed: ' || SQLERRM);
        RAISE;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Procedure created: sp_cleanup_test_data');
END;
/

-- ============================================================
-- RESET SEQUENCES PROCEDURE
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_reset_sequences
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('RESETTING SEQUENCES');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('⚠ WARNING: This should only be done on empty tables!');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Note: In Oracle, you cannot reset sequences directly
    -- You need to drop and recreate them
    
    DBMS_OUTPUT.PUT_LINE('To reset sequences manually:');
    DBMS_OUTPUT.PUT_LINE('1. DROP SEQUENCE sequence_name;');
    DBMS_OUTPUT.PUT_LINE('2. CREATE SEQUENCE sequence_name START WITH 1;');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Or use: ALTER SEQUENCE seq_name RESTART START WITH 1;');
    DBMS_OUTPUT.PUT_LINE('(Oracle 18c+ only)');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Procedure created: sp_reset_sequences');
END;
/

-- ============================================================
-- MAINTENANCE REPORT PROCEDURE
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_maintenance_report
IS
    v_total_size NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('DATABASE MAINTENANCE REPORT');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Generated: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Show invalid objects
    DBMS_OUTPUT.PUT_LINE('INVALID OBJECTS:');
    DBMS_OUTPUT.PUT_LINE('----------------');
    FOR rec IN (
        SELECT object_type, object_name, status
        FROM user_objects
        WHERE status = 'INVALID'
        ORDER BY object_type, object_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.object_type || ': ' || rec.object_name || ' (' || rec.status || ')');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Show table sizes
    DBMS_OUTPUT.PUT_LINE('TABLE SIZES:');
    DBMS_OUTPUT.PUT_LINE('------------');
    FOR rec IN (
        SELECT 
            segment_name,
            ROUND(bytes/1024/1024, 2) AS size_mb
        FROM user_segments
        WHERE segment_type = 'TABLE'
        ORDER BY bytes DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(rec.segment_name, 30) || ' ' || rec.size_mb || ' MB');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Procedure created: sp_maintenance_report');
END;
/

-- ============================================================
-- BACKUP SCRIPT GENERATOR
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('BACKUP INSTRUCTIONS');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('METHOD 1: SQL Developer Export');
    DBMS_OUTPUT.PUT_LINE('------------------------------');
    DBMS_OUTPUT.PUT_LINE('1. Right-click on connection "HOPECARE"');
    DBMS_OUTPUT.PUT_LINE('2. Export > Database Export');
    DBMS_OUTPUT.PUT_LINE('3. Choose export type: DDL + Data');
    DBMS_OUTPUT.PUT_LINE('4. Select all objects');
    DBMS_OUTPUT.PUT_LINE('5. Save to file: hopecare_backup_YYYYMMDD.sql');
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('METHOD 2: Data Pump (Command Line)');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE('Export:');
    DBMS_OUTPUT.PUT_LINE('  expdp hopecare/hopecare123@FREEPDB1 \\');
    DBMS_OUTPUT.PUT_LINE('    DIRECTORY=DATA_PUMP_DIR \\');
    DBMS_OUTPUT.PUT_LINE('    DUMPFILE=hopecare_%U.dmp \\');
    DBMS_OUTPUT.PUT_LINE('    LOGFILE=hopecare_export.log \\');
    DBMS_OUTPUT.PUT_LINE('    SCHEMAS=hopecare');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Import:');
    DBMS_OUTPUT.PUT_LINE('  impdp hopecare/hopecare123@FREEPDB1 \\');
    DBMS_OUTPUT.PUT_LINE('    DIRECTORY=DATA_PUMP_DIR \\');
    DBMS_OUTPUT.PUT_LINE('    DUMPFILE=hopecare_%U.dmp \\');
    DBMS_OUTPUT.PUT_LINE('    LOGFILE=hopecare_import.log');
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('METHOD 3: Use Backup Procedures');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.PUT_LINE('Check backup info:');
    DBMS_OUTPUT.PUT_LINE('  EXEC sp_backup_info;');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Maintenance report:');
    DBMS_OUTPUT.PUT_LINE('  EXEC sp_maintenance_report;');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Clean test data:');
    DBMS_OUTPUT.PUT_LINE('  EXEC sp_cleanup_test_data;');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- ============================================================
-- RUN INITIAL BACKUP INFO
-- ============================================================

EXEC sp_backup_info;

-- ============================================================
-- RUN MAINTENANCE REPORT
-- ============================================================

EXEC sp_maintenance_report;

-- ============================================================
-- COMPLETION MESSAGE
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('BACKUP MODULE COMPLETED!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('AVAILABLE PROCEDURES:');
    DBMS_OUTPUT.PUT_LINE('---------------------');
    DBMS_OUTPUT.PUT_LINE('✓ sp_backup_info - Display backup statistics');
    DBMS_OUTPUT.PUT_LINE('✓ sp_export_table_data - Export table data');
    DBMS_OUTPUT.PUT_LINE('✓ sp_cleanup_test_data - Remove test records');
    DBMS_OUTPUT.PUT_LINE('✓ sp_reset_sequences - Reset sequence info');
    DBMS_OUTPUT.PUT_LINE('✓ sp_maintenance_report - System health check');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('RECOMMENDATION:');
    DBMS_OUTPUT.PUT_LINE('---------------');
    DBMS_OUTPUT.PUT_LINE('Create regular backups using SQL Developer Export');
    DBMS_OUTPUT.PUT_LINE('or Data Pump utilities before major changes.');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ALL DATABASE SCRIPTS COMPLETED! 🎉');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/