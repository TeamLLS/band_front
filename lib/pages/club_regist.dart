//dependencies
import 'dart:developer';
import 'dart:io';

import 'package:band_front/cores/repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

//local dependencies
import '../cores/data_class.dart';
import '../cores/api.dart';
import '../cores/widget_utils.dart';

//regist -> list 디테일 검증 완료.

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

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _image = image);
    }
  }

  Future<void> _createClub() async {
    bool result = await ClubApi.createClub(
      nameCon.text,
      descriptCon.text,
      _image,
      contactCon.text,
    );

    if (result == false) {
      _showSnackBar("모임 생성 실패..");
      return;
    }

    await _navigateToMyClubList();
  }

  Future<void> _navigateToMyClubList() async {
    await context.read<ClubListRepo>().initClubList().then((_) {
      _showSnackBar("모임 등록 성공!");
      context.pop();
    });
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
            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Text("모임명을 입력하세요"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: inputTextUnit(nameCon),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Text("연락처를 알려주세요"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: inputTextUnit(contactCon),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Text("어떤 모임인지 알려주세요"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: desUnit(
              child: InputMultiTextUnit(descriptCon),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 64),
            child: elevatedBtnUnit(
              onPressed: () async => await _createClub(),
              borderColor: Colors.blue,
              text: "등록하기",
            ),
          ),
        ]),
      ),
    );
  }
}
