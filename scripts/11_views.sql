-- ================================================================
-- HOPECARE PROJECT - 11_VIEWS.SQL
-- Business views for simplified queries
-- ================================================================

-- ============================================================
-- VIEW 1: DONOR SUMMARY
-- ============================================================

CREATE OR REPLACE VIEW vw_donor_summary AS
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
    COUNT(DISTINCT don.donation_id) AS total_donations,
    -- Money donations converted to PEN
    SUM(CASE 
        WHEN dt.type_code = 'MONEY' THEN
            CASE 
                WHEN c.currency_code = 'PEN' THEN don.amount
                ELSE don.amount * NVL((
                    SELECT exchange_rate 
                    FROM tbl_exchange_rates 
                    WHERE from_currency_id = don.currency_id 
                    AND to_currency_id = (SELECT currency_id FROM tbl_currencies WHERE currency_code = 'PEN')
                    AND is_active = 'Y'
                    AND ROWNUM = 1
                ), 1)
            END
        ELSE don.quantity * NVL(don.unit_value, 0)
    END) AS total_value_pen,
    MAX(don.donation_date) AS last_donation_date
FROM tbl_donors d
LEFT JOIN tbl_donations don ON d.donor_id = don.donor_id
LEFT JOIN tbl_donation_types dt ON don.donation_type_id = dt.donation_type_id
LEFT JOIN tbl_currencies c ON don.currency_id = c.currency_id
GROUP BY 
    d.donor_id,
    d.donor_code,
    d.full_name,
    d.email,
    d.phone,
    d.donor_type,
    d.address,
    d.is_active,
    d.created_at;

PROMPT 'View created: VW_DONOR_SUMMARY';

-- ============================================================
-- VIEW 2: BENEFICIARY SUMMARY
-- ============================================================

CREATE OR REPLACE VIEW vw_beneficiary_summary AS
SELECT 
    b.beneficiary_id,
    b.beneficiary_code,
    b.full_name,
    b.family_size,
    b.phone,
    b.address,
    b.district,
    b.city,
    b.is_active,
    b.created_at,
    COUNT(DISTINCT d.delivery_id) AS total_deliveries,
    SUM(CASE WHEN d.status = 'COMPLETED' THEN d.quantity_delivered ELSE 0 END) AS total_quantity_received,
    SUM(CASE WHEN d.status = 'COMPLETED' THEN d.total_value ELSE 0 END) AS total_value_received_pen,
    MAX(d.delivery_date) AS last_delivery_date
FROM tbl_beneficiaries b
LEFT JOIN tbl_deliveries d ON b.beneficiary_id = d.beneficiary_id
GROUP BY 
    b.beneficiary_id,
    b.beneficiary_code,
    b.full_name,
    b.family_size,
    b.phone,
    b.address,
    b.district,
    b.city,
    b.is_active,
    b.created_at;

PROMPT 'View created: VW_BENEFICIARY_SUMMARY';

-- ============================================================
-- VIEW 3: PROGRAM SUMMARY
-- ============================================================

CREATE OR REPLACE VIEW vw_program_summary AS
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
    COUNT(DISTINCT da.donation_id) AS total_donations_received,
    SUM(da.assigned_value) AS total_donation_value_pen,
    COUNT(DISTINCT d.delivery_id) AS total_deliveries_made,
    SUM(CASE WHEN d.status = 'COMPLETED' THEN d.total_value ELSE 0 END) AS total_delivery_value_pen,
    COUNT(DISTINCT d.beneficiary_id) AS unique_beneficiaries_served,
    COUNT(DISTINCT i.inventory_id) AS inventory_items
FROM tbl_programs p
LEFT JOIN tbl_donation_assignments da ON p.program_id = da.program_id
LEFT JOIN tbl_deliveries d ON p.program_id = d.program_id
LEFT JOIN tbl_program_inventory i ON p.program_id = i.program_id
GROUP BY 
    p.program_id,
    p.program_code,
    p.program_name,
    p.description,
    p.program_type,
    p.start_date,
    p.end_date,
    p.is_active,
    p.created_at;

PROMPT 'View created: VW_PROGRAM_SUMMARY';

-- ============================================================
-- VIEW 4: DONATION DETAILS
-- ============================================================

CREATE OR REPLACE VIEW vw_donation_details AS
SELECT 
    d.donation_id,
    d.donation_code,
    d.donation_date,
    -- Donor info
    don.donor_code,
    don.full_name AS donor_name,
    don.donor_type,
    -- Donation type
    dt.type_code AS donation_type_code,
    dt.type_name AS donation_type_name,
    -- Money donation info
    d.amount AS original_amount,
    c.currency_code,
    c.symbol AS currency_symbol,
    CASE 
        WHEN dt.type_code = 'MONEY' AND c.currency_code = 'PEN' THEN d.amount
        WHEN dt.type_code = 'MONEY' THEN d.amount * NVL((
            SELECT exchange_rate 
            FROM tbl_exchange_rates 
            WHERE from_currency_id = d.currency_id 
            AND to_currency_id = (SELECT currency_id FROM tbl_currencies WHERE currency_code = 'PEN')
            AND is_active = 'Y'
            AND ROWNUM = 1
        ), 1)
        ELSE d.quantity * NVL(d.unit_value, 0)
    END AS amount_in_pen,
    -- Product donation info
    d.product_description,
    d.quantity,
    d.unit_value,
    -- Program assignment
    p.program_code,
    p.program_name,
    -- Metadata
    d.notes,
    u.full_name AS created_by_name,
    d.created_at
FROM tbl_donations d
JOIN tbl_donors don ON d.donor_id = don.donor_id
JOIN tbl_donation_types dt ON d.donation_type_id = dt.donation_type_id
LEFT JOIN tbl_currencies c ON d.currency_id = c.currency_id
LEFT JOIN tbl_donation_assignments da ON d.donation_id = da.donation_id
LEFT JOIN tbl_programs p ON da.program_id = p.program_id
JOIN tbl_users u ON d.created_by = u.user_id;

PROMPT 'View created: VW_DONATION_DETAILS';

-- ============================================================
-- VIEW 5: DELIVERY DETAILS
-- ============================================================

CREATE OR REPLACE VIEW vw_delivery_details AS
SELECT 
    d.delivery_id,
    d.delivery_code,
    d.delivery_date,
    d.status,
    -- Beneficiary info
    b.beneficiary_code,
    b.full_name AS beneficiary_name,
    b.family_size,
    b.district,
    b.city,
    -- Program info
    p.program_code,
    p.program_name,
    p.program_type,
    -- Delivery details
    d.product_description,
    d.quantity_delivered,
    d.unit_value,
    d.total_value,
    d.notes,
    -- User info
    u_created.full_name AS created_by_name,
    u_approved.full_name AS approved_by_name,
    d.created_at
FROM tbl_deliveries d
JOIN tbl_beneficiaries b ON d.beneficiary_id = b.beneficiary_id
JOIN tbl_programs p ON d.program_id = p.program_id
JOIN tbl_users u_created ON d.created_by = u_created.user_id
LEFT JOIN tbl_users u_approved ON d.approved_by = u_approved.user_id;

PROMPT 'View created: VW_DELIVERY_DETAILS';

-- ============================================================
-- VIEW 6: INVENTORY STATUS
-- ============================================================

CREATE OR REPLACE VIEW vw_inventory_status AS
SELECT 
    i.inventory_id,
    p.program_id,
    p.program_code,
    p.program_name,
    i.product_description,
    i.available_quantity,
    i.reserved_quantity,
    i.delivered_quantity,
    (i.available_quantity + i.reserved_quantity + i.delivered_quantity) AS total_quantity,
    i.unit_value,
    i.available_quantity * NVL(i.unit_value, 0) AS available_value,
    CASE 
        WHEN i.available_quantity = 0 THEN 'OUT_OF_STOCK'
        WHEN i.available_quantity < 10 THEN 'LOW_STOCK'
        WHEN i.available_quantity < 50 THEN 'MEDIUM_STOCK'
        ELSE 'GOOD_STOCK'
    END AS stock_status,
    i.last_updated
FROM tbl_program_inventory i
JOIN tbl_programs p ON i.program_id = p.program_id
WHERE p.is_active = 'Y';

PROMPT 'View created: VW_INVENTORY_STATUS';

-- ============================================================
-- VIEW 7: RECENT ACTIVITY (Last 30 days)
-- ============================================================

CREATE OR REPLACE VIEW vw_recent_activity AS
SELECT 
    'DONATION' AS activity_type,
    d.donation_code AS activity_code,
    don.full_name AS entity_name,
    dt.type_name AS description,
    CASE 
        WHEN dt.type_code = 'MONEY' THEN TO_CHAR(d.amount) || ' ' || c.currency_code
        ELSE d.quantity || ' units of ' || d.product_description
    END AS details,
    d.donation_date AS activity_date,
    u.full_name AS performed_by
FROM tbl_donations d
JOIN tbl_donors don ON d.donor_id = don.donor_id
JOIN tbl_donation_types dt ON d.donation_type_id = dt.donation_type_id
LEFT JOIN tbl_currencies c ON d.currency_id = c.currency_id
JOIN tbl_users u ON d.created_by = u.user_id
WHERE d.donation_date >= SYSDATE - 30

UNION ALL

SELECT 
    'DELIVERY' AS activity_type,
    d.delivery_code AS activity_code,
    b.full_name AS entity_name,
    'Delivery - ' || p.program_name AS description,
    d.quantity_delivered || ' units of ' || d.product_description AS details,
    d.delivery_date AS activity_date,
    u.full_name AS performed_by
FROM tbl_deliveries d
JOIN tbl_beneficiaries b ON d.beneficiary_id = b.beneficiary_id
JOIN tbl_programs p ON d.program_id = p.program_id
JOIN tbl_users u ON d.created_by = u.user_id
WHERE d.delivery_date >= SYSDATE - 30

ORDER BY activity_date DESC;

PROMPT 'View created: VW_RECENT_ACTIVITY';

-- ============================================================
-- VIEW 8: DASHBOARD METRICS
-- ============================================================

CREATE OR REPLACE VIEW vw_dashboard_metrics AS
SELECT
    -- Donors
    (SELECT COUNT(*) FROM tbl_donors WHERE is_active = 'Y') AS total_active_donors,
    (SELECT COUNT(*) FROM tbl_donors WHERE is_active = 'Y' AND created_at >= SYSDATE - 30) AS new_donors_last_month,
    
    -- Beneficiaries
    (SELECT COUNT(*) FROM tbl_beneficiaries WHERE is_active = 'Y') AS total_active_beneficiaries,
    (SELECT SUM(family_size) FROM tbl_beneficiaries WHERE is_active = 'Y') AS total_people_served,
    
    -- Programs
    (SELECT COUNT(*) FROM tbl_programs WHERE is_active = 'Y') AS total_active_programs,
    
    -- Donations
    (SELECT COUNT(*) FROM tbl_donations) AS total_donations_all_time,
    (SELECT COUNT(*) FROM tbl_donations WHERE donation_date >= SYSDATE - 30) AS donations_last_month,
    (SELECT SUM(
        CASE 
            WHEN dt.type_code = 'MONEY' THEN
                CASE 
                    WHEN c.currency_code = 'PEN' THEN d.amount
                    ELSE d.amount * NVL((
                        SELECT exchange_rate 
                        FROM tbl_exchange_rates 
                        WHERE from_currency_id = d.currency_id 
                        AND to_currency_id = (SELECT currency_id FROM tbl_currencies WHERE currency_code = 'PEN')
                        AND is_active = 'Y'
                        AND ROWNUM = 1
                    ), 1)
                END
            ELSE d.quantity * NVL(d.unit_value, 0)
        END
    ) FROM tbl_donations d
    LEFT JOIN tbl_donation_types dt ON d.donation_type_id = dt.donation_type_id
    LEFT JOIN tbl_currencies c ON d.currency_id = c.currency_id) AS total_donations_value_pen,
    
    -- Deliveries
    (SELECT COUNT(*) FROM tbl_deliveries WHERE status = 'COMPLETED') AS total_deliveries_completed,
    (SELECT COUNT(*) FROM tbl_deliveries WHERE status = 'COMPLETED' AND delivery_date >= SYSDATE - 30) AS deliveries_last_month,
    (SELECT SUM(total_value) FROM tbl_deliveries WHERE status = 'COMPLETED') AS total_deliveries_value_pen,
    
    -- Inventory
    (SELECT COUNT(*) FROM tbl_program_inventory WHERE available_quantity > 0) AS inventory_items_in_stock,
    (SELECT COUNT(*) FROM tbl_program_inventory WHERE available_quantity = 0) AS inventory_items_out_of_stock
    
FROM DUAL;

PROMPT 'View created: VW_DASHBOARD_METRICS';

-- ============================================================
-- SUCCESS MESSAGE
-- ============================================================

BEGIN
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('ALL VIEWS CREATED SUCCESSFULLY!');
  DBMS_OUTPUT.PUT_LINE('Business Views:');
  DBMS_OUTPUT.PUT_LINE('  - vw_donor_summary');
  DBMS_OUTPUT.PUT_LINE('  - vw_beneficiary_summary');
  DBMS_OUTPUT.PUT_LINE('  - vw_program_summary');
  DBMS_OUTPUT.PUT_LINE('Detail Views:');
  DBMS_OUTPUT.PUT_LINE('  - vw_donation_details');
  DBMS_OUTPUT.PUT_LINE('  - vw_delivery_details');
  DBMS_OUTPUT.PUT_LINE('Operational Views:');
  DBMS_OUTPUT.PUT_LINE('  - vw_inventory_status');
  DBMS_OUTPUT.PUT_LINE('  - vw_recent_activity');
  DBMS_OUTPUT.PUT_LINE('  - vw_dashboard_metrics');
  DBMS_OUTPUT.PUT_LINE('========================================');
END;
/