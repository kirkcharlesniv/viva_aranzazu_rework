import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SearchEvent extends Equatable {
  SearchEvent([List props = const []]) : super(props);
}

class Search extends SearchEvent {
  final String query;
  final int index;

  Search({@required this.query, @required this.index}) : super([query, index]);

  @override
  String toString() => 'Search { query: $query, index: $index }';
}

class ResetSearch extends SearchEvent {
  @override
  String toString() => 'SearchReset';
}

class FetchMore extends SearchEvent {
  final String query;
  final int index;

  FetchMore({@required this.query, @required this.index})
      : super([query, index]);

  @override
  String toString() => 'FetchMore { query: $query, index: $index }';
}
