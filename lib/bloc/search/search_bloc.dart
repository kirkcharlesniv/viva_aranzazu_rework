import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:viva_aranzazu_rework/bloc/models/post.dart';

import './bloc.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final http.Client httpClient;
  SearchBloc({@required this.httpClient});

  @override
  SearchState get initialState => SearchUninitialized();

  @override
  Stream<SearchState> transform(
    Stream<SearchEvent> events,
    Stream<SearchState> Function(SearchEvent event) next,
  ) {
    return super.transform(
      (events as Observable<SearchEvent>).debounceTime(
        Duration(milliseconds: 500),
      ),
      next,
    );
  }

  @override
  Stream<SearchState> mapEventToState(
    SearchEvent event,
  ) async* {
    if (event is Search && !_hasReachedMax(currentState)) {
      yield SearchUninitialized();
      try {
        if (currentState is SearchUninitialized) {
          final posts = await _fetchSearchPosts(event.index, event.query);
          yield SearchLoaded(posts: posts, hasReachedMax: false);
        }
        if (currentState is SearchLoaded) {
          final posts = await _fetchSearchPosts(event.index + 1, event.query);
          yield posts.isEmpty
              ? (currentState as SearchLoaded).copyWith(hasReachedMax: true)
              : SearchLoaded(
              posts: (currentState as SearchLoaded).posts + posts,
              hasReachedMax: false);
        }
      } catch (_) {
        yield SearchError();
      }
    }
    if (event is FetchMore && !_hasReachedMax(currentState)) {
      try {
        if (currentState is SearchLoaded) {
          final posts = await _fetchSearchPosts(event.index + 1, event.query);
          yield posts.isEmpty
              ? (currentState as SearchLoaded).copyWith(hasReachedMax: true)
              : SearchLoaded(
              posts: (currentState as SearchLoaded).posts + posts,
              hasReachedMax: false);
        }
      } catch (_) {
        yield SearchError();
      }
    }
  }

  bool _hasReachedMax(SearchState state) =>
      state is SearchLoaded && state.hasReachedMax;

  Future<List<Post>> _fetchSearchPosts(int index, String query) async {
    print('FetchPost { $index, $query }');
    final response = await httpClient.get(
        'http://aranzazushrine.ph/home/index.php/wp-json/capie/v1/search/beta/news?page=$index&s=$query');
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
