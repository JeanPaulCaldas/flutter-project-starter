import 'package:flutter_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_starter/features/posts/presentation/widgets/post_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  const post = Post(id: 1, userId: 1, title: 'Hello post', body: 'Body text');

  testWidgets('renders the title and the body excerpt', (tester) async {
    await tester.pumpApp(
      Scaffold(
        body: PostTile(post: post, onTap: () {}),
      ),
    );

    expect(find.text('Hello post'), findsOneWidget);
    expect(find.text('Body text'), findsOneWidget);
  });

  testWidgets('calls onTap once when tapped', (tester) async {
    var taps = 0;
    await tester.pumpApp(
      Scaffold(
        body: PostTile(post: post, onTap: () => taps++),
      ),
    );

    await tester.tap(find.text('Hello post'));

    expect(taps, 1);
  });

  testWidgets('truncates a long title and body to two lines', (tester) async {
    final long = List.filled(200, 'word').join(' ');
    await tester.pumpApp(
      Scaffold(
        body: PostTile(
          post: Post(id: 2, userId: 1, title: long, body: long),
          onTap: () {},
        ),
      ),
    );

    final texts = tester.widgetList<Text>(find.text(long));
    expect(texts.map((t) => t.maxLines), everyElement(2));
  });
}
