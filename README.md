<h1 align="center">SGSITS Student Portal</h1>
<p align="center">
Modernized deployment-ready for the SGSITS student portal context.
</p>

## Overview
This project is a PHP/MySQL student information system providing administrative, academic, and reporting functionality for institutions. It includes modules for school setup, student management, scheduling, grades, attendance, eligibility, discipline, billing, messaging, and utilities. The codebase has been adjusted to support containerized & cloud deployment (e.g. Render) using environment variables rather than hard‑coded credentials.

## Core Features
- Student demographics, enrollment & reenrollment workflows
- Course catalog, sections, marking periods & scheduling tools
- Attendance tracking with validation helpers
- Grade reporting & GPA calculations
- Discipline, eligibility, and billing modules (extensible)
- Custom fields for users, staff, and schools
- Bulk operations (mass schedule, rollover utilities, data import/export)
- Role & profile driven access control
- API endpoints (`api/SchoolInfo.php`, `api/StaffInfo.php`, `api/StudentEnrollmentInfo.php`)
- Health status endpoint (`health.php`) for platform monitoring
- Rollover & backup scripts for year transitions
- Modular UI includes (Top, Side, Bottom, Menus) and dynamic modal components

## Recent Enhancements (Deployment Readiness)
- Environment-driven configuration (`Data.php` sources DB and app settings via env vars)
- Added `Dockerfile` suitable for container hosting
- Added `render.yaml` (infrastructure hint for Render Web Service)
- Centralized database port handling across all runtime connections
- Removed a hard-coded external logging connection for security hardening
- Added `health.php` JSON endpoint for uptime checks
- Expanded `.gitignore` to prevent accidental leakage of secrets and transient data

## Directory Structure (Selected)
```
assets/                Static images, icons, UI media
api/                   Public API endpoints (JSON-oriented)
modules/               Functional modules (schoolsetup, students, users, tools, etc.)
functions/             Reusable function libraries (DB helpers, validation, formatting)
install/               Installation & upgrade scripts (legacy, retain only if needed)
js/                    JavaScript assets and plugins
lang/                  Localization resources (labels, translations)
libraries/             Third-party or shared PHP libraries
health.php             Lightweight health/status probe
ConfigInc.php          Core bootstrap loading DB + app metadata
DatabaseInc.php        DB abstraction & query helpers
ConnectionClass.php    Connection wrapper class (mysqli)
Data.php               Environment variable orchestration (runtime configuration)
render.yaml            Render service definition (optional infrastructure metadata)
Dockerfile             Container build definition
```

## Runtime Architecture (High-Level)
1. `ConfigInc.php` loads `Data.php` (env values) then initializes DB + version metadata from the `app` table.
2. `DatabaseInc.php` supplies query helpers (`DBQuery`, `db_start`, etc.).
3. Session and module resolution flows through `Modules.php`, including security checks & dynamic module includes.
4. Each module encapsulates its UI, forms, and process scripts (procedural style).
5. APIs supply structured JSON outputs using direct SQL queries while reusing global configuration.
6. The health endpoint performs a minimal READ query to validate database connectivity.


An example template is provided in `.env.example` (no real secrets committed).

## Security & Hardening Notes
- **Secrets**: All credentials sourced from environment variables; no secrets stored in VCS.
- **Installer**: The `install/` directory contains legacy provisioning & upgrade scripts. Remove or restrict it in production once the system is initialized.
- **Health Endpoint**: `health.php` currently open; optionally add a token or IP allowlist if required.
- **Error Handling**: `db_show_error` can expose stack traces. Consider disabling verbose output or gating behind an environment flag in production.
- **Legacy Code**: Some legacy procedural patterns and commented `mysql_*` references remain (non-executing). Refactoring opportunity for future modernization.
- **Uploads**: If enabling user/student photo or file uploads, ensure those directories are protected from arbitrary script execution (e.g. disable PHP in upload paths at web server level).

## API Summary (Selected)
- `api/SchoolInfo.php`: School meta & structural data
- `api/StaffInfo.php`: Staff directory & roles
- `api/StudentEnrollmentInfo.php`: Enrollment listings & status
All rely on global DB connection; rate limiting / auth is advised before public exposure.

## Logging & Auditing
The system provides basic logging through DB write operations and (optionally) email notifications for certain errors or violation attempts. Centralized structured logging could be introduced (future enhancement) using middleware or a PSR-3 compatible logger.

## Internationalization
Language resources live under `lang/`. Extending translation coverage involves adding or updating label arrays and ensuring UI echoes translation keys consistently.

## Extensibility
Modules can be added by creating a directory under `modules/` with the appropriate entry point and including it via navigation or direct `modname` dispatch. Shared helpers should live in `functions/` to avoid duplication.

## Roadmap (Suggested Future Work)
- Introduce Composer autoloading & dependency management
- Replace procedural DB wrappers with PDO + prepared statements
- Add automated test coverage (PHPUnit) for critical logic (GPA calc, enrollment transitions)
- Implement a lightweight ORM or query builder for safety
- Migrate inline HTML/PHP mixes toward a template system (Twig / Blade)
- Add role-based API authentication (JWT or session tokens)
- Harden health & API endpoints (rate limiting, structured error responses)
- Implement CI (lint, security scan, container build) via GitHub Actions
- Normalize date/time handling with UTC storage & configurable display timezones
- Remove or archive legacy install scripts after stable migrations are scripted

## Contributing
1. Follow clear commit messages (Conventional Commits style recommended).
2. Keep security in mind—never commit secrets or production dumps.
3. Prefer small, focused pull requests per feature or fix.
4. Include a brief rationale in PR descriptions—especially for schema changes.

## License
This project inherits the original openSIS GPLv2 license headers present in source files. See `license.txt` (or original upstream licensing) for full terms. All modifications herein are provided under the same GPLv2 license.

## Attribution
Based on openSIS (Open Solutions for Education, Inc.). Enhancements & deployment adjustments tailored for SGSITS portal usage.

## Status Badge (Manual)
Add CI or deployment status badges here when pipelines are introduced.

---
This README focuses on architecture, capabilities, and operational context while intentionally omitting step-by-step setup instructions.
