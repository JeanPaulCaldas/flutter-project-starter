import 'package:flutter_starter/features/posts/domain/entities/post.dart';
import 'package:material_ui/material_ui.dart';

class PostTile extends StatelessWidget {
  const new({required this.post, required this.onTap, super.key});

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}
