import 'dart:developer';
import 'dart:io';

import 'package:band_front/cores/api.dart';
import 'package:band_front/cores/repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../cores/data_class.dart';
import '../cores/widget_utils.dart';

enum ClubStatus {
  ACTIVE, //운영중
  CLOSED, //운영종료
  RECRUITING, //모집중
}

class ClubEditView extends StatefulWidget {
  const ClubEditView({super.key});

  @override
  State<ClubEditView> createState() => _ClubEditViewState();
}

class _ClubEditViewState extends State<ClubEditView> {
  late Club club;
  XFile? _image;
  ClubStatus? _clubStatus; //for radio button
  final TextEditingController _nameCon = TextEditingController();
  final TextEditingController _desCon = TextEditingController();
  final TextEditingController _contactCon = TextEditingController();

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _image = image);
    }
  }

  Future<void> _changeBtnListener() async {
    String? namParam = _nameCon.text == "" ? null : _nameCon.text;
    String? desParam = _desCon.text == "" ? null : _desCon.text;
    String? contactParam = _contactCon.text == "" ? null : _contactCon.text;
    String? statusParam;
    if (_clubStatus == ClubStatus.ACTIVE) {
      statusParam = "ACTIVE";
    } else if (_clubStatus == ClubStatus.CLOSED) {
      statusParam = "CLOSED";
    } else if (_clubStatus == ClubStatus.RECRUITING) {
      statusParam = "RECRUITING";
    }

    bool ret = await context.read<ClubDetailRepo>().editClubDetail(
          club.clubId,
          namParam,
          desParam,
          statusParam,
          _image,
          contactParam,
        );
    if (ret == false) {
      _showSnackBar("변경 실패...");
      return;
    }
    await _changeBtnHandler();
  }

  Future<void> _changeBtnHandler() async {
    await context.read<ClubListRepo>().reloadClubList().then((ret) {
      if (ret == false) {
        _showSnackBar("변경 실패...");
        return;
      }
      _showSnackBar("성공적으로 수정되었습니다.");
      context.pop();
    });
  }

  @override
  void initState() {
    super.initState();
    _initClubEdit();
  }

  void _initClubEdit() {
    club = context.read<ClubDetailRepo>().club!;
    _nameCon.text = club.name;
    _desCon.text = club.description ?? "";
    if (club.status == "운영중") {
      _clubStatus = ClubStatus.ACTIVE;
    } else if (club.status == "운영종료") {
      _clubStatus = ClubStatus.CLOSED;
    } else if (club.status == "모집중") {
      _clubStatus = ClubStatus.RECRUITING;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("모임 정보 수정")),
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
            child: inputTextUnit(_nameCon),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Text("연락처를 알려주세요"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: inputTextUnit(_contactCon),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: menuBarUnit(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(children: [
                    Radio<ClubStatus>(
                      value: ClubStatus.ACTIVE,
                      groupValue: _clubStatus,
                      onChanged: (ClubStatus? value) {
                        setState(() {
                          _clubStatus = value;
                        });
                      },
                    ),
                    const Text('운영중'),
                  ]),
                  Row(children: [
                    Radio<ClubStatus>(
                      value: ClubStatus.CLOSED,
                      groupValue: _clubStatus,
                      onChanged: (ClubStatus? value) {
                        setState(() {
                          _clubStatus = value;
                        });
                      },
                    ),
                    const Text('운영종료'),
                  ]),
                  Row(children: [
                    Radio<ClubStatus>(
                      value: ClubStatus.RECRUITING,
                      groupValue: _clubStatus,
                      onChanged: (ClubStatus? value) {
                        setState(() {
                          _clubStatus = value;
                        });
                      },
                    ),
                    const Text('모집중'),
                  ]),
                  const VerticalDivider(),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Text("어떤 모임인지 알려주세요"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: desUnit(
              child: InputMultiTextUnit(_desCon),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
            child: elevatedBtnUnit(
              onPressed: () async => _changeBtnListener(),
              borderColor: Colors.orange,
              text: "변경 완료",
            ),
          ),
        ]),
      ),
    );
  }
}
