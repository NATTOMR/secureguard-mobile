import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secureguard_mobile/main.dart';

void main() {
  testWidgets('SecureGuard Mobile app pump test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SecureGuardApp(),
      ),
    );
    expect(find.byType(SecureGuardApp), findsOneWidget);
  });
}
