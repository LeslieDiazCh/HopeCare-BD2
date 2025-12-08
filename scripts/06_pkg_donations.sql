-- ================================================================
-- HOPECARE PROJECT - 06_PKG_REPORTS.SQL
-- Package for generating reports and statistics
-- ================================================================

-- ============================================================
-- PACKAGE SPECIFICATION
-- ============================================================

CREATE OR REPLACE PACKAGE pkg_reports AS
    
    -- Get total donations by period
    PROCEDURE total_donations_by_period(
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_cursor OUT SYS_REFCURSOR
    );
    
    -- Get donations by program
    PROCEDURE donations_by_program(
        p_cursor OUT SYS_REFCURSOR
    );
    
    -- Get top donors (most active)
    PROCEDURE top_donors(
        p_limit IN NUMBER DEFAULT 10,
        p_cursor OUT SYS_REFCURSOR
    );
    
    -- Get deliveries summary by program
    PROCEDURE deliveries_summary(
        p_cursor OUT SYS_REFCURSOR
    );
    
    -- Get program inventory status
    PROCEDURE program_inventory_status(
        p_program_id IN NUMBER DEFAULT NULL,
        p_cursor OUT SYS_REFCURSOR
    );
    
    -- Get donations by type (Money vs Product)
    PROCEDURE donations_by_type(
        p_cursor OUT SYS_REFCURSOR
    );
    
END pkg_reports;
/

PROMPT 'Package specification created: PKG_REPORTS';

-- ============================================================
-- PACKAGE BODY
-- ============================================================

CREATE OR REPLACE PACKAGE BODY pkg_reports AS

    -- ========================================================
    -- Get total donations by period
    -- ========================================================
    PROCEDURE total_donations_by_period(
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                TO_CHAR(d.donation_date, 'YYYY-MM') AS period,
                dt.type_name AS donation_type,
                COUNT(*) AS total_donations,
                -- Money donations in PEN
                SUM(CASE 
                    WHEN dt.type_code = 'MONEY' THEN
                        CASE 
                            WHEN c.currency_code = 'PEN' THEN d.amount
                            ELSE d.amount * (
                                SELECT exchange_rate 
                                FROM tbl_exchange_rates 
                                WHERE from_currency_id = d.currency_id 
                                AND to_currency_id = (SELECT currency_id FROM tbl_currencies WHERE currency_code = 'PEN')
                                AND is_active = 'Y'
                                AND ROWNUM = 1
                            )
                        END
                    ELSE d.quantity * NVL(d.unit_value, 0)
                END) AS total_value_pen
            FROM tbl_donations d
            JOIN tbl_donation_types dt ON d.donation_type_id = dt.donation_type_id
            LEFT JOIN tbl_currencies c ON d.currency_id = c.currency_id
            WHERE d.donation_date BETWEEN p_start_date AND p_end_date
            GROUP BY TO_CHAR(d.donation_date, 'YYYY-MM'), dt.type_name
            ORDER BY period DESC, dt.type_name;
    END total_donations_by_period;

    -- ========================================================
    -- Get donations by program
    -- ========================================================
    PROCEDURE donations_by_program(
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                p.program_code,
                p.program_name,
                p.program_type,
                COUNT(DISTINCT da.donation_id) AS total_donations,
                COUNT(DISTINCT da.assignment_id) AS total_assignments,
                SUM(da.assigned_value) AS total_value_pen,
                SUM(da.assigned_quantity) AS total_quantity
            FROM tbl_programs p
            LEFT JOIN tbl_donation_assignments da ON p.program_id = da.program_id
            WHERE p.is_active = 'Y'
            GROUP BY p.program_code, p.program_name, p.program_type
            ORDER BY total_value_pen DESC NULLS LAST;
    END donations_by_program;

    -- ========================================================
    -- Get top donors (most active)
    -- ========================================================
    PROCEDURE top_donors(
        p_limit IN NUMBER DEFAULT 10,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT * FROM (
                SELECT 
                    d.donor_code,
                    d.full_name,
                    d.email,
                    d.donor_type,
                    COUNT(don.donation_id) AS total_donations,
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
                WHERE d.is_active = 'Y'
                GROUP BY d.donor_code, d.full_name, d.email, d.donor_type
                ORDER BY total_value_pen DESC NULLS LAST
            )
            WHERE ROWNUM <= p_limit;
    END top_donors;

    -- ========================================================
    -- Get deliveries summary by program
    -- ========================================================
    PROCEDURE deliveries_summary(
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                p.program_code,
                p.program_name,
                COUNT(DISTINCT d.delivery_id) AS total_deliveries,
                COUNT(DISTINCT d.beneficiary_id) AS unique_beneficiaries,
                SUM(d.quantity_delivered) AS total_quantity_delivered,
                SUM(d.total_value) AS total_value_pen,
                SUM(CASE WHEN d.status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_deliveries,
                SUM(CASE WHEN d.status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_deliveries
            FROM tbl_programs p
            LEFT JOIN tbl_deliveries d ON p.program_id = d.program_id
            WHERE p.is_active = 'Y'
            GROUP BY p.program_code, p.program_name
            ORDER BY total_value_pen DESC NULLS LAST;
    END deliveries_summary;

    -- ========================================================
    -- Get program inventory status
    -- ========================================================
    PROCEDURE program_inventory_status(
        p_program_id IN NUMBER DEFAULT NULL,
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        IF p_program_id IS NULL THEN
            -- All programs
            OPEN p_cursor FOR
                SELECT 
                    p.program_code,
                    p.program_name,
                    i.product_description,
                    i.available_quantity,
                    i.reserved_quantity,
                    i.delivered_quantity,
                    i.unit_value,
                    i.available_quantity * NVL(i.unit_value, 0) AS available_value,
                    i.last_updated,
                    CASE 
                        WHEN i.available_quantity = 0 THEN 'OUT_OF_STOCK'
                        WHEN i.available_quantity < 10 THEN 'LOW_STOCK'
                        ELSE 'AVAILABLE'
                    END AS stock_status
                FROM tbl_programs p
                LEFT JOIN tbl_program_inventory i ON p.program_id = i.program_id
                WHERE p.is_active = 'Y'
                ORDER BY p.program_code, i.product_description;
        ELSE
            -- Specific program
            OPEN p_cursor FOR
                SELECT 
                    p.program_code,
                    p.program_name,
                    i.product_description,
                    i.available_quantity,
                    i.reserved_quantity,
                    i.delivered_quantity,
                    i.unit_value,
                    i.available_quantity * NVL(i.unit_value, 0) AS available_value,
                    i.last_updated,
                    CASE 
                        WHEN i.available_quantity = 0 THEN 'OUT_OF_STOCK'
                        WHEN i.available_quantity < 10 THEN 'LOW_STOCK'
                        ELSE 'AVAILABLE'
                    END AS stock_status
                FROM tbl_programs p
                LEFT JOIN tbl_program_inventory i ON p.program_id = i.program_id
                WHERE p.program_id = p_program_id
                ORDER BY i.product_description;
        END IF;
    END program_inventory_status;

    -- ========================================================
    -- Get donations by type (Money vs Product)
    -- ========================================================
    PROCEDURE donations_by_type(
        p_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT 
                dt.type_code,
                dt.type_name,
                COUNT(d.donation_id) AS total_donations,
                -- Money in PEN, Products by value
                SUM(CASE 
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
                END) AS total_value_pen,
                ROUND(AVG(CASE 
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
                END), 2) AS avg_value_pen
            FROM tbl_donation_types dt
            LEFT JOIN tbl_donations d ON dt.donation_type_id = d.donation_type_id
            LEFT JOIN tbl_currencies c ON d.currency_id = c.currency_id
            GROUP BY dt.type_code, dt.type_name
            ORDER BY total_value_pen DESC;
    END donations_by_type;

END pkg_reports;
/

PROMPT 'Package body created: PKG_REPORTS';

-- ============================================================
-- SUCCESS MESSAGE
-- ============================================================

BEGIN
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('PKG_REPORTS CREATED SUCCESSFULLY!');
  DBMS_OUTPUT.PUT_LINE('Procedures:');
  DBMS_OUTPUT.PUT_LINE('  - total_donations_by_period');
  DBMS_OUTPUT.PUT_LINE('  - donations_by_program');
  DBMS_OUTPUT.PUT_LINE('  - top_donors');
  DBMS_OUTPUT.PUT_LINE('  - deliveries_summary');
  DBMS_OUTPUT.PUT_LINE('  - program_inventory_status');
  DBMS_OUTPUT.PUT_LINE('  - donations_by_type');
  DBMS_OUTPUT.PUT_LINE('========================================');
END;
/