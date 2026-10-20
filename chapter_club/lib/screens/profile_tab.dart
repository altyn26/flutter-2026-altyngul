import 'package:flutter/material.dart';
import 'package:chapter_club/models/book.dart';
import 'package:chapter_club/models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.books,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Book> books;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final _groupPattern = RegExp(r'^[A-Za-z]{2,6}-\d{2,3}$');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _group;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // e.g. "Reset data" in the drawer clears the profile
    if (widget.profile.name != _name.text.trim()) {
      _name.text = widget.profile.name;
    }
    if (widget.profile.group != _group.text.trim()) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 2) return 'At least 2 characters';
    return null;
  }

  String? _validateGroup(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Group is required';
    if (!_groupPattern.hasMatch(text)) return 'Use a format like IT-21';
    return null;
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    widget.onProfileChanged(
      widget.profile.copyWith(
        name: _name.text.trim(),
        group: _group.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.name.trim();
    final lists = name.isEmpty
        ? 0
        : widget.books.where((book) => book.contains(name)).length;

    const modes = [
      (ThemeMode.system, 'System'),
      (ThemeMode.light, 'Light'),
      (ThemeMode.dark, 'Dark'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                textInputAction: TextInputAction.next,
                validator: _validateName,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _group,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  hintText: 'IT-21',
                ),
                textInputAction: TextInputAction.done,
                validator: _validateGroup,
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'You are on $lists lists',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        Text('Theme', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final (mode, label) in modes)
              ChoiceChip(
                label: Text(label),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeModeChanged(mode),
              ),
          ],
        ),
      ],
    );
  }
}
