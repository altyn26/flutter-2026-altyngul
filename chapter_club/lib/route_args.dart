import 'package:flutter/material.dart';
import 'package:chapter_club/models/book.dart';

class DetailArgs {
  const DetailArgs({
    required this.book,
    required this.profileName,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Book book;
  final String profileName;
  final void Function(Book updated) onChanged;
  final void Function(Book book) onDelete;
  final VoidCallback onOpenProfile;
}
