import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/table_model.dart';
import '../controllers/booking_controller.dart';

class BookingView extends StatelessWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Reserve a Seat'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(icon: Icon(Icons.event_seat), text: 'New Reservation'),
              Tab(icon: Icon(Icons.confirmation_number), text: 'My Bookings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNewReservationTab(context, controller),
            _buildMyBookingsTab(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildNewReservationTab(BuildContext context, BookingController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & Time Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Date & Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                          label: Obx(() => Text(DateFormat('EEE, dd MMM yyyy').format(controller.selectedDate.value))),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: controller.selectedDate.value,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 14)),
                            );
                            if (picked != null) {
                              controller.selectedDate.value = picked;
                              controller.fetchAvailability();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Obx(
                        () => DropdownButton<int>(
                          value: controller.guestCount.value,
                          items: [1, 2, 4, 6, 8]
                              .map((g) => DropdownMenuItem(value: g, child: Text('$g Guests')))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.guestCount.value = val;
                              controller.fetchAvailability();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Time Slots horizontal list
                  const Text('Time Slot', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(
                      () => Row(
                        children: controller.availableTimeSlots.map((slot) {
                          final isSelected = controller.selectedTimeSlot.value == slot;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(slot),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                              onSelected: (_) {
                                controller.selectedTimeSlot.value = slot;
                                controller.fetchAvailability();
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Seating Map Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Available', Colors.green),
              _buildLegendItem('Selected', AppColors.primary),
              _buildLegendItem('Reserved', Colors.grey),
            ],
          ),
          const SizedBox(height: 16),

          // Interactive Seat Layout Grid
          const Text('Interactive Cafe Floor Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.isLoading.value) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: controller.tables.length,
              itemBuilder: (context, index) {
                final table = controller.tables[index];
                return _buildTableCard(table, controller);
              },
            );
          }),
          const SizedBox(height: 24),

          // Confirm Reservation Button
          Obx(
            () => ElevatedButton(
              onPressed: controller.selectedTable.value == null || controller.isConfirming.value
                  ? null
                  : () => _showPaymentSheet(context, controller),
              child: controller.isConfirming.value
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(controller.selectedTable.value != null
                      ? 'PAY ₹50 DEPOSIT & RESERVE TABLE #${controller.selectedTable.value!.tableNumber}'
                      : 'TAP A TABLE TO RESERVE'),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, BookingController controller) {
    String selectedPaymentMethod = 'UPI';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Seat Deposit Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                  ],
                ),
                const Divider(),
                Text('Table #${controller.selectedTable.value?.tableNumber} • ${controller.guestCount.value} Guests'),
                const Text('Advance Deposit Fee: ₹50.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                const SizedBox(height: 16),
                const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  value: 'UPI',
                  groupValue: selectedPaymentMethod,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedPaymentMethod = val);
                  },
                  title: const Text('UPI (Google Pay, PhonePe, Paytm)', style: TextStyle(fontSize: 14)),
                  secondary: const Icon(Icons.qr_code_2, color: AppColors.primary),
                ),
                RadioListTile<String>(
                  value: 'CARD',
                  groupValue: selectedPaymentMethod,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedPaymentMethod = val);
                  },
                  title: const Text('Credit / Debit Card', style: TextStyle(fontSize: 14)),
                  secondary: const Icon(Icons.credit_card, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Get.back(); // close sheet
                    final booking = await controller.confirmBooking(paymentMethod: selectedPaymentMethod);
                    if (booking != null) {
                      _showQRPassModal(booking);
                    }
                  },
                  child: const Text('PAY ₹50 & CONFIRM RESERVATION'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableCard(TableModel table, BookingController controller) {
    return Obx(() {
      final isSelected = controller.selectedTable.value?.id == table.id;
      Color cardColor = Colors.white;
      Color iconColor = Colors.green;
      String statusText = 'Available';

      if (!table.isAvailable) {
        cardColor = Colors.grey.shade200;
        iconColor = Colors.grey;
        statusText = 'Booked';
      } else if (isSelected) {
        cardColor = AppColors.secondaryLight;
        iconColor = AppColors.primary;
        statusText = 'Selected';
      }

      return Card(
        color: cardColor,
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
        ),
        child: InkWell(
          onTap: () => controller.selectTable(table),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.table_restaurant, color: iconColor, size: 32),
                const SizedBox(height: 4),
                Text(
                  'Table #${table.tableNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '${table.capacity} Seats • $statusText',
                  style: TextStyle(fontSize: 10, color: iconColor),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMyBookingsTab(BookingController controller) {
    return Obx(() {
      if (controller.myBookings.isEmpty) {
        return const Center(child: Text('No active seat reservations found.'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.myBookings.length,
        itemBuilder: (context, index) {
          final booking = controller.myBookings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.qr_code_2, size: 40, color: AppColors.primary),
              title: Text('Booking #${booking.bookingCode}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Table #${booking.table?.tableNumber ?? "N/A"} • ${DateFormat('dd MMM').format(booking.bookingDate)} at ${booking.startTime}\nStatus: ${booking.status}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showQRPassModal(booking),
            ),
          );
        },
      );
    });
  }

  void _showQRPassModal(BookingModel booking) {
    Get.defaultDialog(
      title: '🎟️ Digital Booking Pass',
      content: Column(
        children: [
          Text(
            'Booking Code: ${booking.bookingCode}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            width: 180,
            child: QrImageView(
              data: booking.qrCode,
              version: QrVersions.auto,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Table #${booking.table?.tableNumber ?? "N/A"} • ${booking.guestCount} Guests\nShow this QR code to cafe staff upon arrival.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        child: const Text('CLOSE PASS'),
      ),
    );
  }
}
