import 'dart:developer';

import 'package:band_front/cores/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../cores/api.dart';
import '../cores/data_class.dart';
import '../cores/router.dart';
import '../main.dart';

class ClubmemberListViewModel {
  late int clubId;
  List<Member>? members;
  int pn = 0;

  Future<void> getMemberList() async {
    var data = await ClubApi.getClubMemberList(clubId, pn);
    var list = data['list'];
    List<Member> receivedMembers = [];

    for (Map<String, dynamic> element in list) {
      receivedMembers.add(Member.fromMap(element));
    }
    members = receivedMembers;
    pn++;
    return;
  }
}

class ClubMemberListView extends StatefulWidget {
  ClubMemberListView({super.key, required this.clubId});
  int clubId;

  @override
  State<ClubMemberListView> createState() => _ClubMemberListViewState();
}

class _ClubMemberListViewState extends State<ClubMemberListView> {
  ClubmemberListViewModel _viewModel = ClubmemberListViewModel();

  void _showSnackBar(String text) {
    showSnackBar(context, text);
  }

  Future<void> _initClubMemberListView() async {
    _viewModel.clubId = widget.clubId;
    await _viewModel.getMemberList();
    setState(() {});
  }

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

  Future<void> _inviteBtnListener() async {
    var data = await ClubApi.registMember(_viewModel.clubId, "Dummy_userA");
    if (data == null) {
      _showSnackBar("등록 실패..");
      return;
    }
    await _viewModel.getMemberList();
    setState(() {
      _showSnackBar("등록 성공!");
    });
  }

  @override
  void initState() {
    super.initState();
    _initClubMemberListView();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.members == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<Member> members = _viewModel.members!;

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
                onTap: () {
                  context.push(
                    RouterPath.userProfile,
                    extra: {"username": members[index].username},
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
