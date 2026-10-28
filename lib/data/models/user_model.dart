import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role; // CUSTOMER, STAFF, OWNER
  final int loyaltyPoints;
  final String membershipTier;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.loyaltyPoints = 0,
    this.membershipTier = 'BRONZE',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'CUSTOMER',
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      membershipTier: json['membershipTier'] ?? 'BRONZE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'loyaltyPoints': loyaltyPoints,
      'membershipTier': membershipTier,
    };
  }

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromRawJson(String str) => UserModel.fromJson(json.decode(str));

  bool get isCustomer => role == 'CUSTOMER';
  bool get isStaff => role == 'STAFF';
  bool get isOwner => role == 'OWNER';
}
