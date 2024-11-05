// dependencies
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';

// local dependencies
import 'package:band_front/cores/router.dart';
import 'cores/repositories.dart';
import 'pages/profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: 'da277fdee5d64ec9860898fbcfea84f1',
    javaScriptAppKey: '878ec2f98c8645c0734c4c4499d7cb65',
  );

  runApp(const BandApp());
}

class BandApp extends StatelessWidget {
  const BandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileInfoRepository()),
      ],
      child: MaterialApp.router(
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
          // cardTheme: CardTheme(
          //   clipBehavior: Clip.antiAlias,
          //   shadowColor: Colors.black.withOpacity(1),
          //   elevation: 10.0,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(50.0),
          //   ),
          // ),
          listTileTheme: ListTileThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0),
              side: BorderSide(width: 0.2),
            ),
            tileColor: Colors.white,
            selectedTileColor: Colors.grey.shade200, // 선택된 타일의 배경색
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
      ),
    );
  }
}
