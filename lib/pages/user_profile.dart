import 'dart:developer';

import 'package:band_front/cores/api.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../cores/data_class.dart';
import '../cores/repository.dart';
import '../cores/router.dart';
import '../cores/widget_utils.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  bool _isLoaded = false;
  String? _role;

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<void> _initUserProfileView() async {
    _role = context.read<UserRepo>().role;
    ;
    bool result = await context.read<UserRepo>().getUserProfile();
    if (result == false) {
      return;
    }
    setState(() => _isLoaded = true);
  }

  Future<void> _banBtnListener() async {
    bool result = await context.read<UserRepo>().removeFromClub();
    if (result == false) {
      _showSnackBar("추방 실패..");
      return;
    }

    await _banBtnHandler();
  }

  Future<void> _banBtnHandler() async {
    await context.read<ClubDetailRepo>().getMemberList().then((_) {
      _showSnackBar("추방되었습니다");
      context.pop();
    });
  }

  Future<void> _changeRoleBtnListener() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, stateSetter) {
          return AlertDialog(
            title: const Text("권한 부여"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: "회장",
                      groupValue: _role,
                      onChanged: (String? value) {
                        stateSetter(() => _role = value!);
                      },
                    ),
                    const Text("회장"),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: "관리자",
                      groupValue: _role,
                      onChanged: (String? value) {
                        stateSetter(() => _role = value!);
                      },
                    ),
                    const Text("관리자"),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: "일반",
                      groupValue: _role,
                      onChanged: (String? value) {
                        stateSetter(() => _role = value!);
                      },
                    ),
                    const Text("일반"),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text("취소"),
              ),
              TextButton(
                onPressed: () async => await _changeRoleBtnHandler(),
                child: const Text("확인"),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _changeRoleBtnHandler() async {
    bool result = await context.read<UserRepo>().changeRole(_role!);
    if (result == false) {
      _showSnackBar("권한 변경 실패..");
      return;
    }

    await _returnHandler();
  }

  Future<void> _returnHandler() async {
    await context.read<ClubDetailRepo>().getMemberList().then((_) {
      context.pop();
      context.pop();
    });
  }

  @override
  void initState() {
    super.initState();
    _initUserProfileView();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded == false) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String myRole = context.watch<ClubDetailRepo>().role!;
    User user = context.watch<UserRepo>().user!;
    double parentWidth = MediaQuery.of(context).size.width;
    Image image = user.image == null
        ? Image.asset(
            'assets/images/test1.png',
            fit: BoxFit.cover,
            height: parentWidth * 0.7,
            width: parentWidth,
          )
        : Image.network(
            user.image!,
            fit: BoxFit.cover,
            height: parentWidth * 0.7,
            width: parentWidth,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text("${user.name}"),
        actions: [
          ElevatedButton.icon(
            onPressed: () async => await _banBtnListener(),
            label: const Icon(Icons.block),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
              elevation: WidgetStateProperty.all(2.0),
            ),
          ),
          const VerticalDivider(color: Colors.white),
        ],
      ),
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
                        Text(user.username),
                        const Divider(thickness: 0.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(user.name!),
                            Text(user.age.toString()),
                            Text(user.gender!),
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
                          Text(user.phNum ?? "연락처가 없습니다"),
                        ]),
                        Row(children: [
                          const VerticalDivider(),
                          const Icon(Icons.email),
                          const VerticalDivider(),
                          Text(user.email ?? "연락처가 없습니다"),
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
                        description: user.description ?? "등록된 자기소개가 없습니다",
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            myRole == "일반"
                ? const SizedBox.shrink()
                : Container(
                    width: parentWidth,
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                    child: elevatedBtnUnit(
                      onPressed: () async => await _changeRoleBtnListener(),
                      borderColor: Colors.orange,
                      text: "권한 부여",
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
