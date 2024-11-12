//dependencies
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

//local dependencies
import '../cores/dataclass.dart';
import '../cores/api.dart';
import '../cores/widgetutils.dart';

class ClubRegist extends StatefulWidget {
  const ClubRegist({super.key});

  @override
  State<ClubRegist> createState() => _ClubRegistState();
}

class _ClubRegistState extends State<ClubRegist> {
  XFile? _image;
  final TextEditingController nameCon = TextEditingController();
  final TextEditingController descriptCon = TextEditingController();
  final TextEditingController contactCon = TextEditingController();

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void _navigateToMyClubList(bool result) {
    if (result == false) {
      _showSnackBar("모임 생성 실패");
      return;
    }
    context.pop(true);
  }

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<void> _createClub() async {
    if (_image == null) {
      _showSnackBar("이미지를 선택해주세요");
      return;
    }

    bool result = await ClubApi.createClub(
      nameCon.text,
      descriptCon.text,
      _image,
      contactCon.text,
    );

    _navigateToMyClubList(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("모임 만들기")),
      body: SingleChildScrollView(
        child: Column(children: [
          const Text("대표 사진을 선택해주세요"),
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
            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Text("모임명을 입력하세요"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: TextField(
              controller: nameCon,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  borderSide: const BorderSide(color: Colors.black, width: 0.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  borderSide: const BorderSide(color: Colors.black, width: 0.7),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Text("연락처를 알려주세요"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: TextField(
              controller: contactCon,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  borderSide: const BorderSide(color: Colors.black, width: 0.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  borderSide: const BorderSide(color: Colors.black, width: 0.7),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Text("어떤 모임인지 알려주세요"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: TextField(
              controller: descriptCon,
              maxLines: 5,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(color: Colors.black, width: 0.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(color: Colors.black, width: 0.7),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: ElevatedButton(
              onPressed: () async => await _createClub(),
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
