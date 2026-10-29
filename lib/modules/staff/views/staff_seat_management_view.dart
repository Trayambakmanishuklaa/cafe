import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/core/constants/api_constants.dart';
import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';

class StaffSeatManagementView extends StatefulWidget {
  const StaffSeatManagementView({super.key});

  @override
  State<StaffSeatManagementView> createState() => _StaffSeatManagementViewState();
}

class _StaffSeatManagementViewState extends State<StaffSeatManagementView> {
  final ApiClient _apiClient = Get.find<ApiClient>();
  List<dynamic> _seats = [];
  bool _isLoading = true;

  // Add Seat Controllers
  final _tableNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController(text: '4');
  final _descController = TextEditingController();
  String _selectedManualStatus = 'FREE';

  @override
  void initState() {
    super.initState();
    _fetchSeats();
  }

  Future<void> _fetchSeats() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get(ApiConstants.tables);
      setState(() {
        _seats = res.data['data'] ?? [];
      });
    } catch (e) {
      Get.snackbar('Error', ErrorUtils.getCleanMessage(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSeat() async {
    if (_tableNumberController.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter a seat/table number');
      return;
    }

    try {
      await _apiClient.post(ApiConstants.staffSeats, data: {
        'tableNumber': int.parse(_tableNumberController.text.trim()),
        'name': _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        'capacity': int.tryParse(_capacityController.text.trim()) ?? 4,
        'description': _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        'manualStatus': _selectedManualStatus,
      });

      Get.back(); // close modal
      _tableNumberController.clear();
      _nameController.clear();
      _capacityController.text = '4';
      _descController.clear();

      Get.snackbar('Success', 'New seat added successfully!',
          backgroundColor: Colors.green.withAlpha(25), colorText: Colors.green);
      _fetchSeats();
    } catch (e) {
      Get.snackbar('Add Seat Failed', ErrorUtils.getCleanMessage(e));
    }
  }

  Future<void> _updateSeatStatus(String seatId, String newStatus) async {
    try {
      await _apiClient.patch('${ApiConstants.tables}/staff/$seatId/status', data: {
        'manualStatus': newStatus,
      });
      Get.snackbar('Status Updated', 'Seat marked as $newStatus',
          backgroundColor: Colors.green.withAlpha(25), colorText: Colors.green);
      _fetchSeats();
    } catch (e) {
      Get.snackbar('Update Failed', ErrorUtils.getCleanMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff: Manage Seats & Tables'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSeats,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSeatModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('ADD SEAT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _seats.isEmpty
              ? const Center(child: Text('No seats found. Tap ADD SEAT to create one.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _seats.length,
                  itemBuilder: (context, index) {
                    final seat = _seats[index];
                    final isFree = seat['manualStatus'] == 'FREE';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isFree ? Colors.green.withAlpha(25) : Colors.red.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.table_restaurant,
                                color: isFree ? Colors.green : Colors.red,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Table #${seat['tableNumber']} (${seat['name'] ?? ""})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text('Capacity: ${seat['capacity']} Guests • Zone: ${seat['zone']}'),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isFree ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      seat['manualStatus'],
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (val) => _updateSeatStatus(seat['id'], val),
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'FREE', child: Text('Mark as Free 🟢')),
                                const PopupMenuItem(value: 'BOOKED', child: Text('Mark as Booked 🔴')),
                                const PopupMenuItem(value: 'MAINTENANCE', child: Text('Mark Maintenance 🟡')),
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

  void _showAddSeatModal() {
    Get.defaultDialog(
      title: '➕ Add New Seat / Table',
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _tableNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Table Number (e.g. 11)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Table Name / Section (Optional)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Seating Capacity (e.g. 4)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description (Optional)'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedManualStatus,
              decoration: const InputDecoration(labelText: 'Initial Status'),
              items: const [
                DropdownMenuItem(value: 'FREE', child: Text('Free 🟢')),
                DropdownMenuItem(value: 'BOOKED', child: Text('Booked 🔴')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedManualStatus = val);
              },
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: _addSeat,
        child: const Text('SAVE SEAT'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('CANCEL'),
      ),
    );
  }
}
