//dependencies
import 'package:band_front/pages/clubmanage.dart';
import 'package:band_front/pages/clubregist.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// pages
import 'pages/login.dart';
import 'pages/myclubs.dart';
import 'pages/clubdetail.dart';
import 'pages/profile.dart';
import 'pages/members.dart';

class RouterPath {
  static const String myProfilePage = '/myClubList/myProfile';

  static const String clubDetailPage = '/myClubList/clubDetail';
  static const String members = '/myClubList/clubDetail/members';
  static const String manage = '/myClubList/clubDetail/manage';

  static const String clubModify = '/myClubList/clubDetail/manage/modify';

  static const String clubRegist = '/myClubList/clubRegist';
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
                  path: "manage",
                  builder: (context, state) => const ClubManage(),
                  routes: [
                    GoRoute(
                      path: 'modify',
                      builder: (context, state) => const ClubModify(),
                    ),
                  ],
                ),
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
            GoRoute(
              path: 'clubRegist',
              builder: (context, state) {
                return ClubRegist();
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
