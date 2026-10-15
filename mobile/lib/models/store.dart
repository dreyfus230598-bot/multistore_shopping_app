import 'package:flutter/material.dart';

class Store {
  final String id;
  final String code; // ex: LJ01, LJ02 ... LJ06
  final String name;
  final String? address;
  final Color color;

  Store({
    required this.id,
    required this.code,
    required this.name,
    this.address,
    required this.color,
  });

  Store copyWith({
    String? id,
    String? code,
    String? name,
    String? address,
    Color? color,
  }) {
    return Store(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      address: address ?? this.address,
      color: color ?? this.color,
    );
  }

  factory Store.fromJson(Map<String, dynamic> json) {
    Color parsedColor = const Color(0xFF007AFF);
    if (json['color_hex'] != null) {
      final hex = json['color_hex'].toString().replaceAll('#', '');
      if (hex.length == 6) {
        parsedColor = Color(int.parse('FF$hex', radix: 16));
      }
    }
    return Store(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      color: parsedColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'address': address,
      'color_hex': '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
    };
  }
}
