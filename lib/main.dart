import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: '3cc9dbe84f884464bd5b85837b7ffb24',
    //javaScriptAppKey: 'f28be44086377e58689b77fd56e53787',
  );

  runApp(const Band());
}

class Band extends StatelessWidget {
  const Band({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LogInPage(title: 'Flutter Demo Home Page'),
    );
  }
}
