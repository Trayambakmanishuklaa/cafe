import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import 'staff_order_queue_view.dart';
import 'staff_product_management_view.dart';
import '../../booking/views/booking_view.dart';

class StaffMainNavigationView extends StatefulWidget {
  const StaffMainNavigationView({super.key});

  @override
  State<StaffMainNavigationView> createState() => _StaffMainNavigationViewState();
}

class _StaffMainNavigationViewState extends State<StaffMainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _staffPages = [
    const StaffOverviewTab(),
    const StaffOrderQueueView(),
    const BookingView(),
    const StaffProductManagementView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _staffPages,
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
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen_outlined),
            activeIcon: Icon(Icons.kitchen),
            label: 'Kitchen Queue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'Seat Check-In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Product Mgmt',
          ),
        ],
      ),
    );
  }
}

class StaffOverviewTab extends StatefulWidget {
  const StaffOverviewTab({super.key});

  @override
  State<StaffOverviewTab> createState() => _StaffOverviewTabState();
}

class _StaffOverviewTabState extends State<StaffOverviewTab> {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final _qrCodeController = TextEditingController();
  int _pendingCount = 0;
  int _preparingCount = 0;
  int _readyCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStaffKpis();
  }

  Future<void> _fetchStaffKpis() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get('/orders/staff/queue');
      final List<dynamic> list = res.data['data'] ?? [];
      setState(() {
        _pendingCount = list.where((o) => o['status'] == 'PENDING').length;
        _preparingCount = list.where((o) => o['status'] == 'PREPARING').length;
        _readyCount = list.where((o) => o['status'] == 'READY').length;
      });
    } catch (_) {} finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCheckInPass() async {
    final code = _qrCodeController.text.trim();
    if (code.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter or scan booking code');
      return;
    }

    try {
      await _apiClient.post('/bookings/check-in/$code');
      _qrCodeController.clear();
      Get.snackbar('Check-In Verified!', 'Guest successfully checked in to their table!',
          backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
    } catch (e) {
      Get.snackbar('Check-In Failed', 'Booking pass not found or already checked in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff Operational Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchStaffKpis,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Staff Greeting
              Text(
                'Barista Staff Shift: ${authController.currentUser.value?.name ?? "Staff"} ☕',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 16),

              // Operational KPI Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: [
                  _buildKpiCard('Awaiting', '$_pendingCount', Colors.amber),
                  _buildKpiCard('Preparing', '$_preparingCount', Colors.blue),
                  _buildKpiCard('Ready', '$_readyCount', Colors.green),
                ],
              ),
              const SizedBox(height: 24),

              // QR Booking Pass Verification Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 28),
                          SizedBox(width: 10),
                          Text('Guest Seat Check-In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Enter guest booking code (e.g. SEAT-123456) to verify reservation.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _qrCodeController,
                              decoration: const InputDecoration(
                                hintText: 'Booking Code (e.g. SEAT-100200)',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 48)),
                            onPressed: _verifyCheckInPass,
                            child: const Text('CHECK IN'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color color) {
    return Card(
      elevation: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ],
      ),
    );
  }
}
