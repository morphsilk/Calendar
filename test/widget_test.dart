import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mood_calendar/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Инициализация моковых SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Запуск тестируемого приложения
    await tester.pumpWidget(MoodCalendarApp(prefs: prefs));

    // Проверка начального состояния
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Нажатие на кнопку '+'
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Проверка увеличенного значения
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
