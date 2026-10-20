import 'genre.dart';
import 'countdown.dart';

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.genre,
    required this.meetingDate,
    required this.copies,
    required List<String> readers,
    required this.isOnline,
    required this.place,
    this.note,
    this.favourite = false,
  }) : _readers = readers;

  final String id;
  final String title;
  final Genre genre;
  final DateTime meetingDate;
  final int copies;
  final List<String> _readers;
  final bool isOnline;
  final String place;
  final String? note;
  final bool favourite;

  List<String> get readers => List.unmodifiable(_readers);

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

  int get count => readers.length;
  int get free => copies - count;
  bool get isFull => free <= 0;
  bool get isPast => meetingDate.isBefore(DateTime.now());
  bool contains(String name) => readers.contains(name);

  ({int taken, int free}) get places => (taken: count, free: free);

  Countdown get countdown {
    final now = DateTime.now();
    final end = meetingDate.add(const Duration(hours: 2));
    if (now.isBefore(meetingDate)) {
      return Upcoming(meetingDate.difference(now));
    }
    if (now.isBefore(end)) {
      return Started(now.difference(meetingDate));
    }
    return const Ended();
  }

  Book.empty()
    : id = '',
      title = '',
      genre = Genre.fantasy,
      meetingDate = DateTime.now().add(const Duration(days: 1)),
      copies = 1,
      _readers = const [],
      isOnline = false,
      place = '',
      note = null,
      favourite = false;
}
