import 'package:flutter_test/flutter_test.dart';
import 'package:multistore_shopping_app/providers/store_provider.dart';
import 'package:multistore_shopping_app/models/pdf_extracted_item.dart';

void main() {
  group('StoreProvider - Lojas, Checklist e Modo Compras', () {
    late StoreProvider provider;

    setUp(() {
      provider = StoreProvider();
    });

    test('Inicialização com as 6 lojas padrão (LJ01 a LJ06)', () {
      expect(provider.stores.length, 6);
      expect(provider.stores[0].code, 'LJ01');
      expect(provider.stores[1].code, 'LJ02');
      expect(provider.stores[2].code, 'LJ03');
      expect(provider.stores[3].code, 'LJ04');
      expect(provider.stores[4].code, 'LJ05');
      expect(provider.stores[5].code, 'LJ06');
    });

    test('Alternância entre abas de lojas isola inventários', () {
      provider.selectStore(0); // LJ01
      final store1Items = provider.currentStoreItems;

      provider.selectStore(1); // LJ02
      final store2Items = provider.currentStoreItems;

      expect(provider.currentStore.code, 'LJ02');
      expect(store1Items, isNot(equals(store2Items)));
    });

    test('Modo Compras: Tick de item move para JÁ COMPRADOS e altera progresso', () {
      provider.selectStore(0); // LJ01
      final initialPending = provider.pendingCount;
      final initialPurchased = provider.purchasedCount;

      final pendingItem = provider.pendingItems.first;
      expect(pendingItem.isPurchased, false);

      // Executa o tick no corredor do mercado
      provider.toggleItem(pendingItem.id, buyerName: 'Carlos Teste');

      // Verifica que a lista de pendentes diminuiu e já comprados aumentou
      expect(provider.pendingCount, initialPending - 1);
      expect(provider.purchasedCount, initialPurchased + 1);

      // Item agora está presente na lista de já comprados
      final updatedItem = provider.purchasedItems.firstWhere((i) => i.id == pendingItem.id);
      expect(updatedItem.isPurchased, true);
      expect(updatedItem.purchasedBy, 'Carlos Teste');
      expect(updatedItem.purchasedAt, isNotNull);
    });

    test('Mesclagem de itens revisados do PDF na loja ativa', () {
      provider.selectStore(0);
      final initialCount = provider.totalItemsCount;

      final extractedItems = [
        PdfExtractedItem(
          description: 'Açúcar Refinado 1kg',
          quantity: 10,
          unit: 'pct',
          unitPrice: 4.20,
          subtotal: 42.00,
        ),
        PdfExtractedItem(
          description: 'Macarrão Espaguete 500g',
          quantity: 20,
          unit: 'un',
          unitPrice: 3.50,
          subtotal: 70.00,
        ),
      ];

      provider.mergeExtractedPdfItems(provider.currentStore.id, extractedItems);

      expect(provider.totalItemsCount, initialCount + 2);
      expect(provider.pendingItems.any((i) => i.description == 'Açúcar Refinado 1kg'), true);
    });

    test('Criação dinâmica de nova loja (LJ07)', () {
      provider.addStore(
        code: 'LJ07',
        name: 'Loja Paulista',
        address: 'Av. Paulista, 2000',
      );

      expect(provider.stores.length, 7);
      expect(provider.stores.last.code, 'LJ07');
      expect(provider.currentStore.code, 'LJ07');
    });
  });
}
