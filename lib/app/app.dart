import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/app/router.dart';
import 'package:flutter_starter/app/theme.dart';
import 'package:flutter_starter/features/settings/presentation/theme_mode_controller.dart';
import 'package:flutter_starter/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// Root widget: router, themes and localization.
class App extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeControllerProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => context.l10n.appTitle,
    );
  }
}
