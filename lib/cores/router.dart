//dependencies
import 'package:band_front/pages/activitydetail.dart';
import 'package:band_front/pages/clubmanage.dart';
import 'package:band_front/pages/clubregist.dart';
import 'package:band_front/pages/userprofile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// pages
import '../pages/login.dart';
import '../pages/clubs.dart';
import '../pages/clubdetail.dart';
import '../pages/profile.dart';
import '../pages/clubmembers.dart';

class RouterPath {
  static const String myClubList = "/myClubList";
  static const String myProfilePage = '/myClubList/myProfile';
  static const String myProfileEdit = '/myClubList/myProfile/myProfileEdit';

  static const String clubDetailPage = '/myClubList/clubDetail';
  static const String members = '/myClubList/clubDetail/members';

  static const String manage = '/myClubList/clubDetail/manage';

  static const String clubModify = '/myClubList/clubDetail/manage/modify';

  static const String activityDetail = '/myClubList/clubDetail/activityDetail';

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
      builder: (context, state) => const SignView(),
      routes: [
        GoRoute(
          path: 'myClubList',
          builder: (context, state) => const ClubListView(),
          routes: [
            GoRoute(
              path: 'clubDetail',
              builder: (context, state) {
                final Map<String, dynamic>? argument =
                    state.extra as Map<String, dynamic>?;
                var clubId = argument?['clubId'];
                var role = argument?['role'];
                return ClubDetailView(clubId: clubId, role: role);
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
                  builder: (context, state) {
                    final Map<String, dynamic>? argument =
                        state.extra as Map<String, dynamic>?;
                    var data = argument?['clubId'];
                    return ClubMemberListView(clubId: data);
                  },
                ),
                GoRoute(
                  path: 'activityDetail',
                  builder: (context, state) {
                    final Map<String, dynamic>? argument =
                        state.extra as Map<String, dynamic>?;
                    int actId = argument?['actId'];
                    int clubId = argument?['actId'];
                    return ActivityDetailView(actId: actId, clubId: clubId);
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'myProfile',
              builder: (context, state) => const MyProfileView(),
              routes: [
                GoRoute(
                  path: 'myProfileEdit',
                  builder: (context, state) => const MyProfileEditView(),
                ),
              ],
            ),
            GoRoute(
              path: 'clubRegist',
              builder: (context, state) {
                return ClubRegist();
              },
            ),
          ],
        ),
        //need to push
        GoRoute(
          path: "userProfile",
          builder: (context, state) {
            final Map<String, dynamic>? argument =
                state.extra as Map<String, dynamic>?;
            var data = argument?['username'];
            return UserProfileView(username: data);
          },
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
