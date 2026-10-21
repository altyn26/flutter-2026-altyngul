import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthCtrl]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _unfocus(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      setState(() => _done = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Account created')));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _birth = picked;
      final d = picked.day.toString().padLeft(2, '0');
      final m = picked.month.toString().padLeft(2, '0');
      _birthCtrl.text = '$d.$m.${picked.year}';
    });
  }

  void _startOver() {
    setState(() {
      for (final c in [_name, _email, _password, _confirm, _birthCtrl]) {
        c.clear();
      }
      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _done ? _buildSummary() : _buildForm(),
    ),
  );

  Widget _buildSummary() => Column(
    children: [
      SummaryCard(
        name: _name.text.trim(),
        email: _email.text.trim(),
        group: _group ?? '',
        birthDate: _birthCtrl.text,
      ),
      const SizedBox(height: 16),
      TextButton(onPressed: _startOver, child: const Text('Start over')),
    ],
  );

  Widget _buildForm() => Form(
    key: _formKey,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Column(
      children: [
        TextFormField(
          controller: _name,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _emailFocus.requestFocus(),
          onTapOutside: _unfocus,
          decoration: const InputDecoration(labelText: 'Name'),
          validator: (v) =>
              (v ?? '').trim().length < 2 ? 'Name is too short' : null,
        ),
        TextFormField(
          controller: _email,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          onTapOutside: _unfocus,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'name@kbtu.kz',
          ),
          validator: (v) {
            final s = (v ?? '').trim();
            final at = s.indexOf('@');
            if (at < 1 || !s.substring(at).contains('.')) {
              return 'Email looks wrong';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _password,
          obscureText: true,
          textInputAction: TextInputAction.next,
          onTapOutside: _unfocus,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Password',
            helperText: 'At least 8 characters',
          ),
          validator: (v) =>
              (v ?? '').length < 8 ? 'Password is too short' : null,
        ),
        Text('${_password.text.length} of 8'),
        TextFormField(
          controller: _confirm,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _signUp(),
          onTapOutside: _unfocus,
          decoration: const InputDecoration(labelText: 'Confirm password'),
          validator: (v) =>
              v != _password.text ? 'Passwords do not match' : null,
        ),
        DropdownButtonFormField<String>(
          initialValue: _group,
          decoration: const InputDecoration(labelText: 'Group'),
          items: [
            for (final g in groups) DropdownMenuItem(value: g, child: Text(g)),
          ],
          onChanged: (g) => setState(() => _group = g),
          validator: (g) => g == null ? 'Choose a group' : null,
        ),
        TextFormField(
          controller: _birthCtrl,
          readOnly: true,
          onTap: _pickDate,
          decoration: const InputDecoration(
            labelText: 'Date of birth',
            suffixIcon: Icon(Icons.calendar_today),
          ),
          validator: (_) => _birth == null ? 'Choose a date' : null,
        ),
        CheckboxListTile(
          value: _agreed,
          onChanged: (v) => setState(() => _agreed = v ?? false),
          title: const Text('I agree to the rules'),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _agreed ? _signUp : null,
          child: const Text('Sign up'),
        ),
      ],
    ),
  );
}
