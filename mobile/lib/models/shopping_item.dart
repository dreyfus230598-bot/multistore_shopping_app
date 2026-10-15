class ShoppingItem {
  final String id;
  final String storeId;
  final String description;
  final double quantity;
  final String unit; // un, cx, kg, pct, fd, l
  final double unitPrice;
  final double subtotal;
  final bool isPurchased;
  final DateTime? purchasedAt;
  final String? purchasedBy;
  final String category;

  ShoppingItem({
    required this.id,
    required this.storeId,
    required this.description,
    required this.quantity,
    this.unit = 'un',
    this.unitPrice = 0.0,
    required this.subtotal,
    this.isPurchased = false,
    this.purchasedAt,
    this.purchasedBy,
    this.category = 'Geral',
  });

  ShoppingItem copyWith({
    String? id,
    String? storeId,
    String? description,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? subtotal,
    bool? isPurchased,
    DateTime? purchasedAt,
    String? purchasedBy,
    String? category,
  }) {
    final newQty = quantity ?? this.quantity;
    final newPrice = unitPrice ?? this.unitPrice;
    final calculatedSubtotal = subtotal ?? (newQty * newPrice);

    return ShoppingItem(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      description: description ?? this.description,
      quantity: newQty,
      unit: unit ?? this.unit,
      unitPrice: newPrice,
      subtotal: double.parse(calculatedSubtotal.toStringAsFixed(2)),
      isPurchased: isPurchased ?? this.isPurchased,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      purchasedBy: purchasedBy ?? this.purchasedBy,
      category: category ?? this.category,
    );
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: (json['unit'] as String?) ?? 'un',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      isPurchased: json['is_purchased'] as bool? ?? false,
      purchasedAt: json['purchased_at'] != null ? DateTime.parse(json['purchased_at'] as String) : null,
      purchasedBy: json['purchased_by'] as String?,
      category: (json['category'] as String?) ?? 'Geral',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'is_purchased': isPurchased,
      'purchased_at': purchasedAt?.toIso8601String(),
      'purchased_by': purchasedBy,
      'category': category,
    };
  }
}
