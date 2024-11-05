// dependencies
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// local dependencies
import '../cores/dataclass.dart';
import '../cores/repositories.dart';
import '../cores/router.dart';
import '../cores/widgetutils.dart';
import '../cores/api.dart';

class MyProfileView extends StatefulWidget {
  const MyProfileView({super.key});

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  User? _me;

  Future<void> initProfileView() async {
    await context.read<ProfileInfoRepository>().getMyProfileInfo();
    setState(() {
      _me = context.read<ProfileInfoRepository>().me;
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
            'assets/images/test1.png',
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
                  child: ElevatedButton(
                    onPressed: () => context.push(RouterPath.myProfileEdit),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text("프로필 변경하기"),
                  ),
                ),
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
  late TextEditingController _emailCon;
  late TextEditingController _phNumCon;
  late TextEditingController _desCon;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void changeMyProfileHandler(bool result) {
    if (result == false) {
      showSnackBar(context, "edit profile failed");
      return;
    }
    showSnackBar(context, "프로필이 성공적으로 변경되었습니다");
    context.go(RouterPath.myProfilePage);
  }

  @override
  void initState() {
    super.initState();
    _me = context.read<ProfileInfoRepository>().me!;
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
    _emailCon = TextEditingController(text: _me.email);
    _phNumCon = TextEditingController(text: _me.phNum);
    _desCon = TextEditingController(text: _me.description);

    return Scaffold(
      appBar: AppBar(title: Text('프로필 수정하기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: () async => await pickImage(),
                child: SizedBox(
                  height: parentWidth * 0.5,
                  child: _image == null
                      ? Icon(Icons.photo_album, size: parentWidth * 0.2)
                      : Image.file(File(_image!.path)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextField(
                  controller: _emailCon,
                  decoration: InputDecoration(labelText: '이메일 주소'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextField(
                  controller: _phNumCon,
                  decoration: InputDecoration(labelText: '핸드폰 번호'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextField(
                  controller: _desCon,
                  decoration: InputDecoration(labelText: '자기소개'),
                  maxLines: 3,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                width: parentWidth,
                child: ElevatedButton(
                  onPressed: () async {
                    bool result = await context
                        .read<ProfileInfoRepository>()
                        .changeMyProfile(_image, _emailCon.text, _phNumCon.text,
                            _desCon.text);
                    if (result == true) {
                      await context
                          .read<ProfileInfoRepository>()
                          .getMyProfileInfo();
                    }
                    changeMyProfileHandler(result);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      const Color(0xFF87CEEB),
                    ),
                  ),
                  child: const Text("완료"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
