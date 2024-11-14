import 'dart:developer';

import 'package:band_front/cores/api.dart';
import 'package:band_front/cores/router.dart';
import 'package:band_front/cores/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../cores/data_class.dart';
import '../cores/repository.dart';

class ClubManage extends StatefulWidget {
  const ClubManage({super.key});

  @override
  State<ClubManage> createState() => _ClubManageState();
}

class _ClubManageState extends State<ClubManage> {
  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<dynamic> _deleteBtnListener() async {
    int clubId = context.read<ClubDetail>().clubId!;
    bool result = await ClubApi.deleteMyClub(clubId);
    if (result == false) {
      _showSnackBar("클럽 해체 실패..");
      return;
    }
    await _deleteBtnHandler();
  }

  Future<void> _deleteBtnHandler() async {
    await context.read<ClubList>().initClubList().then((_) {
      _showSnackBar("클럽을 해체하였습니다");
      context.go(RouterPath.myClubList);
    });
  }

  Future<dynamic> _editBtnListener() async {
    context.push(RouterPath.clubEdit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("관리자 페이지")),
      body: Center(
        child: Column(children: [
          ElevatedButton(
            onPressed: () => _editBtnListener(),
            child: Text("모임 정보 변경하기"),
          ),
          ElevatedButton(onPressed: () {}, child: Text("")),
          ElevatedButton(onPressed: () {}, child: Text("")),
          ElevatedButton(
            onPressed: () async => _deleteBtnListener(),
            child: Text("모임 해체"),
          ),
        ]),
      ),
    );
  }
}
