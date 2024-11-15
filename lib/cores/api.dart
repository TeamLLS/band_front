import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'api_utils.dart';

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
  static Future<dynamic> getMyInfo() async {
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
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGet(url, header);
    if (data == null) {
      log("err from getUserProfile");
      return null;
    }
    return data;
  }

  //내 프로필 변경
  static Future<bool> changeMyInfo(
    String? email,
    String? phNum,
    String? description,
    XFile? image,
  ) async {
    Uri url = Uri.parse("${_authInfoApi.url}/user/profile");
    var request = http.MultipartRequest('PATCH', url);

    //insert header
    request.headers['username'] = _authInfoApi.username!;

    //insert body
    if (image != null) {
      var file = await http.MultipartFile.fromPath('image', image.path);
      request.files.add(file);
      request.fields['imageChanged'] = "true";
    } else {
      request.fields['imageChanged'] = "false";
    }
    if (email != null) {
      request.fields['email'] = email;
      request.fields['emailChanged'] = "true";
    } else {
      request.fields['emailChanged'] = "false";
    }
    if (phNum != null) {
      request.fields['phNum'] = phNum;
      request.fields['phNumChanged'] = "true";
    } else {
      request.fields['phNumChanged'] = "false";
    }
    if (description != null) {
      request.fields['description'] = description;
      request.fields['descriptionChanged'] = "true";
    } else {
      request.fields['descriptionChanged'] = "false";
    }

    return await HttpInterface.requestMultipart(request);
  }

  static Future<void> test(XFile imageFile) async {
    Uri uri = Uri.parse("${_authInfoApi.url}/user/profile");

    // 요청 객체 생성
    var request = http.MultipartRequest('PATCH', uri);

    request.headers['username'] = _authInfoApi.username!;

    var file = await http.MultipartFile.fromPath('image', imageFile.path);
    request.files.add(file);
    request.fields['email'] = "1234";
    request.fields['phNum'] = "1234";
    request.fields['description'] = "description";

    // Boolean 필드들
    request.fields['emailChanged'] = "true";
    request.fields['phNumChanged'] = "true";
    request.fields['descriptionChanged'] = "true";
    request.fields['imageChanged'] = "true";

    log("================request info==============");
    log("username : ${_authInfoApi._username}");

    // 요청 전송
    var response = await request.send();

    if (response.statusCode == 200) {
      log('============ Upload successful ============');
    } else {
      log('============ Upload failed ============');
      log("${response.statusCode}");
      Uint8List bytes = await response.stream.toBytes();
      String responseBody = utf8.decode(bytes);
      log("${responseBody}");
    }
  }

  static Future<void> test2(XFile imageFile) async {
    Uri uri = Uri.parse("${_authInfoApi.url}/user/profile");
    var file = File(imageFile.path);
    // 요청 객체 생성
    var request = http.MultipartRequest('PATCH', uri);

    request.headers['username'] = _authInfoApi.username!;

    // 3. MultipartFile로 파일을 추가합니다.
    var fileStream = http.MultipartFile.fromBytes(
      'image', // 서버에서 인식할 필드 이름
      await file.readAsBytes(),
      filename: file.uri.pathSegments.last,
    );
    request.files.add(fileStream);

    // hardcoding field
    request.fields['email'] = "1234";
    request.fields['phNum'] = "1234";
    request.fields['description'] = "description";
    request.fields['emailChanged'] = "true";
    request.fields['phNumChanged'] = "true";
    request.fields['descriptionChanged'] = "true";
    request.fields['imageChanged'] = "true";

    log("================request info==============");
    log("username : ${_authInfoApi._username}");

    // 요청 전송
    var response = await request.send();

    if (response.statusCode == 200) {
      log('============ Upload successful ============');
    } else {
      log('============ Upload failed ============');
    }
  }
}

class ClubApi {
  static final AuthInfoApi _authInfoApi = AuthInfoApi();

  //클럽 생성
  static Future<bool> createClub(
    String name,
    String description,
    XFile image,
    String contactInfo,
  ) async {
    Uri url = Uri.parse("${_authInfoApi.url}/club");

    // 요청 객체 생성
    var request = http.MultipartRequest('POST', url);

    request.headers['username'] = _authInfoApi.username!;

    var file = await http.MultipartFile.fromPath('image', image.path);
    request.files.add(file);
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['contactInfo'] = contactInfo;

    // 요청 전송
    return await HttpInterface.requestMultipart(request);
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
  static Future<bool> changeClubDetail(
    int clubId,
    String? name,
    String? description,
    String? status,
    XFile? image,
  ) async {
    Uri url = Uri.parse("${_authInfoApi.url}/club");
    var request = http.MultipartRequest('PATCH', url);

    //insert header
    request.headers['username'] = _authInfoApi.username!;

    //insert body
    if (image != null) {
      var file = await http.MultipartFile.fromPath('image', image.path);
      request.files.add(file);
      request.fields['imageChanged'] = "true";
    } else {
      request.fields['imageChanged'] = "false";
    }
    if (name != null) {
      request.fields['name'] = name;
      request.fields['nameChanged'] = "true";
    } else {
      request.fields['nameChanged'] = "false";
    }
    if (description != null) {
      request.fields['description'] = description;
      request.fields['descriptionChanged'] = "true";
    } else {
      request.fields['descriptionChanged'] = "false";
    }
    if (status != null) {
      request.fields['status'] = status;
      request.fields['statusChanged'] = "true";
    } else {
      request.fields['statusChanged'] = "false";
    }

    return await HttpInterface.requestMultipart(request);
  }

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
  static Future<bool> deleteMyClub(int clubId) async {
    Uri url = Uri.parse("${_authInfoApi.url}/club/$clubId/close");
    Map<String, String> header = {'username': _authInfoApi.username!};

    return await HttpInterface.requestPatchWithoutBody(url, header);
  }

  // 회원 등록
  static Future<dynamic> registMember(int clubId, String username) async {
    Uri url = Uri.parse("${_authInfoApi.url}/member");
    Map<String, String> header = {
      "Content-Type": "application/json",
      'username': _authInfoApi.username!,
    };
    Map<String, dynamic> body = {
      "clubId": clubId,
      "username": username,
    };

    dynamic data = await HttpInterface.requestPost(url, header, body);
    if (data == null) {
      log("err from registMember");
      return;
    }

    return data;
  }

  // 회원 권한 변경
  static Future<bool> changeMemberRole(int memberId, String role) async {
    Uri url = Uri.parse("${_authInfoApi.url}/member/role");
    Map<String, String> header = {
      "Content-Type": "application/json",
      'username': _authInfoApi.username!,
    };
    Map<String, dynamic> body = {"memberId": memberId, "role": role};

    return await HttpInterface.requestPatch(url, header, body);
  }

  // 회원 강퇴
  static Future<bool> removeMember(int memberId) async {
    Uri url = Uri.parse("${_authInfoApi.url}/member/$memberId/ban");
    Map<String, String> header = {'username': _authInfoApi.username!};

    return await HttpInterface.requestPatchWithoutBody(url, header);
  }

  // 회원 탈퇴, 아직 할당되지 않음
  static Future<bool> deleteMyFromClub(int clubId) async {
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
