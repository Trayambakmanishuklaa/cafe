import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/booking_model.dart';
import '../../../data/models/table_model.dart';
import '../../../data/repositories/booking_repository.dart';

class BookingController extends GetxController {
  final BookingRepository _bookingRepository = Get.put(BookingRepository(Get.find()));

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedTimeSlot = '14:00'.obs;
  final RxInt guestCount = 2.obs;

  final RxList<TableModel> tables = <TableModel>[].obs;
  final Rxn<TableModel> selectedTable = Rxn<TableModel>();

  final RxBool isLoading = false.obs;
  final RxBool isConfirming = false.obs;
  final RxList<BookingModel> myBookings = <BookingModel>[].obs;

  final List<String> availableTimeSlots = [
    '10:00', '11:00', '12:00', '13:00', '14:00', '15:00',
    '16:00', '17:00', '18:00', '19:00', '20:00', '21:00',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchAvailability();
    fetchMyBookings();
  }

  String get formattedSelectedDate => DateFormat('yyyy-MM-dd').format(selectedDate.value);

  Future<void> fetchAvailability() async {
    try {
      isLoading.value = true;
      selectedTable.value = null;

      final result = await _bookingRepository.checkAvailability(
        date: formattedSelectedDate,
        startTime: selectedTimeSlot.value,
        guestCount: guestCount.value,
      );
      tables.assignAll(result);
    } catch (e) {
      Get.snackbar('Availability Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectTable(TableModel table) async {
    if (!table.isAvailable) {
      Get.snackbar('Seat Unavailable', 'This table is already reserved for the selected slot');
      return;
    }

    try {
      selectedTable.value = table;
      final startHour = int.parse(selectedTimeSlot.value.split(':')[0]);
      final endHour = (startHour + 1).toString().padLeft(2, '0');
      final endTime = '$endHour:00';

      // Create temporary hold
      await _bookingRepository.createHold(
        tableId: table.id,
        bookingDate: formattedSelectedDate,
        startTime: selectedTimeSlot.value,
        endTime: endTime,
      );

      Get.snackbar('Seat Held', 'Table #${table.tableNumber} held for 5 minutes!',
          backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
    } catch (e) {
      Get.snackbar('Hold Failed', e.toString());
    }
  }

  Future<BookingModel?> confirmBooking() async {
    if (selectedTable.value == null) {
      Get.snackbar('Select Table', 'Please tap on an available table first');
      return null;
    }

    try {
      isConfirming.value = true;
      final startHour = int.parse(selectedTimeSlot.value.split(':')[0]);
      final endHour = (startHour + 1).toString().padLeft(2, '0');
      final endTime = '$endHour:00';

      final booking = await _bookingRepository.createBooking(
        tableId: selectedTable.value!.id,
        guestCount: guestCount.value,
        bookingDate: formattedSelectedDate,
        startTime: selectedTimeSlot.value,
        endTime: endTime,
      );

      fetchMyBookings();
      fetchAvailability();
      return booking;
    } catch (e) {
      Get.snackbar('Booking Error', e.toString(),
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return null;
    } finally {
      isConfirming.value = false;
    }
  }

  Future<void> fetchMyBookings() async {
    try {
      final list = await _bookingRepository.getMyBookings();
      myBookings.assignAll(list);
    } catch (_) {}
  }
}
