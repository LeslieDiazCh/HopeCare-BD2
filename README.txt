================================================================================
  HOPECARE DONATION MANAGEMENT SYSTEM - ENTREGA FINAL
  Consultora: XTech | Cliente: ONG HopeCare | Fecha: Diciembre 2024
================================================================================

VIDEO DE PRESENTACIÓN: https://drive.google.com/file/d/17RvjdU6bQF6RJbHb-gGwsOiBx_w5x8LU/view?usp=sharing





==================
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

================================================================================
3. INSTRUCCIONES DE INSTALACIÓN
================================================================================
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


