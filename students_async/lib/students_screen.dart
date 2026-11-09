import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

// Level 2: four states by hand. Level 5: the Save button.
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students; // null = not loaded yet
  Object? _error; // non-null = failed
  final _api = FakeApi(); // FakeApi(empty: true) -> the empty state
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // initState is synchronous: we start the load, we do not await it.
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _save(BuildContext context) async {
    setState(() => _saving = true);
    try {
      await _api.save(_students!.length);
      if (!context.mounted) return;
      Navigator.pop(context);
    } on StateError catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _body() {
    if (_error != null) return ErrorView(onRetry: _load);
    if (_students == null) return const LoadingView();
    if (_students!.isEmpty) return const EmptyView();
    return StudentList(_students!);
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _students != null && !_saving;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students (by hand)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        onPressed: canSave ? () => _save(context) : null,
        child: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
      ),
    );
  }
}
