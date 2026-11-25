import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/app/routes.dart';
import 'package:flutter_starter/features/posts/domain/entities/post.dart';
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

    // A failed refresh keeps the previous list, so report it in a SnackBar.
    ref.listen(postsListProvider, (_, next) {
      if (next case AsyncError(
        :final error,
        hasValue: true,
        isLoading: false,
      )) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(errorMessage(error, l10n))));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postsTitle),
        actions: const [ThemeModeMenuButton()],
      ),
      body: switch (posts) {
        // Data first: keep showing it while refreshing and after a failed
        // refresh.
        AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: value.isEmpty
              ? _EmptyPosts(message: l10n.emptyPosts)
              : _PostsList(posts: value),
        ),
        // No data: an error is shown only while no retry is in flight.
        AsyncError(:final error, isLoading: false) => ErrorView(
          message: errorMessage(error, l10n),
          onRetry: () => ref.invalidate(postsListProvider),
        ),
        // First load, or a retry after an error.
        _ => const LoadingView(),
      },
    );
  }

  /// Refetches the list. Never throws: a failure lands in the provider's
  /// state, where `build` reports it.
  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(postsListProvider);
    try {
      await ref.read(postsListProvider.future);
    } on Object {
      // Reported through postsListProvider's AsyncError (see ref.listen).
    }
  }
}

class _PostsList extends StatelessWidget {
  const new({required this.posts});

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Scrollable even when short, so pull-to-refresh always works.
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostTile(
          post: post,
          onTap: () => context.push(AppRoutes.postDetailPath(post.id)),
        );
      },
    );
  }
}

/// [EmptyView] inside a scrollable, so it can be pulled to refresh.
class _EmptyPosts extends StatelessWidget {
  const new({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyView(message: message),
        ),
      ],
    );
  }
}
