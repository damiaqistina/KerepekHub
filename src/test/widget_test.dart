import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kerepekhub/main.dart';
import 'package:kerepekhub/providers/cart_provider.dart';
import 'package:kerepekhub/providers/feedback_provider.dart';

void main() {
  testWidgets('CatalogScreen renders KerepekHub menu items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => FeedbackProvider()),
        ],
        child: const KerepekHubApp(),
      ),
    );

    expect(find.text('All products'), findsOneWidget);
    expect(find.text('Crunchy Spicy Cheese'), findsOneWidget);
  });
}