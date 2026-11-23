import 'package:flutter_starter/app/routes.dart';
import 'package:flutter_starter/features/posts/presentation/screens/post_detail_screen.dart';
import 'package:flutter_starter/features/posts/presentation/screens/posts_screen.dart';
import 'package:flutter_starter/shared/widgets/not_found_view.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

/// The app's [GoRouter]; kept alive so navigation state survives rebuilds.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.posts,
        builder: (context, state) => const PostsScreen(),
      ),
      GoRoute(
        path: AppRoutes.postDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) return const NotFoundView();
          return PostDetailScreen(postId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => const NotFoundView(),
  );
  ref.onDispose(router.dispose);
  return router;
}
