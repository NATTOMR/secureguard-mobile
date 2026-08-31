import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securepulse_mobile/app.dart';

void main() {
  testWidgets('SecurePulse Mobile app pump test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SecurePulseApp(),
      ),
    );
    expect(find.byType(SecurePulseApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
