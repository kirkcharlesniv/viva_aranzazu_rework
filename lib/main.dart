import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viva_aranzazu_rework/bloc/post/bloc.dart';
import 'package:viva_aranzazu_rework/bloc/search/bloc.dart';
import 'widgets/dashboard_page.dart';
import 'package:bloc/bloc.dart';
import 'package:viva_aranzazu_rework/bloc/simple_bloc_delegate.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchBloc>(
          builder: (context) => SearchBloc(httpClient: http.Client()),
        ),
        BlocProvider<PostBloc>(
          builder: (context) => PostBloc(httpClient: http.Client()),
        ),
      ],
      child: MaterialApp(
        title: 'Viva Aranzazu!',
        home: DashboardSearch(),
      ),
    );
  }
}
