import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/features/posts/presentation/providers/posts_providers.dart';
import 'package:flutter_starter/l10n/l10n.dart';
import 'package:flutter_starter/shared/widgets/error_view.dart';
import 'package:flutter_starter/shared/widgets/loading_view.dart';
import 'package:material_ui/material_ui.dart';

class PostDetailScreen extends ConsumerWidget {
  const new({required this.postId, super.key});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final post = ref.watch(postDetailProvider(postId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.postDetailTitle)),
      body: switch (post) {
        // Same order as PostsScreen: data, then a settled error, then
        // loading (first load, or a retry after an error).
        AsyncValue(:final value?) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(value.body),
            ],
          ),
        ),
        AsyncError(:final error, isLoading: false) => ErrorView(
          message: errorMessage(error, l10n),
          onRetry: () => ref.invalidate(postDetailProvider(postId)),
        ),
        _ => const LoadingView(),
      },
    );
  }
}
