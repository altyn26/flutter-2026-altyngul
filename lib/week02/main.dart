import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();

  for (final raw in rawBooks) {
    library.add(Book.fromJson(raw));
  }

  library.open();

  print(library.report());
  print('');

  print('All titles: ${library.allTitles.toList()}');
  print('');

  print('Books after 2010:');
  for (final book in library.booksAfter2010) {
    print('  ${book.describe()}');
  }
  print('');

  print('Average pages: ${library.averagePages.toStringAsFixed(1)}');
  print('');

  print('Book count by author: ${library.bookCountByAuthor}');
  print('');

  print('Distinct author names: ${library.distinctAuthorNames}');
  print('');

  print('All genres: ${library.allGenres}');
  print('');

  print('Display list:');
  for (final line in library.displayList) {
    print(line);
  }
  print('');

  final books = library.items.whereType<Book>().toList();
  final stats = statsOf(books);
  print(
    'Stats: count=${stats.count}, avgPages=${stats.avgPages.toStringAsFixed(1)}',
  );
  print('');

  final states = <ShelfState>[
    const Empty(),
    Ready(books),
    const Broken('Shelf collapsed'),
  ];

  for (final state in states) {
    print(describe(state));
  }
}
