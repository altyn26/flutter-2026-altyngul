import 'package:flutter/material.dart';

enum Genre {
  detective('Detective', Icons.search),
  romance('Romance', Icons.favorite),
  horror('Horror', Icons.nightlight),
  classics('Classics', Icons.history),
  fantasy('Fantasy', Icons.castle);

  const Genre(this.label, this.icon);

  final String label;
  final IconData icon;
}
