-- ================================================================
-- HOPECARE PROJECT - 01_SETUP.SQL (FOR ORACLE FREE PDB)
-- Creates user in pluggable database
-- ================================================================

-- Connect to the pluggable database
ALTER SESSION SET CONTAINER = FREEPDB1;

-- Drop existing user if exists
BEGIN
   EXECUTE IMMEDIATE 'DROP USER hopecare CASCADE';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- Create user (no C## prefix needed in PDB)
CREATE USER hopecare
  IDENTIFIED BY hopecare123
  DEFAULT TABLESPACE users
  TEMPORARY TABLESPACE temp
  QUOTA UNLIMITED ON users;

-- Grant privileges
GRANT CONNECT, RESOURCE TO hopecare;
GRANT CREATE SESSION TO hopecare;
GRANT CREATE TABLE TO hopecare;
GRANT CREATE VIEW TO hopecare;
GRANT CREATE SEQUENCE TO hopecare;
GRANT CREATE PROCEDURE TO hopecare;
GRANT CREATE TRIGGER TO hopecare;
GRANT CREATE SYNONYM TO hopecare;
GRANT UNLIMITED TABLESPACE TO hopecare;

-- Success message
BEGIN
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('HOPECARE SETUP COMPLETED SUCCESSFULLY!');
  DBMS_OUTPUT.PUT_LINE('User: hopecare / Password: hopecare123');
  DBMS_OUTPUT.PUT_LINE('Container: FREEPDB1');
  DBMS_OUTPUT.PUT_LINE('========================================');
END;
/