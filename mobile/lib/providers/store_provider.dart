import 'package:flutter/material.dart';
import '../models/store.dart';
import '../models/shopping_item.dart';
import '../models/pdf_extracted_item.dart';
import '../services/api_service.dart';

class StoreProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Lojas cadastradas (Foco nas 6 lojas iniciais LJ01 a LJ06)
  final List<Store> _stores = [
    Store(id: 'store-1', code: 'LJ01', name: 'Loja Centro', color: const Color(0xFF007AFF)),
    Store(id: 'store-2', code: 'LJ02', name: 'Loja Jardins', color: const Color(0xFF34C759)),
    Store(id: 'store-3', code: 'LJ03', name: 'Express Norte', color: const Color(0xFFFF9500)),
    Store(id: 'store-4', code: 'LJ04', name: 'Shopping Sul', color: const Color(0xFFAF52DE)),
    Store(id: 'store-5', code: 'LJ05', name: 'Bairro Alto', color: const Color(0xFFFF2D55)),
    Store(id: 'store-6', code: 'LJ06', name: 'Depósito Central', color: const Color(0xFF5856D6)),
  ];

  int _selectedStoreIndex = 0;

  // Itens em memória com isolamento por loja
  final List<ShoppingItem> _items = [
    // Loja 1 (LJ01)
    ShoppingItem(
      id: 'item-1',
      storeId: 'store-1',
      description: 'Leite Integral UHT 1L (Caixa c/ 12)',
      quantity: 10,
      unit: 'cx',
      unitPrice: 58.80,
      subtotal: 588.00,
      isPurchased: false,
      category: 'Laticínios',
    ),
    ShoppingItem(
      id: 'item-2',
      storeId: 'store-1',
      description: 'Arroz Branco Nobre 5kg',
      quantity: 15,
      unit: 'pct',
      unitPrice: 29.90,
      subtotal: 448.50,
      isPurchased: false,
      category: 'Mercearia',
    ),
    ShoppingItem(
      id: 'item-3',
      storeId: 'store-1',
      description: 'Óleo de Soja 900ml (Caixa c/ 20)',
      quantity: 8,
      unit: 'cx',
      unitPrice: 125.00,
      subtotal: 1000.00,
      isPurchased: false,
      category: 'Mercearia',
    ),
    ShoppingItem(
      id: 'item-4',
      storeId: 'store-1',
      description: 'Café Tradicional Torrado 500g',
      quantity: 20,
      unit: 'pct',
      unitPrice: 16.90,
      subtotal: 338.00,
      isPurchased: true,
      purchasedAt: DateTime.now().subtract(const Duration(minutes: 25)),
      purchasedBy: 'Carlos Comprador',
      category: 'Mercearia',
    ),
    ShoppingItem(
      id: 'item-5',
      storeId: 'store-1',
      description: 'Açúcar Cristal 5kg (Fardo c/ 6)',
      quantity: 5,
      unit: 'fd',
      unitPrice: 112.50,
      subtotal: 562.50,
      isPurchased: true,
      purchasedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      purchasedBy: 'Carlos Comprador',
      category: 'Mercearia',
    ),

    // Loja 2 (LJ02)
    ShoppingItem(
      id: 'item-6',
      storeId: 'store-2',
      description: 'Refrigerante Cola 2L (Fardo c/ 6)',
      quantity: 12,
      unit: 'fd',
      unitPrice: 51.00,
      subtotal: 612.00,
      isPurchased: false,
      category: 'Bebidas',
    ),
    ShoppingItem(
      id: 'item-7',
      storeId: 'store-2',
      description: 'Sabão em Pó 1kg (Caixa c/ 24)',
      quantity: 4,
      unit: 'cx',
      unitPrice: 285.60,
      subtotal: 1142.40,
      isPurchased: false,
      category: 'Limpeza',
    ),

    // Loja 3 (LJ03)
    ShoppingItem(
      id: 'item-8',
      storeId: 'store-3',
      description: 'Farinha de Trigo Especial 1kg',
      quantity: 30,
      unit: 'pct',
      unitPrice: 4.50,
      subtotal: 135.00,
      isPurchased: false,
      category: 'Mercearia',
    ),
  ];

  // Getters
  List<Store> get stores => List.unmodifiable(_stores);
  int get selectedStoreIndex => _selectedStoreIndex;
  Store get currentStore => _stores[_selectedStoreIndex];

  /// Lista isolada de itens para a loja atualmente selecionada
  List<ShoppingItem> get currentStoreItems {
    return _items.where((item) => item.storeId == currentStore.id).toList();
  }

  /// Itens pendentes de compra (para serem marcados no corredor)
  List<ShoppingItem> get pendingItems {
    return currentStoreItems.where((item) => !item.isPurchased).toList();
  }

  /// Itens já comprados (movidos para a seção inferior)
  List<ShoppingItem> get purchasedItems {
    final list = currentStoreItems.where((item) => item.isPurchased).toList();
    // Ordenar pelos mais recentemente comprados
    list.sort((a, b) {
      if (a.purchasedAt == null || b.purchasedAt == null) return 0;
      return b.purchasedAt!.compareTo(a.purchasedAt!);
    });
    return list;
  }

  // Métricas de progresso da loja atual
  int get totalItemsCount => currentStoreItems.length;
  int get pendingCount => pendingItems.length;
  int get purchasedCount => purchasedItems.length;

  double get progressPercentage {
    if (totalItemsCount == 0) return 0.0;
    return (purchasedCount / totalItemsCount);
  }

  double get totalStoreCost {
    return currentStoreItems.fold(0.0, (acc, item) => acc + item.subtotal);
  }

  double get totalPurchasedCost {
    return purchasedItems.fold(0.0, (acc, item) => acc + item.subtotal);
  }

  // Ações de Navegação Multiloja
  void selectStore(int index) {
    if (index >= 0 && index < _stores.length) {
      _selectedStoreIndex = index;
      notifyListeners();
    }
  }

  void addStore({required String code, required String name, Color? color, String? address}) {
    final newStore = Store(
      id: 'store-${DateTime.now().millisecondsSinceEpoch}',
      code: code.toUpperCase(),
      name: name,
      address: address,
      color: color ?? const Color(0xFF007AFF),
    );
    _stores.add(newStore);
    _selectedStoreIndex = _stores.length - 1;
    notifyListeners();
  }

  void updateStore({required String storeId, required String name, required String code, Color? color}) {
    final idx = _stores.indexWhere((s) => s.id == storeId);
    if (idx != -1) {
      _stores[idx] = _stores[idx].copyWith(
        name: name,
        code: code.toUpperCase(),
        color: color,
      );
      notifyListeners();
    }
  }

  // Ações de Checklist com Tick em Tempo Real
  void toggleItem(String itemId, {String buyerName = 'Eu (Comprador)'}) {
    final idx = _items.indexWhere((item) => item.id == itemId);
    if (idx != -1) {
      final item = _items[idx];
      final newStatus = !item.isPurchased;

      _items[idx] = item.copyWith(
        isPurchased: newStatus,
        purchasedAt: newStatus ? DateTime.now() : null,
        purchasedBy: newStatus ? buyerName : null,
      );

      // Notificar a UI para reagir instantaneamente
      notifyListeners();

      // Sincronizar assincronamente com o backend
      _apiService.toggleItemStatus(itemId, buyerName);
    }
  }

  void addItem({
    required String description,
    required double quantity,
    String unit = 'un',
    double unitPrice = 0.0,
    String category = 'Geral',
    String? storeId,
  }) {
    final targetStoreId = storeId ?? currentStore.id;
    final subtotal = double.parse((quantity * unitPrice).toStringAsFixed(2));

    final newItem = ShoppingItem(
      id: 'item-${DateTime.now().millisecondsSinceEpoch}',
      storeId: targetStoreId,
      description: description,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      subtotal: subtotal,
      isPurchased: false,
      category: category,
    );

    _items.add(newItem);
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  /// Mescla os itens revisados do PDF para a loja de destino
  void mergeExtractedPdfItems(String targetStoreId, List<PdfExtractedItem> extractedItems) {
    for (final item in extractedItems) {
      final newItem = ShoppingItem(
        id: 'pdf-item-${DateTime.now().millisecondsSinceEpoch}-${item.description.hashCode}',
        storeId: targetStoreId,
        description: item.description,
        quantity: item.quantity,
        unit: item.unit,
        unitPrice: item.unitPrice,
        subtotal: item.subtotal,
        isPurchased: false,
        category: 'Fornecedor / PDF',
      );
      _items.add(newItem);
    }
    notifyListeners();
  }
}
