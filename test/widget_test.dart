import 'package:flutter_test/flutter_test.dart';
import 'package:desktra/main.dart';

void main() {
  testWidgets('Desktra smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DesktraApp());
    expect(find.text('DESKTRA'), findsOneWidget);
  });
}