import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchQueue();
  }

  Future<void> _fetchQueue() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final list = await _orderRepository.getStaffQueue();
      setState(() {
        _orders = list;
      });
    } catch (e) {
      Get.snackbar('Queue Error', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      await _orderRepository.updateStatus(orderId, newStatus);
      Get.snackbar('Status Updated', 'Order updated to $newStatus',
          backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
      _fetchQueue();
    } catch (e) {
      Get.snackbar('Update Failed', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff Kitchen Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchQueue,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _orders.isEmpty
              ? const Center(child: Text('No active orders in the queue.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
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
