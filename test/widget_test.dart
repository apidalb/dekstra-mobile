import 'package:flutter_test/flutter_test.dart';
import 'package:dekstra/main.dart';

void main() {
  testWidgets('Dekstra smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DekstraApp());
    expect(find.text('DEKSTRA'), findsOneWidget);
  });
}