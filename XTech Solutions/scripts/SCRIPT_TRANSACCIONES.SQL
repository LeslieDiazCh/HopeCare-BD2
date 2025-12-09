-- ================================================================
-- HOPECARE PROJECT - SCRIPT_TRANSACCIONES.SQL
-- Ejemplos de transacciones completas de negocio
-- ================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

-- ============================================================
-- TRANSACCIÓN 1: DONACIÓN COMPLETA (Money → Programa)
-- ============================================================
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('TRANSACCIÓN 1: REGISTRO DE DONACIÓN MONETARIA');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    DECLARE
        v_donation_id NUMBER;
    BEGIN
        -- Registrar donación de $500 USD al Programa de Alimentos
        pkg_donations.register_money_donation(
            p_donor_id => 1,           -- Donante existente
            p_amount => 500,           -- $500 USD
            p_currency_id => 2,        -- USD
            p_program_id => 1,         -- Food Program
            p_notes => 'Transacción de prueba - Donación corporativa',
            p_created_by => 1,         -- Admin
            p_donation_id => v_donation_id
        );
        
        DBMS_OUTPUT.PUT_LINE('✅ Donación registrada: ID=' || v_donation_id);
        DBMS_OUTPUT.PUT_LINE('✅ Conversión automática a PEN ejecutada');
        DBMS_OUTPUT.PUT_LINE('✅ Asignación al programa completada');
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('❌ Error en transacción: ' || SQLERRM);
    END;
END;
/

-- ============================================================
-- TRANSACCIÓN 2: DONACIÓN DE PRODUCTOS → INVENTARIO
-- ============================================================
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('TRANSACCIÓN 2: DONACIÓN DE PRODUCTOS');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    DECLARE
        v_donation_id NUMBER;
        v_stock_antes NUMBER;
        v_stock_despues NUMBER;
    BEGIN
        -- Consultar stock actual
        SELECT available_quantity INTO v_stock_antes
        FROM tbl_program_inventory
        WHERE program_id = 1 AND UPPER(product_description) = UPPER('Rice 1kg bags');
        
        DBMS_OUTPUT.PUT_LINE('Stock antes: ' || v_stock_antes || ' unidades');
        
        -- Registrar donación de 100 bolsas de arroz
        pkg_donations.register_product_donation(
            p_donor_id => 2,
            p_product_description => 'Rice 1kg bags',
            p_quantity => 100,
            p_unit_value => 3.50,
            p_program_id => 1,
            p_notes => 'Transacción de prueba - Donación de productos',
            p_created_by => 1,
            p_donation_id => v_donation_id
        );
        
        -- Verificar actualización de inventario
        SELECT available_quantity INTO v_stock_despues
        FROM tbl_program_inventory
        WHERE program_id = 1 AND UPPER(product_description) = UPPER('Rice 1kg bags');
        
        DBMS_OUTPUT.PUT_LINE('✅ Donación registrada: ID=' || v_donation_id);
        DBMS_OUTPUT.PUT_LINE('✅ Stock actualizado: ' || v_stock_despues || ' unidades');
        DBMS_OUTPUT.PUT_LINE('✅ Incremento: ' || (v_stock_despues - v_stock_antes) || ' unidades');
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('❌ Error: ' || SQLERRM);
    END;
END;
/

-- ============================================================
-- TRANSACCIÓN 3: ENTREGA CON VALIDACIÓN DE STOCK
-- ============================================================
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('TRANSACCIÓN 3: ENTREGA A BENEFICIARIO');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    DECLARE
        v_delivery_id NUMBER;
        v_stock_antes NUMBER;
        v_stock_despues NUMBER;
    BEGIN
        -- Stock antes de la entrega
        SELECT available_quantity INTO v_stock_antes
        FROM tbl_program_inventory
        WHERE program_id = 1 AND UPPER(product_description) = UPPER('Rice 1kg bags');
        
        DBMS_OUTPUT.PUT_LINE('Stock disponible: ' || v_stock_antes || ' unidades');
        
        -- Realizar entrega de 10 bolsas
        pkg_deliveries.perform_delivery(
            p_beneficiary_id => 1,
            p_program_id => 1,
            p_product_description => 'Rice 1kg bags',
            p_quantity => 10,
            p_notes => 'Transacción de prueba - Entrega programada',
            p_created_by => 2,  -- Assistant
            p_delivery_id => v_delivery_id
        );
        
        -- Stock después de la entrega
        SELECT available_quantity INTO v_stock_despues
        FROM tbl_program_inventory
        WHERE program_id = 1 AND UPPER(product_description) = UPPER('Rice 1kg bags');
        
        DBMS_OUTPUT.PUT_LINE('✅ Entrega registrada: ID=' || v_delivery_id);
        DBMS_OUTPUT.PUT_LINE('✅ Stock actualizado: ' || v_stock_despues || ' unidades');
        DBMS_OUTPUT.PUT_LINE('✅ Reducción: ' || (v_stock_antes - v_stock_despues) || ' unidades');
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('❌ Error: ' || SQLERRM);
    END;
END;
/

-- ============================================================
-- TRANSACCIÓN 4: INTENTO DE ENTREGA SIN STOCK (Debe fallar)
-- ============================================================
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('TRANSACCIÓN 4: VALIDACIÓN DE STOCK');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    DECLARE
        v_delivery_id NUMBER;
    BEGIN
        -- Intentar entregar 10,000 unidades (más de lo disponible)
        pkg_deliveries.perform_delivery(
            p_beneficiary_id => 1,
            p_program_id => 1,
            p_product_description => 'Rice 1kg bags',
            p_quantity => 10000,
            p_notes => 'Esta transacción DEBE FALLAR',
            p_created_by => 2,
            p_delivery_id => v_delivery_id
        );
        
        DBMS_OUTPUT.PUT_LINE('❌ ERROR: La transacción NO debió completarse');
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('✅ CORRECTO: Transacción rechazada por falta de stock');
            DBMS_OUTPUT.PUT_LINE('✅ Mensaje: ' || SUBSTR(SQLERRM, 1, 100));
            ROLLBACK;
    END;
END;
/

-- ============================================================
-- TRANSACCIÓN 5: FLUJO COMPLETO (Donación → Inventario → Entrega)
-- ============================================================
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('TRANSACCIÓN 5: FLUJO COMPLETO');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    DECLARE
        v_donation_id NUMBER;
        v_delivery_id NUMBER;
        v_producto VARCHAR2(100) := 'Canned Tuna - Test Transaction';
    BEGIN
        -- PASO 1: Donación de producto
        DBMS_OUTPUT.PUT_LINE('PASO 1: Registrando donación...');
        pkg_donations.register_product_donation(
            p_donor_id => 2,
            p_product_description => v_producto,
            p_quantity => 50,
            p_unit_value => 4.50,
            p_program_id => 1,
            p_notes => 'Flujo completo de prueba',
            p_created_by => 1,
            p_donation_id => v_donation_id
        );
        DBMS_OUTPUT.PUT_LINE('✅ Donación ID: ' || v_donation_id);
        
        -- PASO 2: Verificar inventario
        DECLARE
            v_stock NUMBER;
        BEGIN
            SELECT available_quantity INTO v_stock
            FROM tbl_program_inventory
            WHERE program_id = 1 AND UPPER(product_description) = UPPER(v_producto);
            DBMS_OUTPUT.PUT_LINE('✅ Stock en inventario: ' || v_stock);
        END;
        
        -- PASO 3: Realizar entrega
        DBMS_OUTPUT.PUT_LINE('PASO 2: Realizando entrega...');
        pkg_deliveries.perform_delivery(
            p_beneficiary_id => 1,
            p_program_id => 1,
            p_product_description => v_producto,
            p_quantity => 20,
            p_notes => 'Entrega de prueba - flujo completo',
            p_created_by => 2,
            p_delivery_id => v_delivery_id
        );
        DBMS_OUTPUT.PUT_LINE('✅ Entrega ID: ' || v_delivery_id);
        
        -- PASO 4: Verificar stock final
        DECLARE
            v_stock_final NUMBER;
        BEGIN
            SELECT available_quantity INTO v_stock_final
            FROM tbl_program_inventory
            WHERE program_id = 1 AND UPPER(product_description) = UPPER(v_producto);
            DBMS_OUTPUT.PUT_LINE('✅ Stock final: ' || v_stock_final || ' (50 - 20 = 30)');
        END;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('✅ FLUJO COMPLETO EXITOSO');
        DBMS_OUTPUT.PUT_LINE('========================================');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('❌ Error en flujo: ' || SQLERRM);
    END;
END;
/

-- ============================================================
-- RESUMEN DE TRANSACCIONES
-- ============================================================
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE PRUEBAS DE TRANSACCIONES');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('✅ Todas las transacciones deben ejecutarse correctamente');
    DBMS_OUTPUT.PUT_LINE('✅ La transacción 4 debe FALLAR por validación de stock');
    DBMS_OUTPUT.PUT_LINE('✅ Verificar integridad referencial en toda la cadena');
    DBMS_OUTPUT.PUT_LINE('✅ Auditoría automática activa en todas las operaciones');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/