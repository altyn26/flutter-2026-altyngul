import 'package:flutter/material.dart';
import 'package:chapter_club/models/book.dart';
import 'package:chapter_club/models/genre.dart';
import 'package:chapter_club/route_args.dart';
import 'package:chapter_club/utils/format.dart';

typedef _Snapshot = ({
  String title,
  String place,
  String copies,
  String note,
  Genre? genre,
  bool online,
  DateTime? date,
  TimeOfDay? time,
});

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
  late final TextEditingController _dateText;
  late final TextEditingController _timeText;

  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _copiesFocus = FocusNode();
  final _noteFocus = FocusNode();

  Genre? _genre;
  late bool _isOnline;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;

  late final _Snapshot _initial;

  bool get _isEditing => widget.args.book != null;

  _Snapshot get _current => (
    title: _title.text,
    place: _place.text,
    copies: _copies.text,
    note: _note.text,
    genre: _genre,
    online: _isOnline,
    date: _date,
    time: _time,
  );

  bool get _dirty => _current != _initial;

  @override
  void initState() {
    super.initState();
    final old = widget.args.book;
    final initial = old ?? Book.empty();
    _title = TextEditingController(text: initial.title);
    _place = TextEditingController(text: initial.place);
    _copies = TextEditingController(text: initial.copies.toString());
    _note = TextEditingController(text: initial.note ?? '');
    _genre = old?.genre;
    _isOnline = initial.isOnline;
    if (old != null) {
      final d = old.meetingDate;
      _date = DateTime(d.year, d.month, d.day);
      _time = TimeOfDay(hour: d.hour, minute: d.minute);
    }
    _dateText = TextEditingController(
      text: _date == null ? '' : formatDay(_date!),
    );
    _timeText = TextEditingController(
      text: _time == null ? '' : formatTime(_time!.hour, _time!.minute),
    );
    _initial = _current;
  }

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _copies.dispose();
    _note.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _copiesFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null || !mounted) return; // Cancel keeps the old value
    setState(() {
      _date = picked;
      _dateText.text = formatDay(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return; // Cancel keeps the old value
    setState(() {
      _time = picked;
      _timeText.text = formatTime(picked.hour, picked.minute);
    });
  }

  DateTime? _combined() {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
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

  String? _validateDate(String? value) {
    if (_date == null) return 'Pick a date';
    return null;
  }

  String? _validateTime(String? value) {
    if (_time == null) return 'Pick a time';
    final combined = _combined();
    if (!_isEditing && combined != null && !combined.isAfter(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving) return; // a double tap does not save twice
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final old = widget.args.book;
    final note = _note.text.trim();
    final book = Book(
      id: old?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      genre: _genre ?? Genre.values.first,
      meetingDate: _combined() ?? DateTime.now(),
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

  Future<void> _askDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _askDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isEditing ? 'Edit book' : 'New book')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: () => setState(() {}),
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
                  controller: _dateText,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _pickDate,
                  validator: _validateDate,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _timeText,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: _pickTime,
                  validator: _validateTime,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _note,
                  focusNode: _noteFocus,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
