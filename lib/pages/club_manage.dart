import 'dart:developer';

import 'package:band_front/cores/api.dart';
import 'package:band_front/cores/router.dart';
import 'package:band_front/cores/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../cores/data_class.dart';

enum ManageAct {
  delete,
  modify,
}

class ClubManage extends StatefulWidget {
  ClubManage({super.key, required this.club});

  Club club;

  @override
  State<ClubManage> createState() => _ClubManageState();
}

class _ClubManageState extends State<ClubManage> {
  void _showSnackBar(String text) {
    showSnackBar(context, text);
  }

  Future<dynamic> _deleteBtnListener() async {
    bool result = await ClubApi.deleteMyClub(widget.club.clubId);
    log("$result");
    if (result == false) {
      _showSnackBar("클럽 해체 실패..");
      return;
    }
    _deleteBtnHandler();
  }

  void _deleteBtnHandler() {
    context.pop(ManageAct.delete);
  }

  Future<dynamic> _editBtnListener() async {
    context.push(
      RouterPath.clubEdit,
      extra: {"club": widget.club},
    );
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
