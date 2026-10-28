import 'table_model.dart';

class BookingModel {
  final String id;
  final String bookingCode;
  final String tableId;
  final TableModel? table;
  final int guestCount;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final String status;
  final double bookingFee;
  final String qrCode;

  BookingModel({
    required this.id,
    required this.bookingCode,
    required this.tableId,
    this.table,
    required this.guestCount,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.bookingFee,
    required this.qrCode,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      bookingCode: json['bookingCode'] ?? '',
      tableId: json['tableId'] ?? '',
      table: json['table'] != null ? TableModel.fromJson(json['table']) : null,
      guestCount: json['guestCount'] ?? 1,
      bookingDate: json['bookingDate'] != null ? DateTime.parse(json['bookingDate']) : DateTime.now(),
      startTime: json['startTime'] ?? '12:00',
      endTime: json['endTime'] ?? '13:00',
      status: json['status'] ?? 'CONFIRMED',
      bookingFee: (json['bookingFee'] as num?)?.toDouble() ?? 50.0,
      qrCode: json['qrCode'] ?? '',
    );
  }
}
