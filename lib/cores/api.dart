import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'apiutils.dart';

class AuthInfoApi {
  final String _url =
      "https://v7csinomac.execute-api.ap-northeast-2.amazonaws.com";
  String? _accessToken;
  String? _refreshToken;

  //make class to singleton
  AuthInfoApi._privateConstructor();
  static final AuthInfoApi _instance = AuthInfoApi._privateConstructor();
  factory AuthInfoApi() => _instance;

  //getter
  String get url => _url;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  void cleanUpToken() {
    _accessToken = null;
    _refreshToken = null;
    log("!!! clean Tokens");
  }

  //setter
  void setAccessToken({required String accessToken}) {
    _accessToken = accessToken;
  }

  void setRefreshToken({required String refreshToken}) {
    _refreshToken = refreshToken;
  }
}

class LogInLegacyApi {
  static final AuthInfoApi _authInfoApi = AuthInfoApi();

  static Future<void> login(String accessToken) async {
    //1. token 저장
    _authInfoApi.setAccessToken(accessToken: accessToken);

    var url = Uri.parse("${_authInfoApi.url}/user/login");
    var header = {
      'token': '${_authInfoApi.accessToken}',
      'provider': "kakao",
    };

    http.Response? response =
        await HttpLegacy.tryPostWithoutBody("log in", url, header);

    if (response == null) {
      debugPrint('!!! login to server error!');
      return;
    }

    var data = jsonDecode(response.body);
    _authInfoApi.setAccessToken(accessToken: data['accessToken']);
    _authInfoApi.setRefreshToken(refreshToken: data['refreshToken']);
    debugPrint("!!! log in success");
    return;
  }

  static Future<void> reissue() async {
    var url = Uri.parse("${_authInfoApi.url}/user/refresh");
    var header = {'token': '${_authInfoApi.refreshToken}'};

    http.Response? response = await HttpLegacy.tryGet("reissue", url, header);

    if (response == null) {
      debugPrint('!!! reissue from server error!');
      return;
    }

    var data = jsonDecode(response.body);
    _authInfoApi.setAccessToken(accessToken: data['accessToken']);
    _authInfoApi.setRefreshToken(refreshToken: data['refreshToken']);
    debugPrint("!!! reissue success");
    return;
  }

  static Future<void> logout() async {
    var url = Uri.parse("${_authInfoApi.url}/user/logout");
    var header = {'accessToken': '${_authInfoApi.accessToken}'};

    http.Response? response = await HttpLegacy.tryGet("logout", url, header);

    if (response == null) {
      debugPrint('!!! logout to server error!');
      return;
    }

    _authInfoApi.cleanUpToken();
    return;
  }
}

class LogInApi {
  static final AuthInfoApi _authInfoApi = AuthInfoApi();

  static Future<void> checkServer() async {
    Uri url = Uri.parse("${_authInfoApi.url}/user/heahth_check");

    bool result = await HttpInterface.requestGetWithoutHeader(url);
    if (result == true) {
      log("server open");
    } else {
      log("server closed");
    }
  }

  static Future<void> testLogIn(String accessToken) async {
    Uri url = Uri.parse("${_authInfoApi.url}/user/authorize_test");
    Map<String, String> header = {'accessToken': accessToken};

    dynamic data = await HttpInterface.requestGet(url, header);
    if (data == null) {
      log("err from getMyProfile");
      return;
    }
    log(data['username']);
    return;
  }

  static Future<bool> logInToServer(
    String provider,
    String kakaoToken,
  ) async {
    Uri url = Uri.parse("${_authInfoApi.url}/user/login");
    Map<String, String> header = {
      'token': kakaoToken,
      'provider': "kakao",
    };

    dynamic data = await HttpInterface.requestPostWithoutBody(url, header);
    if (data == null) {
      log("err from logIntoServer");
      return false;
    }

    _authInfoApi.setAccessToken(accessToken: data['accessToken']);
    _authInfoApi.setRefreshToken(refreshToken: data['refreshToken']);
    return true;
  }

  static Future<bool> reissueFromServer() async {
    Uri url = Uri.parse("${_authInfoApi.url}/user/refresh");
    Map<String, String> header = {'token': '${_authInfoApi.refreshToken}'};

    dynamic data = await HttpInterface.requestPostWithoutBody(url, header);
    if (data == null) {
      log("err from reissueFromServer");
      return false;
    }

    _authInfoApi.setAccessToken(accessToken: data['accessToken']);
    _authInfoApi.setRefreshToken(refreshToken: data['refreshToken']);
    return true;
  }

  static Future<void> logoutFromServer() async {
    Uri url = Uri.parse("${_authInfoApi.url}/user/logout");
    Map<String, String> header = {'accessToken': '${_authInfoApi.accessToken}'};
  }
}

class ProfileApi {
  static final AuthInfoApi _authInfoApi = AuthInfoApi();

  static Future<dynamic> getMyProfile() async {
    Uri url = Uri.parse("${_authInfoApi.url}/user/profile/me");
    Map<String, String> header = {'accessToken': '${_authInfoApi.accessToken}'};

    dynamic data = await HttpInterface.requestGet(url, header);
    if (data == null) {
      log("err from getMyProfile");
      return null;
    }
    return data;
  }

  static Future<dynamic> getUserProfile(String userName) async {
    Uri url = Uri.parse("${_authInfoApi.url}/user/profile/$userName");
    Map<String, String> header = {'accessToken': '${_authInfoApi.accessToken}'};

    dynamic data = await HttpInterface.requestGet(url, header);
    if (data == null) {
      log("err from getUserProfile");
      return null;
    }
    return data;
  }

  static Future<bool> changeMyProfile(
    String email,
    bool emailChanged,
    String phNum,
    bool phNumChanged,
    String description,
    bool descriptionChanged,
    dynamic image,
    bool imageChanged,
  ) async {
    Uri url = Uri.parse("${_authInfoApi.url}/user/profile");
    Map<String, String> header = {'accessToken': '${_authInfoApi.accessToken}'};
    Map<String, dynamic> body = {
      'email': email,
      'emailChanged': emailChanged,
      'phNum': phNum,
      'phNumChanged': phNumChanged,
      'description': description,
      'descriptionChanged': descriptionChanged,
      'image': image,
      'imageChanged': imageChanged,
    };

    return await HttpInterface.requestPatch(url, header, body);
  }
}
