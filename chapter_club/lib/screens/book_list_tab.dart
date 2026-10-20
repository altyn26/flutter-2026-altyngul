import 'package:flutter/material.dart';
import 'package:chapter_club/models/book.dart';
import 'package:chapter_club/models/genre.dart';
import 'package:chapter_club/widgets/book_card.dart';
import 'package:chapter_club/widgets/empty_state.dart';

class BookListTab extends StatefulWidget {
  const BookListTab({
    super.key,
    required this.books,
    required this.onToggleFavourite,
    required this.onOpen,
  });

  final List<Book> books;
  final void Function(Book book) onToggleFavourite;
  final void Function(Book book) onOpen;

  @override
  State<BookListTab> createState() => _BookListTabState();
}

class _BookListTabState extends State<BookListTab> {
  final _searchController = TextEditingController();
  String _query = '';
  Genre? _genre; // null means "All"
  bool _showPast = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _genre = null;
      _showPast = false;
    });
  }

  List<Book> get _visible {
    final result = widget.books.where((book) {
      final matchesQuery = book.title.toLowerCase().contains(
        _query.toLowerCase(),
      );
      final matchesGenre = _genre == null || book.genre == _genre;
      final matchesPast = _showPast || !book.isPast;
      return matchesQuery && matchesGenre && matchesPast;
    }).toList();

    result.sort((a, b) {
      if (a.isPast != b.isPast) {
        return a.isPast ? 1 : -1;
      }
      return a.meetingDate.compareTo(b.meetingDate);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final books = _visible;

    Widget cardFor(Book book) {
      return BookCard(
        book: book,
        onTap: () => widget.onOpen(book),
        onFavourite: () => widget.onToggleFavourite(book),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _genre == null,
                onSelected: (_) => setState(() => _genre = null),
              ),
              for (final genre in Genre.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(genre.label),
                  avatar: Icon(genre.icon),
                  selected: _genre == genre,
                  onSelected: (_) => setState(() => _genre = genre),
                ),
              ],
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: books.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No books match your search',
                  actionLabel: 'Reset filters',
                  onAction: _resetFilters,
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 600) {
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 360,
                              mainAxisExtent: 130,
                            ),
                        itemCount: books.length,
                        itemBuilder: (context, index) => cardFor(books[index]),
                      );
                    }
                    return ListView.separated(
                      itemCount: books.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (context, index) => cardFor(books[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
