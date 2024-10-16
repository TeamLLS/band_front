import 'package:band_front/router.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:google_fonts/google_fonts.dart';
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
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light, //라이트모드, 다크모드
          primary: Colors.black, //버튼, 앱바, 하이라이트되는 UI 요소 등의 기본 색상(글씨)
          onPrimary: Colors.orange,
          secondary: Colors.yellow,
          onSecondary: Colors.green,
          error: Colors.cyan,
          onError: Colors.blueAccent,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
        cardTheme: CardTheme(
          clipBehavior: Clip.antiAlias,
          shadowColor: Colors.black.withOpacity(1),
          elevation: 10.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w600),
          displayMedium: TextStyle(fontWeight: FontWeight.w600),
          displaySmall: TextStyle(fontWeight: FontWeight.w600),
          headlineLarge: TextStyle(fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontWeight: FontWeight.w600), //appbar title
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontWeight: FontWeight.w600), //text widget
          bodySmall: TextStyle(fontWeight: FontWeight.w600),
          labelLarge: TextStyle(fontWeight: FontWeight.w600),
          labelMedium: TextStyle(fontWeight: FontWeight.w600),
          labelSmall: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
