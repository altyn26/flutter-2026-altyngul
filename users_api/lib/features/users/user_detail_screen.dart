import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Username'),
            subtitle: Text(user.username),
          ),
          ListTile(title: const Text('Email'), subtitle: Text(user.email)),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(user.phone),
            subtitle: Text(user.phoneDigits),
            onTap: () {}, // Practice 12: url_launcher
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(user.website ?? '—'),
            onTap: () {}, // Practice 12: url_launcher
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text('${a.street}, ${a.suite}'),
            subtitle: Text(
              '${a.city}, ${a.zipcode}\n'
              'lat ${a.geo.lat}, lng ${a.geo.lng}',
            ),
            isThreeLine: true,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.business),
            title: Text(user.company.name),
            subtitle: Text(user.company.catchPhrase),
          ),
        ],
      ),
    );
  }
}
