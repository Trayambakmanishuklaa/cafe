import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../staff/views/staff_main_navigation_view.dart';
import 'admin_daily_sales_tab.dart';
import 'admin_dashboard_view.dart';
import 'admin_staff_management_view.dart';

class AdminMainNavigationView extends StatefulWidget {
  const AdminMainNavigationView({super.key});

  @override
  State<AdminMainNavigationView> createState() => _AdminMainNavigationViewState();
}

class _AdminMainNavigationViewState extends State<AdminMainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _adminPages = [
    const AdminDashboardView(),
    const AdminStaffManagementView(),
    const AdminDailySalesTab(),
    const StaffOverviewTab(), // Complete Staff Expense Overview Integration
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _adminPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Staff Mgmt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_outlined),
            activeIcon: Icon(Icons.point_of_sale),
            label: 'Daily Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Expenses Tab',
          ),
        ],
      ),
    );
  }
}
