import 'package:flutter/material.dart';

import 'genre.dart';

Color genreColor(Genre genre, ColorScheme scheme) {
  return switch (genre) {
    Genre.detective => scheme.primary,
    Genre.classics => scheme.primaryContainer,
    Genre.fantasy => scheme.tertiaryContainer,
    Genre.horror => scheme.inversePrimary,
    Genre.romance => scheme.secondary,
  };
}
