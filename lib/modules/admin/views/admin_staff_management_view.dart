import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';

class AdminStaffManagementView extends StatefulWidget {
  const AdminStaffManagementView({super.key});

  @override
  State<AdminStaffManagementView> createState() => _AdminStaffManagementViewState();
}

class _AdminStaffManagementViewState extends State<AdminStaffManagementView> {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final _searchController = TextEditingController();

  List<dynamic> _staffList = [];
  bool _isLoading = true;

  // Add Staff Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSavingStaff = false;

  @override
  void initState() {
    super.initState();
    _fetchStaffList();
  }

  Future<void> _fetchStaffList([String? search]) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get('/admin/staff', queryParameters: search != null && search.isNotEmpty ? {'search': search} : null);
      if (!mounted) return;
      setState(() {
        _staffList = res.data['data'] ?? [];
      });
    } catch (e) {
      if (mounted) Get.snackbar('Error', ErrorUtils.getCleanMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createStaffAccount() async {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Full Name, Mobile Number, and Password are required');
      return;
    }

    setState(() => _isSavingStaff = true);

    try {
      await _apiClient.post('/admin/staff', data: {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      });

      Get.back(); // Close modal
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _passwordController.clear();

      if (mounted) {
        Get.snackbar('Staff Created!', 'New staff member account created successfully',
            backgroundColor: Colors.green.withAlpha(25), colorText: Colors.green);
      }
      _fetchStaffList();
    } catch (e) {
      if (mounted) Get.snackbar('Creation Failed', ErrorUtils.getCleanMessage(e));
    } finally {
      if (mounted) setState(() => _isSavingStaff = false);
    }
  }

  void _showAddStaffModal() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _passwordController.clear();

    Get.defaultDialog(
      title: '👤 Create Staff Account',
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email Address (Optional)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Temporary Password'),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Assigned Role: Staff', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: _isSavingStaff ? null : _createStaffAccount,
        child: _isSavingStaff
            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('CREATE STAFF ACCOUNT'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('CANCEL'),
      ),
    );
  }

  void _showResetPasswordDialog(String staffId, String staffName) {
    final resetPasswordController = TextEditingController();

    Get.defaultDialog(
      title: '🔑 Reset Password',
      content: Column(
        children: [
          Text('Enter new password for $staffName:'),
          const SizedBox(height: 10),
          TextField(
            controller: resetPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password (min 6 chars)'),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          final newPass = resetPasswordController.text.trim();
          if (newPass.length < 6) {
            Get.snackbar('Error', 'Password must be at least 6 characters');
            return;
          }
          try {
            await _apiClient.patch('/admin/staff/$staffId/reset-password', data: {'newPassword': newPass});
            Get.back();
            Get.snackbar('Password Reset', 'Password updated for $staffName',
                backgroundColor: Colors.green.withAlpha(25), colorText: Colors.green);
          } catch (e) {
            Get.snackbar('Reset Failed', ErrorUtils.getCleanMessage(e));
          }
        },
        child: const Text('RESET PASSWORD'),
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
        title: const Text('Admin: Staff Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStaffList,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStaffModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('ADD NEW STAFF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search staff by name or mobile number...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _fetchStaffList();
                  },
                ),
              ),
              onChanged: (val) => _fetchStaffList(val),
            ),
          ),

          // Staff List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: _fetchStaffList,
                    child: _staffList.isEmpty
                        ? const Center(child: Text('No staff accounts found.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _staffList.length,
                            itemBuilder: (context, index) {
                              final staff = _staffList[index];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), shape: BoxShape.circle),
                                    child: const Icon(Icons.badge, color: AppColors.primary, size: 24),
                                  ),
                                  title: Text(staff['name'] ?? 'Staff Member', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Mobile: ${staff['phone'] ?? "N/A"}\nEmail: ${staff['email']}'),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (val) {
                                      if (val == 'reset') {
                                        _showResetPasswordDialog(staff['id'], staff['name'] ?? 'Staff');
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'reset', child: Text('Reset Password 🔑')),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
