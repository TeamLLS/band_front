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

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
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
    log("logged in with $username");
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

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
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

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
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
      log("$responseBody");
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
    XFile? image,
    String contactInfo,
  ) async {
    Uri url = Uri.parse("${_authInfoApi.url}/club");

    // 요청 객체 생성
    var request = http.MultipartRequest('POST', url);

    request.headers['username'] = _authInfoApi.username!;

    if (image != null) {
      var file = await http.MultipartFile.fromPath('image', image.path);
      request.files.add(file);
    }
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

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
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

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
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
    String? contactInfo,
  ) async {
    log("===== changeClubDetail in api =====");
    log("clubId : $clubId");
    log("name : $name");
    log("description : $description");
    log("status : $status");
    log("contactInfo : $contactInfo");
    if (image == null) {
      log("image : null");
    } else {
      log("image : exist");
    }

    Uri url = Uri.parse("${_authInfoApi.url}/club");
    var request = http.MultipartRequest('PATCH', url);

    //insert header
    request.headers['username'] = _authInfoApi.username!;

    //insert body
    request.fields['clubId'] = clubId.toString();
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
    if (contactInfo != null) {
      request.fields['contactInfo'] = contactInfo;
      request.fields['contactInfoChanged'] = "true";
    } else {
      request.fields['contactInfoChanged'] = "false";
    }

    return await HttpInterface.requestMultipart(request);
  }

  // 클럽 회원 조회
  static Future<dynamic> getClubMemberList(int clubId, int pn) async {
    Uri url = Uri.parse("${_authInfoApi.url}/member/$clubId/list?pageNo=$pn");
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
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

  // 활동 목록 조회
  static Future<dynamic> getActivityList(int clubId, int pn) async {
    Uri url = Uri.parse("${_authInfoApi.url}/activity/$clubId/list?pageNo=$pn");
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
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

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
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
    dynamic data = await HttpInterface.requestGetLegacy(url, header);

    if (data == null) {
      log("err from getActivityDetail");
      return;
    }

    return data;
  }

  // 활동 등록
  static Future<bool> registActivity(
    int clubId,
    String name,
    String description,
    XFile image,
    String location,
    DateTime startTime,
    DateTime endTime,
    DateTime deadline,
  ) async {
    log("==== regist activity argument =====");
    log("club Id : $clubId");
    log("name : $name");
    log("description : $description");
    log("location : $location");
    log("startTime : $startTime");
    log("endTime : $endTime");
    log("deadline : $deadline");

    Uri url = Uri.parse("${_authInfoApi.url}/activity");

    // 요청 객체 생성
    var request = http.MultipartRequest('POST', url);

    // write header
    request.headers['username'] = _authInfoApi.username!;

    // import image
    var file = await http.MultipartFile.fromPath('image', image.path);
    request.files.add(file);

    request.fields['clubId'] = clubId.toString();
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['location'] = location;
    request.fields['startTime'] = startTime.toIso8601String();
    request.fields['endTime'] = endTime.toIso8601String();
    request.fields['deadline'] = deadline.toIso8601String();

    // 요청 전송
    return await HttpInterface.requestMultipart(request);
  }

  // 활동 모집 취소
  static Future<bool> removeActivity(int clubId, int activityId) async {
    Uri url = Uri.parse(
      "${_authInfoApi.url}/activity/$clubId/$activityId/cancel",
    );
    Map<String, String> header = {'username': _authInfoApi.username!};
    log("===== in api =====");
    log("clubId : $clubId");
    log("activityId : $activityId");
    log("==================");

    return await HttpInterface.requestPatchWithoutBody(url, header);
  }

  // 활동 모집 종료
  static Future<dynamic> closeActivity(int clubId, int activityId) async {
    Uri url = Uri.parse(
      "${_authInfoApi.url}/activity/$clubId/$activityId/close",
    );
    Map<String, String> header = {'username': _authInfoApi.username!};
    log("===== in api =====");
    log("clubId : $clubId");
    log("activityId : $activityId");
    log("==================");
    return await HttpInterface.requestPostWithoutBody(url, header);
  }

  // 활동 참가
  static Future<bool> attendActivity(int clubId, int activityId) async {
    Uri url = Uri.parse(
      "${_authInfoApi.url}/activity/$clubId/$activityId/attend",
    );
    Map<String, String> header = {'username': _authInfoApi.username!};

    await HttpInterface.requestPostWithoutBody(url, header);
    return true;
  }

  // 활동 불참
  static Future<bool> withdrawActivity(int clubId, int activityId) async {
    Uri url = Uri.parse(
      "${_authInfoApi.url}/activity/$clubId/$activityId/not-attend",
    );
    Map<String, String> header = {'username': _authInfoApi.username!};

    await HttpInterface.requestPostWithoutBody(url, header);
    return true;
  }

  // 활동 추가참가
  static Future<bool> attendLateActivity(
    int clubId,
    int activityId,
    String id,
  ) async {
    log("===== argument check in api =====");
    log("clubId : $clubId");
    log("activityId : $activityId");
    log("username : $id");
    log("username in header : ${_authInfoApi.username!}");
    Uri url = Uri.parse(
      "${_authInfoApi.url}/activity/$clubId/$activityId/attend/additional?target=$id",
    );
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic ret = await HttpInterface.requestPostWithoutBody(url, header);
    if (ret == null) return false;
    return true;
  }

  // 활동 추가불참
  static Future<bool> withdrawLateActivity(
    int clubId,
    int activityId,
    String id,
  ) async {
    Uri url = Uri.parse(
      "${_authInfoApi.url}/activity/$clubId/$activityId/not-attend/additional?target=$id",
    );
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic ret = await HttpInterface.requestPostWithoutBody(url, header);
    if (ret == null) return false;
    return true;
  }
}

class BudgetApi {
  static final AuthInfoApi _authInfoApi = AuthInfoApi();

  /// 모든 회원 접근 가능
  // 시간에 따른 예산 누적 액수 조회
  static Future<dynamic> getBudgetAmount(int clubId, DateTime? time) async {
    Uri url;
    if (time == null) {
      url = Uri.parse("${_authInfoApi.url}/budget/$clubId");
    } else {
      String timeParam = time.toUtc().toIso8601String();
      url = Uri.parse("${_authInfoApi.url}/budget/$clubId?time=$timeParam");
    }
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getBudgetAmount");
      return;
    }

    return data;
  }

  // 시간에 따른 납부 내역 조회
  static Future<dynamic> getBudgetRecord(
    int clubId,
    int pn,
    DateTime? time,
  ) async {
    Uri url;
    if (time == null) {
      url = Uri.parse("${_authInfoApi.url}/budget/$clubId/records?pageNo=$pn");
    } else {
      String timeParam = time.toUtc().toIso8601String();
      url = Uri.parse(
        "${_authInfoApi.url}/budget/$clubId/records?pageNo=$pn&time=$timeParam",
      );
    }
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getBudgetRecord");
      return;
    }

    log("===== get budget record in repo =====");
    log("$data");

    return data;
  }

  // 회비 납부 장부 목록 조회
  static Future<dynamic> getPaymentList(int clubId, int pn) async {
    Uri url = Uri.parse("${_authInfoApi.url}/paybook/$clubId/list?pageNo=$pn");
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getBudgetRecord");
      return;
    }

    return data;
  }

  // 회비 납부 장부 조회
  static Future<dynamic> getPayment(int payId) async {
    Uri url = Uri.parse("${_authInfoApi.url}/paybook/$payId");
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getPayment");
      return;
    }

    return data;
  }

  //특정 장부의 납부 대상 목록 조회 : 해당 장부의 납부 대상 목록 조회
  static Future<dynamic> getPaymentTargets(int paymentId, int pn) async {
    Uri url = Uri.parse(
      "${_authInfoApi.url}/paymember/$paymentId/list?pageNo=$pn",
    );
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getPaymentTargets");
      return;
    }

    return data;
  }

  //내 장부 목록 조회 : 내가 등록된 장부 목록 조회, 디버깅용으로만 쓰고 출력은 하지말것
  static Future<dynamic> getMyPayments(int clubId) async {
    Uri url = Uri.parse(
      "${_authInfoApi.url}/paymember/$clubId/paybook/list?pageNo=0",
    );
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getMyPayments");
      return;
    }

    return data;
  }

  /// 관리 api
  // 예산 갱신
  static Future<dynamic> writeExpense(
    int clubId,
    int amount,
    String description,
  ) async {
    Uri url = Uri.parse("${_authInfoApi.url}/budget");
    Map<String, String> header = {
      "Content-Type": "application/json",
      'username': _authInfoApi.username!,
    };
    Map<String, dynamic> body = {
      "clubId": clubId,
      "description": description,
      "amount": amount,
    };

    dynamic data = await HttpInterface.requestPost(url, header, body);
    if (data == null) {
      log("err from writeExpense");
      return;
    }

    return data;
  }

  //장부 생성, amount = 회비
  static Future<dynamic> registPayment(
    int clubId,
    int amount,
    String name,
    String description,
    DateTime deadline, //need to utc
  ) async {
    Uri url = Uri.parse("${_authInfoApi.url}/paybook");
    Map<String, String> header = {
      "Content-Type": "application/json",
      'username': _authInfoApi.username!,
    };
    Map<String, dynamic> body = {
      "clubId": clubId,
      "amount": amount,
      "name": name,
      "description": description,
      "deadline": deadline.toIso8601String(),
    };

    log("regist info - amount : $amount, name : $name, des : $description, clubId : $clubId");

    dynamic data = await HttpInterface.requestPost(url, header, body);
    if (data == null) {
      log("err from registPayment");
      return;
    }

    return data;
  }

  //장부 취소
  static Future<bool> cancelPayment(int clubId, int paymentId) async {
    Uri url =
        Uri.parse("${_authInfoApi.url}/paybook/$clubId/$paymentId/cancel");

    Map<String, String> header = {'username': _authInfoApi.username!};
    log("===== cancelPayment api =====");
    log("clubId : $clubId");
    log("paymentId : $paymentId");

    return await HttpInterface.requestPatchWithoutBody(url, header);
  }

  //장부 만료
  static Future<bool> expirePayment(int clubId, int paymentId) async {
    Uri url = Uri.parse("${_authInfoApi.url}/paybook/$clubId/$paymentId/close");

    Map<String, String> header = {'username': _authInfoApi.username!};
    log("===== expirePayment api =====");
    log("clubId : $clubId");
    log("paymentId : $paymentId");

    return await HttpInterface.requestPatchWithoutBody(url, header);
  }

  /// 납부 대상 상호작용
  //납부 대상 등록-전체 (디폴트로 장부 생성 시 동작)
  static Future<bool> selectAllMember(int clubId, int paymentId) async {
    Uri url = Uri.parse("${_authInfoApi.url}/paymember/$clubId/$paymentId/all");

    Map<String, String> header = {'username': _authInfoApi.username!};
    log("===== selectAllMember api =====");
    log("clubId : $clubId");
    log("paymentId : $paymentId");

    return await HttpInterface.requestPostWithoutBody(url, header);
  }

  //납부 대상 등록-선택
  static Future<bool> selectMember(
    int clubId,
    int paymentId,
    int memberId,
  ) async {
    Uri url = Uri.parse("${_authInfoApi.url}/paymember/list");
    Map<String, String> header = {'username': _authInfoApi.username!};
    Map<String, dynamic> body = {
      'clubId': clubId,
      'payBookId': paymentId,
      'list': [memberId],
    };

    log("===== selectMember api =====");
    log("clubId : $clubId");
    log("paymentId : $paymentId");
    log("memberId : $paymentId");
    return await HttpInterface.requestPost(url, header, body);
  }

  //특정 회원 납부 대상 제외
  static Future<bool> excludeMember(int paymentId, int memberId) async {
    Uri url =
        Uri.parse("${_authInfoApi.url}/paymember/$paymentId/$memberId/exclude");
    Map<String, String> header = {'username': _authInfoApi.username!};

    return await HttpInterface.requestPatchWithoutBody(url, header);
  }

  /// 회원 납부 상황 변경
  //납부됨
  static Future<bool> setPaid(int paymentId, int memberId) async {
    Uri url =
        Uri.parse("${_authInfoApi.url}/paymember/$paymentId/$memberId/pay");
    Map<String, String> header = {
      "Content-Type": "application/json", // << 기입 필요
      'username': _authInfoApi.username!,
    };
    // String 객체를 위한 작은 따옴표
    // json형식 문자열 인식을 위해 작은 따옴표 안에 큰 따옴표
    String body = '"${DateTime.now().toUtc().toIso8601String()}"';

    log("======== setPaid api ========");
    log("paymentId : $paymentId");
    log("memberId : $memberId");
    log("header : $header");
    log("body : $body");

    try {
      final response = await http.patch(url, headers: header, body: body);

      if (response.statusCode == 200) {
        log('Success: ${response.body}');
        return true;
      } else {
        log('Failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      log('Error: $e');
      return false;
    }
  }

  //미납됨
  static Future<bool> setUnpaid(int paymentId, int memberId) async {
    Uri url =
        Uri.parse("${_authInfoApi.url}/paymember/$paymentId/$memberId/unpay");

    Map<String, String> header = {'username': _authInfoApi.username!};
    log("===== setUnpaid api =====");
    log("clubId : $paymentId");
    log("paymentId : $memberId");

    return await HttpInterface.requestPatchWithoutBody(url, header);
  }

  //연체 납부됨
  static Future<bool> setLatepaid(int paymentId, int memberId) async {
    Uri url = Uri.parse(
        "${_authInfoApi.url}/paymember/$paymentId/$memberId/late-pay");

    Map<String, String> header = {
      "Content-Type": "application/json", // << 기입 필요
      'username': _authInfoApi.username!,
    };
    // String 객체를 위한 작은 따옴표
    // json형식 문자열 인식을 위해 작은 따옴표 안에 큰 따옴표
    String body = '"${DateTime.now().toUtc().toIso8601String()}"';

    log("======== setLatepaid api ========");
    log("paymentId : $paymentId");
    log("memberId : $memberId");
    log("header : $header");
    log("body : $body");

    try {
      final response = await http.patch(url, headers: header, body: body);

      if (response.statusCode == 200) {
        log('Success: ${response.body}');
        return true;
      } else {
        log('Failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      log('Error: $e');
      return false;
    }
  }
}

class StatisticsApi {
  static final AuthInfoApi _authInfoApi = AuthInfoApi();

  // 회원수 변화 조회
  static Future<dynamic> getMemberStatistics(int clubId, DateTime? time) async {
    Uri url;
    if (time == null) {
      url = Uri.parse("${_authInfoApi.url}/data/club/$clubId/member");
    } else {
      String timeParam = time.toUtc().toIso8601String();
      url = Uri.parse(
        "${_authInfoApi.url}/data/club/$clubId/member?fromTime=$timeParam",
      );
    }

    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getMemberStatistics");
      return;
    }

    log("===== getMemberStatistics in api =====");
    log("$data");

    return data;
  }

  // 활동수 변화 조회
  static Future<dynamic> getActivityStatistics(
    int clubId,
    DateTime? time,
  ) async {
    Uri url;
    if (time == null) {
      url = Uri.parse("${_authInfoApi.url}/data/club/$clubId/activity");
    } else {
      String timeParam = time.toUtc().toIso8601String();
      url = Uri.parse(
        "${_authInfoApi.url}/data/club/$clubId/activity?fromTime=$timeParam",
      );
    }

    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getMemberStatistics");
      return;
    }

    log("===== getActivityStatistics in api =====");
    log("$data");

    return data;
  }

  // 예산 변화 조회
  static Future<dynamic> getBudgetStatistics(
    int clubId,
    DateTime? time,
  ) async {
    Uri url;
    if (time == null) {
      url = Uri.parse("${_authInfoApi.url}/data/club/$clubId/budget");
    } else {
      String timeParam = time.toUtc().toIso8601String();

      url = Uri.parse(
        "${_authInfoApi.url}/data/club/$clubId/budget?fromTime=$timeParam",
      );
    }

    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getBudgetStatistics");
      return;
    }

    log("===== getBudgetStatistics in api =====");
    log("$data");

    return data;
  }

  // 모임 내 회원들의 순위 조회
  static Future<dynamic> getRankStatistics(int clubId, int? option) async {
    Uri url;
    if (option == null) {
      url = Uri.parse("${_authInfoApi.url}/data/member/$clubId/rank");
    } else {
      url = Uri.parse(
          "${_authInfoApi.url}/data/member/$clubId/rank?option=$option");
    }

    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getRankStatistics");
      return;
    }

    return data;
  }

  // 개인 회원 점수 조회
  static Future<dynamic> getScoreStatistics(int clubId, int memberId) async {
    Uri url =
        Uri.parse("${_authInfoApi.url}/data/member/$clubId/$memberId/score");

    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getScoreStatistics");
      return;
    }

    return data;
  }

  // 참가율 변화 조회
  static Future<dynamic> getParticipationRateStatistics(
    int clubId,
    int memberId,
    DateTime? time,
  ) async {
    Uri url;
    if (time == null) {
      url = Uri.parse(
        "${_authInfoApi.url}/data/member/$clubId/$memberId/participant",
      );
    } else {
      String timeParam = time.toUtc().toIso8601String();
      url = Uri.parse(
        "${_authInfoApi.url}/data/member/$clubId/$memberId/participant?fromTime=$timeParam",
      );
    }

    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getParticipationRateStatistics");
      return;
    }

    return data;
  }

  // 납부율 변화 조회
  static Future<dynamic> getPaymentRateStatistics(
    int clubId,
    int memberId,
    DateTime? time,
  ) async {
    Uri url;
    if (time == null) {
      url = Uri.parse(
        "${_authInfoApi.url}/data/member/$clubId/$memberId/payMember",
      );
    } else {
      String timeParam = time.toUtc().toIso8601String();

      url = Uri.parse(
        "${_authInfoApi.url}/data/member/$clubId/$memberId/payMember?fromTime=$timeParam",
      );
    }

    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getPaymentRateStatistics");
      return;
    }

    return data;
  }
}

class BoardApi {
  static final AuthInfoApi _authInfoApi = AuthInfoApi();

  // 게시글 작성
  static Future<bool> writePost(
    int clubId,
    String title,
    String content,
    XFile? image,
  ) async {
    log("==== writePost argument =====");
    log("club Id : $clubId");
    log("title : $title");
    log("content : $content");

    Uri url = Uri.parse("${_authInfoApi.url}/board/post");

    // 요청 객체 생성
    var request = http.MultipartRequest('POST', url);

    // write header
    request.headers['username'] = _authInfoApi.username!;

    // import image
    if (image != null) {
      var file = await http.MultipartFile.fromPath('image', image.path);
      request.files.add(file);
    }

    request.fields['clubId'] = clubId.toString();
    request.fields['title'] = title;
    request.fields['content'] = content;

    // 요청 전송
    return await HttpInterface.requestMultipart(request);
  }

  // 게시글 수정

  // 게시글 삭제
  static Future<bool> deletePost(int clubId, int postId) async {
    log("===== delete post in api =====");
    log("clubId : $clubId");
    log("postId : $postId");
    Uri url = Uri.parse("${_authInfoApi.url}/board/$clubId/post/$postId");
    Map<String, String> header = {'username': _authInfoApi.username!};

    // DELETE 요청 전송
    final response = await http.delete(url, headers: header);

    // 요청 결과 확인
    if (response.statusCode == 200) {
      log("게시글 삭제 성공");
      return true;
    } else {
      log("게시글 삭제 실패: ${response.statusCode}");
      log("응답 내용: ${response.body}");
      return false;
    }
  }

  // 댓글 작성
  static Future<bool> writeComment(
    int clubId,
    int postId,
    int? baseId,
    String content,
  ) async {
    log("==== writePost argument =====");
    log("club Id : $clubId");
    log("postId : $postId");
    log("baseId : $baseId");
    log("content : $content");

    Uri url = Uri.parse("${_authInfoApi.url}/board/comment");
    Map<String, String> header = {
      "Content-Type": "application/json",
      'username': _authInfoApi.username!,
    };
    Map<String, dynamic> body;
    if (baseId == null) {
      body = {
        'clubId': clubId,
        'postId': postId,
        'content': content,
      };
    } else {
      body = {
        'clubId': clubId,
        'postId': postId,
        'baseId': baseId,
        'content': content,
      };
    }

    await HttpInterface.requestPost(url, header, body);
    return true;
  }

  // 댓글 수정
  // 댓글 삭제
  // 게시글 리스트 조회
  static Future<dynamic> getPostList(int clubId, int pn) async {
    Uri url = Uri.parse("${_authInfoApi.url}/board/$clubId/list?pageNo=$pn");
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getPostList");
      return;
    }

    return data;
  }

  // 게시글 조회
  static Future<dynamic> getPostDetail(int postId) async {
    Uri url = Uri.parse("${_authInfoApi.url}/board/$postId");
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getPostDetail");
      return;
    }

    return data;
  }

  // 댓글 조회
  static Future<dynamic> getComments(int postId) async {
    Uri url = Uri.parse("${_authInfoApi.url}/board/$postId/comments");
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGetLegacy(url, header);
    if (data == null) {
      log("err from getPostDetail");
      return;
    }

    return data;
  }
}
