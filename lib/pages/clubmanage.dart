import 'package:band_front/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../dataclass.dart';

class ClubManage extends StatelessWidget {
  const ClubManage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("관리자 페이지")),
      body: Column(children: [
        ElevatedButton(
          onPressed: () => context.go(RouterPath.clubModify),
          child: Text("모임 정보 변경하기"),
        ),
        ElevatedButton(onPressed: () {}, child: Text("")),
        ElevatedButton(onPressed: () {}, child: Text("")),
        ElevatedButton(onPressed: () {}, child: Text("")),
      ]),
    );
  }
}

class ClubModify extends StatefulWidget {
  const ClubModify({super.key});

  @override
  State<ClubModify> createState() => _ClubModifyState();
}

class _ClubModifyState extends State<ClubModify> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("모임 수정")),
    );
  }
}
