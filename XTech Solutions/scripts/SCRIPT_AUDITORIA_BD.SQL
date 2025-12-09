-- ================================================================
-- HOPECARE PROJECT - SCRIPT_AUDITORIA_BD.SQL
-- Consultas de auditoría y verificación de integridad
-- ================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('HOPECARE - AUDITORÍA DE BASE DE DATOS');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Fecha: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================
-- 1. AUDITORÍA DE OBJETOS DE BASE DE DATOS
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('1. INVENTARIO DE OBJETOS');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

SELECT object_type, COUNT(*) AS cantidad, SUM(CASE WHEN status = 'VALID' THEN 1 ELSE 0 END) AS validos,
       SUM(CASE WHEN status = 'INVALID' THEN 1 ELSE 0 END) AS invalidos
FROM user_objects
GROUP BY object_type
ORDER BY object_type;

-- Detalle de objetos inválidos
SELECT object_type, object_name, status, last_ddl_time
FROM user_objects
WHERE status = 'INVALID'
ORDER BY object_type, object_name;

-- ============================================================
-- 2. AUDITORÍA DE TABLAS Y DATOS
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('2. ESTADÍSTICAS DE TABLAS');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

SELECT 
    table_name,
    num_rows,
    blocks,
    ROUND(blocks * 8 / 1024, 2) AS size_mb,
    last_analyzed
FROM user_tables
WHERE table_name LIKE 'TBL_%'
ORDER BY num_rows DESC NULLS LAST;

-- Conteo real de registros
SELECT 'tbl_donors' AS tabla, COUNT(*) AS registros FROM tbl_donors
UNION ALL
SELECT 'tbl_beneficiaries', COUNT(*) FROM tbl_beneficiaries
UNION ALL
SELECT 'tbl_programs', COUNT(*) FROM tbl_programs
UNION ALL
SELECT 'tbl_donations', COUNT(*) FROM tbl_donations
UNION ALL
SELECT 'tbl_deliveries', COUNT(*) FROM tbl_deliveries
UNION ALL
SELECT 'tbl_program_inventory', COUNT(*) FROM tbl_program_inventory
UNION ALL
SELECT 'tbl_donation_assignments', COUNT(*) FROM tbl_donation_assignments
UNION ALL
SELECT 'tbl_audit_donations', COUNT(*) FROM tbl_audit_donations
UNION ALL
SELECT 'tbl_audit_deliveries', COUNT(*) FROM tbl_audit_deliveries
ORDER BY tabla;

-- ============================================================
-- 3. AUDITORÍA DE TRANSACCIONES (Últimas 24 horas)
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('3. ACTIVIDAD TRANSACCIONAL (24h)');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- Donaciones registradas
SELECT 
    TO_CHAR(donation_date, 'YYYY-MM-DD') AS fecha,
    COUNT(*) AS donaciones,
    SUM(CASE WHEN amount IS NOT NULL THEN 1 ELSE 0 END) AS monetarias,
    SUM(CASE WHEN product_description IS NOT NULL THEN 1 ELSE 0 END) AS productos
FROM tbl_donations
WHERE donation_date >= SYSDATE - 1
GROUP BY TO_CHAR(donation_date, 'YYYY-MM-DD')
ORDER BY fecha DESC;

-- Entregas realizadas
SELECT 
    TO_CHAR(delivery_date, 'YYYY-MM-DD') AS fecha,
    status,
    COUNT(*) AS entregas,
    SUM(quantity_delivered) AS unidades_totales,
    SUM(total_value) AS valor_total_pen
FROM tbl_deliveries
WHERE delivery_date >= SYSDATE - 1
GROUP BY TO_CHAR(delivery_date, 'YYYY-MM-DD'), status
ORDER BY fecha DESC, status;

-- ============================================================
-- 4. AUDITORÍA DE CAMBIOS (Audit Trail)
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('4. AUDIT TRAIL - CAMBIOS REGISTRADOS');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- Últimos cambios en donaciones
SELECT 
    a.audit_id,
    a.donation_id,
    d.donation_code,
    a.action_type,
    u.full_name AS usuario,
    TO_CHAR(a.changed_at, 'DD-MON-YY HH24:MI:SS') AS fecha_hora
FROM tbl_audit_donations a
LEFT JOIN tbl_donations d ON a.donation_id = d.donation_id
LEFT JOIN tbl_users u ON a.changed_by = u.user_id
WHERE a.changed_at >= SYSDATE - 7
ORDER BY a.changed_at DESC
FETCH FIRST 20 ROWS ONLY;

-- Últimos cambios en entregas
SELECT 
    a.audit_id,
    a.delivery_id,
    d.delivery_code,
    a.action_type,
    u.full_name AS usuario,
    TO_CHAR(a.changed_at, 'DD-MON-YY HH24:MI:SS') AS fecha_hora
FROM tbl_audit_deliveries a
LEFT JOIN tbl_deliveries d ON a.delivery_id = d.delivery_id
LEFT JOIN tbl_users u ON a.changed_by = u.user_id
WHERE a.changed_at >= SYSDATE - 7
ORDER BY a.changed_at DESC
FETCH FIRST 20 ROWS ONLY;

-- Resumen de operaciones por usuario
SELECT 
    u.full_name AS usuario,
    u.username,
    r.role_name,
    (SELECT COUNT(*) FROM tbl_audit_donations WHERE changed_by = u.user_id) AS operaciones_donaciones,
    (SELECT COUNT(*) FROM tbl_audit_deliveries WHERE changed_by = u.user_id) AS operaciones_entregas,
    (SELECT COUNT(*) FROM tbl_audit_donations WHERE changed_by = u.user_id) +
    (SELECT COUNT(*) FROM tbl_audit_deliveries WHERE changed_by = u.user_id) AS total_operaciones
FROM tbl_users u
JOIN tbl_roles r ON u.role_id = r.role_id
WHERE u.is_active = 'Y'
ORDER BY total_operaciones DESC;

-- ============================================================
-- 5. INTEGRIDAD REFERENCIAL
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('5. VERIFICACIÓN DE INTEGRIDAD REFERENCIAL');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- Verificar constraints activos
SELECT 
    constraint_name,
    constraint_type,
    table_name,
    status
FROM user_constraints
WHERE constraint_type IN ('P', 'R', 'C', 'U')
AND table_name LIKE 'TBL_%'
ORDER BY constraint_type, table_name;

-- Donaciones huérfanas (sin donante válido)
SELECT COUNT(*) AS donaciones_huerfanas
FROM tbl_donations d
WHERE NOT EXISTS (
    SELECT 1 FROM tbl_donors don 
    WHERE don.donor_id = d.donor_id
);

-- Entregas huérfanas (sin beneficiario válido)
SELECT COUNT(*) AS entregas_huerfanas
FROM tbl_deliveries d
WHERE NOT EXISTS (
    SELECT 1 FROM tbl_beneficiaries b 
    WHERE b.beneficiary_id = d.beneficiary_id
);

-- ============================================================
-- 6. CONSISTENCIA DE INVENTARIO
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('6. CONSISTENCIA DE INVENTARIO');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- Verificar balance de inventario
SELECT 
    i.program_id,
    p.program_name,
    i.product_description,
    i.available_quantity,
    i.delivered_quantity,
    -- Calcular cantidad total entregada desde deliveries
    (SELECT COALESCE(SUM(quantity_delivered), 0)
     FROM tbl_deliveries d
     WHERE d.program_id = i.program_id
     AND UPPER(d.product_description) = UPPER(i.product_description)
     AND d.status = 'COMPLETED') AS entregas_reales,
    -- Diferencia (debe ser 0)
    i.delivered_quantity - 
    (SELECT COALESCE(SUM(quantity_delivered), 0)
     FROM tbl_deliveries d
     WHERE d.program_id = i.program_id
     AND UPPER(d.product_description) = UPPER(i.product_description)
     AND d.status = 'COMPLETED') AS diferencia
FROM tbl_program_inventory i
JOIN tbl_programs p ON i.program_id = p.program_id
ORDER BY diferencia DESC;

-- Stock negativo (ERROR)
SELECT 
    program_id,
    product_description,
    available_quantity
FROM tbl_program_inventory
WHERE available_quantity < 0;

-- ============================================================
-- 7. ACTIVIDAD DE USUARIOS
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('7. ACTIVIDAD DE USUARIOS');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

SELECT 
    u.user_id,
    u.username,
    u.full_name,
    r.role_name,
    u.is_active,
    TO_CHAR(u.last_login, 'DD-MON-YY HH24:MI:SS') AS ultimo_login,
    ROUND(SYSDATE - u.last_login) AS dias_inactivo
FROM tbl_users u
JOIN tbl_roles r ON u.role_id = r.role_id
ORDER BY u.last_login DESC NULLS LAST;

-- ============================================================
-- 8. ANÁLISIS DE PERFORMANCE
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('8. ÍNDICES Y PERFORMANCE');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- Índices existentes
SELECT 
    index_name,
    table_name,
    uniqueness,
    status
FROM user_indexes
WHERE table_name LIKE 'TBL_%'
ORDER BY table_name, index_name;

-- Índices por tabla
SELECT 
    table_name,
    COUNT(*) AS num_indices
FROM user_indexes
WHERE table_name LIKE 'TBL_%'
GROUP BY table_name
ORDER BY num_indices DESC;

-- ============================================================
-- 9. ESPACIO EN DISCO
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('9. USO DE ESPACIO');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

SELECT 
    segment_name,
    segment_type,
    ROUND(bytes/1024/1024, 2) AS size_mb
FROM user_segments
WHERE segment_type IN ('TABLE', 'INDEX')
AND segment_name LIKE 'TBL_%' OR segment_name LIKE 'IDX_%'
ORDER BY bytes DESC;

-- Espacio total usado
SELECT 
    ROUND(SUM(bytes)/1024/1024, 2) AS total_mb
FROM user_segments;

-- ============================================================
-- 10. RECOMENDACIONES Y ALERTAS
-- ============================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('10. RECOMENDACIONES Y ALERTAS');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Verificar objetos inválidos
    DECLARE
        v_invalidos NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_invalidos
        FROM user_objects
        WHERE status = 'INVALID';
        
        IF v_invalidos > 0 THEN
            DBMS_OUTPUT.PUT_LINE('⚠️ ALERTA: ' || v_invalidos || ' objetos inválidos detectados');
            DBMS_OUTPUT.PUT_LINE('   Acción: Ejecutar ALTER PACKAGE pkg_name COMPILE;');
        ELSE
            DBMS_OUTPUT.PUT_LINE('✅ OK: Todos los objetos son válidos');
        END IF;
    END;
    
    -- Verificar inconsistencias de inventario
    DECLARE
        v_inconsistencias NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_inconsistencias
        FROM tbl_program_inventory i
        WHERE i.delivered_quantity != (
            SELECT COALESCE(SUM(quantity_delivered), 0)
            FROM tbl_deliveries d
            WHERE d.program_id = i.program_id
            AND UPPER(d.product_description) = UPPER(i.product_description)
            AND d.status = 'COMPLETED'
        );
        
        IF v_inconsistencias > 0 THEN
            DBMS_OUTPUT.PUT_LINE('⚠️ ALERTA: ' || v_inconsistencias || ' inconsistencias en inventario');
            DBMS_OUTPUT.PUT_LINE('   Acción: Revisar script de corrección de inventario');
        ELSE
            DBMS_OUTPUT.PUT_LINE('✅ OK: Inventario consistente');
        END IF;
    END;
    
    -- Verificar stock negativo
    DECLARE
        v_stock_negativo NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_stock_negativo
        FROM tbl_program_inventory
        WHERE available_quantity < 0;
        
        IF v_stock_negativo > 0 THEN
            DBMS_OUTPUT.PUT_LINE('🔴 ERROR CRÍTICO: Stock negativo detectado');
            DBMS_OUTPUT.PUT_LINE('   Acción: Revisar transacciones recientes');
        ELSE
            DBMS_OUTPUT.PUT_LINE('✅ OK: No hay stock negativo');
        END IF;
    END;
    
    -- Verificar usuarios inactivos
    DECLARE
        v_inactivos NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_inactivos
        FROM tbl_users
        WHERE is_active = 'Y'
        AND (last_login IS NULL OR last_login < SYSDATE - 90);
        
        IF v_inactivos > 0 THEN
            DBMS_OUTPUT.PUT_LINE('⚠️ ALERTA: ' || v_inactivos || ' usuarios sin actividad >90 días');
            DBMS_OUTPUT.PUT_LINE('   Acción: Considerar desactivar usuarios inactivos');
        ELSE
            DBMS_OUTPUT.PUT_LINE('✅ OK: Todos los usuarios activos');
        END IF;
    END;
    
    -- Verificar tamaño de tablas de auditoría
    DECLARE
        v_audit_records NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_audit_records
        FROM tbl_audit_donations
        WHERE changed_at < SYSDATE - 365;
        
        IF v_audit_records > 10000 THEN
            DBMS_OUTPUT.PUT_LINE('⚠️ ALERTA: Auditoría con >10,000 registros antiguos (>1 año)');
            DBMS_OUTPUT.PUT_LINE('   Acción: Considerar archivado y purga');
        ELSE
            DBMS_OUTPUT.PUT_LINE('✅ OK: Tamaño de auditoría manejable');
        END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('AUDITORÍA COMPLETADA');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/