import 'package:flutter_test/flutter_test.dart';
import 'package:agenda_app/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const AgendaApp());
    expect(find.text('Minha Agenda'), findsOneWidget);
  });
}
