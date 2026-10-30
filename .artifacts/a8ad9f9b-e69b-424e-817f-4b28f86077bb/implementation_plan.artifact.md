# Date-wise Daily Expense Details in Staff Overview Page — Implementation Plan

Extend the Staff Overview Page with a **Date-wise Expense Details** section, allowing staff to select any date, view expense records grouped by category with full details (Item, Amount, Payment Method, Note, Staff Creator Name), and see category totals and overall daily total.

## User Review Required

> [!NOTE]
> All existing features remain 100% untouched: Kitchen Page expense submission, 8 expense categories, Monthly Expense Graph, Monthly Total Calculation, and Customer/Staff screens.

## Proposed Changes

### Backend & Database (Node.js + Express + Prisma + MongoDB)
1. **Expense Service & API (`backend/src/modules/expenses/`)**:
   - Add `GET /api/v1/expenses/by-date?date=YYYY-MM-DD`.
   - Fetches all expense records for the specified calendar day across all authorized staff members.
   - Populates staff creator name (`user: { name }`).
   - Calculates `dailyTotal` and `categoryTotals` map (`{ "Raw Materials": 500, "Ingredients": 300 }`).

### Frontend (Flutter + GetX)
1. **Staff Overview Page (`StaffOverviewTab` in `staff_main_navigation_view.dart`)**:
   - Add **"Date-wise Expense Details"** section below the Monthly Expense Overview card.
   - **Date Selector**: Controls for Previous Date `<` and Next Date `>`, and date picker.
   - **Expense Record Cards**: Grouped by category, displaying Item Details, Amount in ₹, Payment Method, Note, and Staff Creator Name.
   - **Category Totals**: Total amount for each displayed category.
   - **Daily Total Banner**: `Total Expenses on [Date]: ₹X,XXX`.
   - **Empty State**: Displays *"No expenses recorded for this date."* and ₹0 total when no records exist.
   - **Sync with Month Selector**: Changing month updates the date selector to today's date (if in month) or 1st of selected month and refreshes date-wise details.

## Verification Plan

### Automated Tests
- Run backend unit/integration tests (`npm test`).
- Run Flutter static analyzer (`analyze_file`).

### Manual Verification
- Add expenses from Kitchen Page under multiple categories.
- Verify today's date on Overview Page displays records grouped by category with staff creator name and totals.
- Select previous dates to verify historical daily records.
- Change months in the monthly graph and verify date-wise details sync cleanly.
