import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'api.dart';
import 'dataclass.dart';

class ProfileInfoRepository with ChangeNotifier {
  User? me;

  Future<bool> getMyProfileInfo() async {
    log("--- before get profile ---");
    LogInApi.printAuth();
    var data = await ProfileApi.getMyProfile();
    if (data == null) {
      return false;
    }
    me = User.fromJson(data);
    if (me == null) {
      return false;
    }

    //if test user, early return
    if (LogInApi.getUserName() == "Dummy_userA" ||
        LogInApi.getUserName() == "Dummy_userB") {
      log("current : ${LogInApi.getUserName()}");
      log("--- after get profile ---");
      LogInApi.printAuth();
      return true;
    }
    LogInApi.setUserName(me!.username);
    return true;
  }

  Future<bool> changeMyProfile(
      XFile? image, String email, String phNum, String description) async {
    log("in repo func, email : $email, phNum : $phNum, description : $description");
    return await ProfileApi.changeMyProfile(
        email, true, phNum, true, description, true, image, true);
  }
}
