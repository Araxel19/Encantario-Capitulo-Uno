import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encantario_capitulo_uno/main.dart';

void main() {
  testWidgets('EncantarioApp loads splash and navigates to home', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const EncantarioApp());
    expect(find.textContaining('ENCANTARIO'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.textContaining('Progreso'), findsOneWidget);
  });
}
