import 'dart:developer';
import 'package:band_front/cores/repository.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cores/api.dart';
import '../cores/widget_utils.dart';

class KakaoSignMethod {
  Future<void> getKakaoKeyHash() async {
    var key = await KakaoSdk.origin;
    log("!!! hash key : $key");
    return;
  }

  Future<String?> signInKakao() async {
    OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
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

    //1. get kakao authorization
    String? kakaoToken = await kakao.signInKakao();
    if (kakaoToken == null) {
      log("accToken err");
      return false;
    }
    //log("kakao accessToken: $kakaoToken");

    //2. get server authorization
    bool result = await LogInApi.logInToServer("kakao", kakaoToken);
    if (result == false) {
      log("log in to server err");
      return false;
    }

    //3. get profile
    // ignore: use_build_context_synchronously
    result = await context.read<MyRepo>().getMyInfo();
    if (result == false) {
      log("get profile err");
      return false;
    }
    return true;
  }

  Future<bool> loginTestUser() async {
    String dummy = "Dummy_userA";
    LogInApi.setUserName(dummy);
    context.read<MyRepo>().setDummy(dummy);
    LogInApi.printAuth();
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
      body: Container(
        color: const Color(0xFFDCDCDA),
        child: Stack(
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
              child: Image.asset(
                'assets/images/appIcon.jpg',
                height: 200,
                width: 200,
              ),
            ),
            // Center(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       ElevatedButton(
            //         onPressed: () async => context.go('/myClubList'),
            //         child: const Text("pass without login"),
            //       ),
            //       ElevatedButton(
            //         onPressed: () async {
            //           bool result = await loginTestUser();
            //           loginHandler(result);
            //         },
            //         child: const Text("pass with test user"),
            //       ),
            //       ElevatedButton(
            //         onPressed: () async {
            //           var helper = KakaoSignMethod();
            //           await helper.getKakaoKeyHash();
            //         },
            //         child: const Text("get hash key"),
            //       ),
            //       ElevatedButton(
            //         onPressed: () async => await LogInApi.checkServer(),
            //         child: const Text("check server"),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
