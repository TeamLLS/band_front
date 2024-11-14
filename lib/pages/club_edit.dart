import 'dart:developer';
import 'dart:io';

import 'package:band_front/cores/api.dart';
import 'package:band_front/cores/repository.dart';
import 'package:flutter/material.dart';
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
    String? statusParam;
    if (_clubStatus == ClubStatus.ACTIVE) {
      statusParam = "운영중";
    } else if (_clubStatus == ClubStatus.CLOSED) {
      statusParam = "운영종료";
    } else if (_clubStatus == ClubStatus.RECRUITING) {
      statusParam = "모집중";
    }

    bool result = await ClubApi.changeClubDetail(
      club.clubId,
      namParam,
      desParam,
      statusParam,
      _image,
    );
    log("$result");
  }

  void _initClubEdit() {
    club = context.read<ClubDetail>().club!;
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

  // clubId: 클럽 ID, (Long) -> get from before page
  // name: 모임 이름, (String) V
  // nameChanged: 이름 변경 여부, (Boolean, true or false)
  // description: 모임 설명, (String) V
  // descriptionChanged: 설명 변경 경부, (Boolean, true or false)
  // image: 모임 이미지, (MulitPartFile) V
  // imageChanged: 이미지 변경 여부, (Boolean, true or false)
  // status: 클럽 상태 (ACTIVE or RECRUITING or TERMINATED) V
  // statusChanged: 상태 변경 여부 (Boolean, true or false)

  @override
  void initState() {
    super.initState();
    _initClubEdit();
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
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: ElevatedButton(
              onPressed: () async => _changeBtnListener(),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.orange),
              ),
              child: const Text("변경 완료"),
            ),
          ),
        ]),
      ),
    );
  }
}
