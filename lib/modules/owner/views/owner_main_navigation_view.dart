import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import 'owner_dashboard_view.dart';
import 'staff_management_view.dart';
import 'customer_management_view.dart';
import '../../staff/views/staff_order_queue_view.dart';

class OwnerMainNavigationView extends StatefulWidget {
  const OwnerMainNavigationView({super.key});

  @override
  State<OwnerMainNavigationView> createState() => _OwnerMainNavigationViewState();
}

class _OwnerMainNavigationViewState extends State<OwnerMainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _ownerPages = [
    const OwnerDashboardView(),
    const StaffManagementView(),
    const CustomerManagementView(),
    const StaffOrderQueueView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _ownerPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Overview KPIs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge_outlined),
            activeIcon: Icon(Icons.badge),
            label: 'Staff Mgmt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt),
            label: 'Customer CRM',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen_outlined),
            activeIcon: Icon(Icons.kitchen),
            label: 'Kitchen Queue',
          ),
        ],
      ),
    );
  }
}
