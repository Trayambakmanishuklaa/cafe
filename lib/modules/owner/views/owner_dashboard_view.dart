import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> {
  final ApiClient _apiClient = Get.find<ApiClient>();
  Map<String, dynamic>? _overview;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOverview();
  }

  Future<void> _fetchOverview() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await _apiClient.get('/admin/overview');
      setState(() {
        _overview = res.data['data'];
      });
    } catch (e) {
      Get.snackbar('Admin Error', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Owner Intelligence KPIs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOverview,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business KPI Metric Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _buildKpiCard(
                        'Today\'s Revenue',
                        '₹${_overview?['todaySales'] ?? 0}',
                        Icons.payments,
                        Colors.green,
                      ),
                      _buildKpiCard(
                        'Completed Orders',
                        '${_overview?['completedOrdersCount'] ?? 0}',
                        Icons.check_circle_outline,
                        AppColors.primary,
                      ),
                      _buildKpiCard(
                        'Average Order Value',
                        '₹${_overview?['avgOrderValue'] ?? 0}',
                        Icons.analytics_outlined,
                        Colors.blue,
                      ),
                      _buildKpiCard(
                        'Seat Occupancy',
                        '${_overview?['seatUtilization'] ?? 0}%',
                        Icons.event_seat,
                        Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Category Sales Revenue Distribution
                  const Text('Category Revenue Split', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildRevenueBar('Tea Corner', _overview?['categoryRevenueMap']?['tea'] ?? 0, Colors.amber),
                          const SizedBox(height: 10),
                          _buildRevenueBar('Coffee Corner', _overview?['categoryRevenueMap']?['coffee'] ?? 0, AppColors.primary),
                          const SizedBox(height: 10),
                          _buildRevenueBar('Bun & Bakery', _overview?['categoryRevenueMap']?['bun-bakery'] ?? 0, Colors.brown),
                          const SizedBox(height: 10),
                          _buildRevenueBar('Burger Station', _overview?['categoryRevenueMap']?['burger'] ?? 0, Colors.deepOrange),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.trending_up, color: color, size: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueBar(String category, dynamic revenue, Color color) {
    final double amount = (revenue as num).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (amount / 1000.0).clamp(0.05, 1.0),
          backgroundColor: Colors.grey.shade200,
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
