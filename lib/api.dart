import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthInfoApi {
  String? _accessToken;
  String? _refreshToken;

  //make class to singleton
  AuthInfoApi._privateConstructor();
  static final AuthInfoApi _instance = AuthInfoApi._privateConstructor();
  factory AuthInfoApi() => _instance;

  //getter
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  void cleanUpToken() {
    _accessToken = null;
    _refreshToken = null;
    debugPrint('!!! clean Tokens');
  }

  //setter
  void setAccessToken({required String accessToken}) {
    _accessToken = accessToken;
  }

  void setRefreshToken({required String refreshToken}) {
    _refreshToken = refreshToken;
  }
}

class HttpMethod {
  static Future<http.Response?> tryGet(
    String title,
    Uri url,
    Map<String, String> header,
  ) async {
    debugPrint("!!! Get $title");

    try {
      http.Response? response = await http.get(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint("!!! fail ${response.statusCode}");
        debugPrint("!!! body ${response.body}");
        return null;
      }

      debugPrint("[!!!] success $title");
      return response;
    } catch (e) {
      debugPrint('[!!!] error $title: $e');
      return null;
    }
  }

  // static Future<http.Response?> tryPost({
  //   required String title,
  //   required Uri url,
  //   required Map<String, String> header,
  //   required Map<String, dynamic> body,
  // }) async {
  //   debugPrint("[!!!] start $title");

  //   try {
  //     var response =
  //         await http.post(url, headers: header, body: jsonEncode(body));
  //     if (response.statusCode != 200) {
  //       debugPrint("[!!!] fail code ${response.statusCode}");
  //       debugPrint("[!!!] fail body ${response.body}");
  //       return null;
  //     }
  //     debugPrint("[!!!] success $title");
  //     return response;
  //   } catch (e) {
  //     debugPrint('[!!!] error $title: $e');
  //     return null;
  //   }
  // }

  // static Future<http.Response?> tryPostWithoutBody({
  //   required String title,
  //   required Uri url,
  //   required Map<String, String> header,
  // }) async {
  //   debugPrint("[!!!] start $title");

  //   try {
  //     var response = await http.post(url, headers: header);
  //     if (response.statusCode != 200) {
  //       debugPrint("[!!!] fail code ${response.statusCode}");
  //       debugPrint("[!!!] fail body ${response.body}");
  //       return null;
  //     }
  //     debugPrint("[!!!] success $title");
  //     return response;
  //   } catch (e) {
  //     debugPrint('[!!!] error $title: $e');
  //     return null;
  //   }
  // }

  // static Future<http.Response?> tryPatch({
  //   required String title,
  //   required Uri url,
  //   required Map<String, String> header,
  //   required Map<String, dynamic> body,
  // }) async {
  //   debugPrint("[!!!] start $title");

  //   try {
  //     var response =
  //         await http.patch(url, headers: header, body: json.encode(body));
  //     if (response.statusCode != 200) {
  //       debugPrint("[!!!] fail ${response.statusCode}");
  //       debugPrint("[!!!] fail body ${response.body}");
  //       return null;
  //     }
  //     debugPrint("[!!!] success $title");
  //     return response;
  //   } catch (e) {
  //     debugPrint('[!!!] error $title: $e');
  //     return null;
  //   }
  // }

  // static Future<http.Response?> tryPatchWithoutBody({
  //   required String title,
  //   required Uri url,
  //   required Map<String, String> header,
  // }) async {
  //   debugPrint("[!!!] start $title");

  //   try {
  //     var response = await http.patch(url, headers: header);
  //     if (response.statusCode != 200) {
  //       debugPrint("[!!!] fail ${response.statusCode}");
  //       debugPrint("[!!!] fail body ${response.body}");
  //       return null;
  //     }
  //     debugPrint("[!!!] success $title");
  //     return response;
  //   } catch (e) {
  //     debugPrint('[!!!] error $title: $e');
  //     return null;
  //   }
  // }

  // static Future<bool> tryDelete({
  //   required String title,
  //   required Uri url,
  //   required Map<String, String> header,
  // }) async {
  //   debugPrint("[!!!] start $title");

  //   try {
  //     http.Response? response = await http.delete(url, headers: header);
  //     if (response.statusCode != 200) {
  //       debugPrint("[!!!] fail ${response.statusCode}");
  //       debugPrint("[!!!] body ${response.body}");
  //       return false;
  //     }
  //     debugPrint("[!!!] success $title");
  //     return true;
  //   } catch (e) {
  //     debugPrint('[!!!] error $title: $e');
  //     return false;
  //   }
  // }

  // static Future<http.Response?> tryPut({
  //   required String title,
  //   required Uri url,
  //   required Map<String, String> header,
  // }) async {
  //   debugPrint("[!!!] start $title");

  //   try {
  //     http.Response? response = await http.put(url, headers: header);
  //     if (response.statusCode != 200) {
  //       debugPrint("[!!!] fail ${response.statusCode}");
  //       debugPrint("[!!!] body ${response.body}");
  //       return null;
  //     }
  //     debugPrint("[!!!] success $title");
  //     return response;
  //   } catch (e) {
  //     debugPrint('[!!!] error $title: $e');
  //     return null;
  //   }
  // }

  // static Future<bool> tryMultipartRequest({
  //   required String title,
  //   required http.MultipartRequest request,
  // }) async {
  //   debugPrint("[!!!] start $title");

  //   try {
  //     http.StreamedResponse response = await request.send();
  //     if (response.statusCode != 200) {
  //       final responseBody = await response.stream.bytesToString();
  //       debugPrint('[!!!] fail ${response.statusCode}');
  //       debugPrint('[!!!] fail body: $responseBody');
  //       return false;
  //     }
  //     debugPrint("[!!!] success $title");
  //     return true;
  //   } catch (e) {
  //     debugPrint('[!!!] error $title, $e');
  //     return false;
  //   }
  // }
}

class LogInApi {
  static final AuthInfoApi _authInfoApi = AuthInfoApi();

  static Future<void> login() async {
    var url = Uri.parse("ServerUrl"); //주소가 머야
    var header = {
      'token': 'Bearer ${_authInfoApi.accessToken}',
      'provider': "kakao", //이거 그냥 이렇게쓰면되는거여?
    };

    http.Response? response = await HttpMethod.tryGet("log in", url, header);

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
    var url = Uri.parse("ServerUrl");
    var header = {'token': 'Bearer ${_authInfoApi.refreshToken}'};

    http.Response? response = await HttpMethod.tryGet("reissue", url, header);

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
    var url = Uri.parse("ServerUrl");
    var header = {'token': 'Bearer ${_authInfoApi.accessToken}'};

    http.Response? response = await HttpMethod.tryGet("logout", url, header);

    if (response == null) {
      debugPrint('!!! logout to server error!');
      return;
    }

    _authInfoApi.cleanUpToken();
    return;
  }
}
