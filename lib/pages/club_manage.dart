import 'dart:developer';

import 'package:band_front/cores/api.dart';
import 'package:band_front/cores/router.dart';
import 'package:band_front/cores/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../cores/data_class.dart';
import '../cores/repository.dart';

//TODO: 아이콘 또는 이미지로 버튼 만들기

class ClubManage extends StatefulWidget {
  const ClubManage({super.key});

  @override
  State<ClubManage> createState() => _ClubManageState();
}

class _ClubManageState extends State<ClubManage> {
  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<dynamic> _deleteBtnListener() async {
    int clubId = context.read<ClubDetailRepo>().clubId!;
    bool result = await ClubApi.deleteMyClub(clubId);
    if (result == false) {
      _showSnackBar("클럽 해체 실패..");
      return;
    }
    await _deleteBtnHandler();
  }

  Future<void> _deleteBtnHandler() async {
    await context.read<ClubListRepo>().initClubList().then((_) {
      _showSnackBar("클럽을 해체하였습니다");
      context.go(RouterPath.myClubList);
    });
  }

  void _editBtnListener() {
    context.push(RouterPath.clubEdit);
  }

  void _budgetManageBtnListener() {
    context.push(RouterPath.budgetManage);
  }

  void _paymentManageBtnListener() {
    log("goto context.push(RouterPath.paymentManage);");
    context.push(RouterPath.paymentManage);
  }

  void _statisticsBtnListener() {
    context.push(RouterPath.statistics);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("모임 관리")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _editBtnListener(),
              child: const Text("모임 정보 수정하기"),
            ),
            ElevatedButton(
              onPressed: () => _budgetManageBtnListener(),
              child: const Text("예산 관리"),
            ),
            ElevatedButton(
              onPressed: () => _paymentManageBtnListener(),
              child: const Text("납부 내역 관리"),
            ),
            ElevatedButton(
              onPressed: () => _statisticsBtnListener(),
              child: const Text("모임 통계 조회"),
            ),
            ElevatedButton(
              child: const Text("모임 해체"),
              onPressed: () async => _deleteBtnListener(),
            ),
          ],
        ),
      ),
    );
  }
}
