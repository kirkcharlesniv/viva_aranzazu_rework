import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SearchEvent extends Equatable {
  SearchEvent([List props = const []]) : super(props);
}

class Search extends SearchEvent {
  final String query;
  Search({@required this.query}) : super([query]);

  @override
  String toString() => 'Search { query: $query }';
}
