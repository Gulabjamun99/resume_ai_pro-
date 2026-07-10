import 'package:flutter_test/flutter_test.dart';
import 'package:resume_ai_pro/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ResumeAIApp());
    expect(find.text('ResumeAI Pro'), findsWidgets);
  });
}
