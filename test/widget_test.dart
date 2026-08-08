import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_command/main.dart';

void main() {
  testWidgets('HomeScreen にタイトルとゲーム開始ボタンが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MyApp()),
    );

    expect(find.textContaining('DAILY'), findsOneWidget);
    expect(find.text('ゲーム開始'), findsOneWidget);
  });
}
