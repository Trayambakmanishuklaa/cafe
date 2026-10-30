import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import 'staff_day_closing_view.dart';
import 'staff_inventory_view.dart';
import 'staff_order_queue_view.dart';
import 'staff_pos_view.dart';
import 'staff_product_management_view.dart';
import 'staff_seat_management_view.dart';

class StaffMainNavigationView extends StatefulWidget {
  const StaffMainNavigationView({super.key});

  @override
  State<StaffMainNavigationView> createState() => _StaffMainNavigationViewState();
}

class _StaffMainNavigationViewState extends State<StaffMainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _staffPages = [
    const StaffOverviewTab(),
    const StaffPosView(),
    const StaffOrderQueueView(),
    const StaffInventoryView(),
    const StaffSeatManagementView(),
    const StaffProductManagementView(),
    const StaffDayClosingView(),
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
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_outlined),
            activeIcon: Icon(Icons.point_of_sale),
            label: 'POS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen_outlined),
            activeIcon: Icon(Icons.kitchen),
            label: 'Kitchen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_outlined),
            activeIcon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_restaurant_outlined),
            activeIcon: Icon(Icons.table_restaurant),
            label: 'Seats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_clock_outlined),
            activeIcon: Icon(Icons.lock_clock),
            label: 'Closing',
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

  // Monthly Expense Graph state
  DateTime _selectedMonth = DateTime.now();
  double _totalMonthlyExpense = 0.0;
  List<dynamic> _dailyExpenses = [];
  bool _isLoadingExpenses = false;

  @override
  void initState() {
    super.initState();
    _fetchStaffKpis();
    _fetchMonthlyExpenses();
  }

  Future<void> _fetchStaffKpis() async {
    try {
      final res = await _apiClient.get('/orders/staff/queue');
      final List<dynamic> list = res.data['data'] ?? [];
      setState(() {
        _pendingCount = list.where((o) => o['status'] == 'PENDING').length;
        _preparingCount = list.where((o) => o['status'] == 'PREPARING').length;
        _readyCount = list.where((o) => o['status'] == 'READY').length;
      });
    } catch (_) {}
  }

  Future<void> _fetchMonthlyExpenses() async {
    setState(() => _isLoadingExpenses = true);
    try {
      final res = await _apiClient.get('/expenses/monthly', queryParameters: {
        'month': _selectedMonth.month,
        'year': _selectedMonth.year,
      });
      final data = res.data['data'] ?? {};
      setState(() {
        _totalMonthlyExpense = (data['totalExpense'] as num?)?.toDouble() ?? 0.0;
        _dailyExpenses = data['dailyExpenses'] ?? [];
      });
    } catch (e) {
      Get.snackbar('Expense Error', ErrorUtils.getCleanMessage(e));
    } finally {
      setState(() => _isLoadingExpenses = false);
    }
  }

  void _changeMonth(int increment) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + increment, 1);
    });
    _fetchMonthlyExpenses();
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
          backgroundColor: Colors.green.withAlpha(25), colorText: Colors.green);
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
        onRefresh: () async {
          await _fetchStaffKpis();
          await _fetchMonthlyExpenses();
        },
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

              // Monthly Expense Overview Section
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Monthly Expense Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, size: 22),
                                onPressed: () => _changeMonth(-1),
                              ),
                              Text(
                                DateFormat('MMM yyyy').format(_selectedMonth),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, size: 22),
                                onPressed: () => _changeMonth(1),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 16),

                      // Expense Bar Graph / Empty State
                      if (_isLoadingExpenses)
                        const SizedBox(height: 140, child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
                      else if (_dailyExpenses.every((d) => (d['total'] as num? ?? 0) == 0))
                        const Container(
                          height: 120,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart, size: 40, color: AppColors.textLight),
                              SizedBox(height: 6),
                              Text('No expenses recorded for this month', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: 140,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _dailyExpenses.map((d) {
                              final dayNum = d['day'];
                              final total = (d['total'] as num?)?.toDouble() ?? 0.0;
                              final maxVal = _dailyExpenses
                                  .map((x) => (x['total'] as num?)?.toDouble() ?? 0.0)
                                  .reduce((a, b) => a > b ? a : b);
                              final heightRatio = maxVal > 0 ? (total / maxVal) : 0.0;

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (total > 0)
                                        FittedBox(
                                          child: Text('₹${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                                        ),
                                      const SizedBox(height: 2),
                                      Container(
                                        height: MathUtils.clampDouble(100 * heightRatio, 4, 100),
                                        decoration: BoxDecoration(
                                          color: total > 0 ? AppColors.primary : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('$dayNum', style: const TextStyle(fontSize: 8, color: AppColors.textLight)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Total Expenses Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Expenses This Month:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              '₹${_totalMonthlyExpense.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
              const SizedBox(height: 30),
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

class MathUtils {
  static double clampDouble(double val, double min, double max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
  }
}
