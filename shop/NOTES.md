# Practice 9 — Put It High, Subscribe Low

## Level 1 — Lift it up
Total in the badge, the honest way:
- Constructors touched: 2 — BooksScreen (new `total`, only passes it on), CartBadge (new `total`)
- Files touched: 3 — main.dart, books_screen.dart, cart_badge.dart

Rebuilds after one tap on Add: 8 lines (1 × BooksScreen build + 6 × row) + 1 × badge build.
setState in Shell marks everything under it dirty.

## Level 2 - A model with no widgets
Cart imports only foundation.dart. 'items' is List.unmodifiable —
`cart.items.add(...)` throws `Cannot add to an unmodifiable list`.
A BuildContext field in Cart would be impossible — no context before runApp.

## Level 3 — Two provider errors
**Loud** (`context.watch<Cart>().add(b)` in onPressed):
> Tried to listen to a value exposed with provider, from outside of the widget tree.
>
> This is likely caused by an event handler (like a button's onPressed) that called
> Provider.of without passing `listen: false`.
>
> To fix, write:
> Provider.of<Cart>(context, listen: false);

**Silent** (`context.read<Cart>().count` in the badge build):
no error, app runs, the badge is frozen at 0 forever —
nobody said "I depend on the cart".

Rule: watch is a verb of build, read is a verb of onPressed.

## Level 4 — Rebuild counts (3 presses on +)
| Badge uses | badge build |
|---|---|
| watch  | 3 |
| select | 0 (removing a book → 1) |

Subscribe where the value is shown, not where it is convenient.

## Where does it live?
- **Cart** — provided: two screens and the badge need it, it must survive navigation.
- **Search text** — ephemeral: only the Books screen uses it.
- **Total expanded/collapsed** — ephemeral: a UI detail of one widget.
- **Theme mode** — provided (or lifted above MaterialApp): MaterialApp reads it, a switch on another screen changes it.
