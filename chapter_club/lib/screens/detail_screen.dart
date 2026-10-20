import 'dart:async';

import 'package:chapter_club/routes.dart';
import 'package:flutter/material.dart';
import 'package:chapter_club/models/book.dart';
import 'package:chapter_club/models/countdown.dart';
import 'package:chapter_club/route_args.dart';
import 'package:chapter_club/utils/format.dart';
import 'package:chapter_club/widgets/empty_state.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Book _book;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _book = widget.args.book;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _countdownText(Countdown countdown) {
    return switch (countdown) {
      Upcoming(:final left) when left.inDays > 0 =>
        'In ${left.inDays} d ${left.inHours % 24} h',
      Upcoming(:final left) =>
        'In ${left.inHours} h ${left.inMinutes % 60} min',
      Started(:final passed) => 'Started ${passed.inMinutes} min ago',
      Ended() => 'Ended',
    };
  }

  Future<void> _toggleMembership() async {
    final name = widget.args.profileName.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Set your name in the profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              Navigator.pop(context);
              widget.args.onOpenProfile();
            },
          ),
        ),
      );
      return;
    }

    final joining = !_book.contains(name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(joining ? 'Borrow this book?' : 'Return this book?'),
        content: Text(_book.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(joining ? 'Borrow' : 'Return'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final updated = _book.copyWith(
      readers: joining
          ? [..._book.readers, name]
          : [
              for (final r in _book.readers)
                if (r != name) r,
            ],
    );
    setState(() => _book = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _edit() async {
    final updated = await Navigator.pushNamed<Book>(
      context,
      Routes.form,
      arguments: FormArgs(book: _book),
    );
    if (updated == null || !mounted) return;
    setState(() => _book = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this book?'),
        content: Text(_book.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.args.onDelete(_book);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final name = widget.args.profileName.trim();
    final isMember = name.isNotEmpty && _book.contains(name);
    final canAct = isMember || !_book.isFull;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _edit();
                if (value == 'delete') _confirmDelete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/cover.jpg', fit: BoxFit.cover),
                  Center(
                    child: CircleAvatar(
                      radius: 32,
                      child: Icon(_book.genre.icon, size: 32),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: _Tag(text: _book.genre.label),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _Tag(text: _countdownText(_book.countdown)),
                  ),
                ],
              ),
            ),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Readers (${_book.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(_book.title, style: textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text('Date: ${formatDate(_book.meetingDate)}'),
                      Text('Place: ${_book.place}'),
                      Text(
                        'Copies: ${_book.places.taken} taken, '
                        '${_book.places.free} free',
                      ),
                      if (_book.note != null) ...[
                        const SizedBox(height: 12),
                        Text(_book.note!), // safe: checked for null above
                      ],
                    ],
                  ),
                  _book.readers.isEmpty
                      ? const EmptyState(
                          icon: Icons.person_off,
                          message: 'Nobody has borrowed it yet',
                        )
                      : ListView(
                          children: [
                            for (final reader in _book.readers)
                              ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(
                                  reader == name ? '$reader (You)' : reader,
                                ),
                                tileColor: reader == name
                                    ? scheme.primaryContainer
                                    : null,
                              ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              onPressed: canAct ? _toggleMembership : null,
              child: Text(isMember ? 'Return' : 'Borrow'),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
