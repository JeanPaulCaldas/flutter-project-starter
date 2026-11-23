import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/features/settings/presentation/theme_mode_controller.dart';
import 'package:flutter_starter/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// App bar menu for choosing the theme mode.
class ThemeModeMenuButton extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(themeModeControllerProvider);

    return PopupMenuButton<ThemeMode>(
      tooltip: l10n.themeMenuTooltip,
      icon: const Icon(Icons.brightness_6_outlined),
      initialValue: current,
      onSelected: ref.read(themeModeControllerProvider.notifier).setThemeMode,
      itemBuilder: (context) => [
        PopupMenuItem(value: ThemeMode.system, child: Text(l10n.themeSystem)),
        PopupMenuItem(value: ThemeMode.light, child: Text(l10n.themeLight)),
        PopupMenuItem(value: ThemeMode.dark, child: Text(l10n.themeDark)),
      ],
    );
  }
}
