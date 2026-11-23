import 'package:flutter_starter/l10n/l10n.dart';
import 'package:flutter_starter/shared/widgets/empty_view.dart';
import 'package:material_ui/material_ui.dart';

/// Full-screen "page not found" state used for unknown or invalid routes.
///
/// [onGoHome] is supplied by the router, so `shared/` stays unaware of the
/// app's routes.
class NotFoundView extends StatelessWidget {
  const new({required this.onGoHome, super.key});

  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: EmptyView(
        message: l10n.pageNotFound,
        action: FilledButton(onPressed: onGoHome, child: Text(l10n.goHome)),
      ),
    );
  }
}
