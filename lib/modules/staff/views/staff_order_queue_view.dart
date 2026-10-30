import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

class StaffOrderQueueView extends StatefulWidget {
  const StaffOrderQueueView({super.key});

  @override
  State<StaffOrderQueueView> createState() => _StaffOrderQueueViewState();
}

class _StaffOrderQueueViewState extends State<StaffOrderQueueView> {
  final OrderRepository _orderRepository = Get.put(OrderRepository(Get.find()));
  final ApiClient _apiClient = Get.find<ApiClient>();

  List<OrderModel> _orders = [];
  bool _isLoading = false;

  // Expense Modal Controllers
  final _itemDetailsController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Raw Materials';
  String _selectedPaymentMethod = 'UPI';
  bool _isSavingExpense = false;

  final List<Map<String, dynamic>> _expenseCategories = [
    {'title': 'Raw Materials', 'icon': Icons.shopping_bag_outlined, 'color': Colors.amber},
    {'title': 'Ingredients', 'icon': Icons.restaurant_outlined, 'color': Colors.orange},
    {'title': 'Staff & Labour', 'icon': Icons.people_outlined, 'color': Colors.blue},
    {'title': 'Utilities', 'icon': Icons.bolt_outlined, 'color': Colors.purple},
    {'title': 'Rent & Maintenance', 'icon': Icons.home_work_outlined, 'color': Colors.teal},
    {'title': 'Equipment', 'icon': Icons.build_outlined, 'color': Colors.indigo},
    {'title': 'Marketing', 'icon': Icons.campaign_outlined, 'color': Colors.pink},
    {'title': 'Other Expenses', 'icon': Icons.receipt_long_outlined, 'color': Colors.brown},
  ];

  final List<String> _paymentMethods = ['Cash', 'UPI', 'Card', 'Bank Transfer', 'Other'];

  @override
  void initState() {
    super.initState();
    _fetchQueue();
  }

  Future<void> _fetchQueue() async {
    setState(() => _isLoading = true);
    try {
      final list = await _orderRepository.getStaffQueue();
      setState(() {
        _orders = list;
      });
    } catch (e) {
      Get.snackbar('Queue Error', ErrorUtils.getCleanMessage(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      await _orderRepository.updateStatus(orderId, newStatus);
      Get.snackbar('Status Updated', 'Order updated to $newStatus',
          backgroundColor: Colors.green.withAlpha(25), colorText: Colors.green);
      _fetchQueue();
    } catch (e) {
      Get.snackbar('Update Failed', ErrorUtils.getCleanMessage(e));
    }
  }

  Future<void> _saveExpense() async {
    if (_itemDetailsController.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter item details');
      return;
    }

    final amt = double.tryParse(_amountController.text.trim());
    if (amt == null || amt <= 0) {
      Get.snackbar('Validation Error', 'Amount must be greater than zero');
      return;
    }

    setState(() => _isSavingExpense = true);

    try {
      await _apiClient.post('/expenses', data: {
        'category': _selectedCategory,
        'itemDetails': _itemDetailsController.text.trim(),
        'amount': amt,
        'expenseDate': _selectedDate.toIso8601String(),
        'paymentMethod': _selectedPaymentMethod,
        'note': _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      });

      Get.back(); // Close modal
      _itemDetailsController.clear();
      _amountController.clear();
      _noteController.clear();
      _selectedDate = DateTime.now();

      Get.snackbar('Expense Saved!', 'Daily expense recorded successfully',
          backgroundColor: Colors.green.withAlpha(25), colorText: Colors.green);
    } catch (e) {
      Get.snackbar('Save Failed', ErrorUtils.getCleanMessage(e));
    } finally {
      setState(() => _isSavingExpense = false);
    }
  }

  void _showAddExpenseModal(String categoryTitle) {
    _selectedCategory = categoryTitle;
    _itemDetailsController.clear();
    _amountController.clear();
    _noteController.clear();
    _selectedDate = DateTime.now();

    Get.defaultDialog(
      title: '💸 Record Daily Expense',
      content: StatefulBuilder(
        builder: (context, setModalState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _expenseCategories
                      .map((c) => DropdownMenuItem<String>(value: c['title'] as String, child: Text(c['title'] as String)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 10),

                // Item Details
                TextField(
                  controller: _itemDetailsController,
                  decoration: const InputDecoration(labelText: 'Item Details (e.g. Milk Purchase, Wages)'),
                ),
                const SizedBox(height: 10),

                // Amount
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (₹)'),
                ),
                const SizedBox(height: 10),

                // Date Picker Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('Change Date'),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setModalState(() => _selectedDate = picked);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Payment Method
                DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                  items: _paymentMethods
                      .map((p) => DropdownMenuItem<String>(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => _selectedPaymentMethod = val);
                  },
                ),
                const SizedBox(height: 10),

                // Note
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Note (Optional)'),
                ),
              ],
            ),
          );
        },
      ),
      confirm: ElevatedButton(
        onPressed: _isSavingExpense ? null : _saveExpense,
        child: _isSavingExpense
            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('SAVE EXPENSE'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('CANCEL'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff Kitchen Queue & Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchQueue,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchQueue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kitchen Order Queue Section
              const Text('Active Orders Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
              const SizedBox(height: 10),
              _isLoading
                  ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
                  : _orders.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text('No active orders in the kitchen queue.')),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '#${order.orderNumber}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        _buildStatusBadge(order.status),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Type: ${order.orderType} | Items: ${order.items.length}'),
                                    const Divider(height: 16),
                                    ...order.items.map((i) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('${i.quantity}x ${i.productName}'),
                                              Text('₹${i.subtotal.toStringAsFixed(0)}'),
                                            ],
                                          ),
                                        )),
                                    const Divider(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (order.status == 'PENDING')
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                            onPressed: () => _updateStatus(order.id, 'PREPARING'),
                                            child: const Text('START PREPARING'),
                                          ),
                                        if (order.status == 'PREPARING')
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                            onPressed: () => _updateStatus(order.id, 'READY'),
                                            child: const Text('MARK READY'),
                                          ),
                                        if (order.status == 'READY')
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                            onPressed: () => _updateStatus(order.id, 'COMPLETED'),
                                            child: const Text('COMPLETE ORDER'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              const SizedBox(height: 24),

              // Daily Expenses Section
              const Text('Daily Expenses (8 Categories)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
              const SizedBox(height: 6),
              const Text('Tap a category tile below to record a new cafe expense.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _expenseCategories.length,
                itemBuilder: (context, index) {
                  final cat = _expenseCategories[index];
                  final color = cat['color'] as Color;
                  return Card(
                    elevation: 2,
                    child: InkWell(
                      onTap: () => _showAddExpenseModal(cat['title'] as String),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
                              child: Icon(cat['icon'] as IconData, color: color, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cat['title'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.grey;
    if (status == 'PENDING') bg = Colors.amber;
    if (status == 'PREPARING') bg = Colors.blue;
    if (status == 'READY') bg = Colors.orange;
    if (status == 'COMPLETED') bg = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
