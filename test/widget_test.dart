import 'package:flutter_test/flutter_test.dart';

import 'package:about_me_portfolio/main.dart';

void main() {
  testWidgets('Portfolio hero renders in English by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PortfolioApp());

    expect(find.text('Portfolio'), findsOneWidget);
    expect(find.text('Hello, I am Dávid'), findsOneWidget);
    expect(
      find.text(
          'Hello, this chat responds as Dávid Schwartz’s portfolio agent.'),
      findsOneWidget,
    );
  });

  testWidgets('Language switch updates the portfolio copy',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PortfolioApp());

    await tester.tap(find.text('SK'));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Dobrý deň, som Dávid'), findsOneWidget);
    expect(find.text('Čomu sa venujem'), findsOneWidget);
    expect(
      find.text('Dobrý deň, odpovedám ako agent portfólia Dávida Schwartza.'),
      findsOneWidget,
    );
  });
}
