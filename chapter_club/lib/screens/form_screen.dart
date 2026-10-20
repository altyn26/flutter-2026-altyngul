import 'package:flutter/material.dart';
import 'package:chapter_club/models/book.dart';
import 'package:chapter_club/models/genre.dart';
import 'package:chapter_club/route_args.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _place;
  late final TextEditingController _copies;
  late final TextEditingController _note;

  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _copiesFocus = FocusNode();
  final _noteFocus = FocusNode();

  Genre? _genre;
  late bool _isOnline;
  late DateTime _date;

  bool get _isEditing => widget.args.book != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.args.book ?? Book.empty();
    _title = TextEditingController(text: initial.title);
    _place = TextEditingController(text: initial.place);
    _copies = TextEditingController(text: initial.copies.toString());
    _note = TextEditingController(text: initial.note ?? '');
    _genre = widget.args.book?.genre;
    _isOnline = initial.isOnline;
    _date = initial.meetingDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _copies.dispose();
    _note.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _copiesFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 3) return 'At least 3 characters';
    if (text.length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validatePlace(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return _isOnline ? 'Link is required' : 'Place is required';
    }
    if (_isOnline && !text.contains('://')) return 'Link must contain ://';
    return null;
  }

  String? _validateCopies(String? value) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null) return 'Enter a whole number';
    if (number < 1 || number > 500) return 'From 1 to 500';
    final current = widget.args.book?.count ?? 0;
    if (number < current) return 'Not below current readers ($current)';
    return null;
  }

  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final old = widget.args.book;
    final note = _note.text.trim();
    final book = Book(
      id: old?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      genre: _genre ?? Genre.values.first,
      meetingDate: _date,
      copies: int.parse(_copies.text.trim()),
      readers: old?.readers ?? const [],
      isOnline: _isOnline,
      place: _place.text.trim(),
      note: note.isEmpty ? null : note,
      favourite: old?.favourite ?? false,
    );
    Navigator.pop(context, book);
  }

  void _dismissKeyboard(PointerDownEvent _) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit book' : 'New book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                decoration: const InputDecoration(labelText: 'Title'),
                maxLength: 60,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                onTapOutside: _dismissKeyboard,
                validator: _validateTitle,
              ),
              DropdownButtonFormField<Genre>(
                initialValue: _genre,
                decoration: const InputDecoration(labelText: 'Genre'),
                items: [
                  for (final genre in Genre.values)
                    DropdownMenuItem(value: genre, child: Text(genre.label)),
                ],
                onChanged: (value) => setState(() => _genre = value),
                validator: (value) => value == null ? 'Choose a genre' : null,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online meeting'),
                value: _isOnline,
                onChanged: (value) => setState(() => _isOnline = value),
              ),
              TextFormField(
                controller: _place,
                focusNode: _placeFocus,
                decoration: InputDecoration(
                  labelText: _isOnline ? 'Meeting link' : 'Place',
                ),
                keyboardType: _isOnline
                    ? TextInputType.url
                    : TextInputType.text,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _copiesFocus.requestFocus(),
                onTapOutside: _dismissKeyboard,
                validator: _validatePlace,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _copies,
                focusNode: _copiesFocus,
                decoration: const InputDecoration(labelText: 'Copies'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _noteFocus.requestFocus(),
                onTapOutside: _dismissKeyboard,
                validator: _validateCopies,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _note,
                focusNode: _noteFocus,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                onTapOutside: _dismissKeyboard,
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
