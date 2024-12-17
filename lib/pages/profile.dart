// dependencies
import 'dart:developer';
import 'dart:io';

import 'package:band_front/cores/api.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// local dependencies
import '../cores/data_class.dart';
import '../cores/repository.dart';
import '../cores/router.dart';
import '../cores/widget_utils.dart';

class MyProfileView extends StatefulWidget {
  const MyProfileView({super.key});

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  User? _me;

  Future<void> initProfileView() async {
    await context.read<MyRepo>().getMyInfo();
    setState(() {
      _me = context.read<MyRepo>().me;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initProfileView();
  }

  @override
  Widget build(BuildContext context) {
    if (_me == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('내 프로필')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    double parentWidth = MediaQuery.of(context).size.width;
    Image image = _me!.image == null
        ? Image.asset(
            'assets/images/empty.png',
            fit: BoxFit.cover,
            height: parentWidth * 0.7,
            width: parentWidth,
          )
        : Image.network(
            _me!.image!,
            fit: BoxFit.cover,
            height: parentWidth * 0.7,
            width: parentWidth,
          );

    return Scaffold(
      appBar: AppBar(title: const Text('내 프로필')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            image,
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: desUnit(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        Text(_me!.username),
                        const Divider(thickness: 0.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(_me!.name!),
                            Text(_me!.age.toString()),
                            Text(_me!.gender!),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: desUnit(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        const Text("contact"),
                        const Divider(thickness: 0.5),
                        Row(children: [
                          const VerticalDivider(),
                          const Icon(Icons.phone),
                          const VerticalDivider(),
                          Text(_me!.phNum!),
                        ]),
                        Row(children: [
                          const VerticalDivider(),
                          const Icon(Icons.email),
                          const VerticalDivider(),
                          Text(_me!.email!),
                        ]),
                      ]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: desUnit(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: desTextUnit(
                        maxLine: 5,
                        description: _me!.description ?? "등록된 자기소개가 없습니다",
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  width: parentWidth,
                  child: elevatedBtnUnit(
                    onPressed: () => context.push(RouterPath.myProfileEdit),
                    borderColor: Colors.orange,
                    text: "프로필 변경하기",
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class MyProfileEditView extends StatefulWidget {
  const MyProfileEditView({super.key});

  @override
  State<MyProfileEditView> createState() => _MyProfileEditViewState();
}

class _MyProfileEditViewState extends State<MyProfileEditView> {
  late User _me;
  XFile? _image;
  late final TextEditingController _emailCon;
  late final TextEditingController _phNumCon;
  late final TextEditingController _desCon;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void _navigateToMyProfilePage() => context.go(RouterPath.myProfilePage);
  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<void> _changeMyProfileHandler(bool result) async {
    if (result == false) {
      _showSnackBar("프로필 변경 실패");
      return;
    }

    result = await context.read<MyRepo>().getMyInfo();
    if (result == false) {
      _showSnackBar("프로필 변경 실패");
      return;
    }
    _showSnackBar("프로필이 성공적으로 변경되었습니다");
    _navigateToMyProfilePage();
  }

  Future<void> changeMyProfile() async {
    // await ProfileApi.test(_image!);
    // return;
    //preprocessing data
    String? emailParam = _emailCon.text == "" ? null : _emailCon.text;
    String? phNumParam = _phNumCon.text == "" ? null : _phNumCon.text;
    String? desParam = _desCon.text == "" ? null : _desCon.text;

    //request change
    log("========== in profile page state ==========");
    log("email : $emailParam");
    log("phNum : $phNumParam");
    log("description : $desParam");
    log("===========================================");
    bool result = await context
        .read<MyRepo>()
        .changeMyInfo(_image, emailParam, phNumParam, desParam);
    _changeMyProfileHandler(result);
  }

  @override
  void initState() {
    super.initState();
    _me = context.read<MyRepo>().me!;
    _emailCon = TextEditingController(text: _me.email);
    _phNumCon = TextEditingController(text: _me.phNum);
    _desCon = TextEditingController(text: _me.description);
  }

  @override
  void dispose() {
    _emailCon.dispose();
    _phNumCon.dispose();
    _desCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double parentWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('프로필 수정하기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: () async => await _pickImage(),
                child: SizedBox(
                  height: parentWidth * 0.5,
                  child: _image == null
                      ? Image.asset('assets/images/empty.png')
                      : Image.file(File(_image!.path)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Text("이메일 주소"),
              ),
              inputTextUnit(_emailCon),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Text("핸드폰 번호"),
              ),
              inputTextUnit(_phNumCon),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Text("자기소개란"),
              ),
              desUnit(
                child: InputMultiTextUnit(_desCon),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                width: parentWidth,
                child: elevatedBtnUnit(
                  onPressed: () async {
                    await changeMyProfile();
                    //await ProfileApi.test(_image!);
                  },
                  borderColor: Colors.blue,
                  text: "완료",
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
