// dependencies
import 'package:band_front/customwidgets.dart';
import 'package:flutter/material.dart';

// pages
import '../dataclass.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

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
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
              child: Column(children: [
                desUnit(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      Text(testUser.username),
                      const Divider(thickness: 0.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(testUser.name!),
                          Text("-1(age)"),
                          Text(testUser.gender!),
                        ],
                      ),
                    ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
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
                          Text(testUser.phNum!),
                        ]),
                        Row(children: [
                          const VerticalDivider(),
                          const Icon(Icons.email),
                          const VerticalDivider(),
                          Text(testUser.email!),
                        ]),
                      ]),
                    ),
                  ),
                ),
                desUnit(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(testUser.description!),
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
