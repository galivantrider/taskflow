import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow/main.dart';

void main() {
  testWidgets('TaskFlow app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TaskFlowApp(),
      ),
    );

    expect(find.text('TaskFlow'), findsWidgets);
  });
}