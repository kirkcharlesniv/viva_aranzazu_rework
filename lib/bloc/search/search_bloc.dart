import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:viva_aranzazu_rework/bloc/models/post.dart';
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'dart:convert';
import './bloc.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final http.Client httpClient;
  int index = 1;
  String query;
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
      try {
        if (currentState is SearchUninitialized) {
          final posts = await _fetchPosts(index, query);
          yield SearchLoaded(posts: posts, hasReachedMax: false);
          return;
        }
        if (currentState is SearchLoaded) {
          index += 1;
          final posts = await _fetchPosts(index, query);
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

  // TODO: add string for search
  Future<List<Post>> _fetchPosts(int index, String query) async {
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
