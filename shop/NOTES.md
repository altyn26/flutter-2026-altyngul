# Practice 9 — Put It High, Subscribe Low

## Level 1 — Lift it up
Total in the badge, the honest way:
- Constructors touched: 2 — BooksScreen (new `total`, only passes it on), CartBadge (new `total`)
- Files touched: 3 — main.dart, books_screen.dart, cart_badge.dart

Rebuilds after one tap on Add: 8 lines (1 × BooksScreen build + 6 × row) + 1 × badge build.
setState in Shell marks everything under it dirty.