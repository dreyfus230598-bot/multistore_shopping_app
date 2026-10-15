class PdfExtractedItem {
  final String description;
  double quantity;
  final String unit;
  double unitPrice;
  double subtotal;

  PdfExtractedItem({
    required this.description,
    required this.quantity,
    this.unit = 'un',
    required this.unitPrice,
    required this.subtotal,
  });

  void updateQuantity(double newQuantity) {
    quantity = newQuantity;
    subtotal = double.parse((quantity * unitPrice).toStringAsFixed(2));
  }

  void updateUnitPrice(double newPrice) {
    unitPrice = newPrice;
    subtotal = double.parse((quantity * unitPrice).toStringAsFixed(2));
  }

  factory PdfExtractedItem.fromJson(Map<String, dynamic> json) {
    return PdfExtractedItem(
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: (json['unit'] as String?) ?? 'un',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }
}

class PdfExtractionResult {
  final List<PdfExtractedItem> items;
  final int totalItemsCount;
  final double calculatedTotalValue;
  final String? detectedSupplier;
  final String? notes;

  PdfExtractionResult({
    required this.items,
    required this.totalItemsCount,
    required this.calculatedTotalValue,
    this.detectedSupplier,
    this.notes,
  });

  factory PdfExtractionResult.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    return PdfExtractionResult(
      items: rawItems.map((e) => PdfExtractedItem.fromJson(e as Map<String, dynamic>)).toList(),
      totalItemsCount: (json['total_items_count'] as num?)?.toInt() ?? 0,
      calculatedTotalValue: (json['calculated_total_value'] as num?)?.toDouble() ?? 0.0,
      detectedSupplier: json['detected_supplier'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
