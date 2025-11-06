// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:ouruniverse/src/app.dart';
import 'package:ouruniverse/src/data/in_memory_repo.dart';

void main() {
  testWidgets('Together app smoke test', (tester) async {
  await tester.pumpWidget(App(repositoryOverride: InMemoryCheckInRepository()));
  await tester.pumpAndSettle();

    // Verify home renders with navigation labels
    expect(find.text('Together'), findsOneWidget);
    expect(find.text('Check-In'), findsOneWidget);
    expect(find.text('Partner'), findsOneWidget);
    expect(find.text('Shared'), findsOneWidget);
    // Depending on onboarding, either onboarding CTA or check-in will appear.
    expect(
      find.text('Daily Check-In').hitTestable().evaluate().isNotEmpty ||
          find.text("Let’s set up Together").hitTestable().evaluate().isNotEmpty,
      true,
    );
  });
}
