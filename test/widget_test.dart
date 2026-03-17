import 'package:flutter_test/flutter_test.dart';

import 'package:about_me_portfolio/main.dart';

void main() {
  testWidgets('Portfolio hero renders', (WidgetTester tester) async {
    await tester.pumpWidget(const PortfolioApp());

    expect(find.text('Flutter Portfolio'), findsOneWidget);
    expect(find.text('Ahoj, som Tvoje Meno'), findsOneWidget);
  });
}
