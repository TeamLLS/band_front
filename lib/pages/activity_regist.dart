/*  
  clubId: Club Id, (Long)
  name, 활동 이름, (String)
  description: 활동 설명, (String)
  image: 활동 이미지, (MulitPartFile)
  startTime: 활동 시작 시간, (Instant, ISO 8601)
  endTime: 활동 종료 시간 (Instnat, ISO 8601)
*/

import 'package:flutter/material.dart';

class ActivityRegistView extends StatefulWidget {
  const ActivityRegistView({super.key});

  @override
  State<ActivityRegistView> createState() => _ActivityRegistViewState();
}

class _ActivityRegistViewState extends State<ActivityRegistView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("data")),
      body: Text("d"),
    );
  }
}
