import 'dart:developer';

import 'package:flutter/material.dart';
import '../cores/api.dart';
import '../cores/dataclass.dart';
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

  Future<void> initClubMemberListView() async {
    _viewModel.clubId = widget.clubId;
    await _viewModel.getMemberList();
    setState(() {});
  }

  Icon getRoleIcon(String role) {
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

  @override
  void initState() {
    super.initState();
    initClubMemberListView();
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
            onPressed: () {},
            label: const Icon(Icons.person_add),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.yellow),
            ),
          ),
          const VerticalDivider(color: Colors.white),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        itemCount: members.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: getRoleIcon(members[index].roleName),
              title: Text(members[index].roleName),
              subtitle:
                  Text('${members[index].name}  |  ${members[index].username}'),
              trailing: Text(members[index].statusName),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
