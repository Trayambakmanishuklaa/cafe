import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';
import 'staff_daily_sales_view.dart';
import 'staff_order_queue_view.dart';
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
    const StaffOrderQueueView(),
    const StaffDailySalesView(),
    const StaffSeatManagementView(),
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
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen_outlined),
            activeIcon: Icon(Icons.kitchen),
            label: 'Kitchen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_outlined),
            activeIcon: Icon(Icons.point_of_sale),
            label: 'Daily Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_restaurant_outlined),
            activeIcon: Icon(Icons.table_restaurant),
            label: 'Seats Mgmt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
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

  // Date-wise Expense Details state
  DateTime _selectedDateDetails = DateTime.now();
  double _dailyTotalExpense = 0.0;
  Map<String, dynamic> _categoryTotals = {};
  List<dynamic> _dateExpensesList = [];
  bool _isLoadingDateExpenses = false;

  @override
  void initState() {
    super.initState();
    _fetchStaffKpis();
    _fetchMonthlyExpenses();
    _fetchDateExpenses();
  }

  Future<void> _fetchStaffKpis() async {
    try {
      final res = await _apiClient.get('/orders/staff/queue');
      final List<dynamic> list = res.data['data'] ?? [];
      if (!mounted) return;
      setState(() {
        _pendingCount = list.where((o) => o['status'] == 'PENDING').length;
        _preparingCount = list.where((o) => o['status'] == 'PREPARING').length;
        _readyCount = list.where((o) => o['status'] == 'READY').length;
      });
    } catch (_) {}
  }

  Future<void> _fetchMonthlyExpenses() async {
    if (!mounted) return;
    setState(() => _isLoadingExpenses = true);
    try {
      final res = await _apiClient.get('/expenses/monthly', queryParameters: {
        'month': _selectedMonth.month,
        'year': _selectedMonth.year,
      });
      final data = res.data['data'] ?? {};
      if (!mounted) return;
      setState(() {
        _totalMonthlyExpense = (data['totalExpense'] as num?)?.toDouble() ?? 0.0;
        _dailyExpenses = data['dailyExpenses'] ?? [];
      });
    } catch (e) {
      if (mounted) {
        Get.snackbar('Expense Error', ErrorUtils.getCleanMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingExpenses = false);
      }
    }
  }

  Future<void> _fetchDateExpenses() async {
    if (!mounted) return;
    setState(() => _isLoadingDateExpenses = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDateDetails);
      final res = await _apiClient.get('/expenses/by-date', queryParameters: {'date': dateStr});
      final data = res.data['data'] ?? {};
      if (!mounted) return;
      setState(() {
        _dailyTotalExpense = (data['dailyTotal'] as num?)?.toDouble() ?? 0.0;
        _categoryTotals = Map<String, dynamic>.from(data['categoryTotals'] ?? {});
        _dateExpensesList = data['expenses'] ?? [];
      });
    } catch (e) {
      if (mounted) {
        Get.snackbar('Date Expense Error', ErrorUtils.getCleanMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingDateExpenses = false);
      }
    }
  }

  void _changeMonth(int increment) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + increment, 1);
      final now = DateTime.now();
      if (_selectedMonth.month == now.month && _selectedMonth.year == now.year) {
        _selectedDateDetails = now;
      } else {
        _selectedDateDetails = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      }
    });
    _fetchMonthlyExpenses();
    _fetchDateExpenses();
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDateDetails = _selectedDateDetails.add(Duration(days: days));
      if (_selectedDateDetails.month != _selectedMonth.month || _selectedDateDetails.year != _selectedMonth.year) {
        _selectedMonth = DateTime(_selectedDateDetails.year, _selectedDateDetails.month, 1);
        _fetchMonthlyExpenses();
      }
    });
    _fetchDateExpenses();
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
      if (mounted) {
        Get.snackbar('Check-In Verified!', 'Guest successfully checked in to their table!',
            backgroundColor: Colors.green.withAlpha(25), colorText: Colors.green);
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Check-In Failed', 'Booking pass not found or already checked in');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Group date expenses by category
    final Map<String, List<dynamic>> groupedExpenses = {};
    for (final exp in _dateExpensesList) {
      final cat = exp['category']?.toString() ?? 'Other Expenses';
      if (!groupedExpenses.containsKey(cat)) {
        groupedExpenses[cat] = [];
      }
      groupedExpenses[cat]!.add(exp);
    }

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
          await _fetchDateExpenses();
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
                crossAxisCount: AppResponsive.getGridCrossAxisCount(context, phone: 3, tablet: 3, landscape: 6),
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
                        children: [
                          const Expanded(
                            child: Text(
                              'Monthly Expense Overview',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _changeMonth(-1),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM yyyy').format(_selectedMonth),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
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
                        const SizedBox(
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

              // Date-wise Expense Details Section
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Date-wise Expense Details',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _changeDate(-1),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDateDetails,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 30)),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _selectedDateDetails = picked;
                                      if (_selectedDateDetails.month != _selectedMonth.month ||
                                          _selectedDateDetails.year != _selectedMonth.year) {
                                        _selectedMonth = DateTime(_selectedDateDetails.year, _selectedDateDetails.month, 1);
                                        _fetchMonthlyExpenses();
                                      }
                                    });
                                    _fetchDateExpenses();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    DateFormat('dd MMM yyyy').format(_selectedDateDetails),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryDark),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _changeDate(1),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 16),

                      if (_isLoadingDateExpenses)
                        const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
                      else if (_dateExpensesList.isEmpty)
                        const SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 36, color: AppColors.textLight),
                              SizedBox(height: 6),
                              Text('No expenses recorded for this date.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                            ],
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: groupedExpenses.entries.map((entry) {
                            final categoryName = entry.key;
                            final itemsList = entry.value;
                            final double catTotal = (_categoryTotals[categoryName] as num?)?.toDouble() ??
                                itemsList.fold<double>(0.0, (double sum, dynamic x) => sum + ((x['amount'] as num?)?.toDouble() ?? 0.0));

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F7F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE8E3D8)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Category Header
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(categoryName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                                      Text('₹${catTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                                    ],
                                  ),
                                  const Divider(height: 12),

                                  // Expense Item Records
                                  ...itemsList.map((exp) {
                                    final amt = (exp['amount'] as num?)?.toDouble() ?? 0.0;
                                    final itemDetails = exp['itemDetails'] ?? 'Expense Item';
                                    final payMethod = exp['paymentMethod'] ?? 'Cash';
                                    final note = exp['note']?.toString().isNotEmpty == true ? exp['note'] : 'No note added';
                                    final staffName = exp['user']?['name'] ?? exp['createdBy']?['name'] ?? 'Staff Member';

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(itemDetails, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                              ),
                                              Text('₹${amt.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withAlpha(20),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(payMethod, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text('Added By: $staffName', style: const TextStyle(fontSize: 11, color: AppColors.textLight), overflow: TextOverflow.ellipsis),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text('Note: $note', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text('$categoryName Total: ₹${catTotal.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 12),

                      // Overall Daily Total Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.withAlpha(50)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Expenses on ${DateFormat('dd MMM yyyy').format(_selectedDateDetails)}:',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                              '₹${_dailyTotalExpense.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
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
