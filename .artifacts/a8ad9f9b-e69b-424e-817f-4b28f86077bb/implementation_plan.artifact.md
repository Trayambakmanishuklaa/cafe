# Admin Panel, Staff Management, Daily Sales & Staff Overview Integration — Implementation Plan

Build a complete **Admin Panel** inside the existing single Flutter app, featuring Staff Account Management, Daily Sales Entry & Reporting, Expense Overview Integration, and Combined Business Financial Overview (Sales, Expenses, Net Operating Difference).

## User Review Required

> [!IMPORTANT]
> **Role-Based Security & Privacy**: Admin endpoints are strictly protected by `authorize('ADMIN')`. Staff members can record their daily sales and expenses, but cannot access Admin financial reports, staff management, or change other staff members' records.

## Proposed Changes

### Backend & Database (Node.js + Express + Prisma + MongoDB)
1. **Prisma Schema (`schema.prisma`)**:
   - `DailySales` model: `id`, `staffId` (User relation), `salesDate`, `totalSales`, `note`, `createdAt`, `updatedAt`.
   - Ensure `User` model supports `ADMIN`, `STAFF`, `CUSTOMER` roles and relations.
2. **Daily Sales Module (`backend/src/modules/sales/`)**:
   - `POST /api/v1/sales/daily` — Record/update staff daily sales entry (upsert by `staffId` + `salesDate`).
   - `GET /api/v1/sales/daily/my-records` — Staff views their own daily sales entries.
   - `GET /api/v1/admin/sales/by-date` — Admin views all staff sales for a date.
   - `GET /api/v1/admin/sales/monthly` — Admin views aggregated monthly sales graph and total.
3. **Staff Management Module (`backend/src/modules/admin/`)**:
   - `POST /api/v1/admin/staff` — Create staff account (Full Name, Mobile, Email, Password, Active status).
   - `GET /api/v1/admin/staff` — List and search staff.
   - `PATCH /api/v1/admin/staff/:id/status` — Activate/Deactivate staff account.
   - `PATCH /api/v1/admin/staff/:id/reset-password` — Reset password.
4. **Combined Business Overview (`/api/v1/admin/dashboard/overview`)**:
   - Aggregates total sales, total expenses, net operating difference (Sales - Expenses), total orders, and active staff.

### Frontend (Flutter + GetX)
1. **Role-Based Navigation (`MainNavigationView`)**:
   - Automatically routes logged-in user to Customer, Staff, or Admin dashboard based on `user.role`.
2. **Staff Panel Addition (`staff_main_navigation_view.dart`)**:
   - Add **"Daily Sales Entry"** tab/section so staff can enter and submit today's sales before shift end.
3. **Admin Panel Screens (`lib/modules/admin/views/`)**:
   - `admin_dashboard_view.dart` — Combined Business Summary, Monthly Sales Graph, Monthly Expense Graph, Date-wise Sales & Expenses.
   - `admin_staff_management_view.dart` — Create Staff, Search Staff, Toggle Status, Reset Password.

## Verification Plan

### Automated Tests
- Run backend integration tests (`npm test`).
- Run Flutter static analyzer (`analyze_file`) across all new views.

### Manual Verification
- Log in as Admin (`admin@cafe.com` / `Admin@123`).
- Create a new Staff account (`Staff`).
- Log in as the new Staff, record daily expenses in Kitchen, and submit Daily Sales.
- Log back in as Admin, verify the daily sales and expense records appear under Date-wise and Monthly graphs.
- Verify Customer Panel remains 100% operational.
