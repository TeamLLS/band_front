import 'dart:developer';

import 'package:band_front/cores/repository.dart';
import 'package:band_front/cores/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../cores/api.dart';
import '../cores/data_class.dart';
import '../cores/router.dart';
import '../main.dart';

class ClubMemberListView extends StatefulWidget {
  ClubMemberListView({super.key, required this.clubId});
  int clubId;

  @override
  State<ClubMemberListView> createState() => _ClubMemberListViewState();
}

class _ClubMemberListViewState extends State<ClubMemberListView> {
  void _showSnackBar(String text) => showSnackBar(context, text);

  Icon _getRoleIcon(String role) {
    switch (role) {
      case '회장':
        return const Icon(Icons.stars, color: Colors.yellow);
      case '관리자':
        return const Icon(Icons.build, color: Colors.blue);
      case '일반':
        return const Icon(Icons.person, color: Colors.green);
      default:
        return const Icon(Icons.help, color: Colors.red);
    }
  }

  void _navigateToUserProfile(String username, int memberId, String role) {
    context.read<UserRepo>().setUserInfo(username, memberId, role);
    context.push(RouterPath.userProfile);
  }

  Future<void> _inviteBtnListener() async {
    int clubId = context.read<ClubDetailRepo>().clubId!;
    var data = await ClubApi.registMember(clubId, "Dummy_userD");

    await _inviteBtnHandler(data);
  }

  Future<void> _inviteBtnHandler(dynamic data) async {
    if (data == null) {
      _showSnackBar("등록 실패..");
      return;
    }
    await context.read<ClubDetailRepo>().getMemberList();
    _showSnackBar("등록 성공!");
  }

  Future<void> _initClubMemberListView() async {
    await context.read<ClubDetailRepo>().getMemberList();
  }

  @override
  void initState() {
    super.initState();
    _initClubMemberListView();
  }

  @override
  Widget build(BuildContext context) {
    List<Member> members = context.watch<ClubDetailRepo>().members;

    return Scaffold(
      appBar: AppBar(
        title: const Text("회원 목록"),
        actions: [
          ElevatedButton.icon(
            onPressed: () async => await _inviteBtnListener(),
            label: const Icon(Icons.person_add),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.yellow),
              elevation: WidgetStateProperty.all(2.0),
            ),
          ),
          const VerticalDivider(color: Colors.white),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        itemCount: members.length,
        itemBuilder: (context, index) {
          log("username : ${members[index].username}");
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              elevation: 5.0, // 그림자 효과
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              child: ListTile(
                leading: _getRoleIcon(members[index].roleName),
                title: Text(members[index].roleName),
                subtitle: Text(
                    '${members[index].name}  |  ${members[index].username}'),
                trailing: Text(members[index].status),
                onTap: () => _navigateToUserProfile(
                  members[index].username,
                  members[index].memberId,
                  members[index].roleName,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
