import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';

class CustomerManagementView extends StatefulWidget {
  const CustomerManagementView({super.key});

  @override
  State<CustomerManagementView> createState() => _CustomerManagementViewState();
}

class _CustomerManagementViewState extends State<CustomerManagementView> {
  final ApiClient _apiClient = Get.find<ApiClient>();
  List<dynamic> _customers = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String _selectedTierFilter = '';

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() => _isLoading = true);
    try {
      final query = <String, dynamic>{};
      if (_searchController.text.trim().isNotEmpty) {
        query['search'] = _searchController.text.trim();
      }
      if (_selectedTierFilter.isNotEmpty) {
        query['tier'] = _selectedTierFilter;
      }

      final res = await _apiClient.get('/admin/customers', queryParameters: query);
      setState(() {
        _customers = res.data['data'] ?? [];
      });
    } catch (e) {
      Get.snackbar('Customer Error', ErrorUtils.getCleanMessage(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Owner: Customer CRM Management'),
      ),
      body: Column(
        children: [
          // Search & Tier Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _fetchCustomers(),
                  decoration: const InputDecoration(
                    hintText: 'Search customers by name, email or phone...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTierFilterChip('All Tiers', ''),
                      _buildTierFilterChip('Bronze', 'BRONZE'),
                      _buildTierFilterChip('Silver', 'SILVER'),
                      _buildTierFilterChip('Gold', 'GOLD'),
                      _buildTierFilterChip('VIP', 'VIP'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Customer Directory List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _customers.isEmpty
                    ? const Center(child: Text('No customers found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _customers.length,
                        itemBuilder: (context, index) {
                          final customer = _customers[index];
                          final points = customer['loyaltyAccount']?['pointsBalance'] ?? 0;
                          final tier = customer['loyaltyAccount']?['tier'] ?? 'BRONZE';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(customer['name'] ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${customer['email']}\nOrders: ${customer['_count']?['orders'] ?? 0} | Points: $points PTS'),
                              isThreeLine: true,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tier,
                                  style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              onTap: () => _openCustomerDetailsModal(customer['id']),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierFilterChip(String label, String tierCode) {
    final isSelected = _selectedTierFilter == tierCode;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 12),
        onSelected: (_) {
          setState(() => _selectedTierFilter = tierCode);
          _fetchCustomers();
        },
      ),
    );
  }

  void _openCustomerDetailsModal(String customerId) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      barrierDismissible: false,
    );

    try {
      final res = await _apiClient.get('/admin/customers/$customerId');
      Get.back(); // close loading dialog

      final details = res.data['data'];
      _showCustomerDetailsSheet(details);
    } catch (e) {
      Get.back();
      Get.snackbar('Details Error', ErrorUtils.getCleanMessage(e));
    }
  }

  void _showCustomerDetailsSheet(Map<String, dynamic> details) {
    final _adjustPointsController = TextEditingController();
    final _adjustReasonController = TextEditingController();

    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DefaultTabController(
          length: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Banner Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(details['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Text(details['email'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
              const Divider(height: 20),

              // Tab Bar
              const TabBar(
                labelColor: AppColors.primary,
                indicatorColor: AppColors.primary,
                isScrollable: true,
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Orders History'),
                  Tab(text: 'Bookings'),
                  Tab(text: 'Loyalty Points Adjust'),
                ],
              ),

              // Tab Bar View Content
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: Overview
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Account Role', details['role'] ?? 'CUSTOMER'),
                          _buildDetailRow('Phone Number', details['phone'] ?? 'Not provided'),
                          _buildDetailRow('Member Since', DateFormat('dd MMM yyyy').format(DateTime.parse(details['createdAt']))),
                          _buildDetailRow('Total Completed Orders', '${(details['orders'] as List?)?.length ?? 0}'),
                          _buildDetailRow('Total Bookings', '${(details['bookings'] as List?)?.length ?? 0}'),
                          _buildDetailRow('Loyalty Balance', '${details['loyaltyAccount']?['pointsBalance'] ?? 0} PTS'),
                          _buildDetailRow('Membership Tier', details['loyaltyAccount']?['tier'] ?? 'BRONZE'),
                        ],
                      ),
                    ),

                    // Tab 2: Orders History
                    ListView.builder(
                      itemCount: (details['orders'] as List?)?.length ?? 0,
                      itemBuilder: (context, idx) {
                        final order = details['orders'][idx];
                        return ListTile(
                          dense: true,
                          title: Text('Order #${order['orderNumber']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${order['orderType']} • ₹${order['totalAmount']}'),
                          trailing: Text(order['status'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                        );
                      },
                    ),

                    // Tab 3: Bookings
                    ListView.builder(
                      itemCount: (details['bookings'] as List?)?.length ?? 0,
                      itemBuilder: (context, idx) {
                        final b = details['bookings'][idx];
                        return ListTile(
                          dense: true,
                          title: Text('Booking #${b['bookingCode']}'),
                          subtitle: Text('Table #${b['table']?['tableNumber'] ?? "N/A"} • ${b['bookingDate'].toString().substring(0, 10)}'),
                          trailing: Text(b['status']),
                        );
                      },
                    ),

                    // Tab 4: Loyalty Points Adjustment
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _adjustPointsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Points to Add/Deduct (e.g. +50 or -20)'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _adjustReasonController,
                            decoration: const InputDecoration(labelText: 'Reason for Adjustment'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              final p = int.tryParse(_adjustPointsController.text.trim());
                              if (p == null) {
                                Get.snackbar('Invalid Input', 'Please enter a valid number of points');
                                return;
                              }
                              try {
                                await _apiClient.post('/admin/customers/${details['id']}/adjust-points', data: {
                                  'points': p,
                                  'description': _adjustReasonController.text.trim(),
                                });
                                Get.back();
                                Get.snackbar('Adjusted', 'Loyalty points updated successfully!', backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
                                _fetchCustomers();
                              } catch (e) {
                                Get.snackbar('Adjustment Error', ErrorUtils.getCleanMessage(e));
                              }
                            },
                            child: const Text('SUBMIT AUDIT ADJUSTMENT'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textLight)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
