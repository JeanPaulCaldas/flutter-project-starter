import 'package:flutter_starter/shared/widgets/error_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the message and calls onRetry once when tapped', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpApp(ErrorView(message: 'boom', onRetry: () => calls++));

    expect(find.text('boom'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(calls, 1);
  });

  testWidgets('localizes the retry button in Spanish', (tester) async {
    await tester.pumpApp(
      ErrorView(message: 'boom', onRetry: () {}),
      locale: const Locale('es'),
    );

    expect(find.text('Reintentar'), findsOneWidget);
  });
}
