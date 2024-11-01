import 'dart:developer';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter/material.dart';
import '../api.dart';

class KakaoLoginHelper {
  Future<void> getKakaoKeyHash() async {
    var key = await KakaoSdk.origin;
    debugPrint("!!! hash key : $key");
    return;
  }

  Future<String?> login() async {
    OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
    log('!!! login with kakao : ${token.toString()}');
    return token.accessToken;
  }

  Future<void> logout() async {
    try {
      UserApi.instance.logout();
    } catch (error) {
      debugPrint('!!! 카카오 로그인 실패 $error');
    }
  }
}

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  Future<bool> kakaoLogin() async {
    var kakaoLoginHelper = KakaoLoginHelper();
    String? accessToken = await kakaoLoginHelper.login();
    if (accessToken == null) {
      debugPrint("!!! accToken err");
      return false;
    }
    debugPrint("!!! accessToken: $accessToken");
    await LogInApi.login(accessToken);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async => context.go('/myClubList'),
              child: const Text("pass without login"),
            ),
            ElevatedButton(
              onPressed: () async {
                context.go('/myClubList');
              },
              child: const Text("pass with test user"),
            ),
            ElevatedButton(
              onPressed: () async {
                await kakaoLogin().then(
                  (bool result) {
                    if (result == false) {
                      debugPrint("!!! login fail");
                      return;
                    }
                    context.go('/myClubList');
                  },
                );
              },
              child: const Text("kakao login"),
            ),
            ElevatedButton(
              onPressed: () async {
                var helper = KakaoLoginHelper();
                await helper.getKakaoKeyHash();
              },
              child: const Text("get hash key"),
            ),
          ],
        ),
      ),
    );
  }
}
