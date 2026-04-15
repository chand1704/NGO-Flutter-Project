import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String title;
  final String? base64Image;
  final IconData icon;
  final String fallbackImage;
  final List<dynamic> items;
  CategoryModel({
    required this.id,
    required this.title,
    this.base64Image,
    required this.icon,
    required this.fallbackImage,
    this.items = const [],
  });
  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String docId) {
    final meta = _getLocalMetadata(docId);
    return CategoryModel(
      id: docId,
      title: data['category_name'] ?? 'Unnamed Category',
      base64Image: data['image'], // Matches your Firestore field
      items: data['items'] as List? ?? [],
      icon: meta['icon'],
      fallbackImage: meta['imagePath'],
    );
  }
  static Map<String, dynamic> _getLocalMetadata(String id) {
    final Map<String, Map<String, dynamic>> metaMap = {
      "old_age": {
        "icon": Icons.elderly,
        "imagePath": "assets/images/old_age.jpg",
      },
      "tree": {"icon": Icons.park, "imagePath": "assets/images/tree.jpeg"},
      "cow": {
        "icon": Icons.pets,
        "imagePath": "assets/images/cow_shelter.jpeg",
      },
      "food": {"icon": Icons.restaurant, "imagePath": "assets/images/food.jpg"},
      "education": {
        "icon": Icons.school,
        "imagePath": "assets/images/education.jpg",
      },
      "medical": {
        "icon": Icons.local_hospital,
        "imagePath": "assets/images/medical.jpeg",
      },
    };
    return metaMap[id] ??
        {"icon": Icons.help, "imagePath": "assets/images/ngo_logo.png"};
  }
}
