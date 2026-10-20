import 'package:flutter/material.dart';
import 'package:chapter_club/data/seed_books.dart';
import 'package:chapter_club/widgets/book_card.dart';

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
        body: SafeArea(
          child: ListView(
            children: [
              for (final book in seedBooks())
                BookCard(book: book, onTap: () {}, onFavourite: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
