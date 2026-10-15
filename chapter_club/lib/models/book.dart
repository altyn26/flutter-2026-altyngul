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

  Book copyWith({
    String? title,
    String? place,
    bool? favourite,
    String? note,
    String? id,
    Genre? genre,
    DateTime? meetingDate,
    int? copies,
    List<String>? readers,
    bool? isOnline,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      favourite: favourite ?? this.favourite,
      genre: genre ?? this.genre,
      meetingDate: meetingDate ?? this.meetingDate,
      copies: copies ?? this.copies,
      readers: readers ?? this.readers,
      isOnline: isOnline ?? this.isOnline,
      place: place ?? this.place,
      note: note ?? this.note,
    );
  }
}
