import 'dart:developer';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter/material.dart';
import '../cores/api.dart';
import '../cores/widgetutils.dart';

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
  Future<bool> login() async {
    var kakao = KakaoSignMethod();
    String? kakaoToken = await kakao.signInKakao();
    if (kakaoToken == null) {
      log("accToken err");
      return false;
    }

    log("kakao accessToken: $kakaoToken");
    await LogInApi.logInToServer("kakao", kakaoToken);
    return true;
  }

  void loginHandler(bool result) {
    if (result == false) {
      showSnackBar(context, "로그인 실패..");
      return;
    }
    showSnackBar(context, "로그인 성공");
    context.go('/myClubList');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 64),
            child: Column(children: [
              const Spacer(),
              InkWell(
                onTap: () async {
                  bool result = await login();
                  loginHandler(result);
                },
                child: Image.asset("assets/images/kakao_login_btn.png"),
              ),
            ]),
          ),
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
                    var helper = KakaoSignMethod();
                    await helper.getKakaoKeyHash();
                  },
                  child: const Text("get hash key"),
                ),
                ElevatedButton(
                  onPressed: () async => await LogInApi.checkServer(),
                  child: const Text("check server"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
