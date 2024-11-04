import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class HttpInterface {
  //this is return data after json decode
  //
  static Future<dynamic> requestGet(Uri url, Map<String, String> header) async {
    //1. try http request
    http.Response? response = await HttpMethod.tryGet(url, header);
    if (response == null) {
      log("err from try get");
      return null;
    }

    //2. handling response
    String? json = HttpMethod.handle(response);
    if (json == null) {
      log("err from handling response");
      return null;
    }

    //3. json decoding
    dynamic data = jsonDecode(json);
    return data;
  }

  static Future<bool> requestGetWithoutHeader(Uri url) async {
    http.Response? response = await HttpMethod.tryGetWithoutHeader(url);
    if (response == null) {
      log("err from try get");
      return false;
    }
    return HttpMethod.handleBool(response);
  }

  static Future<bool> requestPatch(
    Uri url,
    Map<String, String> header,
    Map<String, dynamic> body,
  ) async {
    http.Response? response = await HttpMethod.tryPatch(url, header, body);
    if (response == null) {
      log("err from try patch");
      return false;
    }

    return HttpMethod.handleBool(response);
  }

  static Future<dynamic> requestPostWithoutBody(
    Uri url,
    Map<String, String> header,
  ) async {
    http.Response? response = await HttpMethod.tryPostWithoutBody(url, header);
    if (response == null) {
      log("err from try post");
      return null;
    }

    String? json = HttpMethod.handle(response);
    if (json == null) {
      log("err from handling response");
      return null;
    }

    dynamic data = jsonDecode(json);
    return data;
  }
}

class HttpMethod {
  //http request
  static Future<http.Response?> tryGet(
    Uri url,
    Map<String, String> header,
  ) async {
    try {
      http.Response? response = await http.get(url, headers: header);
      return response;
    } catch (e) {
      log('try get err : $e');
      return null;
    }
  }

  static Future<http.Response?> tryGetWithoutHeader(Uri url) async {
    try {
      http.Response? response = await http.get(url);
      return response;
    } catch (e) {
      log('try get err : $e');
      return null;
    }
  }

  static Future<http.Response?> tryPatch(
    Uri url,
    Map<String, String> header,
    Map<String, dynamic> body,
  ) async {
    try {
      http.Response response = await http.patch(
        url,
        headers: header,
        body: json.encode(body),
      );
      return response;
    } catch (e) {
      log('try patch err : $e');
      return null;
    }
  }

  static Future<http.Response?> tryPostWithoutBody(
    Uri url,
    Map<String, String> header,
  ) async {
    try {
      http.Response response = await http.post(url, headers: header);
      return response;
    } catch (e) {
      log('try post err : $e');
      return null;
    }
  }

  //response handler
  static String? handle(http.Response response) {
    if (response.statusCode != 200) {
      log("${response.statusCode} failed");
      log("body : ${response.body}");
      return null;
    }
    return response.body;
  }

  static bool handleBool(http.Response response) {
    if (response.statusCode != 200) {
      log("${response.statusCode} failed");
      log("body : ${response.body}");
      return false;
    }
    return true;
  }
}

////////////////////////////////////////////////////////////////////////////////
class HttpLegacy {
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

  static Future<http.Response?> tryPostWithoutBody(
    String title,
    Uri url,
    Map<String, String> header,
  ) async {
    debugPrint("[!!!] start $title");

    try {
      var response = await http.post(url, headers: header);
      if (response.statusCode != 200) {
        debugPrint("[!!!] fail code ${response.statusCode}");
        debugPrint("[!!!] fail body ${response.body}");
        return null;
      }
      debugPrint("[!!!] success $title");
      return response;
    } catch (e) {
      debugPrint('[!!!] error $title: $e');
      return null;
    }
  }

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