import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';

class AdminDailySalesTab extends StatefulWidget {
  const AdminDailySalesTab({super.key});

  @override
  State<AdminDailySalesTab> createState() => _AdminDailySalesTabState();
}

class _AdminDailySalesTabState extends State<AdminDailySalesTab> {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Monthly Sales Graph state
  DateTime _selectedMonth = DateTime.now();
  double _monthlyTotalSales = 0.0;
  List<dynamic> _dailySalesGraph = [];
  bool _isLoadingMonthly = false;

  // Date-wise Sales Details state
  DateTime _selectedDateSales = DateTime.now();
  double _dateCombinedSales = 0.0;
  List<dynamic> _dateSalesRecords = [];
  bool _isLoadingDateSales = false;

  @override
  void initState() {
    super.initState();
    _fetchMonthlySales();
    _fetchDateSales();
  }

  Future<void> _fetchMonthlySales() async {
    if (!mounted) return;
    setState(() => _isLoadingMonthly = true);
    try {
      final res = await _apiClient.get('/admin/sales/monthly', queryParameters: {
        'month': _selectedMonth.month,
        'year': _selectedMonth.year,
      });
      final data = res.data['data'] ?? {};
      if (!mounted) return;
      setState(() {
        _monthlyTotalSales = (data['monthlyTotalSales'] as num?)?.toDouble() ?? 0.0;
        _dailySalesGraph = data['dailySalesGraph'] ?? [];
      });
    } catch (e) {
      if (mounted) Get.snackbar('Sales Graph Error', ErrorUtils.getCleanMessage(e));
    } finally {
      if (mounted) setState(() => _isLoadingMonthly = false);
    }
  }

  Future<void> _fetchDateSales() async {
    if (!mounted) return;
    setState(() => _isLoadingDateSales = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDateSales);
      final res = await _apiClient.get('/admin/sales/by-date', queryParameters: {'date': dateStr});
      final data = res.data['data'] ?? {};
      if (!mounted) return;
      setState(() {
        _dateCombinedSales = (data['totalCombinedSales'] as num?)?.toDouble() ?? 0.0;
        _dateSalesRecords = data['records'] ?? [];
      });
    } catch (e) {
      if (mounted) Get.snackbar('Date Sales Error', ErrorUtils.getCleanMessage(e));
    } finally {
      if (mounted) setState(() => _isLoadingDateSales = false);
    }
  }

  void _changeMonth(int increment) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + increment, 1);
      final now = DateTime.now();
      if (_selectedMonth.month == now.month && _selectedMonth.year == now.year) {
        _selectedDateSales = now;
      } else {
        _selectedDateSales = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      }
    });
    _fetchMonthlySales();
    _fetchDateSales();
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDateSales = _selectedDateSales.add(Duration(days: days));
      if (_selectedDateSales.month != _selectedMonth.month || _selectedDateSales.year != _selectedMonth.year) {
        _selectedMonth = DateTime(_selectedDateSales.year, _selectedDateSales.month, 1);
        _fetchMonthlySales();
      }
    });
    _fetchDateSales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Daily Sales Reporting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchMonthlySales();
              _fetchDateSales();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchMonthlySales();
          await _fetchDateSales();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Sales Overview Graph Card
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
                              'Monthly Sales Overview',
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

                      // Sales Bar Graph / Empty State
                      if (_isLoadingMonthly)
                        const SizedBox(height: 140, child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
                      else if (_dailySalesGraph.every((d) => (d['total'] as num? ?? 0) == 0))
                        const SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart, size: 40, color: AppColors.textLight),
                              SizedBox(height: 6),
                              Text('No sales submitted for this month', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: 140,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _dailySalesGraph.map((d) {
                              final dayNum = d['day'];
                              final total = (d['total'] as num?)?.toDouble() ?? 0.0;
                              final maxVal = _dailySalesGraph
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
                                          color: total > 0 ? Colors.green : Colors.grey.shade300,
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

                      // Total Monthly Sales Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Sales This Month:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              '₹${_monthlyTotalSales.toStringAsFixed(2)}',
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

              // Date-wise Sales Details Card
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
                              'Date-wise Sales Details',
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
                                    initialDate: _selectedDateSales,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 7)),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _selectedDateSales = picked;
                                      if (_selectedDateSales.month != _selectedMonth.month ||
                                          _selectedDateSales.year != _selectedMonth.year) {
                                        _selectedMonth = DateTime(_selectedDateSales.year, _selectedDateSales.month, 1);
                                        _fetchMonthlySales();
                                      }
                                    });
                                    _fetchDateSales();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    DateFormat('dd MMM yyyy').format(_selectedDateSales),
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

                      if (_isLoadingDateSales)
                        const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
                      else if (_dateSalesRecords.isEmpty)
                        const SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.point_of_sale_outlined, size: 36, color: AppColors.textLight),
                              SizedBox(height: 6),
                              Text('No daily sales submitted for this date.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: [
                            ..._dateSalesRecords.map((rec) {
                              final amt = (rec['totalSales'] as num?)?.toDouble() ?? 0.0;
                              final staffName = rec['staff']?['name'] ?? 'Staff Member';
                              final note = rec['note']?.toString().isNotEmpty == true ? rec['note'] : 'No note';
                              final submitTime = DateFormat('hh:mm a').format(DateTime.parse(rec['updatedAt'] ?? rec['createdAt']));

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F7F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE8E3D8)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: Colors.green.withAlpha(20), shape: BoxShape.circle),
                                      child: const Icon(Icons.person, color: Colors.green, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(staffName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text('Submitted at $submitTime • Note: $note', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                                        ],
                                      ),
                                    ),
                                    Text('₹${amt.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 12),

                            // Daily Combined Total Banner
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
                                    'Total Sales on ${DateFormat('dd MMM yyyy').format(_selectedDateSales)}:',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  Text(
                                    '₹${_dateCombinedSales.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                                  ),
                                ],
                              ),
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
}

class MathUtils {
  static double clampDouble(double val, double min, double max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
  }
}
