import 'package:flutter_test/flutter_test.dart';
import 'package:technitian_panal/main.dart';
import 'package:technitian_panal/screens/welcome_screen.dart';

void main() {
  testWidgets('App builds and shows welcome screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TechnicianApp());
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
