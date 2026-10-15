import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/store.dart';

class StoreTabBar extends StatelessWidget {
  const StoreTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final stores = storeProvider.stores;
    final selectedIndex = storeProvider.selectedStoreIndex;

    return Container(
      height: 58.0,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1.0,
          ),
        ),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: stores.length + 1, // +1 para o botão de adicionar loja
        separatorBuilder: (_, __) => const SizedBox(width: 10.0),
        itemBuilder: (context, index) {
          if (index == stores.length) {
            // Botão Adicionar Loja Dinamicamente
            return _buildAddStoreButton(context);
          }

          final store = stores[index];
          final isSelected = index == selectedIndex;

          // Contar itens pendentes nesta loja
          final pendingCount = storeProvider.stores.isNotEmpty
              ? storeProvider.currentStore.id == store.id
                  ? storeProvider.pendingCount
                  : 0
              : 0;

          return _buildStoreTabItem(
            context: context,
            store: store,
            isSelected: isSelected,
            pendingCount: pendingCount,
            onTap: () => storeProvider.selectStore(index),
          );
        },
      ),
    );
  }

  Widget _buildStoreTabItem({
    required BuildContext context,
    required Store store,
    required bool isSelected,
    required int pendingCount,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected
              ? store.color.withOpacity(isDark ? 0.25 : 0.12)
              : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? store.color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bolinha indicadora de cor da unidade
            Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: store.color,
              ),
            ),
            const SizedBox(width: 8.0),
            // Código (ex: LJ01) em negrito
            Text(
              store.code,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? store.color
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(width: 5.0),
            // Nome da loja resumido
            Text(
              store.name,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ),
            if (pendingCount > 0) ...[
              const SizedBox(width: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: isSelected ? store.color : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  '$pendingCount',
                  style: const TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddStoreButton(BuildContext context) {
    return InkWell(
      onTap: () => _showAddStoreDialog(context),
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 16.0,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 4.0),
            Text(
              'Nova Loja',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStoreDialog(BuildContext context) {
    final codeController = TextEditingController(text: 'LJ07');
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cadastrar Nova Loja'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Código da Unidade (ex: LJ07)'),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome da Loja (ex: Loja Vila Mariana)'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Endereço (opcional)'),
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
              if (nameController.text.trim().isNotEmpty) {
                context.read<StoreProvider>().addStore(
                      code: codeController.text.trim(),
                      name: nameController.text.trim(),
                      address: addressController.text.trim(),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
