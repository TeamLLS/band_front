import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'api.dart';
import 'data_class.dart';

class MyInfo with ChangeNotifier {
  User? me;

  Future<bool> getMyInfo() async {
    //if test user, early return
    if (LogInApi.getUserName() == "Dummy_userA" ||
        LogInApi.getUserName() == "Dummy_userB" ||
        LogInApi.getUserName() == "Dummy_userC" ||
        LogInApi.getUserName() == "Dummy_userD") {
      log("current : ${LogInApi.getUserName()}");
      log("--- current profile ---");
      LogInApi.printAuth();
      return true;
    }

    var data = await ProfileApi.getMyInfo();
    if (data == null) {
      return false;
    }

    me = User.fromMap(data);
    if (me == null) {
      return false;
    }

    LogInApi.setUserName(me!.username);
    return true;
  }

  Future<bool> changeMyInfo(
      XFile? image, String? email, String? phNum, String? description) async {
    return await ProfileApi.changeMyInfo(email, phNum, description, image);
  }
}

class UserInfo with ChangeNotifier {
  String? username;
  int? memberId;
  User? user;
  String? role;

  void _clear() {
    username = null;
    memberId = null;
    user = null;
    role = null;
  }

  void setUserInfo(String username, int memberId, String role) {
    _clear();
    this.username = username;
    this.memberId = memberId;
    this.role = role;
  }

  Future<bool> getUserProfile() async {
    if (username == null || memberId == null) {
      log("username null in getUserProfile");
      return false;
    }
    var data = await ProfileApi.getUserProfile(username!);
    if (data == null) {
      log("get club detail failed");
      return false;
    }
    user = User.fromMap(data);
    return true;
  }

  Future<bool> removeFromClub() async {
    bool result = await ClubApi.removeMember(memberId!);
    if (result == false) {
      log("remove member from this club fail");
      return false;
    }
    return true;
  }

  Future<bool> changeRole(String role) async {
    String? roleParam;
    switch (role) {
      case "회장":
        roleParam = "OWNER";
        break;
      case "관리자":
        roleParam = "MANAGER";
        break;
      case "일반":
        roleParam = "REGULAR";
        break;
      default:
        log("changeRole in repository err");
        return false;
    }

    bool result = await ClubApi.changeMemberRole(memberId!, roleParam);
    if (result == false) {
      log("changeRole from this club fail");
      return false;
    }
    return true;
  }
}

class ClubDetail with ChangeNotifier {
  int? clubId;
  String? role; // 회장, 관리자, 일반
  Club? club;
  List<ActivityEntity> actList = [];
  int pnAct = 0;
  List<Member> members = [];
  int pnMem = 0;

  void _clear() {
    clubId = null;
    role = null;
    club = null;
    actList.clear();
    pnAct = 0;
    members.clear();
    pnMem = 0;
  }

  void _clearMember() {
    members.clear();
    pnMem = 1;
  }

  Future<bool> initClubDetail(int clubId, String role) async {
    _clear();
    this.clubId = clubId;
    this.role = role;
    await getClubDetail().then((bool result) {
      if (result == false) {
        return false;
      }
    });
    await getActivityList().then((bool result) {
      if (result == false) {
        return false;
      }
    });
    notifyListeners();
    return true;
  }

  Future<bool> getClubDetail() async {
    if (clubId == null) {
      log("get club detail failed");
      return false;
    }
    var data = await ClubApi.getClubDetail(clubId!);
    if (data == null) {
      log("get club detail failed");
      return false;
    }
    club = Club.fromMap(data);
    notifyListeners();
    return true;
  }

  Future<bool> getActivityList() async {
    if (clubId == null) {
      log("club id null in getActivityList");
      return false;
    }
    var data = await ActivityApi.getActivityList(clubId!, pnAct);
    var list = data['list'];
    for (Map<String, dynamic> element in list) {
      actList.add(ActivityEntity.fromMap(element));
    }
    pnAct++;
    notifyListeners();
    return true;
  }

  Future<void> getMemberList() async {
    _clearMember();
    var data = await ClubApi.getClubMemberList(clubId!, pnMem);
    var list = data['list'];
    for (Map<String, dynamic> element in list) {
      members.add(Member.fromMap(element));
    }
    pnMem++;
    notifyListeners();
    return;
  }
}

class ClubList with ChangeNotifier {
  List<ClubEntity> clubs = [];
  int pn = 0;

  void _clear() {
    clubs.clear();
    pn = 0;
  }

  Future<bool> initClubList() async {
    _clear();
    var data = await ClubApi.getMyClubList(pn);
    var list = data['list'];
    log("$data");
    for (Map<String, dynamic> element in list) {
      ClubEntity temp = ClubEntity.fromMap(element);
      if (temp.clubStatus != "운영종료") {
        clubs.add(temp);
      }
    }
    pn++;
    notifyListeners();
    return true;
  }

  Future<bool> getMoreClubList() async {
    var data = await ClubApi.getMyClubList(pn);
    var list = data['list'];
    log("$data");
    for (Map<String, dynamic> element in list) {
      ClubEntity temp = ClubEntity.fromMap(element);
      if (temp.clubStatus != "운영종료") {
        clubs.add(temp);
      }
    }
    pn++;
    notifyListeners();
    return true;
  }
}

class BudgetInfo with ChangeNotifier {
  int? budgetId;
  int? clubId;
  int? budget;
  List<BudgetRecordEntity> record = [];
  int pn = 0;

  void _clear() {
    budgetId = null;
    clubId = null;
    budget = null;
    record.clear();
    pn = 0;
    return;
  }

  void _clearForReload() {
    budget = null;
    record.clear();
    pn = 0;
    return;
  }

  Future<bool> _getBudgetAmount(DateTime? time) async {
    var data = await BudgetApi.getBudgetAmount(clubId!, time);
    if (data == null) {
      log("getBudgetAmount fail");
      return false;
    }

    budget = data['amount'];
    return true;
  }

  Future<bool> _getBudgetRecord(DateTime? time) async {
    var data = await BudgetApi.getBudgetRecord(clubId!, pn, time);
    if (data == null) {
      log("getBudgetRecord fail");
      return false;
    }
    log("$data");

    var list = data['list'];
    for (Map<String, dynamic> element in list) {
      BudgetRecordEntity temp = BudgetRecordEntity.fromMap(element);
      record.add(temp);
    }
    pn++;
    return true;
  }

  Future<bool> initBudgetInfo(int clubId) async {
    _clear();
    this.clubId = clubId;

    //budget amount init
    bool result = await _getBudgetAmount(null);
    if (result == false) {
      log("init fail");
      return false;
    }

    //record init
    result = await _getBudgetRecord(null);
    if (result == false) {
      log("init fail");
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<bool> reloadBudgetInfo(DateTime time) async {
    _clearForReload();

    //get budget amount
    bool result = await _getBudgetAmount(time);
    if (result == false) {
      log("get budget amount fail");
      return false;
    }

    //get record
    result = await _getBudgetRecord(time);
    if (result == false) {
      log("get record fail");
      return false;
    }

    notifyListeners();
    return true;
  }
}

class PaymentInfo with ChangeNotifier {}
