import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_model.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  bool _saving = false;

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _validateUsername(String? v) {
    final value = v?.trim() ?? '';
    if (value.length < 3) return 'At least 3 characters';
    if (value.contains(' ')) return 'No spaces';
    return null;
  }

  String? _validateEmail(String? v) =>
      _emailRe.hasMatch(v?.trim() ?? '') ? null : 'Invalid email';

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(
      () => _saving = true,
    ); // before await → a double tap sends one POST
    final model = context.read<UsersModel>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await model.add(
        User.draft(
          name: _name.text.trim(),
          username: _username.text.trim(),
          email: _email.text.trim(),
        ),
      );
      navigator.pop();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_describe(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _describe(ApiException e) => switch (e) {
    NoConnectionException() => 'No connection. Try again.',
    ServerException(:final status) => 'Server error ($status). Try again.',
    BadResponseException() => 'Unexpected response from the server.',
    NotFoundException() || UnauthorizedException() => 'Request rejected.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New user')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: _required,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: _validateUsername,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
