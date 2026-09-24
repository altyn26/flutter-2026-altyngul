import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String university;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Замените путь на свою фотографию из assets/images/.
        ClipOval(
          child: Image.asset(
            'assets/images/photo.jpg',
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: 12)),
        Text(
          name,
          style: textTheme.headlineSmall?.copyWith(
            fontFamily: 'MyFont',
            color: colorScheme.onSurface,
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: 4)),
        Text(
          university,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
