import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multistore_shopping_app/models/store.dart';
import 'package:multistore_shopping_app/models/shopping_item.dart';
import 'package:multistore_shopping_app/models/pdf_extracted_item.dart';
import 'package:multistore_shopping_app/models/team_member.dart';

void main() {
  group('Modelos de Dados Multi-Lojas', () {
    test('Store: parsing de JSON e conversão de cores hex', () {
      final json = {
        'id': 'store-1',
        'code': 'LJ01',
        'name': 'Loja Central',
        'address': 'Rua das Flores, 123',
        'color_hex': '#007AFF',
      };

      final store = Store.fromJson(json);

      expect(store.id, 'store-1');
      expect(store.code, 'LJ01');
      expect(store.name, 'Loja Central');
      expect(store.color.value, const Color(0xFF007AFF).value);

      final exportedJson = store.toJson();
      expect(exportedJson['code'], 'LJ01');
      expect(exportedJson['color_hex'], '#007AFF');
    });

    test('ShoppingItem: cálculo automático de subtotal e copyWith', () {
      final item = ShoppingItem(
        id: 'item-10',
        storeId: 'store-1',
        description: 'Feijão Preto 1kg',
        quantity: 5.0,
        unit: 'pct',
        unitPrice: 8.50,
        subtotal: 42.50,
        isPurchased: false,
      );

      expect(item.subtotal, 42.50);

      // Alterar quantidade para 10 através do copyWith
      final updated = item.copyWith(quantity: 10.0);
      expect(updated.quantity, 10.0);
      expect(updated.subtotal, 85.00); // 10 * 8.50 = 85.00
    });

    test('PdfExtractedItem: recálculo dinâmico ao ajustar quantidade no modal', () {
      final extracted = PdfExtractedItem(
        description: 'Óleo de Girassol 900ml',
        quantity: 20.0,
        unit: 'un',
        unitPrice: 7.20,
        subtotal: 144.00,
      );

      // Usuário incrementa para 25 no modal
      extracted.updateQuantity(25.0);
      expect(extracted.quantity, 25.0);
      expect(extracted.subtotal, 180.00); // 25 * 7.20 = 180.00
    });

    test('TeamMember & MemberRole: mapeamento de permissões', () {
      final checklistMember = TeamMember(
        id: 'mem-1',
        name: 'Carlos',
        email: 'carlos@mercado.com',
        role: MemberRole.checklistOnly,
        assignedStoreIds: ['store-1'],
      );

      expect(checklistMember.role.label, 'Apenas Checklist');
      expect(checklistMember.role.toApiString(), 'checklist_only');

      final editorMember = TeamMember(
        id: 'mem-2',
        name: 'Ana',
        email: 'ana@mercado.com',
        role: MemberRole.editor,
        assignedStoreIds: ['store-1', 'store-2'],
      );

      expect(editorMember.role.label, 'Editor Completo');
      expect(editorMember.role.toApiString(), 'editor');
    });
  });
}
