# 🤝 HopeCare - Donation Management System

Sistema de gestión de donaciones para ONGs desarrollado con Oracle Database y Spring Boot.

## 📊 Video Demo

[Ver presentación del sistema](https://drive.google.com/file/d/1w22a1J6rRTQDVKpixD2jYnWrbCNcQbrf/view?usp=sharing)

##  Características

- Gestión de donantes y beneficiarios
- Control de donaciones y entregas
- Programas de ayuda personalizables
- Reportes y métricas en tiempo real
- Sistema de roles y permisos
- Auditoría completa de operaciones

##  Instalación

### 1. Base de Datos

```sql
-- Conectar como SYS
sqlplus sys as sysdba

-- Ejecutar scripts en orden:
@04_SCRIPTS_BASE_DATOS/01_SETUP.sql
@04_SCRIPTS_BASE_DATOS/02_TABLES.sql
@04_SCRIPTS_BASE_DATOS/03_DATA_CATALOGS.sql
@04_SCRIPTS_BASE_DATOS/04_PKG_DONATIONS.sql
@04_SCRIPTS_BASE_DATOS/05_PKG_DELIVERIES.sql
@04_SCRIPTS_BASE_DATOS/06_PKG_REPORTS.sql
@04_SCRIPTS_BASE_DATOS/07_PKG_DONORS.sql
@04_SCRIPTS_BASE_DATOS/08_PKG_BENEFICIARIES.sql
@04_SCRIPTS_BASE_DATOS/09_PKG_PROGRAMS.sql
@04_SCRIPTS_BASE_DADOS/10_TRIGGERS.sql
@04_SCRIPTS_BASE_DATOS/11_VIEWS.sql
@04_SCRIPTS_BASE_DATOS/13_SECURITY.sql
```

### 2. Aplicación Web

```bash
cd 06_APLICACION
mvn clean install
mvn spring-boot:run
```

Acceder en: `http://localhost:8080/hopecare`

## 🔑 Credenciales

**Base de Datos:**
- Usuario: `hopecare`
- Contraseña: `hopecare123`
- Servicio: `FREEPDB1`

**Administrador:**
- Usuario: `admin`
- Contraseña: `admin123`

**Asistente:**
- Usuario: `assistant`
- Contraseña: `assist123`

##  Estructura

```
XTech Solutions/
├── aplicacion/             # Aplicación Spring Boot
├── modelos/                # Modelos de base de datos
├── scripts/                # Scripts SQL y PL/SQL
├── HC-DMS - Informe Ejecutivo.pdf
├── HC-DMS - Informe Técnico.pdf
├── HC-DMS - Informe Entregable p...
└── README.md
```

##  Stack Tecnológico

- **Backend:** Spring Boot, Java
- **Base de Datos:** Oracle Database (PL/SQL)
- **Frontend:** Thymeleaf, HTML/CSS/JS
- **Build:** Maven



##  Licencia

Proyecto desarrollado por **XTech** para **ONG HopeCare** - Diciembre 2024

---

💙 *Desarrollado con el propósito de facilitar la gestión de ayuda humanitaria*
