//dependencies
import 'package:band_front/pages/activity_detail.dart';
import 'package:band_front/pages/club_budget.dart';
import 'package:band_front/pages/club_manage.dart';
import 'package:band_front/pages/club_regist.dart';
import 'package:band_front/pages/manage_budget.dart';
import 'package:band_front/pages/manage_payment.dart';
import 'package:band_front/pages/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// pages
import '../pages/activity_location.dart';
import '../pages/activity_regist.dart';
import '../pages/manage_edit.dart';
import '../pages/login.dart';
import '../pages/club_list.dart';
import '../pages/club_detail.dart';
import '../pages/manage_statistics.dart';
import '../pages/profile.dart';
import '../pages/club_members.dart';

class RouterPath {
  static const String myClubList = "/myClubList";
  static const String myProfilePage = '/myClubList/myProfile';
  static const String myProfileEdit = '/myClubList/myProfile/myProfileEdit';

  static const String clubDetailPage = '/myClubList/clubDetail';
  static const String members = '/myClubList/clubDetail/members';

  static const String manage = '/myClubList/clubDetail/manage';

  static const String clubEdit = '/myClubList/clubDetail/manage/edit';
  static const String budgetManage =
      '/myClubList/clubDetail/manage/budgetManage';
  static const String paymentManage =
      '/myClubList/clubDetail/manage/paymentManage';
  static const String paymentDetailManage =
      '/myClubList/clubDetail/manage/paymentManage/paymentDetailManage';

  static const String statistics = '/myClubList/clubDetail/manage/statistics';

  static const String activityDetail = '/myClubList/clubDetail/activityDetail';
  static const String activityLocation =
      '/myClubList/clubDetail/activityDetail/activityLocation';

  static const String activityRegist = '/myClubList/clubDetail/activityRegist';
  static const String addressGet =
      '/myClubList/clubDetail/activityRegist/AddressGet';

  static const String budget = '/myClubList/clubDetail/budget';
  static const String paymentDetail =
      '/myClubList/clubDetail/budget/paymentDetail';

  static const String clubRegist = '/myClubList/clubRegist';

  static const String userProfile = "/userProfile";
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
                  builder: (context, state) => ClubManage(),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) => ClubEditView(),
                    ),
                    GoRoute(
                      path: 'budgetManage',
                      builder: (context, state) => BudgetManageView(),
                    ),
                    GoRoute(
                      path: 'paymentManage',
                      builder: (context, state) => PaymentManageView(),
                      routes: [
                        GoRoute(
                          path: 'paymentDetailManage',
                          builder: (context, state) {
                            final Map<String, dynamic>? argument =
                                state.extra as Map<String, dynamic>?;
                            var data = argument?['paymentId'];
                            return PaymentDetailManageView(paymentId: data);
                          },
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'statistics',
                      builder: (context, state) => StatisticsView(),
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
                    int clubId = argument?['clubId'];
                    return ActivityDetailView(actId: actId, clubId: clubId);
                  },
                  routes: [
                    GoRoute(
                      path: 'activityLocation',
                      builder: (context, state) => const ActivityLocationView(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'activityRegist',
                  builder: (context, state) => const ActivityRegistView(),
                  routes: [
                    GoRoute(
                      path: 'AddressGet',
                      builder: (context, state) => const AddressGetView(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'budget',
                  builder: (context, state) => const BudgetCtrlView(),
                  routes: [
                    GoRoute(
                      path: 'paymentDetail',
                      builder: (context, state) {
                        final Map<String, dynamic>? argument =
                            state.extra as Map<String, dynamic>?;
                        var data = argument?['paymentId'];
                        return PaymentDetailView(paymentId: data);
                      },
                    ),
                  ],
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
          builder: (context, state) => const UserProfileView(),
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
