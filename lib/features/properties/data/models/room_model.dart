import 'package:flutter/material.dart';

class PropertyModel {
  final String id;
  final String title;
  final String imageUrl;
  final String location;
  final String price;
  final Color bgColor;

  // Gumamit tayo ng const constructor at default values para sa price at bgColor
  // para hindi mag-error yung mock data ni Claude.
  const PropertyModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.location,
    this.price = "0", // Default price kung walang nakalagay
    this.bgColor = const Color(0xFFF5F5F5), // Default background color
  });
}