import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';

class StaffDailySalesView extends StatefulWidget {
  const StaffDailySalesView({super.key});

  @override
  State<StaffDailySalesView> createState() => _StaffDailySalesViewState();
}

class _StaffDailySalesViewState extends State<StaffDailySalesView> {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedSalesDate = DateTime.now();
  List<dynamic> _mySalesHistory = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchMySalesHistory();
  }

  Future<void> _fetchMySalesHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get('/sales/daily/my-records');
      if (!mounted) return;
      setState(() {
        _mySalesHistory = res.data['data'] ?? [];
      });
    } catch (e) {
      if (mounted) Get.snackbar('Error', ErrorUtils.getCleanMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitDailySales() async {
    final amtText = _amountController.text.trim();
    if (amtText.isEmpty) {
      Get.snackbar('Validation Error', "Please enter today's total sales amount");
      return;
    }

    final salesAmt = double.tryParse(amtText);
    if (salesAmt == null || salesAmt < 0) {
      Get.snackbar('Validation Error', 'Sales amount must be zero or greater');
      return;
    }

    // Check if entry already exists for selected date
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedSalesDate);
    final existingIndex = _mySalesHistory.indexWhere((s) {
      final sDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(s['salesDate']));
      return sDate == formattedDate;
    });

    if (existingIndex != -1) {
      // Prompt confirmation before updating
      Get.defaultDialog(
        title: '⚠️ Confirm Update',
        middleText: 'You already submitted sales for $formattedDate. Do you want to update it to ₹${salesAmt.toStringAsFixed(2)}?',
        confirm: ElevatedButton(
          onPressed: () {
            Get.back(); // close dialog
            _executeSaveSales(salesAmt);
          },
          child: const Text('UPDATE SALES'),
        ),
        cancel: TextButton(
          onPressed: () => Get.back(),
          child: const Text('CANCEL'),
        ),
      );
    } else {
      _executeSaveSales(salesAmt);
    }
  }

  Future<void> _executeSaveSales(double salesAmt) async {
    setState(() => _isSaving = true);
    try {
      await _apiClient.post('/sales/daily', data: {
        'salesDate': _selectedSalesDate.toIso8601String(),
        'totalSales': salesAmt,
        'note': _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      });

      _amountController.clear();
      _noteController.clear();
      _selectedSalesDate = DateTime.now();

      if (mounted) {
        Get.snackbar('Sales Submitted!', 'Daily sales record saved successfully',
            backgroundColor: Colors.green.withAlpha(25), colorText: Colors.green);
      }
      _fetchMySalesHistory();
    } catch (e) {
      if (mounted) Get.snackbar('Submission Error', ErrorUtils.getCleanMessage(e));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff Daily Sales Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMySalesHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _fetchMySalesHistory,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Sales Form Card
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.point_of_sale, color: AppColors.primary, size: 26),
                                SizedBox(width: 8),
                                Text('Record Shift Sales', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text("Enter today's total sales amount before completing shift.", style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                            const Divider(height: 20),

                            // Date Selector
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Sales Date: ${DateFormat('dd MMM yyyy').format(_selectedSalesDate)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                TextButton.icon(
                                  icon: const Icon(Icons.calendar_today, size: 16),
                                  label: const Text('Change Date'),
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedSalesDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now().add(const Duration(days: 7)),
                                    );
                                    if (picked != null) {
                                      setState(() => _selectedSalesDate = picked);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Amount Field
                            TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Today's Total Sales Amount (₹)",
                                prefixIcon: Icon(Icons.currency_rupee, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Note Field
                            TextField(
                              controller: _noteController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Shift Notes (Optional)',
                                prefixIcon: Icon(Icons.notes, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Submit Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                              onPressed: _isSaving ? null : _submitDailySales,
                              child: _isSaving
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('SUBMIT DAILY SALES'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // My Daily Sales History
                    const Text('My Daily Sales History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                    const SizedBox(height: 10),

                    if (_mySalesHistory.isEmpty)
                      const SizedBox(
                        height: 120,
                        child: Center(child: Text('No daily sales submitted yet.')),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _mySalesHistory.length,
                        itemBuilder: (context, index) {
                          final item = _mySalesHistory[index];
                          final amt = (item['totalSales'] as num?)?.toDouble() ?? 0.0;
                          final dateStr = DateFormat('dd MMM yyyy').format(DateTime.parse(item['salesDate']));

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.green.withAlpha(20), shape: BoxShape.circle),
                                child: const Icon(Icons.attach_money, color: Colors.green, size: 24),
                              ),
                              title: Text('Date: $dateStr', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(item['note']?.toString().isNotEmpty == true ? 'Note: ${item['note']}' : 'No note'),
                              trailing: Text('₹${amt.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
