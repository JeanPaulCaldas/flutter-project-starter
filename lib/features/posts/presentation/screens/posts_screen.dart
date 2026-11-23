import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/app/router.dart';
import 'package:flutter_starter/features/posts/presentation/providers/posts_providers.dart';
import 'package:flutter_starter/features/posts/presentation/widgets/post_tile.dart';
import 'package:flutter_starter/features/settings/presentation/widgets/theme_mode_menu_button.dart';
import 'package:flutter_starter/l10n/l10n.dart';
import 'package:flutter_starter/shared/widgets/empty_view.dart';
import 'package:flutter_starter/shared/widgets/error_view.dart';
import 'package:flutter_starter/shared/widgets/loading_view.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class PostsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final posts = ref.watch(postsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postsTitle),
        actions: const [ThemeModeMenuButton()],
      ),
      body: switch (posts) {
        AsyncData(:final value) when value.isEmpty => EmptyView(
          message: l10n.emptyPosts,
        ),
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.refresh(postsListProvider.future),
          child: ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              final post = value[index];
              return PostTile(
                post: post,
                onTap: () => context.push(AppRoutes.postDetailPath(post.id)),
              );
            },
          ),
        ),
        AsyncError(:final error) => ErrorView(
          message: errorMessage(error, l10n),
          onRetry: () => ref.invalidate(postsListProvider),
        ),
        _ => const LoadingView(),
      },
    );
  }
}
