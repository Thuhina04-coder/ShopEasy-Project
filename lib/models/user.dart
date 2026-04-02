import 'package:flutter/material.dart';

class Address {
  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String province;
  final String postalCode;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.province,
    required this.postalCode,
    this.isDefault = false,
  });

  Address copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? province,
    String? postalCode,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'fullName': fullName,
        'phone': phone,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'city': city,
        'province': province,
        'postalCode': postalCode,
        'isDefault': isDefault,
      };

  Map<String, dynamic> toDbMap(String userId) => {
        'id': id,
        'user_id': userId,
        'label': label,
        'full_name': fullName,
        'phone': phone,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'province': province,
        'postal_code': postalCode,
        'is_default': isDefault ? 1 : 0,
      };

  factory Address.fromMap(Map<String, dynamic> map) => Address(
        id: map['id'],
        label: map['label'],
        fullName: map['fullName'] ?? map['full_name'] ?? '',
        phone: map['phone'],
        addressLine1: map['addressLine1'] ?? map['address_line1'] ?? '',
        addressLine2: map['addressLine2'] ?? map['address_line2'] ?? '',
        city: map['city'],
        province: map['province'],
        postalCode: map['postalCode'] ?? map['postal_code'] ?? '',
        isDefault: map['isDefault'] == true ||
            map['isDefault'] == 1 ||
            map['is_default'] == 1,
      );

  String get formatted =>
      '$addressLine1${addressLine2.isNotEmpty ? ', $addressLine2' : ''}, $city, $province $postalCode';
}

class User {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final int avatarColor;
  final List<Address> addresses;

  static const List<int> avatarColors = [
    0xFF1A9CB7,
    0xFFF85606,
    0xFF43A047,
    0xFFE53935,
    0xFF8E24AA,
    0xFF3949AB,
    0xFFD4400A,
    0xFF00897B,
    0xFFFFB300,
    0xFF546E7A,
  ];

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone = '',
    this.avatarColor = 0xFF1A9CB7,
    this.addresses = const [],
  });

  Color get avatarColorValue => Color(avatarColor);

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    int? avatarColor,
    List<Address>? addresses,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarColor: avatarColor ?? this.avatarColor,
      addresses: addresses ?? this.addresses,
    );
  }
}
