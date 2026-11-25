import 'package:flutter_starter/shared/widgets/empty_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the message and no action by default', (tester) async {
    await tester.pumpApp(const EmptyView(message: 'Nothing here'));

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('shows the optional action below the message', (tester) async {
    var calls = 0;
    await tester.pumpApp(
      EmptyView(
        message: 'Nothing here',
        action: TextButton(onPressed: () => calls++, child: const Text('Add')),
      ),
    );

    await tester.tap(find.text('Add'));

    expect(calls, 1);
  });
}
