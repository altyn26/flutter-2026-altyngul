import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final q = _query.toLowerCase();
    final visible = books
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search books',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: const [CartBadge()],
      ),
      body: ListView.builder(
        itemCount: visible.length,
        itemBuilder: (context, i) => BookRow(book: visible[i]),
      ),
    );
  }
}

class BookRow extends StatelessWidget {
  const BookRow({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    debugPrint('row ${book.title}');
    final inCart = context.select<Cart, bool>((c) => c.contains(book));
    return ListTile(
      title: Text(book.title),
      subtitle: Text('${book.author} · ${book.price} ₸'),
      trailing: inCart
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () => _add(context),
              child: const Text('Add'),
            ),
    );
  }

  void _add(BuildContext context) {
    final ok = context.read<Cart>().add(book);
    if (ok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Added: ${book.title}'),
            duration: const Duration(seconds: 1),
          ),
        );
    }
  }
}
