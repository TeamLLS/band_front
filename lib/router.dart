//dependencies
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// pages
import 'login.dart';
import 'pages/myclubs.dart';
import 'pages/clubdetail.dart';
import 'pages/profile.dart';
import 'pages/members.dart';

class RouterPath {
  static const String myProfilePage = '/myClubList/myProfile';

  static const String clubDetailPage = '/myClubList/clubDetail';
  static const String members = '/myClubList/clubDetail/members';
}

// context.go(
//   '/myClubList/clubDetail',
//   extra: {'clubId': '$index'},
// );

final GoRouter route = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LogInPage(),
      routes: [
        GoRoute(
          path: 'myClubList',
          builder: (context, state) => const MyClubsPage(),
          routes: [
            GoRoute(
              path: 'clubDetail',
              builder: (context, state) {
                final Map<String, dynamic>? argument =
                    state.extra as Map<String, dynamic>?;
                var data = argument?['clubId'];
                return ClubDetail(clubId: data);
              },
              routes: [
                GoRoute(
                  path: 'members',
                  builder: (context, state) => const Members(),
                ),
              ],
            ),
            GoRoute(
              path: 'myProfile',
              builder: (context, state) {
                return MyProfilePage();
              },
            ),
          ],
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
