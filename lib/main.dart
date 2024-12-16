// dependencies
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';

// local dependencies
import 'package:band_front/cores/router.dart';
import 'cores/repository.dart';
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
        ChangeNotifierProvider(create: (_) => MyRepo()),
        ChangeNotifierProvider(create: (_) => UserRepo()),
        ChangeNotifierProvider(create: (_) => BudgetRepo()),
        ChangeNotifierProvider(create: (_) => PaymentListRepo()),
        ChangeNotifierProvider(create: (_) => PaymentDetailRepo()),
        ChangeNotifierProvider(create: (_) => ClubDetailRepo()),
        ChangeNotifierProvider(create: (_) => ClubListRepo()),
        ChangeNotifierProvider(create: (_) => ActivityDetailRepo()),
        ChangeNotifierProvider(create: (_) => BoardRepo()),
        ChangeNotifierProvider(create: (_) => BoardPostDetailRepo()),
      ],
      child: MaterialApp.router(
        routerConfig: route,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus(); // 키보드 해제
            },
            child: child,
          );
        },
        theme: ThemeData(
          colorScheme: const ColorScheme(
            //라이트모드, 다크모드
            brightness: Brightness.light,
            // 로딩 인디케이터, 버튼, 앱바, 하이라이트되는 UI 요소 등의 기본 색상(글씨)
            // tabbar, bottomnavigator가 하이라이트 될 때
            // datepicker의 picked된 날짜를 칠한 색, 원래 지정되어있던 날짜를 나타내는 색
            primary: Colors.black,
            // primary가 주어지는 ui의 테두리, 글 색 등
            onPrimary: Colors.white,
            secondary: Colors.black, //timepicker am pm 하이라이트
            onSecondary: Colors.white,
            error: Colors.cyan,
            onError: Colors.blueAccent,
            surface: Colors.white,
            //버튼, 앱바, 하이라이트되는 UI 요소 등의 기본 색상(글씨)
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
