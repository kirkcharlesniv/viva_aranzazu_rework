import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SearchEvent extends Equatable {
  SearchEvent([List props = const []]) : super(props);
}

class Search extends SearchEvent {
  Search(String query);

  @override
  String toString() => 'Search';
}
