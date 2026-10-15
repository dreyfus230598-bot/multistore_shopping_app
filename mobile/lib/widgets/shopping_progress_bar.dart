import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';

class ShoppingProgressBar extends StatelessWidget {
  const ShoppingProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final pendingCount = storeProvider.pendingCount;
    final purchasedCount = storeProvider.purchasedCount;
    final totalCount = storeProvider.totalItemsCount;
    final percentage = storeProvider.progressPercentage;
    final store = storeProvider.currentStore;

    final percentDisplay = (percentage * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 18.0,
                    color: store.color,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    'Progresso de Reposição',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: percentage == 1.0
                      ? const Color(0xFF34C759).withOpacity(0.15)
                      : store.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '$percentDisplay% Concluído',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: percentage == 1.0 ? const Color(0xFF34C759) : store.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          // Barra de progresso linear arredondada
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: LinearProgressIndicator(
              value: totalCount == 0 ? 0.0 : percentage,
              minHeight: 8.0,
              backgroundColor: Theme.of(context).dividerColor.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage == 1.0 ? const Color(0xFF34C759) : store.color,
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$purchasedCount de $totalCount itens comprados',
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Total: R\$ ${storeProvider.totalStoreCost.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
