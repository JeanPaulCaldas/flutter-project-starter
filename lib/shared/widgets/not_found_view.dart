import 'package:flutter_starter/l10n/l10n.dart';
import 'package:flutter_starter/shared/widgets/empty_view.dart';
import 'package:material_ui/material_ui.dart';

/// Full-screen "page not found" state used for unknown or invalid routes.
class NotFoundView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: EmptyView(message: context.l10n.pageNotFound),
    );
  }
}
