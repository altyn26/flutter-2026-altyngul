import 'package:flutter/material.dart';
import 'package:chapter_club/data/seed_books.dart';
import 'package:chapter_club/models/book.dart';
import 'package:chapter_club/models/profile.dart';
import 'package:chapter_club/route_args.dart';
import 'package:chapter_club/routes.dart';
import 'package:chapter_club/screens/book_list_tab.dart';
import 'package:chapter_club/screens/favourites_tab.dart';
import 'package:chapter_club/screens/profile_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  List<Book> _books = seedBooks();
  Profile _profile = const Profile.empty();

  void _toggleFavourite(Book book) {
    setState(() {
      _books = [
        for (final b in _books)
          b.id == book.id ? b.copyWith(favourite: !b.favourite) : b,
      ];
    });
  }

  void _replaceBook(Book updated) {
    setState(() {
      _books = [for (final b in _books) b.id == updated.id ? updated : b];
    });
  }

  void _deleteBook(Book book) {
    setState(() {
      _books = [
        for (final b in _books)
          if (b.id != book.id) b,
      ];
    });
  }

  void _updateProfile(Profile profile) {
    setState(() => _profile = profile);
  }

  void _openDetail(Book book) {
    Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: DetailArgs(
        book: book,
        profileName: _profile.name,
        onChanged: _replaceBook,
        onDelete: _deleteBook,
        onOpenProfile: () => _selectTab(2),
      ),
    );
  }

  Future<void> _addBook() async {
    final book = await Navigator.pushNamed<Book>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (book == null || !mounted) return;
    setState(() => _books = [..._books, book]);
  }

  void _selectTab(int index) {
    setState(() => _tab = index);
  }

  Future<void> _showAbout() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Text('Chapter Club: a small app for a reading club.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text('Books will be restored and the profile cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _books = seedBooks();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      BookListTab(
        books: _books,
        onToggleFavourite: _toggleFavourite,
        onOpen: _openDetail,
      ),
      FavouritesTab(
        books: _books,
        onToggleFavourite: _toggleFavourite,
        onOpen: _openDetail,
      ),
      ProfileTab(
        profile: _profile,
        books: _books,
        themeMode: widget.themeMode,
        onProfileChanged: _updateProfile,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Chapter Club')),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _showAbout();
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Reset data'),
                onTap: () {
                  Navigator.pop(context);
                  _resetData();
                },
              ),
            ],
          ),
        ),
      ),
      body: tabs[_tab],
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: _addBook,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Books'),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
