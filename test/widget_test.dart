import 'package:arrow_puzzle/main.dart';
import 'package:arrow_puzzle/services/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('bosh ekran ochiladi', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await Storage.init();
    await tester.pumpWidget(const ArrowPuzzleApp());
    expect(find.text('Arrow Puzzle'), findsOneWidget);
    expect(find.text('Bugungi boshqotirma'), findsOneWidget);
    expect(find.text('Kalendar'), findsOneWidget);
  });
}
