import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  final ApiClient _apiClient = Get.find<ApiClient>();
  Map<String, dynamic>? _overviewData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOverview();
  }

  Future<void> _fetchOverview() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get('/admin/dashboard/overview');
      if (!mounted) return;
      setState(() {
        _overviewData = res.data['data'];
      });
    } catch (e) {
      if (mounted) Get.snackbar('Overview Error', ErrorUtils.getCleanMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSales = (_overviewData?['totalSales'] as num?)?.toDouble() ?? 0.0;
    final totalExpenses = (_overviewData?['totalExpenses'] as num?)?.toDouble() ?? 0.0;
    final netDifference = (_overviewData?['netOperatingDifference'] as num?)?.toDouble() ?? 0.0;
    final totalOrders = (_overviewData?['totalOrders'] as num?)?.toInt() ?? 0;
    final totalStaff = (_overviewData?['totalStaff'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Business Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOverview,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _fetchOverview,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppResponsive.getScreenPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Net Operating Difference Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: netDifference >= 0
                              ? [const Color(0xFF1E392A), const Color(0xFF2C4C38)]
                              : [const Color(0xFF8B0000), const Color(0xFFB22222)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Net Operating Difference (Sales - Expenses)',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${netDifference.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Sales: ₹${totalSales.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              Text('Total Expenses: ₹${totalExpenses.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Metric Cards Grid
                    const Text('Business Performance Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: AppResponsive.getGridCrossAxisCount(context, phone: 2, tablet: 4, landscape: 4),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _buildMetricCard('Total Sales', '₹${totalSales.toStringAsFixed(0)}', Icons.payments, Colors.green),
                        _buildMetricCard('Total Expenses', '₹${totalExpenses.toStringAsFixed(0)}', Icons.money_off, Colors.red),
                        _buildMetricCard('Total Orders', '$totalOrders', Icons.receipt_long, Colors.blue),
                        _buildMetricCard('Active Staff', '$totalStaff Members', Icons.badge, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 6),
                Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
