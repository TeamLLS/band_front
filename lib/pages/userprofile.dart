import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../cores/dataclass.dart';
import '../cores/router.dart';
import '../cores/widgetutils.dart';

class UserProfileViewModel {
  late String username;
  User? user;

  Future<void> getUserProfile() async {}
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
    await _viewModel.getUserProfile();
    setState(() {});
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
                          Text(user.phNum!),
                        ]),
                        Row(children: [
                          const VerticalDivider(),
                          const Icon(Icons.email),
                          const VerticalDivider(),
                          Text(user.email!),
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
