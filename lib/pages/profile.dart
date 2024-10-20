import 'package:flutter/material.dart';
import '../dataclass.dart';

class MyProfilePage extends StatelessWidget {
  MyProfilePage({super.key});

  Profile testProfile = Profile(
    userId: 1, //hide
    username: "username",
    name: "name",
    age: 1,
    gender: "gender",
    phNum: "phNum",
    email: "email",
    description: "description",
    image: "image",
  );

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('내 프로필')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/test1.png',
              fit: BoxFit.cover,
              height: width * 0.7,
              width: width,
            ),
            Container(
              width: width,
              padding: const EdgeInsets.fromLTRB(32, 12, 32, 12),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Column(children: [
                  Text(testProfile.username),
                  Text(testProfile.name),
                  Text(testProfile.age.toString()),
                  Text(testProfile.gender),
                ]),
              ),
            ),
            Container(
              width: width,
              padding: const EdgeInsets.fromLTRB(32, 12, 32, 12),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Column(children: [
                  Text("contact"),
                  Text(testProfile.phNum),
                  Text(testProfile.email),
                ]),
              ),
            ),
            Container(
              width: width,
              constraints: BoxConstraints(minHeight: width * 0.5),
              padding: const EdgeInsets.fromLTRB(32, 12, 32, 12),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                  child: Text(testProfile.description),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
