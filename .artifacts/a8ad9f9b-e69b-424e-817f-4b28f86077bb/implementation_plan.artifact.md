# Complete Responsive UI, Adaptive Font Scaling & Overflow Prevention — Implementation Plan

Upgrade the entire Flutter application to be 100% responsive and adaptive across all Android screen sizes, display zoom levels, and system accessibility font scaling settings without breaking existing functionality or visual identity.

## User Review Required

> [!NOTE]
> All existing business logic, GetX controllers, APIs, authentication, and screens remain 100% intact. This optimization ensures fluid responsiveness, zero overflow stripes, and accessibility font scaling support.

## Proposed Changes

### Centralized Responsive & Typography Utility (`lib/app/theme/app_theme.dart`)
- **`AppResponsive` Utility**:
  - Screen size categorization (`isSmallScreen`, `isTablet`, `isLandscape`).
  - Adaptive padding, margin, and font size helpers using modern `MediaQueryData` and `TextScaler`.
  - Responsive Theme Data configuring `TextTheme` and `InputDecorationTheme`.

### Frontend Screen Responsiveness Audit & Optimization
1. **Authentication Screens (`login_view.dart`, `register_view.dart`)**:
   - Wrap in `SingleChildScrollView` with `LayoutBuilder` & `ConstrainedBox(minHeight: constraint.maxHeight)`.
   - Ensure zero overflow when soft keyboard opens or system font size increases.
2. **Customer Screens (`home_view.dart`, `menu_view.dart`, `booking_view.dart`, `passport_view.dart`)**:
   - Use `Expanded`, `Flexible`, and adaptive grid crossAxisCount (2 columns on mobile, 3-4 on tablet/landscape).
   - Ensure cards, category chips, loyalty progress bars, and seat layout map adapt dynamically without text clipping.
3. **Staff Screens (`staff_main_navigation_view.dart`, `staff_order_queue_view.dart`, `staff_product_management_view.dart`, `staff_seat_management_view.dart`)**:
   - Responsive KPI grid, Monthly Expense Graph, Date-wise Expense cards, and seat check-in card.
   - Adaptive category grid (2 columns on phone, 4 on tablet/landscape).

## Verification Plan

### Automated Tests
- Run Flutter static analyzer (`analyze_file`) on all modified UI views.

### Manual Verification
- Test screens on small phone screens, standard phones, tablets, and landscape orientation.
- Verify zero `RenderFlex` overflow errors when soft keyboard appears.
- Test with increased system font size (accessibility scaling).
