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

  Map<String, dynamic> toDbMap() => {
        'id': id,
        'name': name,
        'icon_code': icon.codePoint,
        'image_url': imageUrl,
      };

  factory Category.fromDbMap(Map<String, dynamic> map) => Category(
        id: map['id'],
        name: map['name'],
        icon: IconData(map['icon_code'] as int, fontFamily: 'MaterialIcons'),
        imageUrl: map['image_url'],
      );
}
