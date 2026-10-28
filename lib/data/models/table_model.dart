class TableModel {
  final String id;
  final int tableNumber;
  final int capacity;
  final String zone;
  final String status;
  final bool isAvailable;
  final bool isHeld;

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.zone,
    required this.status,
    this.isAvailable = true,
    this.isHeld = false,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] ?? '',
      tableNumber: json['tableNumber'] ?? 0,
      capacity: json['capacity'] ?? 2,
      zone: json['zone'] ?? 'MAIN_HALL',
      status: json['status'] ?? 'AVAILABLE',
      isAvailable: json['isAvailable'] ?? true,
      isHeld: json['isHeld'] ?? false,
    );
  }
}
