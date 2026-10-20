import 'package:flutter/material.dart';
import 'package:chapter_club/data/seed_books.dart';
import 'package:chapter_club/screens/book_list_tab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chapter Club',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Chapter Club')),
        body: BookListTab(
          books: seedBooks(),
          onToggleFavourite: (_) {},
          onOpen: (_) {},
        ),
      ),
    );
  }
}
