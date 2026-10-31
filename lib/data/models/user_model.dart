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

  factory UserModel.fromJson(dynamic json) {
    if (json is! Map) {
      return UserModel(
        id: '',
        name: '',
        email: '',
        role: 'CUSTOMER',
      );
    }
    final map = Map<String, dynamic>.from(json);
    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString(),
      role: map['role']?.toString() ?? 'CUSTOMER',
      loyaltyPoints: int.tryParse(map['loyaltyPoints']?.toString() ?? '0') ?? 0,
      membershipTier: map['membershipTier']?.toString() ?? 'BRONZE',
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

  bool get isCustomer => role.toUpperCase() == 'CUSTOMER';
  bool get isStaff => role.toUpperCase() == 'STAFF';
  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get isOwner => role.toUpperCase() == 'OWNER';
}
