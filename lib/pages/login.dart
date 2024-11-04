import 'dart:developer';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter/material.dart';
import '../cores/api.dart';

class KakaoSignMethod {
  Future<void> getKakaoKeyHash() async {
    var key = await KakaoSdk.origin;
    debugPrint("!!! hash key : $key");
    return;
  }

  Future<String?> signInKakao() async {
    OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
    log('!!! login with kakao : ${token.toString()}');
    return token.accessToken;
  }

  Future<void> signOutKakao() async {
    try {
      UserApi.instance.logout();
    } catch (error) {
      debugPrint('!!! 카카오 로그인 실패 $error');
    }
  }
}

class SignView extends StatefulWidget {
  const SignView({super.key});

  @override
  State<SignView> createState() => _SignViewState();
}

class _SignViewState extends State<SignView> {
  Future<bool> kakaoLogin() async {
    var kakaoLoginHelper = KakaoSignMethod();
    String? kakaoToken = await kakaoLoginHelper.signInKakao();
    if (kakaoToken == null) {
      log("accToken err");
      return false;
    }
    log("kakao accessToken: $kakaoToken");
    //await LogInLegacyApi.login(kakaoToken);
    await LogInApi.logInToServer("kakao", kakaoToken);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async => context.go('/myClubList'),
                  child: const Text("pass without login"),
                ),
                ElevatedButton(
                  onPressed: () async => context.go('/myClubList'),
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
                    var helper = KakaoSignMethod();
                    await helper.getKakaoKeyHash();
                  },
                  child: const Text("get hash key"),
                ),
                ElevatedButton(
                  onPressed: () async => await LogInApi.checkServer(),
                  child: const Text("check server to debug console"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
