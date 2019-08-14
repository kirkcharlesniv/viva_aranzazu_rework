import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viva_aranzazu_rework/bloc/search/bloc.dart';
import 'package:viva_aranzazu_rework/widgets/dashboard/index.dart';

import 'dashboard/bottom_loader.dart';
import 'dashboard/post.dart';

class DashboardSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: DataSearch(BlocProvider.of<SearchBloc>(context)));
            },
          )
        ],
      ),
      body: DashboardPage(),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final _scrollController = ScrollController();
  final recentSearches = [];
  final searches = [];
  final SearchBloc searchBloc;

  int indexPage = 1;
  String globalQueryString;

  DataSearch(this.searchBloc);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, null);
        });
  }

  bool handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        _scrollController.position.extentAfter == 0) {
      print('REACHED END OF SEARCH!');
      indexPage += 1;
      searchBloc
          .dispatch(FetchMore(query: globalQueryString, index: indexPage));
    }
    return false;
  }

  @override
  Widget buildResults(BuildContext context) {
    globalQueryString = query;
    indexPage = 1;
    searchBloc.dispatch(ResetSearch());
    searchBloc.dispatch(Search(query: query, index: 1));
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (BuildContext context, SearchState state) {
        if (state is SearchUninitialized) {
          return Center(child: Text('Start Searching'));
        }
        if (state is SearchError) {
          return Center(
            child: Text('Failed To Load Posts'),
          );
        }
        if (state is SearchLoaded) {
          if (state.posts.isEmpty) {
            return Center(
              child: Text('No Results'),
            );
          }
          return NotificationListener<ScrollNotification>(
            onNotification: handleScrollNotification,
            child: ListView.builder(
              key: new PageStorageKey('myListView'),
              itemBuilder: (BuildContext context, int index) {
                return index >= state.posts.length
                    ? BottomLoader()
                    : PostWidget(post: state.posts[index]);
              },
              itemCount: state.hasReachedMax
                  ? state.posts.length
                  : state.posts.length + 1,
              controller: _scrollController,
            ),
          );
        }
        return Scaffold();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentSearches
        : searches.where((p) => p.startsWith(query)).toList();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          showResults(context);
        },
        leading: Icon(Icons.search),
        title: RichText(
            text: TextSpan(
                text: suggestionList[index].substring(0, query.length),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                children: [
              TextSpan(
                  text: suggestionList[index].substring(query.length),
                  style: TextStyle(color: Colors.grey))
            ])),
      ),
      itemCount: suggestionList.length,
    );
  }
}
