import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:shop/main.dart';
import 'package:shop/models/cart.dart';

void main() {
  testWidgets('Books screen shows Add buttons', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()),
    );
    expect(find.text('Add'), findsWidgets);
  });
}
