import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  void add(LibraryItem item) {
    items.add(item);
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }
    return null;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  late final DateTime openedAt;

  void open() {
    openedAt = DateTime.now();
  }

  String? _cachedReport;

  String report() {
    return _cachedReport ??= _buildReport();
  }

  String _buildReport() {
    return 'Library opened at $openedAt with ${items.length} item(s)';
  }

  Iterable<String> get allTitles => items.map((item) => item.title);

  Iterable<Book> get booksAfter2010 =>
      items.whereType<Book>().where((book) => book.year > 2010);

  double get averagePages {
    final books = items.whereType<Book>().toList();
    if (books.isEmpty) return 0;
    final totalPages = books.fold<int>(0, (sum, book) => sum + book.pages);
    return totalPages / books.length;
  }

  Map<String, int> get bookCountByAuthor {
    final result = <String, int>{};
    for (final book in items.whereType<Book>()) {
      result[book.author.name] = (result[book.author.name] ?? 0) + 1;
    }
    return result;
  }

  Set<String> get distinctAuthorNames =>
      items.whereType<Book>().map((book) => book.author.name).toSet();

  Set<Genre> get allGenres =>
      items.whereType<Book>().map((book) => book.genre).toSet();

  List<String> get displayList {
    final hasIncompleteData = items.whereType<Book>().any(
      (book) => book.pages == 0,
    );

    return [
      'CATALOGUE',
      for (final item in items) '${item.title} (${item.year})',
      ...distinctAuthorNames,
      if (hasIncompleteData) '(incomplete data)',
    ];
  }
}
