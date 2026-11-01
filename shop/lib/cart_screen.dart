import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('All books will be removed from the cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (ok == true) context.read<Cart>().clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            tooltip: 'Clear cart',
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _confirmClear(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<Cart>(
              builder: (context, cart, _) {
                final items = cart.items;
                if (items.isEmpty) {
                  return const Center(child: Text('Cart is empty'));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final b = items[i];
                    return ListTile(
                      title: Text(b.title),
                      subtitle: Text('${b.price} ₸'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('×${cart.qtyOf(b)}'),
                          IconButton(
                            tooltip: 'One more',
                            icon: const Icon(Icons.add),
                            onPressed: () => cart.increment(b),
                          ),
                          IconButton(
                            tooltip: 'Remove',
                            icon: const Icon(Icons.close),
                            onPressed: () => cart.remove(b),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Consumer<Cart>(
            builder: (context, cart, child) => Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  child!,
                  const Spacer(),
                  Text(
                    '${cart.total} ₸',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            child: const TotalLabel(),
          ),
        ],
      ),
    );
  }
}

class TotalLabel extends StatelessWidget {
  const TotalLabel({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('TotalLabel build');
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(Icons.receipt_long), SizedBox(width: 8), Text('Total')],
    );
  }
}
