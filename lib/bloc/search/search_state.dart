import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:viva_aranzazu_rework/bloc/models/post.dart';

@immutable
abstract class SearchState extends Equatable {
  SearchState([List props = const []]) : super(props);
}

class SearchUninitialized extends SearchState {
  @override
  String toString() => 'SearchUninitialized';
}

class SearchError extends SearchState {
  @override
  String toString() => 'SearchError';
}

class SearchLoaded extends SearchState {
  final List<Post> posts;
  final bool hasReachedMax;

  SearchLoaded({this.posts, this.hasReachedMax})
      : super([posts, hasReachedMax]);

  SearchLoaded copyWith({List<Post> posts, bool hasReachedMax}) {
    return SearchLoaded(
        posts: posts ?? this.posts,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  String toString() =>
      'SearchLoaded { posts: ${posts.length}, hasReachedMax: $hasReachedMax }';
}
