import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'apiutils.dart';

class AuthInfoApi {
  final String _url =
      "https://v7csinomac.execute-api.ap-northeast-2.amazonaws.com";
  String? _accessToken;
  String? _refreshToken;
  String? _username;

  //make class to singleton
  AuthInfoApi._privateConstructor();
  static final AuthInfoApi _instance = AuthInfoApi._privateConstructor();
  factory AuthInfoApi() => _instance;

  //getter
  String get url => _url;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get username => _username;

  void cleanUpToken() {
    _accessToken = null;
    _refreshToken = null;
    _username = null;
    log("!!! clean Tokens");
  }

  //setter
  void setAccessToken({required String accessToken}) {
    _accessToken = accessToken;
  }

  void setRefreshToken({required String refreshToken}) {
    _refreshToken = refreshToken;
  }

  void setUserName(String username) {
    _username = username;
  }
}

class LogInApi {
  static final AuthInfoApi _authInfoApi = AuthInfoApi();

  //서버 상태 체크
  static Future<void> checkServer() async {
    Uri url = Uri.parse("${_authInfoApi.url}/user/heahth_check");

    bool result = await HttpInterface.requestGetWithoutHeader(url);
    if (result == true) {
      log("server open");
    } else {
      log("server closed");
    }
  }

  //로그인 테스트(쓰지 않는다)
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

  //로그인
  static Future<bool> logInToServer(String provider, String kakaoToken) async {
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

  //액세스 토큰 재발급
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

  //로그아웃
  static Future<void> logoutFromServer() async {
    Uri url = Uri.parse("${_authInfoApi.url}/user/logout");
    Map<String, String> header = {'accessToken': '${_authInfoApi.accessToken}'};
  }

  //Dummy_A용 메소드
  //유저네임 auth에 등록
  static void setUserName(String username) {
    _authInfoApi.setUserName(username);
  }

  //auth 출력
  static void printAuth() {
    log("access token : ${_authInfoApi.accessToken}");
    log("refresh token : ${_authInfoApi.refreshToken}");
    log("username : ${_authInfoApi.username}");
  }

  static String? getUserName() {
    return _authInfoApi.username;
  }
}

class ProfileApi {
  static final AuthInfoApi _authInfoApi = AuthInfoApi();

  //내 프로필 조회
  static Future<dynamic> getMyProfile() async {
    Uri url = Uri.parse("${_authInfoApi.url}/user/profile/me");
    Map<String, String> header = {
      'Authorization': 'Bearer ${_authInfoApi.accessToken}'
    };
    log("[[[ profile downloaded ]]]");

    dynamic data = await HttpInterface.requestGet(url, header);
    if (data == null) {
      log("err from getMyProfile");
      return null;
    }

    return data;
  }

  //상대 프로필 조회
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

  //내 프로필 변경 -> 검사 필요
  static Future<bool> changeMyProfile(
    String email,
    bool emailChanged,
    String phNum,
    bool phNumChanged,
    String description,
    bool descriptionChanged,
    XFile? image,
    bool imageChanged,
  ) async {
    Uri url = Uri.parse("${_authInfoApi.url}/user/profile");
    Map<String, String> header = {'username': _authInfoApi.username!};
    Map<String, dynamic> body;
    if (image == null) {
      body = {
        "email": email,
        "emailChanged": emailChanged,
        "phNum": phNum,
        "phNumChanged": phNumChanged,
        "description": description,
        "descriptionChanged": descriptionChanged,
        "image": null,
        "imageChanged": false,
      };
      log("${_authInfoApi.username}'s value, in not image change func, email : $email, phNum : $phNum, description : $description");
    } else {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      body = {
        "email": email,
        "emailChanged": emailChanged,
        "phNum": phNum,
        "phNumChanged": phNumChanged,
        "description": description,
        "descriptionChanged": descriptionChanged,
        "image": base64Image,
        "imageChanged": imageChanged,
      };
      log("${_authInfoApi.username}'s value, in set image change func, email : $email, phNum : $phNum, description : $description");
    }

    dynamic data = await HttpInterface.requestPatch(url, header, body);
    if (data == null) {
      log("err from getMyClubList");
      return false;
    }

    return true;
  }
}

class ClubApi {
  static final AuthInfoApi _authInfoApi = AuthInfoApi();

  //클럽 생성
  static Future<bool> createClub(
    String name,
    String description,
    String image,
    String contactInfo,
  ) async {
    Uri url = Uri.parse("${_authInfoApi.url}/club");
    Map<String, String> header = {'username': _authInfoApi.username!};
    Map<String, dynamic> body = {
      "name": name,
      "description": description,
      "image": "null",
      "contactInfo": contactInfo,
    };
    log("create start");
    dynamic data = await HttpInterface.requestPost(url, header, body);
    if (data == null) {
      log("err from createClub");
      return false;
    }
    return true;
  }

  //내 클럽 리스트 조회
  static Future<dynamic> getMyClubList(int pn) async {
    Uri url = Uri.parse("${_authInfoApi.url}/member/club/list?pageNo=$pn");
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGet(url, header);
    if (data == null) {
      log("err from getMyClubList");
      return;
    }

    return data;
  }

  // 클럽 정보 조회
  static Future<dynamic> getClubDetail(int clubId) async {
    Uri url = Uri.parse("${_authInfoApi.url}/club/$clubId");
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGet(url, header);
    if (data == null) {
      log("err from getMyClubList");
      return;
    }

    return data;
  }

  // 클럽 정보 변경

  // 클럽 회원 조회
  static Future<dynamic> getClubMemberList(int clubId, int pn) async {
    Uri url = Uri.parse("${_authInfoApi.url}/member/$clubId/list?pageNo=$pn");
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGet(url, header);
    if (data == null) {
      log("err from getClubMemberList");
      return;
    }

    return data;
  }

  // 클럽 해체
  // 회원 등록
  // 회원 권한 변경
  // 회원 강퇴

  // 회원 탈퇴
  static Future<bool> deleteClub(int clubId) async {
    Uri url = Uri.parse("${_authInfoApi.url}/member/$clubId/withdraw");
    Map<String, String> header = {'username': _authInfoApi.username!};

    return await HttpInterface.requestPatchWithoutBody(url, header);
  }
}

class ActivityApi {
  static final AuthInfoApi _authInfoApi = AuthInfoApi();

  // 활동 생성

  // 활동 목록 조회
  static Future<dynamic> getActivityList(int clubId, int pn) async {
    Uri url = Uri.parse("${_authInfoApi.url}/activity/$clubId/list?pageNo=$pn");
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGet(url, header);
    if (data == null) {
      log("err from getActivityList");
      return;
    }

    return data;
  }

  // 활동 조회
  static Future<dynamic> getActivityDetail(int actId) async {
    Uri url = Uri.parse("${_authInfoApi.url}/activity/$actId");
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGet(url, header);
    if (data == null) {
      log("err from getActivityDetail");
      return;
    }

    return data;
  }

  // 나의 참가 활동 조회

  // 참가자 조회
  static Future<dynamic> getParticipant(int actId, int pn) async {
    Uri url = Uri.parse(
      "${_authInfoApi.url}/participant/$actId/list?pageNo=$pn",
    );
    Map<String, String> header = {'username': _authInfoApi.username!};
    dynamic data = await HttpInterface.requestGet(url, header);

    if (data == null) {
      log("err from getActivityDetail");
      return;
    }

    return data;
  }

  // 활동 취소
  // 활동 종료
  // 활동 불참
  // 활동 추가참가
  // 활동 추가불참

  // 활동 참가
  static Future<bool> attendActivity(int clubId, int activityId) async {
    Uri url = Uri.parse(
      "${_authInfoApi.url}/activity/$clubId/$activityId/attend",
    );
    Map<String, String> header = {'username': _authInfoApi.username!};

    await HttpInterface.requestPostWithoutBody(url, header);
    return true;
  }
}
