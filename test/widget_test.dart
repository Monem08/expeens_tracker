import 'package:flutter_test/flutter_test.dart';

import 'package:expeens_tracker/main.dart';

void main() {
  testWidgets('App boots to Home with MintyExpense header', (tester) async {
    await tester.pumpWidget(const ExpeensTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('MintyExpense'), findsWidgets);
    expect(find.text('TOTAL BALANCE'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
  });
}
