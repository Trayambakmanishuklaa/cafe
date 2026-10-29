class TableModel {
  final String id;
  final int tableNumber;
  final String? name;
  final int capacity;
  final String zone;
  final String status;
  final String manualStatus;
  final bool isAvailable;
  final bool isHeld;

  TableModel({
    required this.id,
    required this.tableNumber,
    this.name,
    required this.capacity,
    required this.zone,
    required this.status,
    required this.manualStatus,
    this.isAvailable = true,
    this.isHeld = false,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] ?? '',
      tableNumber: (json['tableNumber'] as num?)?.toInt() ?? 0,
      name: json['name'],
      capacity: (json['capacity'] as num?)?.toInt() ?? 2,
      zone: json['zone'] ?? 'MAIN_HALL',
      status: json['status'] ?? 'AVAILABLE',
      manualStatus: json['manualStatus'] ?? json['effectiveStatus'] ?? 'FREE',
      isAvailable: json['isAvailable'] ?? true,
      isHeld: json['isHeld'] ?? false,
    );
  }
}
