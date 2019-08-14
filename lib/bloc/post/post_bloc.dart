import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:viva_aranzazu_rework/bloc/models/post.dart';

import './bloc.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClient;
  int index = 1;

  PostBloc({@required this.httpClient});

  @override
  PostState get initialState => PostUninitialized();

  @override
  Stream<PostState> transform(Stream<PostEvent> events,
      Stream<PostState> Function(PostEvent event) next,) {
    return super.transform(
      (events as Observable<PostEvent>).debounceTime(
        Duration(milliseconds: 500),
      ),
      next,
    );
  }

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    if (event is Fetch && !_hasReachedMax(currentState)) {
      try {
        if (currentState is PostUninitialized) {
          final posts = await _fetchPosts(index);
          yield PostLoaded(posts: posts, hasReachedMax: false);
        }
        if (currentState is PostLoaded) {
          index += 1;
          final posts = await _fetchPosts(index);
          yield posts.isEmpty
              ? (currentState as PostLoaded).copyWith(hasReachedMax: true)
              : PostLoaded(
            posts: (currentState as PostLoaded).posts + posts,
            hasReachedMax: false,
          );
        }
      } catch (_) {
        yield PostError();
      }
    }
  }

  bool _hasReachedMax(PostState state) =>
      state is PostLoaded && state.hasReachedMax;

  Future<List<Post>> _fetchPosts(int index) async {
    final response = await httpClient.get(
        'http://aranzazushrine.ph/home/index.php/wp-json/capie/v1/beta/news?page=$index');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawPost) {
        return Post(
            id: rawPost['id'],
            date: rawPost['date'],
            title: rawPost['title'],
            excerpt: rawPost['excerpt'],
            authorName: rawPost['authorName'],
            authorImage: rawPost['authorImage'],
            thumbnail: rawPost['thumbnail']);
      }).toList();
    } else {
      final failedData = json.decode(response.body);
      throw Exception(failedData['message']);
    }
  }
}
