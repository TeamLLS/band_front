import 'package:flutter/material.dart';

class MyClubsPage extends StatefulWidget {
  const MyClubsPage({super.key});

  @override
  State<MyClubsPage> createState() => _MyClubsPageState();
}

class _MyClubsPageState extends State<MyClubsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text("my club list"),
      ),
    );
  }
}
