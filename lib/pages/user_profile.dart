import 'dart:developer';

import 'package:band_front/cores/api.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../cores/data_class.dart';
import '../cores/router.dart';
import '../cores/widget_utils.dart';

class UserProfileViewModel {
  late String username;
  User? user;

  Future<bool> getUserProfile() async {
    var data = await ProfileApi.getUserProfile(username);
    if (data == null) {
      log("get club detail failed");
      return false;
    }
    user = User.fromMap(data);
    return true;
  }
}

class UserProfileView extends StatefulWidget {
  UserProfileView({super.key, required this.username});
  String username;

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  UserProfileViewModel _viewModel = UserProfileViewModel();

  Future<void> _initUserProfileView() async {
    _viewModel.username = widget.username;
    bool result = await _viewModel.getUserProfile();
    if (result == true) {
      setState(() {});
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    _initUserProfileView();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.user == null) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    User user = _viewModel.user!;
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
      appBar: AppBar(title: Text("${user.name}")),
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
          ],
        ),
      ),
    );
  }
}
