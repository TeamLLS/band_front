import 'dart:io';

import 'package:band_front/cores/repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../cores/widget_utils.dart';

class BoardRegistView extends StatefulWidget {
  const BoardRegistView({super.key});

  @override
  State<BoardRegistView> createState() => _BoardRegistViewState();
}

class _BoardRegistViewState extends State<BoardRegistView> {
  XFile? _image;
  final TextEditingController titleCon = TextEditingController();
  final TextEditingController contentCon = TextEditingController();

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _image = image);
    }
  }

  Future<void> writeBtnListener() async {
    await context
        .read<BoardRepo>()
        .writePost(titleCon.text, contentCon.text, _image)
        .then((ret) {
      if (ret == false) {
        _showSnackBar("something went wrong..");
        return;
      }
      _showSnackBar("등록 완료");
      context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("게시글 작성하기")),
      body: SingleChildScrollView(
        child: Column(children: [
          const Text("첨부할 이미지를 선택해주세요"),
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
            child: Text("글 제목을 입력하세요"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: inputTextUnit(titleCon),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Text("본문을 작성해주세요"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: desUnit(
              child: InputMultiTextUnit(contentCon),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: elevatedBtnUnit(
              onPressed: () async => await writeBtnListener(),
              borderColor: Colors.blue,
              text: "등록하기",
            ),
          ),
        ]),
      ),
    );
  }
}
