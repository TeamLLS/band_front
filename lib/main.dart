import 'package:band_front/pages/router.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: '73a1fd675447ff78421025b9d793648d',
    javaScriptAppKey: 'cb88712593a98c7099de35c7dc12bfca',
  );

  runApp(const BandApp());
}

class BandApp extends StatelessWidget {
  const BandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: route,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
    );
  }
}
