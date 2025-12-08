-- ================================================================
-- HOPECARE PROJECT - 12_TEST_OPERATIONS.SQL
-- Complete integration tests for all modules
-- ================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

BEGIN
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('HOPECARE - INTEGRATION TESTS');
  DBMS_OUTPUT.PUT_LINE('Testing all modules end-to-end');
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================
-- TEST SUITE 1: DONOR MANAGEMENT
-- ============================================================

DECLARE
    v_donor_id NUMBER;
    v_timestamp VARCHAR2(20) := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST SUITE 1: DONOR MANAGEMENT ===');
    
    -- Test 1.1: Register individual donor
    pkg_donors.register_donor(
        p_full_name => 'Test Individual ' || v_timestamp,
        p_email => 'test.individual.' || v_timestamp || '@test.com',
        p_phone => '999888777',
        p_donor_type => 'INDIVIDUAL',
        p_address => 'Test Address 123',
        p_donor_id => v_donor_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ Individual donor registered: ID=' || v_donor_id);
    
    -- Test 1.2: Register corporate donor
    pkg_donors.register_donor(
        p_full_name => 'Test Corp ' || v_timestamp,
        p_email => 'test.corp.' || v_timestamp || '@test.com',
        p_phone => '999888666',
        p_donor_type => 'CORPORATE',
        p_address => 'Corporate HQ 456',
        p_donor_id => v_donor_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ Corporate donor registered: ID=' || v_donor_id);
    
    -- Test 1.3: Update donor
    pkg_donors.update_donor(
        p_donor_id => v_donor_id,
        p_full_name => 'Test Corp Updated ' || v_timestamp,
        p_email => 'test.corp.updated.' || v_timestamp || '@test.com',
        p_phone => '999888555',
        p_address => 'New Corporate Address'
    );
    DBMS_OUTPUT.PUT_LINE('✓ Donor updated successfully');
    
    DBMS_OUTPUT.PUT_LINE('');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ DONOR TEST FAILED: ' || SQLERRM);
        ROLLBACK;
END;
/

-- ============================================================
-- TEST SUITE 2: BENEFICIARY MANAGEMENT
-- ============================================================

DECLARE
    v_beneficiary_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST SUITE 2: BENEFICIARY MANAGEMENT ===');
    
    -- Test 2.1: Register beneficiary
    pkg_beneficiaries.register_beneficiary(
        p_full_name => 'Test Family Rodriguez',
        p_family_size => 5,
        p_phone => '987654321',
        p_address => 'Test Street 789',
        p_district => 'Test District',
        p_city => 'Lima',
        p_notes => 'Test family for integration testing',
        p_beneficiary_id => v_beneficiary_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ Beneficiary registered: ID=' || v_beneficiary_id);
    
    -- Test 2.2: Update beneficiary
    pkg_beneficiaries.update_beneficiary(
        p_beneficiary_id => v_beneficiary_id,
        p_full_name => 'Test Family Rodriguez Updated',
        p_family_size => 6,
        p_phone => '987654322',
        p_address => 'Updated Test Street 789',
        p_district => 'Test District',
        p_city => 'Lima',
        p_notes => 'Updated notes'
    );
    DBMS_OUTPUT.PUT_LINE('✓ Beneficiary updated successfully');
    
    DBMS_OUTPUT.PUT_LINE('');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ BENEFICIARY TEST FAILED: ' || SQLERRM);
        ROLLBACK;
END;
/

-- ============================================================
-- TEST SUITE 3: PROGRAM MANAGEMENT
-- ============================================================

DECLARE
    v_program_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST SUITE 3: PROGRAM MANAGEMENT ===');
    
    -- Test 3.1: Create program
    pkg_programs.create_program(
        p_program_name => 'Test Emergency Program',
        p_description => 'Integration test program',
        p_program_type => 'EMERGENCY',
        p_start_date => SYSDATE,
        p_end_date => ADD_MONTHS(SYSDATE, 3),
        p_program_id => v_program_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ Program created: ID=' || v_program_id);
    
    -- Test 3.2: Update program
    pkg_programs.update_program(
        p_program_id => v_program_id,
        p_program_name => 'Test Emergency & Relief Program',
        p_description => 'Updated test program',
        p_program_type => 'EMERGENCY',
        p_start_date => SYSDATE,
        p_end_date => ADD_MONTHS(SYSDATE, 6)
    );
    DBMS_OUTPUT.PUT_LINE('✓ Program updated successfully');
    
    DBMS_OUTPUT.PUT_LINE('');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ PROGRAM TEST FAILED: ' || SQLERRM);
        ROLLBACK;
END;
/

-- ============================================================
-- TEST SUITE 4: DONATION MANAGEMENT
-- ============================================================

DECLARE
    v_donation_id NUMBER;
    v_donor_id NUMBER := 1; -- Using existing donor
    v_program_id NUMBER := 1; -- Using existing program
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST SUITE 4: DONATION MANAGEMENT ===');
    
    -- Test 4.1: Money donation in PEN
    pkg_donations.register_money_donation(
        p_donor_id => v_donor_id,
        p_amount => 1000,
        p_currency_id => 1, -- PEN
        p_program_id => v_program_id,
        p_notes => 'Test donation PEN',
        p_created_by => 1,
        p_donation_id => v_donation_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ Money donation (PEN) registered: ID=' || v_donation_id);
    
    -- Test 4.2: Money donation in USD
    pkg_donations.register_money_donation(
        p_donor_id => v_donor_id,
        p_amount => 500,
        p_currency_id => 2, -- USD
        p_program_id => v_program_id,
        p_notes => 'Test donation USD',
        p_created_by => 1,
        p_donation_id => v_donation_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ Money donation (USD) registered: ID=' || v_donation_id);
    
    -- Test 4.3: Product donation
    pkg_donations.register_product_donation(
        p_donor_id => v_donor_id,
        p_product_description => 'Test Product - Integration',
        p_quantity => 100,
        p_unit_value => 5.00,
        p_program_id => v_program_id,
        p_notes => 'Test product donation',
        p_created_by => 1,
        p_donation_id => v_donation_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ Product donation registered: ID=' || v_donation_id);
    
    -- Test 4.4: Currency conversion
    DECLARE
        v_converted NUMBER;
    BEGIN
        v_converted := pkg_donations.convert_to_base_currency(100, 2); -- 100 USD to PEN
        DBMS_OUTPUT.PUT_LINE('✓ Currency conversion: 100 USD = ' || v_converted || ' PEN');
    END;
    
    -- Test 4.5: Donor total contributions
    DECLARE
        v_total NUMBER;
    BEGIN
        v_total := pkg_donations.get_donor_total_contributions(v_donor_id);
        DBMS_OUTPUT.PUT_LINE('✓ Donor total contributions: ' || v_total || ' PEN');
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ DONATION TEST FAILED: ' || SQLERRM);
        ROLLBACK;
END;
/

-- ============================================================
-- TEST SUITE 5: DELIVERY MANAGEMENT WITH STOCK VALIDATION
-- ============================================================

DECLARE
    v_delivery_id NUMBER;
    v_beneficiary_id NUMBER := 1; -- Using existing beneficiary
    v_program_id NUMBER := 1; -- Using existing program
    v_available_stock NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST SUITE 5: DELIVERY MANAGEMENT ===');
    
    -- Test 5.1: Check stock before delivery
    v_available_stock := pkg_deliveries.get_available_stock(v_program_id, 'Rice 1kg bags');
    DBMS_OUTPUT.PUT_LINE('✓ Current stock of Rice: ' || v_available_stock || ' units');
    
    -- Test 5.2: Valid delivery
    IF v_available_stock >= 5 THEN
        pkg_deliveries.perform_delivery(
            p_beneficiary_id => v_beneficiary_id,
            p_program_id => v_program_id,
            p_product_description => 'Rice 1kg bags',
            p_quantity => 5,
            p_notes => 'Test delivery',
            p_created_by => 2,
            p_delivery_id => v_delivery_id
        );
        DBMS_OUTPUT.PUT_LINE('✓ Delivery completed: ID=' || v_delivery_id);
    ELSE
        DBMS_OUTPUT.PUT_LINE('⚠ Skipping delivery test - insufficient stock');
    END IF;
    
    -- Test 5.3: Try invalid delivery (exceeds stock)
    BEGIN
        pkg_deliveries.perform_delivery(
            p_beneficiary_id => v_beneficiary_id,
            p_program_id => v_program_id,
            p_product_description => 'Rice 1kg bags',
            p_quantity => 10000,
            p_notes => 'This should fail',
            p_created_by => 2,
            p_delivery_id => v_delivery_id
        );
        DBMS_OUTPUT.PUT_LINE('✗ VALIDATION FAILED - Should have rejected invalid delivery');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('✓ Stock validation working - correctly rejected: ' || SUBSTR(SQLERRM, 1, 50));
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ DELIVERY TEST FAILED: ' || SQLERRM);
        ROLLBACK;
END;
/

-- ============================================================
-- TEST SUITE 6: REPORTING
-- ============================================================

DECLARE
    v_cursor SYS_REFCURSOR;
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST SUITE 6: REPORTING ===');
    
    -- Test 6.1: Donations by program
    pkg_reports.donations_by_program(v_cursor);
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('✓ Donations by program report executed');
    
    -- Test 6.2: Top donors
    pkg_reports.top_donors(5, v_cursor);
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('✓ Top donors report executed');
    
    -- Test 6.3: Deliveries summary
    pkg_reports.deliveries_summary(v_cursor);
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('✓ Deliveries summary report executed');
    
    -- Test 6.4: Inventory status
    pkg_reports.program_inventory_status(NULL, v_cursor);
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('✓ Inventory status report executed');
    
    -- Test 6.5: Donations by type
    pkg_reports.donations_by_type(v_cursor);
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('✓ Donations by type report executed');
    
    DBMS_OUTPUT.PUT_LINE('');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ REPORTING TEST FAILED: ' || SQLERRM);
END;
/

-- ============================================================
-- TEST SUITE 7: VIEWS
-- ============================================================

DECLARE
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST SUITE 7: VIEWS ===');
    
    -- Test 7.1: Donor summary view
    SELECT COUNT(*) INTO v_count FROM vw_donor_summary;
    DBMS_OUTPUT.PUT_LINE('✓ vw_donor_summary: ' || v_count || ' records');
    
    -- Test 7.2: Beneficiary summary view
    SELECT COUNT(*) INTO v_count FROM vw_beneficiary_summary;
    DBMS_OUTPUT.PUT_LINE('✓ vw_beneficiary_summary: ' || v_count || ' records');
    
    -- Test 7.3: Program summary view
    SELECT COUNT(*) INTO v_count FROM vw_program_summary;
    DBMS_OUTPUT.PUT_LINE('✓ vw_program_summary: ' || v_count || ' records');
    
    -- Test 7.4: Donation details view
    SELECT COUNT(*) INTO v_count FROM vw_donation_details;
    DBMS_OUTPUT.PUT_LINE('✓ vw_donation_details: ' || v_count || ' records');
    
    -- Test 7.5: Delivery details view
    SELECT COUNT(*) INTO v_count FROM vw_delivery_details;
    DBMS_OUTPUT.PUT_LINE('✓ vw_delivery_details: ' || v_count || ' records');
    
    -- Test 7.6: Inventory status view
    SELECT COUNT(*) INTO v_count FROM vw_inventory_status;
    DBMS_OUTPUT.PUT_LINE('✓ vw_inventory_status: ' || v_count || ' records');
    
    -- Test 7.7: Recent activity view
    SELECT COUNT(*) INTO v_count FROM vw_recent_activity;
    DBMS_OUTPUT.PUT_LINE('✓ vw_recent_activity: ' || v_count || ' records');
    
    -- Test 7.8: Dashboard metrics view
    SELECT COUNT(*) INTO v_count FROM vw_dashboard_metrics;
    DBMS_OUTPUT.PUT_LINE('✓ vw_dashboard_metrics: ' || v_count || ' records');
    
    DBMS_OUTPUT.PUT_LINE('');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ VIEWS TEST FAILED: ' || SQLERRM);
END;
/

-- ============================================================
-- TEST SUITE 8: AUDIT TRIGGERS
-- ============================================================

DECLARE
    v_donation_id NUMBER;
    v_audit_count_before NUMBER;
    v_audit_count_after NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST SUITE 8: AUDIT TRIGGERS ===');
    
    -- Test 8.1: Check audit before operation
    SELECT COUNT(*) INTO v_audit_count_before FROM tbl_audit_donations;
    
    -- Test 8.2: Perform operation that should trigger audit
    pkg_donations.register_money_donation(
        p_donor_id => 1,
        p_amount => 50,
        p_currency_id => 1,
        p_program_id => 1,
        p_notes => 'Audit trigger test',
        p_created_by => 1,
        p_donation_id => v_donation_id
    );
    
    -- Test 8.3: Check audit after operation
    SELECT COUNT(*) INTO v_audit_count_after FROM tbl_audit_donations;
    
    IF v_audit_count_after > v_audit_count_before THEN
        DBMS_OUTPUT.PUT_LINE('✓ Donation audit trigger working: ' || 
            (v_audit_count_after - v_audit_count_before) || ' new audit record(s)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✗ Donation audit trigger may not be working');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ AUDIT TEST FAILED: ' || SQLERRM);
        ROLLBACK;
END;
/

-- ============================================================
-- FINAL SUMMARY
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('INTEGRATION TESTS COMPLETED');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('DATABASE STATISTICS:');
    DBMS_OUTPUT.PUT_LINE('--------------------');
END;
/

-- Show statistics
SELECT 'Active Donors' AS metric, COUNT(*) AS count FROM tbl_donors WHERE is_active = 'Y'
UNION ALL
SELECT 'Active Beneficiaries', COUNT(*) FROM tbl_beneficiaries WHERE is_active = 'Y'
UNION ALL
SELECT 'Active Programs', COUNT(*) FROM tbl_programs WHERE is_active = 'Y'
UNION ALL
SELECT 'Total Donations', COUNT(*) FROM tbl_donations
UNION ALL
SELECT 'Total Deliveries', COUNT(*) FROM tbl_deliveries
UNION ALL
SELECT 'Inventory Items', COUNT(*) FROM tbl_program_inventory
UNION ALL
SELECT 'Audit Records (Donations)', COUNT(*) FROM tbl_audit_donations
UNION ALL
SELECT 'Audit Records (Deliveries)', COUNT(*) FROM tbl_audit_deliveries;

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('All tests executed. Check results above.');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/