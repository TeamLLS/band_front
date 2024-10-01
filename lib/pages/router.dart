//dependencies
import 'package:band_front/pages/myclubs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../login.dart';

class RouterPath {}

final GoRouter route = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LogInPage(),
      routes: [
        GoRoute(
          path: 'myClubList',
          builder: (context, state) => const MyClubsPage(),
        ),
      ],
    ),
  ],
);

class ErrorPage extends StatelessWidget {
  final String err;
  const ErrorPage({super.key, required this.err});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(err)),
    );
  }
}
