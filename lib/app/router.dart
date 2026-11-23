/// Route paths used across the app.
abstract final class AppRoutes {
  static const posts = '/';
  static const postDetail = '/posts/:id';

  static String postDetailPath(int id) => '/posts/$id';
}
