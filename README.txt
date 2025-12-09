================================================================================
  HOPECARE DONATION MANAGEMENT SYSTEM - ENTREGA FINAL
  Consultora: XTech | Cliente: ONG HopeCare | Fecha: Diciembre 2024
================================================================================

TABLA DE CONTENIDO
==================
1. Información General
2. Estructura de Carpetas
3. Instrucciones de Instalación
4. Credenciales de Acceso
5. Descripción de Archivos
6. Orden de Ejecución de Scripts
7. Notas Importantes
8. Contacto

================================================================================
1. INFORMACIÓN GENERAL
================================================================================

Proyecto: Sistema de Gestión de Donaciones para ONG HopeCare
Consultora: XTech Consulting
Estudiante: Leslie Diaz Chambi
Curso: Base de Datos II
Docente: Jorge Luis Chávez Soto
Universidad: UNMSM - Facultad de Ingeniería de Sistemas e Informática

Tecnologías Utilizadas:
- Base de Datos: Oracle Database 19c (FREEPDB1)
- Backend: Java 17 + Spring Boot 3.2
- Frontend: HTML5 + CSS3 + JavaScript + Thymeleaf
- Arquitectura: 3 capas (Presentación, Negocio, Datos)

Características Principales:
✓ 14 tablas normalizadas (3FN)
✓ 6 packages PL/SQL (36 métodos)
✓ 8 triggers automáticos
✓ 8 vistas de negocio
✓ Sistema de auditoría completo
✓ Control de acceso por roles
✓ Aplicación web funcional

================================================================================
2. ESTRUCTURA DE CARPETAS
================================================================================

XTECH_HOPECARE_FINAL/
│
├── README.txt (este archivo)
│
│   ├── HC-DMS - Informe Entregable parcial 01.pdf
│   └── HC-DMS - Informe Entregable parcial 02.pdf
│   ├── Informe_Ejecutivo_HopeCare.pdf
│   └── Informe_Tecnico_HopeCare.pdf
│
├── 03_MODELOS/
│   ├── Modelo_Conceptual.png
│   ├── Modelo_Logico.png
│   └── Modelo_Fisico.png
│
├── 04_SCRIPTS_BASE_DATOS/
│   ├── 01_SETUP.sql
│   ├── 02_TABLES.sql
│   ├── 03_DATA_CATALOGS.sql
│   ├── 03_DATA_TEST.sql
│   ├── 04_PKG_DONATIONS.sql
│   ├── 05_PKG_DELIVERIES.sql
│   ├── 06_PKG_REPORTS.sql
│   ├── 07_PKG_DONORS.sql
│   ├── 08_PKG_BENEFICIARIES.sql
│   ├── 09_PKG_PROGRAMS.sql
│   ├── 10_TRIGGERS.sql
│   ├── 11_VIEWS.sql
│   ├── 12_TEST_OPERATIONS.sql
│   ├── 13_SECURITY.sql
│   └── 14_BACKUP.sql
│   ├── Script_Transacciones.sql
│   ├── Script_Concurrencia.sql
│   ├── Script_Prevencion_SQL_Injection.sql
│   ├── Script_Auditoria_BD.sql
│
├── 06_APLICACION/
│   ├── pom.xml
│   ├── README_APP.txt
│   └── src/
│       ├── main/
│       │   ├── java/com/hopecare/
│       │   │   ├── HopeCareApplication.java
│       │   │   ├── config/
│       │   │   ├── controller/
│       │   │   ├── model/
│       │   │   ├── repository/
│       │   │   └── service/
│       │   └── resources/
│       │       ├── application.properties
│       │       ├── static/
│       │       │   ├── css/style.css
│       │       │   └── js/main.js
│       │       └── templates/
│       │           ├── index.html
│       │           ├── login.html
│       │           ├── donors.html
│       │           ├── beneficiaries.html
│       │           ├── programs.html
│       │           ├── donations.html
│       │           ├── deliveries.html
│       │           └── reports.html
│       └── test/
│
│
└── 08_CAPTURAS/
    ├── Dashboard.png
    ├── Login.png
    ├── Donors_Module.png
    ├── Beneficiaries_Module.png
    ├── Programs_Module.png
    ├── Donations_Module.png
    ├── Deliveries_Module.png
    └── Reports_Module.png

================================================================================
3. INSTRUCCIONES DE INSTALACIÓN
================================================================================

REQUISITOS PREVIOS:
-------------------
✓ Oracle Database 19c instalado y ejecutándose
✓ Java 17 JDK instalado
✓ Maven 3.8+ instalado
✓ SQL Developer (recomendado)

PASO 1: CREAR BASE DE DATOS
----------------------------
1. Abrir SQL Developer
2. Conectarse como SYS (as SYSDBA)
3. Ejecutar: 04_SCRIPTS_BASE_DATOS/01_SETUP.sql
4. Verificar creación del usuario HOPECARE

PASO 2: CREAR ESTRUCTURA DE TABLAS
-----------------------------------
1. Conectarse como HOPECARE/hopecare123 a FREEPDB1
2. Ejecutar en orden:
   - 02_TABLES.sql
   - 03_DATA_CATALOGS.sql
   - 03_DATA_TEST.sql (datos de prueba)

PASO 3: CREAR OBJETOS PL/SQL
-----------------------------
Ejecutar en orden:
   - 04_PKG_DONATIONS.sql
   - 05_PKG_DELIVERIES.sql
   - 06_PKG_REPORTS.sql
   - 07_PKG_DONORS.sql
   - 08_PKG_BENEFICIARIES.sql
   - 09_PKG_PROGRAMS.sql
   - 10_TRIGGERS.sql
   - 11_VIEWS.sql
   - 13_SECURITY.sql

PASO 4: EJECUTAR PRUEBAS (OPCIONAL)
------------------------------------
   - 12_TEST_OPERATIONS.sql
   - Script_Transacciones.sql
   - Script_Auditoria_BD.sql

PASO 5: INSTALAR APLICACIÓN WEB
--------------------------------
1. Abrir terminal en carpeta 06_APLICACION/
2. Ejecutar: mvn clean install
3. Ejecutar: mvn spring-boot:run
4. Esperar mensaje: "HopeCare System Started Successfully!"
5. Abrir navegador en: http://localhost:8080/hopecare

PASO 6: VERIFICAR INSTALACIÓN
------------------------------
1. Login con: admin / admin123
2. Verificar dashboard muestra métricas
3. Probar navegación por módulos

================================================================================
4. CREDENCIALES DE ACCESO
================================================================================

BASE DE DATOS:
--------------
Usuario: hopecare
Contraseña: hopecare123
Servidor: localhost:1521
Servicio: FREEPDB1

APLICACIÓN WEB - ADMINISTRADOR:
--------------------------------
Usuario: admin
Contraseña: admin123
Rol: Administrator
Permisos: Acceso total a todos los módulos

APLICACIÓN WEB - ASISTENTE:
----------------------------
Usuario: assistant
Contraseña: assist123
Rol: Assistant
Permisos: Donaciones, Entregas, Reportes básicos
Restricción: NO puede acceder a Donors, Beneficiaries, Programs

================================================================================
5. DESCRIPCIÓN DE ARCHIVOS
================================================================================

INFORMES:
---------
- Informe_Ejecutivo_HopeCare.pdf
  * Para gerentes NO técnicos
  * Enfoque: Retorno de inversión, beneficios de negocio
  * 15 páginas aprox.

- Informe_Tecnico_HopeCare.pdf
  * Para gerentes técnicos y DBAs
  * Enfoque: Arquitectura, implementación, objetos PL/SQL
  * 40+ páginas

MODELOS:
--------
- Modelo_Conceptual.png: Diagrama E-R con 14 entidades
- Modelo_Logico.png: Modelo normalizado (3FN)
- Modelo_Fisico.png: Implementación en Oracle con tipos de datos

SCRIPTS PRINCIPALES:
--------------------
01_SETUP.sql
  - Crea usuario HOPECARE
  - Asigna privilegios necesarios
  - Configura tablespaces

02_TABLES.sql
  - Crea 14 tablas
  - Crea 14 secuencias
  - Define Primary Keys

03_DATA_CATALOGS.sql
  - Carga catálogos (monedas, roles, tipos de donación)
  - Carga tasas de cambio iniciales
  - Crea usuarios del sistema

04-09_PKG_*.sql
  - 6 packages PL/SQL con 36 métodos en total
  - Encapsulan lógica de negocio
  - Validaciones y control de transacciones

10_TRIGGERS.sql
  - 8 triggers automáticos
  - Auditoría de donaciones y entregas
  - Protección de datos de auditoría
  - Actualización automática de timestamps

11_VIEWS.sql
  - 8 vistas de negocio
  - Simplifica consultas complejas
  - Pre-calcula métricas para dashboard

13_SECURITY.sql
  - Funciones de hash de contraseñas
  - Validación de credenciales
  - Procedimientos de gestión de usuarios

SCRIPTS ADICIONALES:
--------------------
Script_Transacciones.sql
  - Demuestra flujos transaccionales completos
  - Valida integridad de datos
  - Casos de éxito y fallo

Script_Concurrencia.sql
  - Pruebas de bloqueos y deadlocks
  - Niveles de aislamiento
  - SELECT FOR UPDATE

Script_Prevencion_SQL_Injection.sql
  - Demuestra protecciones implementadas
  - Intenta ataques reales (todos bloqueados)
  - Uso de bind variables

Script_Auditoria_BD.sql
  - Reporte de salud de la base de datos
  - Verificación de integridad
  - Alertas y recomendaciones

================================================================================
6. ORDEN DE EJECUCIÓN DE SCRIPTS
================================================================================

INSTALACIÓN INICIAL (ejecutar UNA VEZ):
========================================
Como SYSDBA:
  1. 01_SETUP.sql

Como HOPECARE:
  2. 02_TABLES.sql
  3. 03_DATA_CATALOGS.sql
  4. 03_DATA_TEST.sql (opcional, datos de prueba)
  5. 04_PKG_DONATIONS.sql
  6. 05_PKG_DELIVERIES.sql
  7. 06_PKG_REPORTS.sql
  8. 07_PKG_DONORS.sql
  9. 08_PKG_BENEFICIARIES.sql
 10. 09_PKG_PROGRAMS.sql
 11. 10_TRIGGERS.sql
 12. 11_VIEWS.sql
 13. 13_SECURITY.sql

PRUEBAS (ejecutar después de instalación):
===========================================
 14. 12_TEST_OPERATIONS.sql
 15. Script_Transacciones.sql
 16. Script_Prevencion_SQL_Injection.sql
 17. Script_Auditoria_BD.sql

MANTENIMIENTO (ejecutar cuando sea necesario):
===============================================
 18. 14_BACKUP.sql (procedimientos de backup)

IMPORTANTE: NO ejecutar Script_Concurrencia.sql completo, ya que requiere
2 sesiones simultáneas. Ver README_Scripts.md para instrucciones detalladas.

================================================================================
7. NOTAS IMPORTANTES
================================================================================

ANTES DE EJECUTAR:
------------------
✓ Asegurarse de que Oracle Database está ejecutándose
✓ Verificar que FREEPDB1 está disponible
✓ Tener permisos de SYSDBA para crear usuarios
✓ Configurar variables de entorno Java y Maven

DURANTE LA EJECUCIÓN:
---------------------
✓ Revisar mensajes de error en SQL Developer
✓ Verificar que cada script se completa sin errores
✓ No interrumpir la ejecución de los packages (pueden tardar 1-2 min)
✓ Activar DBMS_OUTPUT para ver mensajes informativos (SET SERVEROUTPUT ON)

DESPUÉS DE LA INSTALACIÓN:
---------------------------
✓ Verificar objetos inválidos: SELECT * FROM user_objects WHERE status='INVALID';
✓ Si hay objetos inválidos, recompilarlos: ALTER PACKAGE pkg_name COMPILE;
✓ Ejecutar Script_Auditoria_BD.sql para verificar salud del sistema
✓ Hacer backup inicial: Tools > Database Export en SQL Developer

SOLUCIÓN DE PROBLEMAS:
-----------------------
1. Error ORA-01017: Invalid username/password
   → Verificar que 01_SETUP.sql se ejecutó correctamente
   → Reconectarse a SQL Developer

2. Error ORA-00942: Table or view does not exist
   → Verificar que 02_TABLES.sql se ejecutó completamente
   → Revisar si estás conectado al esquema correcto (HOPECARE)

3. Error ORA-04043: Object does not exist
   → Ejecutar los packages antes que los triggers y views
   → Seguir el orden de ejecución especificado arriba

4. Aplicación no inicia
   → Verificar que Java 17 está instalado: java -version
   → Verificar que Maven está instalado: mvn -version
   → Revisar application.properties tiene credenciales correctas

5. No se ve el dashboard
   → Verificar que iniciaste sesión con admin/admin123
   → Revisar en consola de Spring Boot si hay errores
   → Verificar que el puerto 8080 no está en uso

VIDEO DE PRESENTACIÓN:
-----------------------
