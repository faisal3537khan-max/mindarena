import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mindarena/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MindArena boots into splash', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MindArenaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('MINDARENA'), findsWidgets);
  });
}
