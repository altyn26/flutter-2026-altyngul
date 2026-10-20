import 'package:flutter/material.dart';
import 'package:chapter_club/models/book.dart';
import 'package:chapter_club/widgets/book_card.dart';
import 'package:chapter_club/widgets/empty_state.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.books,
    required this.onToggleFavourite,
    required this.onOpen,
  });

  final List<Book> books;
  final void Function(Book book) onToggleFavourite;
  final void Function(Book book) onOpen;

  @override
  Widget build(BuildContext context) {
    final favourites = [
      for (final book in books)
        if (book.favourite) book,
    ];

    if (favourites.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
      );
    }

    return ListView.separated(
      itemCount: favourites.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final book = favourites[index];
        return BookCard(
          book: book,
          onTap: () => onOpen(book),
          onFavourite: () => onToggleFavourite(book),
        );
      },
    );
  }
}
