class OrderItemModel {
  final String id;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? '',
      productName: json['productName'] ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String orderType;
  final String status;
  final double subtotal;
  final double discount;
  final double tax;
  final double totalAmount;
  final String paymentStatus;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.status,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.totalAmount,
    required this.paymentStatus,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      orderType: json['orderType'] ?? 'DINE_IN',
      status: json['status'] ?? 'PENDING',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => OrderItemModel.fromJson(i))
              .toList() ??
          [],
    );
  }
}
