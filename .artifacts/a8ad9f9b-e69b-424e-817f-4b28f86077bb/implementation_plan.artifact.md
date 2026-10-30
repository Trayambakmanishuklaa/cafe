# Staff Panel Daily Expense Tracker with Monthly Graph — Implementation Plan

Add a Daily Expense Tracking system to the existing Cafe Management App, allowing staff to record expenses in 8 categories on the Kitchen Page, with a live daily expense graph and total monthly summary on the Staff Overview Page.

## User Review Required

> [!NOTE]
> All existing screens, including Customer Panel (Home, Menu, Book Seat, Passport) and Staff Panel (Overview, Kitchen Queue, Seats Mgmt, Products), remain completely intact and functional.

## Proposed Changes

### Backend & Database (Node.js + Express + Prisma + MongoDB)
1. **Prisma Schema (`schema.prisma`)**:
   - Add `Expense` model with fields: `id`, `category`, `itemDetails`, `amount`, `expenseDate`, `paymentMethod`, `note`, `createdBy`, `createdAt`, `updatedAt`.
   - Relation with `User` (`createdBy` -> `User`).
2. **Expense Service & Endpoints (`backend/src/modules/expenses/`)**:
   - `POST /api/v1/expenses` — Create expense.
   - `GET /api/v1/expenses/monthly` — Returns `month`, `year`, `totalExpense`, and `dailyExpenses` array (`[{ day: 1, total: 500 }, ...]`).
   - `GET /api/v1/expenses` — Fetch expense history.
3. **Register Route in `backend/src/app.js`**:
   - Mount `/api/v1/expenses`.

### Frontend (Flutter + GetX)
1. **Kitchen Page (`StaffOrderQueueView`)**:
   - Add "Daily Expenses" section below the order queue.
   - 8 Category Cards: Raw Materials, Ingredients, Staff & Labour, Utilities, Rent & Maintenance, Equipment, Marketing, Other.
   - Add Expense Form modal with category pre-selection, item details, amount in ₹, date picker, payment method dropdown, and note.
2. **Staff Overview Page (`StaffOverviewTab`)**:
   - Add "Monthly Expense Overview" section.
   - Month/Year selector with `<` and `>` controls.
   - Interactive Bar Graph showing daily expenses for the selected month.
   - "Total Expenses This Month: ₹X" banner.
   - Empty state when no expenses exist for the selected month ("No expenses recorded for this month", ₹0 total).

## Verification Plan

### Automated Tests
- Run backend unit/integration tests (`npm test`).
- Run Flutter static analyzer (`analyze_file`).

### Manual Verification
- Test adding expenses under different categories in the Kitchen Page.
- Verify expense is saved in MongoDB.
- Switch to Staff Overview Page and verify the daily graph and monthly total update instantly.
- Test changing months to view historical data and empty month state.
