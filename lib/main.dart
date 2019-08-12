import 'package:flutter/material.dart';
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
    return MaterialApp(
      title: 'Viva Aranzazu!',
      home: DashboardSearch(),
    );
  }
}
