-- ================================================================
-- HOPECARE PROJECT - 03_DATA_CATALOGS_AND_TEST.SQL
-- Loads catalog data and test records
-- ================================================================

-- ============================================================
-- CATALOG DATA
-- ============================================================

-- Currencies
INSERT INTO tbl_currencies VALUES (seq_currencies.NEXTVAL, 'PEN', 'Peruvian Sol', 'S/', 'Y', CURRENT_TIMESTAMP);
INSERT INTO tbl_currencies VALUES (seq_currencies.NEXTVAL, 'USD', 'US Dollar', '$', 'Y', CURRENT_TIMESTAMP);
INSERT INTO tbl_currencies VALUES (seq_currencies.NEXTVAL, 'EUR', 'Euro', '€', 'Y', CURRENT_TIMESTAMP);

COMMIT;
PROMPT '3 currencies loaded';

-- Donation Types
INSERT INTO tbl_donation_types VALUES (seq_donation_types.NEXTVAL, 'MONEY', 'Monetary Donation', 'Cash or bank transfer donations', 'Y', CURRENT_TIMESTAMP);
INSERT INTO tbl_donation_types VALUES (seq_donation_types.NEXTVAL, 'PRODUCT', 'Product Donation', 'Physical goods and supplies', 'Y', CURRENT_TIMESTAMP);

COMMIT;
PROMPT '2 donation types loaded';

-- Roles
INSERT INTO tbl_roles VALUES (seq_roles.NEXTVAL, 'ADMIN', 'Administrator', 'Full system access, can create programs', 'Y', CURRENT_TIMESTAMP);
INSERT INTO tbl_roles VALUES (seq_roles.NEXTVAL, 'ASSISTANT', 'Assistant', 'Can register donations and deliveries', 'Y', CURRENT_TIMESTAMP);

COMMIT;
PROMPT '2 roles loaded';

-- Exchange Rates (base currency: PEN)
INSERT INTO tbl_exchange_rates VALUES (seq_exchange_rates.NEXTVAL, 2, 1, 3.75, SYSDATE, 'Y', CURRENT_TIMESTAMP); -- USD to PEN
INSERT INTO tbl_exchange_rates VALUES (seq_exchange_rates.NEXTVAL, 3, 1, 4.10, SYSDATE, 'Y', CURRENT_TIMESTAMP); -- EUR to PEN
INSERT INTO tbl_exchange_rates VALUES (seq_exchange_rates.NEXTVAL, 1, 2, 0.27, SYSDATE, 'Y', CURRENT_TIMESTAMP); -- PEN to USD
INSERT INTO tbl_exchange_rates VALUES (seq_exchange_rates.NEXTVAL, 1, 3, 0.24, SYSDATE, 'Y', CURRENT_TIMESTAMP); -- PEN to EUR

COMMIT;
PROMPT '4 exchange rates loaded';

-- ============================================================
-- USERS (for testing)
-- ============================================================

-- Admin user (password: admin123)
INSERT INTO tbl_users VALUES (
    seq_users.NEXTVAL,
    'admin',
    'e10adc3949ba59abbe56e057f20f883e', -- MD5 hash of "admin123"
    'System Administrator',
    'admin@hopecare.org',
    1, -- ADMIN role
    'Y',
    NULL,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- Assistant user (password: assist123)
INSERT INTO tbl_users VALUES (
    seq_users.NEXTVAL,
    'assistant',
    '5f4dcc3b5aa765d61d8327deb882cf99', -- MD5 hash of "assist123"
    'Maria Rodriguez',
    'assistant@hopecare.org',
    2, -- ASSISTANT role
    'Y',
    NULL,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

COMMIT;
PROMPT '2 users loaded (admin/admin123, assistant/assist123)';

-- ============================================================
-- TEST DATA - PROGRAMS
-- ============================================================

INSERT INTO tbl_programs VALUES (
    seq_programs.NEXTVAL,
    'PROG001',
    'Food Program',
    'Distribution of food supplies to families in need',
    'FOOD',
    SYSDATE,
    NULL,
    'Y',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_programs VALUES (
    seq_programs.NEXTVAL,
    'PROG002',
    'School Supplies Program',
    'Educational materials for children',
    'EDUCATION',
    SYSDATE,
    NULL,
    'Y',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_programs VALUES (
    seq_programs.NEXTVAL,
    'PROG003',
    'Healthcare Support',
    'Medical supplies and medicines',
    'HEALTH',
    SYSDATE,
    NULL,
    'Y',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

COMMIT;
PROMPT '3 programs loaded';

-- ============================================================
-- TEST DATA - DONORS
-- ============================================================

INSERT INTO tbl_donors VALUES (
    seq_donors.NEXTVAL,
    'DON001',
    'Juan Carlos Pérez',
    'jperez@email.com',
    '987654321',
    'INDIVIDUAL',
    'Av. Arequipa 1234, Lima',
    'Y',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_donors VALUES (
    seq_donors.NEXTVAL,
    'DON002',
    'Empresa ABC S.A.C.',
    'contacto@empresaabc.com',
    '941234567',
    'CORPORATE',
    'Jr. Comercio 567, Lima',
    'Y',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_donors VALUES (
    seq_donors.NEXTVAL,
    'DON003',
    'María González',
    'mgonzalez@email.com',
    '998765432',
    'INDIVIDUAL',
    'Calle Los Álamos 890, San Isidro',
    'Y',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_donors VALUES (
    seq_donors.NEXTVAL,
    'DON004',
    'Fundación Solidaria',
    'info@fundacionsolidaria.org',
    '912345678',
    'GOVERNMENT',
    'Av. Javier Prado 2345, San Borja',
    'Y',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

COMMIT;
PROMPT '4 donors loaded';

-- ============================================================
-- TEST DATA - BENEFICIARIES
-- ============================================================

INSERT INTO tbl_beneficiaries VALUES (
    seq_beneficiaries.NEXTVAL,
    'BEN001',
    'Rosa Mamani Quispe',
    5,
    '923456789',
    'Calle Las Flores 123, Villa El Salvador',
    'Villa El Salvador',
    'Lima',
    'Family of 5, urgent need',
    'Y',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_beneficiaries VALUES (
    seq_beneficiaries.NEXTVAL,
    'BEN002',
    'Pedro Ccahuana',
    4,
    '934567890',
    'Jr. Los Andes 456, San Juan de Lurigancho',
    'San Juan de Lurigancho',
    'Lima',
    'Single father with 3 children',
    'Y',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_beneficiaries VALUES (
    seq_beneficiaries.NEXTVAL,
    'BEN003',
    'Carmen Flores Vargas',
    3,
    '945678901',
    'Av. Perú 789, Comas',
    'Comas',
    'Lima',
    'Mother with 2 children',
    'Y',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_beneficiaries VALUES (
    seq_beneficiaries.NEXTVAL,
    'BEN004',
    'Luis Huamán Castro',
    6,
    '956789012',
    'Calle Central 234, Ate',
    'Ate',
    'Lima',
    'Large family, limited resources',
    'Y',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

COMMIT;
PROMPT '4 beneficiaries loaded';

-- ============================================================
-- TEST DATA - DONATIONS
-- ============================================================

-- Money donations
INSERT INTO tbl_donations VALUES (
    seq_donations.NEXTVAL,
    'DON-2024-001',
    1, -- Juan Carlos Pérez
    1, -- MONEY
    SYSDATE - 10,
    5000,
    1, -- PEN
    NULL,
    NULL,
    NULL,
    'Monthly contribution',
    1, -- created by admin
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_donations VALUES (
    seq_donations.NEXTVAL,
    'DON-2024-002',
    2, -- Empresa ABC
    1, -- MONEY
    SYSDATE - 8,
    1000,
    2, -- USD
    NULL,
    NULL,
    NULL,
    'Corporate donation',
    1,
    CURRENT_TIMESTAMP
);

-- Product donations
INSERT INTO tbl_donations VALUES (
    seq_donations.NEXTVAL,
    'DON-2024-003',
    3, -- María González
    2, -- PRODUCT
    SYSDATE - 5,
    NULL,
    NULL,
    'Rice 1kg bags',
    50,
    3.50,
    'High quality rice',
    2, -- created by assistant
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_donations VALUES (
    seq_donations.NEXTVAL,
    'DON-2024-004',
    4, -- Fundación Solidaria
    2, -- PRODUCT
    SYSDATE - 3,
    NULL,
    NULL,
    'School notebooks',
    100,
    2.00,
    'For School Supplies Program',
    2,
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_donations VALUES (
    seq_donations.NEXTVAL,
    'DON-2024-005',
    2, -- Empresa ABC
    2, -- PRODUCT
    SYSDATE - 1,
    NULL,
    NULL,
    'Canned tuna',
    80,
    4.50,
    'Nutritious food supplies',
    1,
    CURRENT_TIMESTAMP
);

COMMIT;
PROMPT '5 donations loaded';

-- ============================================================
-- TEST DATA - DONATION ASSIGNMENTS
-- ============================================================

INSERT INTO tbl_donation_assignments VALUES (
    seq_donation_assignments.NEXTVAL,
    3, -- Rice donation
    1, -- Food Program
    50,
    175, -- 50 x 3.50
    SYSDATE - 5,
    1,
    'Assigned to food program',
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_donation_assignments VALUES (
    seq_donation_assignments.NEXTVAL,
    4, -- Notebooks
    2, -- School Supplies Program
    100,
    200, -- 100 x 2.00
    SYSDATE - 3,
    1,
    'For back-to-school campaign',
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_donation_assignments VALUES (
    seq_donation_assignments.NEXTVAL,
    5, -- Canned tuna
    1, -- Food Program
    80,
    360, -- 80 x 4.50
    SYSDATE - 1,
    2,
    'Emergency food supplies',
    CURRENT_TIMESTAMP
);

COMMIT;
PROMPT '3 donation assignments loaded';

-- ============================================================
-- TEST DATA - PROGRAM INVENTORY
-- ============================================================

INSERT INTO tbl_program_inventory VALUES (
    seq_program_inventory.NEXTVAL,
    1, -- Food Program
    'Rice 1kg bags',
    45, -- available
    5, -- reserved
    0, -- delivered
    3.50,
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_program_inventory VALUES (
    seq_program_inventory.NEXTVAL,
    1, -- Food Program
    'Canned tuna',
    70,
    10,
    0,
    4.50,
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_program_inventory VALUES (
    seq_program_inventory.NEXTVAL,
    2, -- School Supplies Program
    'School notebooks',
    90,
    10,
    0,
    2.00,
    CURRENT_TIMESTAMP
);

COMMIT;
PROMPT '3 inventory items loaded';

-- ============================================================
-- TEST DATA - DELIVERIES
-- ============================================================

INSERT INTO tbl_deliveries VALUES (
    seq_deliveries.NEXTVAL,
    'DEL-2024-001',
    1, -- Rosa Mamani
    1, -- Food Program
    SYSDATE - 2,
    'Rice 1kg bags',
    5,
    3.50,
    17.50,
    'COMPLETED',
    'Emergency delivery',
    2, -- created by assistant
    1, -- approved by admin
    CURRENT_TIMESTAMP
);

INSERT INTO tbl_deliveries VALUES (
    seq_deliveries.NEXTVAL,
    'DEL-2024-002',
    2, -- Pedro Ccahuana
    2, -- School Supplies Program
    SYSDATE - 1,
    'School notebooks',
    10,
    2.00,
    20.00,
    'COMPLETED',
    'For his children',
    2,
    1,
    CURRENT_TIMESTAMP
);

COMMIT;
PROMPT '2 deliveries loaded';

-- ============================================================
-- SUCCESS MESSAGE
-- ============================================================

BEGIN
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('DATA LOADED SUCCESSFULLY!');
  DBMS_OUTPUT.PUT_LINE('- 3 Currencies');
  DBMS_OUTPUT.PUT_LINE('- 2 Donation Types');
  DBMS_OUTPUT.PUT_LINE('- 2 Roles');
  DBMS_OUTPUT.PUT_LINE('- 4 Exchange Rates');
  DBMS_OUTPUT.PUT_LINE('- 2 Users');
  DBMS_OUTPUT.PUT_LINE('- 3 Programs');
  DBMS_OUTPUT.PUT_LINE('- 4 Donors');
  DBMS_OUTPUT.PUT_LINE('- 4 Beneficiaries');
  DBMS_OUTPUT.PUT_LINE('- 5 Donations');
  DBMS_OUTPUT.PUT_LINE('- 3 Assignments');
  DBMS_OUTPUT.PUT_LINE('- 3 Inventory items');
  DBMS_OUTPUT.PUT_LINE('- 2 Deliveries');
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('Login credentials:');
  DBMS_OUTPUT.PUT_LINE('  admin / admin123');
  DBMS_OUTPUT.PUT_LINE('  assistant / assist123');
  DBMS_OUTPUT.PUT_LINE('========================================');
END;
/