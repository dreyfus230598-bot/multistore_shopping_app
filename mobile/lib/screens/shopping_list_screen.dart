import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/shopping_item.dart';
import '../widgets/circular_checkbox.dart';
import '../widgets/store_tab_bar.dart';
import '../widgets/shopping_progress_bar.dart';
import '../widgets/pdf_upload_review_modal.dart';
import '../widgets/share_sheet_modal.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  bool _isPurchasedExpanded = true;

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final pendingItems = storeProvider.pendingItems;
    final purchasedItems = storeProvider.purchasedItems;
    final currentStore = storeProvider.currentStore;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${currentStore.code} • ${currentStore.name}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const Text(
              'Modo Reposição & Compras',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          // Botão Importar PDF
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF007AFF)),
            tooltip: 'Importar PDF de Fornecedor',
            onPressed: () => PdfUploadReviewModal.show(context),
          ),
          // Botão Compartilhar / Delegar Lista
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF007AFF)),
            tooltip: 'Compartilhar com Compradores',
            onPressed: () => ShareSheetModal.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Abas horizontais roláveis para alternar rapidamente entre LJ01 a LJ06
          const StoreTabBar(),

          // Barra de progresso visual de reposição
          const ShoppingProgressBar(),

          // Listas de Compras: Pendentes + Seção Inferior "JÁ COMPRADOS"
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              physics: const BouncingScrollPhysics(),
              children: [
                // Seção Itens Pendentes
                if (pendingItems.isEmpty)
                  _buildEmptyPendingState()
                else ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                    child: Text(
                      'A COMPRAR (${pendingItems.length})',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  ...pendingItems.map((item) => _buildShoppingItemTile(item, isPending: true)),
                ],

                const SizedBox(height: 16.0),

                // Seção Inferior "JÁ COMPRADOS" (Estilo tachado e atenuado)
                if (purchasedItems.isNotEmpty) ...[
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isPurchasedExpanded = !_isPurchasedExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF34C759)),
                              const SizedBox(width: 6),
                              Text(
                                'JÁ COMPRADOS (${purchasedItems.length})',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            _isPurchasedExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isPurchasedExpanded)
                    ...purchasedItems.map((item) => _buildShoppingItemTile(item, isPending: false)),
                ],

                const SizedBox(height: 80.0), // Espaço para rolagem suave
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF007AFF),
        foregroundColor: Colors.white,
        elevation: 3.0,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Item', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddItemDialog(context),
      ),
    );
  }

  Widget _buildShoppingItemTile(ShoppingItem item, {required bool isPending}) {
    final storeProvider = context.read<StoreProvider>();

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        storeProvider.removeItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.description} removido.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: isPending ? Theme.of(context).cardColor : Colors.grey.shade100.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isPending ? Theme.of(context).dividerColor.withOpacity(0.08) : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox Circular Otimizado para Corredor de Mercado
              CircularCheckbox(
                value: item.isPurchased,
                onChanged: (_) {
                  storeProvider.toggleItem(item.id);
                },
              ),
              const SizedBox(width: 8.0),

              // Detalhes do Produto (Tachado e atenuado quando comprado)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: isPending ? FontWeight.w600 : FontWeight.w400,
                        color: isPending ? Colors.black87 : Colors.grey.shade500,
                        decoration: isPending ? TextDecoration.none : TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}',
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              color: isPending ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Unit: R\$ ${item.unitPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: TextStyle(
                            fontSize: 11.0,
                            color: Colors.grey.shade600,
                            decoration: isPending ? TextDecoration.none : TextDecoration.lineThrough,
                          ),
                        ),
                        if (!isPending && item.purchasedBy != null) ...[
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              '• ${item.purchasedBy}',
                              style: TextStyle(
                                fontSize: 10.0,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Subtotal Calculado
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'R\$ ${item.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: isPending ? const Color(0xFF007AFF) : Colors.grey.shade500,
                    decoration: isPending ? TextDecoration.none : TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPendingState() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 48, color: Colors.green.shade400),
          const SizedBox(height: 12),
          const Text(
            'Tudo Comprado nesta Unidade!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Importe um PDF de fornecedor ou adicione itens manualmente.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final descController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: '0,00');
    String unit = 'un';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Adicionar Item na Lista'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Descrição do Produto'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantidade'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: unit,
                      decoration: const InputDecoration(labelText: 'Unidade'),
                      items: ['un', 'cx', 'kg', 'pct', 'fd', 'l'].map((u) {
                        return DropdownMenuItem(value: u, child: Text(u));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => unit = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor Unitário Estimado (R\$)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descController.text.trim().isNotEmpty) {
                  final qty = double.tryParse(qtyController.text.replaceAll(',', '.')) ?? 1.0;
                  final price = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0;
                  context.read<StoreProvider>().addItem(
                        description: descController.text.trim(),
                        quantity: qty,
                        unit: unit,
                        unitPrice: price,
                      );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}
