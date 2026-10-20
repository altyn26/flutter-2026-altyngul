import 'package:flutter/material.dart';
import 'package:chapter_club/route_args.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  Widget build(BuildContext context) {
    final book = args.book;
    return Scaffold(
      appBar: AppBar(title: Text(book.title, maxLines: 1)),
      body: Center(child: Text(book.title)),
    );
  }
}
