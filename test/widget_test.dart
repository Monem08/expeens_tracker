import 'package:flutter_test/flutter_test.dart';

import 'package:expeens_tracker/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpeensTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byTooltip('Increment'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Home renders core widgets', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpeensTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('Expeens Tracker'), findsOneWidget);
    expect(find.text('Total balance'), findsOneWidget);
    expect(find.text('Add expense'), findsOneWidget);
    expect(find.text('Income'), findsWidgets);
  });
}
