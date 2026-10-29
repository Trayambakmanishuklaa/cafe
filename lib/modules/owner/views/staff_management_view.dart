import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';

class StaffManagementView extends StatefulWidget {
  const StaffManagementView({super.key});

  @override
  State<StaffManagementView> createState() => _StaffManagementViewState();
}

class _StaffManagementViewState extends State<StaffManagementView> {
  final ApiClient _apiClient = Get.find<ApiClient>();
  List<dynamic> _staffList = [];
  bool _isLoading = true;

  // Form Controllers for Adding Staff
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'STAFF';

  @override
  void initState() {
    super.initState();
    _fetchStaffList();
  }

  Future<void> _fetchStaffList() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get('/admin/staff');
      setState(() {
        _staffList = res.data['data'] ?? [];
      });
    } catch (e) {
      Get.snackbar('Staff Error', ErrorUtils.getCleanMessage(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addStaff() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please fill in all required fields');
      return;
    }

    try {
      await _apiClient.post('/admin/staff', data: {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'role': _selectedRole,
      });

      Get.back(); // close modal
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _phoneController.clear();

      Get.snackbar('Success', 'New staff member added!',
          backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
      _fetchStaffList();
    } catch (e) {
      Get.snackbar('Add Failed', ErrorUtils.getCleanMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Owner: Staff Management'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(icon: Icon(Icons.badge), text: 'Staff Directory'),
              Tab(icon: Icon(Icons.table_chart), text: 'Permission Matrix'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _showAddStaffModal,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildDirectoryTab(),
            _buildPermissionMatrixTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_staffList.isEmpty) {
      return const Center(child: Text('No staff members registered yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _staffList.length,
      itemBuilder: (context, index) {
        final staff = _staffList[index];
        final isOwner = staff['role'] == 'OWNER';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isOwner ? AppColors.primary : AppColors.secondary,
              child: Icon(
                isOwner ? Icons.admin_panel_settings : Icons.badge,
                color: Colors.white,
              ),
            ),
            title: Text(staff['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${staff['email']}\nRole: ${staff['role']}'),
            isThreeLine: true,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isOwner ? AppColors.primary.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isOwner ? 'OWNER' : 'ACTIVE STAFF',
                style: TextStyle(
                  color: isOwner ? AppColors.primary : Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionMatrixTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Staff Role & Permission Matrix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Backend enforced role restrictions for staff members.', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
          const SizedBox(height: 16),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Permission', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Cashier/Staff', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Supervisor', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Owner', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: const [
                  DataRow(cells: [DataCell(Text('View Live Orders')), DataCell(Icon(Icons.check, color: Colors.green)), DataCell(Icon(Icons.check, color: Colors.green)), DataCell(Icon(Icons.check, color: Colors.green))]),
                  DataRow(cells: [DataCell(Text('Update Preparation Status')), DataCell(Icon(Icons.check, color: Colors.green)), DataCell(Icon(Icons.check, color: Colors.green)), DataCell(Icon(Icons.check, color: Colors.green))]),
                  DataRow(cells: [DataCell(Text('Seat Reservation Check-In')), DataCell(Icon(Icons.check, color: Colors.green)), DataCell(Icon(Icons.check, color: Colors.green)), DataCell(Icon(Icons.check, color: Colors.green))]),
                  DataRow(cells: [DataCell(Text('Toggle Product Availability')), DataCell(Icon(Icons.check, color: Colors.green)), DataCell(Icon(Icons.check, color: Colors.green)), DataCell(Icon(Icons.check, color: Colors.green))]),
                  DataRow(cells: [DataCell(Text('Approve Refunds')), DataCell(Icon(Icons.close, color: Colors.red)), DataCell(Icon(Icons.check, color: Colors.green)), DataCell(Icon(Icons.check, color: Colors.green))]),
                  DataRow(cells: [DataCell(Text('View Owner Financial KPIs')), DataCell(Icon(Icons.close, color: Colors.red)), DataCell(Icon(Icons.close, color: Colors.red)), DataCell(Icon(Icons.check, color: Colors.green))]),
                  DataRow(cells: [DataCell(Text('Add / Manage Staff Accounts')), DataCell(Icon(Icons.close, color: Colors.red)), DataCell(Icon(Icons.close, color: Colors.red)), DataCell(Icon(Icons.check, color: Colors.green))]),
                  DataRow(cells: [DataCell(Text('Manual Loyalty Points Edit')), DataCell(Icon(Icons.close, color: Colors.red)), DataCell(Icon(Icons.close, color: Colors.red)), DataCell(Icon(Icons.check, color: Colors.green))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStaffModal() {
    Get.defaultDialog(
      title: '➕ Add Staff Account',
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone (Optional)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: 'Assigned Role'),
              items: const [
                DropdownMenuItem(value: 'STAFF', child: Text('Staff / Barista')),
                DropdownMenuItem(value: 'OWNER', child: Text('Co-Owner / Admin')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
              },
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: _addStaff,
        child: const Text('CREATE STAFF ACCOUNT'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('CANCEL'),
      ),
    );
  }
}
