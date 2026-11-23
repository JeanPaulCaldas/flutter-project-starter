// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All posts.

@ProviderFor(postsList)
final postsListProvider = PostsListProvider._();

/// All posts.

final class PostsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          FutureOr<List<Post>>
        >
    with $FutureModifier<List<Post>>, $FutureProvider<List<Post>> {
  /// All posts.
  PostsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postsListHash();

  @$internal
  @override
  $FutureProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Post>> create(Ref ref) {
    return postsList(ref);
  }
}

String _$postsListHash() => r'ff22fa9f76d4803fa408199372fbf9744bcc7209';

/// A single post by [id].

@ProviderFor(postDetail)
final postDetailProvider = PostDetailFamily._();

/// A single post by [id].

final class PostDetailProvider
    extends $FunctionalProvider<AsyncValue<Post>, Post, FutureOr<Post>>
    with $FutureModifier<Post>, $FutureProvider<Post> {
  /// A single post by [id].
  PostDetailProvider._({
    required PostDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'postDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postDetailHash();

  @override
  String toString() {
    return r'postDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Post> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Post> create(Ref ref) {
    final argument = this.argument as int;
    return postDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postDetailHash() => r'0ad712780c7d875c1680c39c588de45badf605b5';

/// A single post by [id].

final class PostDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Post>, int> {
  PostDetailFamily._()
    : super(
        retry: null,
        name: r'postDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A single post by [id].

  PostDetailProvider call(int id) =>
      PostDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'postDetailProvider';
}
