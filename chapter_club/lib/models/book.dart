import 'genre.dart';

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.genre,
    required this.meetingDate,
    required this.copies,
    required this.readers,
    required this.isOnline,
    required this.place,
    this.note,
    this.favourite = false,
  });

  final String id;
  final String title;
  final Genre genre;
  final DateTime meetingDate;
  final int copies;
  final List<String> readers;
  final bool isOnline;
  final String place;
  final String? note;
  final bool favourite;
}
