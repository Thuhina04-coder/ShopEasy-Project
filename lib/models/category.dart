import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final String imageUrl;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
  });

  static final Map<int, IconData> _iconByCodePoint = {
    Icons.devices.codePoint: Icons.devices,
    Icons.checkroom.codePoint: Icons.checkroom,
    Icons.home.codePoint: Icons.home,
    Icons.sports_basketball.codePoint: Icons.sports_basketball,
    Icons.face.codePoint: Icons.face,
    Icons.menu_book.codePoint: Icons.menu_book,
    Icons.shopping_basket.codePoint: Icons.shopping_basket,
    Icons.toys.codePoint: Icons.toys,
  };

  Map<String, dynamic> toDbMap() => {
        'id': id,
        'name': name,
        'icon_code': icon.codePoint,
        'image_url': imageUrl,
      };

  factory Category.fromDbMap(Map<String, dynamic> map) => Category(
        id: map['id'],
        name: map['name'],
        icon: _iconByCodePoint[map['icon_code'] as int] ?? Icons.category,
        imageUrl: map['image_url'],
      );
}
