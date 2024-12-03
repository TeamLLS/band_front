/*  
  clubId: Club Id, (Long) ㅇㅇ
  name, 활동 이름, (String) ㅇㅇ
  description: 활동 설명, (String) ㅇㅇ
  image: 활동 이미지, (MulitPartFile) ㅇㅇ
  location: 활동 장소, (String) 
  startTime: 활동 시작 시간, (Instant, ISO 8601)
  endTime: 활동 종료 시간, (Instnat, ISO 8601)
  deadline: 모집 종료 시간  (Instnat, ISO 8601)
*/

// TODO: 위치 선택 추가, 등록 성공 시 리로딩 추가

import 'dart:developer';
import 'dart:io';

import 'package:band_front/cores/api.dart';
import 'package:band_front/cores/repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../cores/widget_utils.dart';

class ActivityRegistView extends StatefulWidget {
  const ActivityRegistView({super.key});

  @override
  State<ActivityRegistView> createState() => _ActivityRegistViewState();
}

class _ActivityRegistViewState extends State<ActivityRegistView> {
  XFile? _image;
  final TextEditingController nameCon = TextEditingController();
  final TextEditingController desCon = TextEditingController();
  DateTime? startTime;
  DateTime? endTime;
  DateTime? deadline;

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<DateTime?> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return null;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _image = image);
    }
  }

  Future<void> regist() async {
    if (_image == null ||
        startTime == null ||
        endTime == null ||
        deadline == null) {
      _showSnackBar("모두 입력해주세요");
      return;
    }

    bool ret = await context.read<ClubDetailRepo>().registActivity(nameCon.text,
        desCon.text, _image!, "장소장소", startTime!, endTime!, deadline!);
    registHandler(ret);
  }

  void registHandler(bool ret) {
    if (ret == false) {
      _showSnackBar("등록 실패..");
      return;
    }
    _showSnackBar("등록 성공!");
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    String start = startTime == null ? "~" : formatToMDHM(startTime!);
    String end = endTime == null ? "~" : formatToMDHM(endTime!);
    String dead = deadline == null ? "~" : formatToMDHM(deadline!);

    return Scaffold(
      appBar: AppBar(title: const Text("모임 활동 등록하기")),
      body: SingleChildScrollView(
        child: Column(children: [
          const Text("모집을 위한 팸플릿 등이 있으신가요?"),
          InkWell(
            onTap: () async => await _pickImage(),
            child: _image == null
                ? Image.asset(
                    'assets/images/empty.png',
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 0.5,
                    fit: BoxFit.fitHeight,
                  )
                : Image.file(
                    File(_image!.path),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 0.5,
                    fit: BoxFit.fitHeight,
                  ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Text("어떤 목적의 활동인가요?"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: inputTextUnit(nameCon),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Text("회원님들을 위해 자세한 설명을 부탁드려요"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: desUnit(
              child: InputMultiTextUnit(desCon),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Text("모임을 가질 장소가 있으시다면"),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.green[300]),
              ),
              child: const Text("..."),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Text("약속 시간을 정해주세요"),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: ElevatedButton(
              onPressed: () async {
                final pickedDateTime = await _pickDateTime();
                setState(() => startTime = pickedDateTime);
              },
              child: Text("$start  부터"),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: ElevatedButton(
              onPressed: () async {
                final pickedDateTime = await _pickDateTime();
                setState(() => endTime = pickedDateTime);
              },
              child: Text("$end  까지"),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Text("인원은 언제까지 모집하실 건가요?"),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: ElevatedButton(
              onPressed: () async {
                final pickedDateTime = await _pickDateTime();
                setState(() => deadline = pickedDateTime);
              },
              child: Text("$dead  까지"),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 48, 0, 0),
            child: Text("등록하기 전에 한번 더 확인해주세요"),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: ElevatedButton(
              onPressed: () async => await regist(),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  const Color(0xFF87CEEB),
                ),
              ),
              child: const Text("등록하기"),
            ),
          ),
        ]),
      ),
    );
  }
}
