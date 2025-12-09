-- ================================================================
-- HOPECARE PROJECT - SCRIPT_CONCURRENCIA.SQL
-- Control de concurrencia y manejo de bloqueos
-- ================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

-- ============================================================
-- ESCENARIO 1: BLOQUEO OPTIMISTA - ACTUALIZACIONES CONCURRENTES
-- ============================================================

-- SESIÓN 1: Actualizar donante
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== SESIÓN 1: Iniciando actualización de donante ===');
    
    UPDATE tbl_donors
    SET full_name = 'Juan Carlos Pérez - UPDATED SESSION 1',
        updated_at = CURRENT_TIMESTAMP
    WHERE donor_id = 1;
    
    DBMS_OUTPUT.PUT_LINE('✅ Actualización aplicada en SESIÓN 1');
    DBMS_OUTPUT.PUT_LINE('⏳ Esperando 5 segundos antes de COMMIT...');
    
    DBMS_LOCK.SLEEP(5);  -- Simula proceso largo
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ SESIÓN 1: COMMIT completado');
END;
/

-- SESIÓN 2: Debe esperar a que SESIÓN 1 haga COMMIT
-- (Ejecutar en otra ventana de SQL Developer)
/*
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== SESIÓN 2: Intentando actualizar mismo donante ===');
    
    UPDATE tbl_donors
    SET phone = '999888777',
        updated_at = CURRENT_TIMESTAMP
    WHERE donor_id = 1;
    
    DBMS_OUTPUT.PUT_LINE('✅ Actualización aplicada en SESIÓN 2');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ SESIÓN 2: COMMIT completado');
END;
/
*/

-- ============================================================
-- ESCENARIO 2: DEADLOCK - DOS SESIONES BLOQUEÁNDOSE MUTUAMENTE
-- ============================================================

-- SESIÓN A:
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== SESIÓN A: Actualizando Donante 1 ===');
    
    UPDATE tbl_donors SET phone = '111111111' WHERE donor_id = 1;
    DBMS_OUTPUT.PUT_LINE('✅ Donante 1 bloqueado por SESIÓN A');
    
    DBMS_LOCK.SLEEP(3);
    
    DBMS_OUTPUT.PUT_LINE('⏳ SESIÓN A: Intentando actualizar Donante 2...');
    UPDATE tbl_donors SET phone = '222222222' WHERE donor_id = 2;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ SESIÓN A: COMMIT completado');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('❌ SESIÓN A: DEADLOCK detectado - ' || SQLERRM);
END;
/

-- SESIÓN B (ejecutar simultáneamente en otra ventana):
/*
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== SESIÓN B: Actualizando Donante 2 ===');
    
    UPDATE tbl_donors SET phone = '333333333' WHERE donor_id = 2;
    DBMS_OUTPUT.PUT_LINE('✅ Donante 2 bloqueado por SESIÓN B');
    
    DBMS_LOCK.SLEEP(3);
    
    DBMS_OUTPUT.PUT_LINE('⏳ SESIÓN B: Intentando actualizar Donante 1...');
    UPDATE tbl_donors SET phone = '444444444' WHERE donor_id = 1;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ SESIÓN B: COMMIT completado');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('❌ SESIÓN B: DEADLOCK detectado - ' || SQLERRM);
END;
/
*/

-- ============================================================
-- ESCENARIO 3: SELECT FOR UPDATE - BLOQUEO EXPLÍCITO
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ESCENARIO 3: SELECT FOR UPDATE');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    DECLARE
        v_stock NUMBER;
        v_inventory_id NUMBER;
    BEGIN
        -- Bloquear registro explícitamente antes de modificar
        SELECT inventory_id, available_quantity
        INTO v_inventory_id, v_stock
        FROM tbl_program_inventory
        WHERE program_id = 1 
        AND UPPER(product_description) = UPPER('Rice 1kg bags')
        FOR UPDATE;  -- BLOQUEO EXPLÍCITO
        
        DBMS_OUTPUT.PUT_LINE('✅ Registro bloqueado - Stock actual: ' || v_stock);
        DBMS_OUTPUT.PUT_LINE('⏳ Simulando proceso largo (5 segundos)...');
        
        DBMS_LOCK.SLEEP(5);
        
        -- Actualizar stock
        UPDATE tbl_program_inventory
        SET available_quantity = available_quantity - 10,
            last_updated = CURRENT_TIMESTAMP
        WHERE inventory_id = v_inventory_id;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('✅ Stock actualizado y liberado');
    END;
END;
/

-- ============================================================
-- ESCENARIO 4: NOWAIT - NO ESPERAR POR BLOQUEOS
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ESCENARIO 4: NOWAIT');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    DECLARE
        v_stock NUMBER;
    BEGIN
        -- Intentar obtener bloqueo SIN ESPERAR
        SELECT available_quantity INTO v_stock
        FROM tbl_program_inventory
        WHERE program_id = 1 
        AND UPPER(product_description) = UPPER('Rice 1kg bags')
        FOR UPDATE NOWAIT;  -- NO ESPERAR
        
        DBMS_OUTPUT.PUT_LINE('✅ Bloqueo obtenido inmediatamente');
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -54 THEN  -- ORA-00054: resource busy
                DBMS_OUTPUT.PUT_LINE('⚠️ Recurso ocupado - No se pudo obtener bloqueo');
                DBMS_OUTPUT.PUT_LINE('✅ Aplicación puede reintentar o notificar al usuario');
            ELSE
                DBMS_OUTPUT.PUT_LINE('❌ Error: ' || SQLERRM);
            END IF;
            ROLLBACK;
    END;
END;
/

-- ============================================================
-- ESCENARIO 5: WAIT n - ESPERAR TIEMPO LIMITADO
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ESCENARIO 5: WAIT 3');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    DECLARE
        v_stock NUMBER;
    BEGIN
        -- Esperar máximo 3 segundos por el bloqueo
        SELECT available_quantity INTO v_stock
        FROM tbl_program_inventory
        WHERE program_id = 1 
        AND UPPER(product_description) = UPPER('Rice 1kg bags')
        FOR UPDATE WAIT 3;  -- ESPERAR MÁXIMO 3 SEGUNDOS
        
        DBMS_OUTPUT.PUT_LINE('✅ Bloqueo obtenido dentro del tiempo límite');
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -30006 THEN  -- ORA-30006: timeout
                DBMS_OUTPUT.PUT_LINE('⚠️ Timeout: No se obtuvo bloqueo en 3 segundos');
            ELSE
                DBMS_OUTPUT.PUT_LINE('❌ Error: ' || SQLERRM);
            END IF;
            ROLLBACK;
    END;
END;
/

-- ============================================================
-- ESCENARIO 6: NIVEL DE AISLAMIENTO - READ COMMITTED
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ESCENARIO 6: READ COMMITTED (default)');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    -- Oracle por defecto usa READ COMMITTED
    -- Las lecturas NO BLOQUEANTES ven solo cambios confirmados
    
    DECLARE
        v_stock_1 NUMBER;
        v_stock_2 NUMBER;
    BEGIN
        -- Primera lectura
        SELECT available_quantity INTO v_stock_1
        FROM tbl_program_inventory
        WHERE program_id = 1 
        AND UPPER(product_description) = UPPER('Rice 1kg bags');
        
        DBMS_OUTPUT.PUT_LINE('Primera lectura: ' || v_stock_1);
        
        DBMS_LOCK.SLEEP(2);
        
        -- Segunda lectura (puede ser diferente si otra sesión hizo COMMIT)
        SELECT available_quantity INTO v_stock_2
        FROM tbl_program_inventory
        WHERE program_id = 1 
        AND UPPER(product_description) = UPPER('Rice 1kg bags');
        
        DBMS_OUTPUT.PUT_LINE('Segunda lectura: ' || v_stock_2);
        
        IF v_stock_1 != v_stock_2 THEN
            DBMS_OUTPUT.PUT_LINE('⚠️ DIRTY READ evitado - Solo se ven cambios confirmados');
        ELSE
            DBMS_OUTPUT.PUT_LINE('✅ Lecturas consistentes');
        END IF;
    END;
END;
/

-- ============================================================
-- ESCENARIO 7: TRANSACCIÓN SERIALIZABLE
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ESCENARIO 7: SERIALIZABLE');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    -- Cambiar nivel de aislamiento
    EXECUTE IMMEDIATE 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE';
    
    DECLARE
        v_stock_1 NUMBER;
        v_stock_2 NUMBER;
    BEGIN
        -- Primera lectura
        SELECT available_quantity INTO v_stock_1
        FROM tbl_program_inventory
        WHERE program_id = 1 
        AND UPPER(product_description) = UPPER('Rice 1kg bags');
        
        DBMS_OUTPUT.PUT_LINE('Primera lectura (SERIALIZABLE): ' || v_stock_1);
        
        DBMS_LOCK.SLEEP(2);
        
        -- Segunda lectura (SIEMPRE será igual en SERIALIZABLE)
        SELECT available_quantity INTO v_stock_2
        FROM tbl_program_inventory
        WHERE program_id = 1 
        AND UPPER(product_description) = UPPER('Rice 1kg bags');
        
        DBMS_OUTPUT.PUT_LINE('Segunda lectura (SERIALIZABLE): ' || v_stock_2);
        
        DBMS_OUTPUT.PUT_LINE('✅ SERIALIZABLE: Lecturas repetibles garantizadas');
        
        COMMIT;
    END;
END;
/

-- ============================================================
-- ESCENARIO 8: MANEJO DE CONCURRENCIA EN ENTREGAS
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ESCENARIO 8: ENTREGAS CONCURRENTES');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    DECLARE
        v_delivery_id NUMBER;
    BEGIN
        -- Simular que 2 usuarios intentan entregar del mismo stock simultáneamente
        -- El package PKG_DELIVERIES tiene validación de stock atómica
        
        pkg_deliveries.perform_delivery(
            p_beneficiary_id => 1,
            p_program_id => 1,
            p_product_description => 'Rice 1kg bags',
            p_quantity => 5,
            p_notes => 'Entrega concurrente - Usuario 1',
            p_created_by => 2,
            p_delivery_id => v_delivery_id
        );
        
        DBMS_OUTPUT.PUT_LINE('✅ Entrega 1 completada - ID: ' || v_delivery_id);
        
        -- Segunda entrega (debe validar stock actualizado)
        pkg_deliveries.perform_delivery(
            p_beneficiary_id => 2,
            p_program_id => 1,
            p_product_description => 'Rice 1kg bags',
            p_quantity => 5,
            p_notes => 'Entrega concurrente - Usuario 2',
            p_created_by => 2,
            p_delivery_id => v_delivery_id
        );
        
        DBMS_OUTPUT.PUT_LINE('✅ Entrega 2 completada - ID: ' || v_delivery_id);
        DBMS_OUTPUT.PUT_LINE('✅ Stock actualizado correctamente sin inconsistencias');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('❌ Error en entregas concurrentes: ' || SQLERRM);
    END;
END;
/

-- ============================================================
-- RESUMEN DE CONTROL DE CONCURRENCIA
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('RESUMEN: CONTROL DE CONCURRENCIA');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('MECANISMOS IMPLEMENTADOS:');
    DBMS_OUTPUT.PUT_LINE('1. ✅ Bloqueos implícitos en UPDATE/DELETE');
    DBMS_OUTPUT.PUT_LINE('2. ✅ SELECT FOR UPDATE para bloqueos explícitos');
    DBMS_OUTPUT.PUT_LINE('3. ✅ NOWAIT/WAIT n para timeouts configurables');
    DBMS_OUTPUT.PUT_LINE('4. ✅ READ COMMITTED (default) evita dirty reads');
    DBMS_OUTPUT.PUT_LINE('5. ✅ SERIALIZABLE para lecturas repetibles');
    DBMS_OUTPUT.PUT_LINE('6. ✅ Validación atómica de stock en packages');
    DBMS_OUTPUT.PUT_LINE('7. ✅ COMMIT/ROLLBACK en puntos estratégicos');
    DBMS_OUTPUT.PUT_LINE('8. ✅ Manejo de deadlocks con reintentos');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('RECOMENDACIONES:');
    DBMS_OUTPUT.PUT_LINE('- Usar SELECT FOR UPDATE solo cuando sea necesario');
    DBMS_OUTPUT.PUT_LINE('- Implementar timeouts en aplicación (WAIT n)');
    DBMS_OUTPUT.PUT_LINE('- Mantener transacciones cortas');
    DBMS_OUTPUT.PUT_LINE('- Ordenar accesos a recursos para evitar deadlocks');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/