import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'api.dart';
import 'data_class.dart';

//TODO: 활동 참가, 취소 오류(주최자는 활동참가, 취소가 되지 않아야 함)
// 주최자가 명시되어야 활동 종료, 취소 등이 가능.

class MyRepo with ChangeNotifier {
  User? me;
  String? username;

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
    username = me!.username;

    LogInApi.setUserName(me!.username);
    return true;
  }

  Future<bool> changeMyInfo(
      XFile? image, String? email, String? phNum, String? description) async {
    return await ProfileApi.changeMyInfo(email, phNum, description, image);
  }

  void setDummy(String username) {
    this.username = username;
  }
}

class UserRepo with ChangeNotifier {
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

class ClubDetailRepo with ChangeNotifier {
  int? clubId;
  String? role; // 회장, 관리자, 일반
  Club? club;
  List<ActivityEntity> actList = [];
  int pnAct = 0;
  List<Member> members = [];
  int pnMem = 0;
  String? buffer;

  void _clear() {
    clubId = null;
    role = null;
    club = null;
    actList.clear();
    pnAct = 0;
    members.clear();
    pnMem = 0;
    buffer = null;
  }

  void _clearMember() {
    members.clear();
    pnMem = 0;
  }

  void _clearForReload() {
    club = null;
    actList.clear();
    pnAct = 0;
    buffer = null;
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

  Future<bool> reloadClubDetail() async {
    _clearForReload();
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

  Future<bool> editClubDetail(
    int clubId,
    String? name,
    String? description,
    String? status,
    XFile? image,
    String? contact,
  ) async {
    bool ret = await ClubApi.changeClubDetail(
      clubId,
      name,
      description,
      status,
      image,
      contact,
    );
    if (ret == false) return false;

    Future.delayed(const Duration(seconds: 1));
    ret = await reloadClubDetail();
    if (ret == false) return false;
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
    notifyListeners();
    return true;
  }

  Future<bool> registActivity(
      String name,
      String des,
      XFile image,
      String location,
      DateTime startTime,
      DateTime endTime,
      DateTime deadline) async {
    bool ret = await ActivityApi.registActivity(
        clubId!, name, des, image, location, startTime, endTime, deadline);
    if (ret == false) return false;

    await Future.delayed(const Duration(seconds: 1));
    ret = await reloadClubDetail();
    if (ret == false) return false;
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

  void setBuffer(String str) {
    //buffer for activity regist
    buffer = str;
    notifyListeners();
  }
}

class ClubListRepo with ChangeNotifier {
  List<ClubEntity> clubs = [];
  int pn = 0;

  void _clear() {
    clubs.clear();
    pn = 0;
  }

  Future<bool> initClubList() async {
    _clear();
    return await getMyClubList();
  }

  Future<bool> reloadClubList() async {
    _clear();
    return await getMyClubList();
  }

  Future<bool> getMyClubList() async {
    var data = await ClubApi.getMyClubList(pn);
    var list = data['list'];
    for (Map<String, dynamic> element in list) {
      ClubEntity temp = ClubEntity.fromMap(element);
      if (temp.clubStatus != "운영종료") {
        clubs.add(temp);
      }
    }
    log("===== club list in repo =====");
    log("$data");

    notifyListeners();
    return true;
  }
}

class BudgetRepo with ChangeNotifier {
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

    if (data == "") {
      budget = 0;
    } else {
      budget = data['amount'];
    }
    return true;
  }

  Future<bool> _getBudgetRecord(DateTime? time) async {
    var data = await BudgetApi.getBudgetRecord(clubId!, pn, time);
    if (data == null) {
      log("getBudgetRecord fail");
      return false;
    }

    var list = data['list'];
    for (Map<String, dynamic> element in list) {
      BudgetRecordEntity temp = BudgetRecordEntity.fromMap(element);
      record.add(temp);
    }
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

  Future<bool> reloadBudgetInfo(DateTime? time) async {
    _clearForReload();
    log("start reload");

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

  Future<bool> writeExpense(int amount, String description) async {
    await BudgetApi.writeExpense(clubId!, amount, description);
    await Future.delayed(const Duration(seconds: 1));
    await reloadBudgetInfo(null);
    notifyListeners();
    return true;
  }
}

class PaymentListRepo with ChangeNotifier {
  int? clubId;
  List<PaymentEntity> paments = [];
  int pn = 0;

  void _clear() {
    clubId = null;
    paments.clear();
    pn = 0;
  }

  void _clearForReload() {
    paments.clear();
    pn = 0;
  }

  Future<bool> initPaymentListInfo(int clubId) async {
    _clear();
    this.clubId = clubId;
    bool ret = await getPaymentList();
    if (ret == false) {
      log("init PaymentInfo fail");
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<bool> reloadPaymentListInfo() async {
    _clearForReload();
    Future.delayed(const Duration(seconds: 1));
    bool ret = await getPaymentList();
    if (ret == false) {
      log("init reloadPaymentInfo fail");
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<bool> getPaymentList() async {
    log("===== getPaymentList in repo =====");
    var data = await BudgetApi.getPaymentList(clubId!, pn);
    if (data == null) {
      log("getPaymentList fail");
      return false;
    }
    log("$data");
    var list = data['list'];
    for (Map<String, dynamic> element in list) {
      PaymentEntity temp = PaymentEntity.fromMap(element);
      paments.add(temp);
    }
    return true;
  }

  Future<bool> registPayment(
    int amount,
    String name,
    String description,
    DateTime dateTime,
  ) async {
    await BudgetApi.registPayment(clubId!, amount, name, description, dateTime);
    await Future.delayed(const Duration(seconds: 1));
    await reloadPaymentListInfo();
    notifyListeners();
    return true;
  }
}

class PaymentDetailRepo with ChangeNotifier {
  int? clubId;
  int? paymentId;
  Payment? payment;
  List<PaymentTargetEntity> paymentTargets = [];
  int pn = 0;

  void _clear() {
    clubId = null;
    paymentId = null;
    payment = null;
    paymentTargets.clear();
    pn = 0;
  }

  void _clearForReload() {
    payment = null;
    paymentTargets.clear();
    pn = 0;
  }

  Future<bool> initPaymentDetail(int clubId, int paymentId) async {
    _clear();
    this.clubId = clubId;
    this.paymentId = paymentId;

    bool ret = await getPayment();
    if (ret == false) {
      log("init fail");
      return false;
    }

    ret = await getPaymentTargets();
    if (ret == false) {
      log("init fail");
      return false;
    }

    if (paymentTargets.isEmpty) {
      await _isTargetEmpty();
    }

    notifyListeners();
    return true;
  }

  Future<bool> getPayment() async {
    var data = await BudgetApi.getPayment(paymentId!);
    if (data == null) {
      log("getPayment fail");
      return false;
    }
    log("===== payment detail =====");
    log("$data");
    payment = Payment.fromMap(data);
    return true;
  }

  Future<bool> getPaymentTargets() async {
    var data = await BudgetApi.getPaymentTargets(paymentId!, pn);
    if (data == null) {
      log("getPaymentTargets fail");
      return false;
    }
    log("===== payment targets =====");
    log("$data");

    var list = data['list'];
    for (Map<String, dynamic> element in list) {
      PaymentTargetEntity temp = PaymentTargetEntity.fromMap(element);
      paymentTargets.add(temp);
    }
    return true;
  }

  Future<bool> cancelPayment() async {
    log("===== cancelPayment in repo =====");
    log("clubId : $clubId");
    log("paymentId : $paymentId");
    return await BudgetApi.cancelPayment(clubId!, paymentId!);
  }

  Future<bool> expirePayment() async {
    bool ret = await BudgetApi.expirePayment(clubId!, paymentId!);
    if (ret == false) return false;

    await Future.delayed(const Duration(seconds: 1));
    ret = await reloadPaymentDetail();
    if (ret == false) return false;
    return true;
  }

  Future<bool> reloadPaymentDetail() async {
    _clearForReload();
    bool ret = await getPayment();
    if (ret == false) return false;

    ret = await getPaymentTargets();
    if (ret == false) return false;

    notifyListeners();
    return true;
  }

  Future<bool> setPaid(int memberId) async {
    bool ret = await BudgetApi.setPaid(paymentId!, memberId);
    if (ret == false) return false;

    await Future.delayed(const Duration(seconds: 1));
    ret = await reloadPaymentDetail();
    if (ret == false) return false;
    return true;
  }

  Future<bool> setUnPaid(int memberId) async {
    bool ret = await BudgetApi.setUnpaid(paymentId!, memberId);
    if (ret == false) return false;

    await Future.delayed(const Duration(seconds: 1));
    ret = await reloadPaymentDetail();
    if (ret == false) return false;
    return true;
  }

  Future<bool> setLatePaid(int memberId) async {
    bool ret = await BudgetApi.setLatepaid(paymentId!, memberId);
    if (ret == false) return false;

    await Future.delayed(const Duration(seconds: 1));
    ret = await reloadPaymentDetail();
    if (ret == false) return false;
    return true;
  }

  Future<bool> excludeMember(int memberId) async {
    bool ret = await BudgetApi.excludeMember(paymentId!, memberId);
    if (ret == false) return false;

    await Future.delayed(const Duration(seconds: 1));
    ret = await reloadPaymentDetail();
    if (ret == false) return false;
    return true;
  }

  Future<bool> _isTargetEmpty() async {
    bool ret = await BudgetApi.selectAllMember(clubId!, paymentId!);
    if (ret == false) return false;

    ret = await getPaymentTargets();
    if (ret == false) return false;

    return true;
  }
}

class ActivityDetailRepo with ChangeNotifier {
  int? clubId;
  int? actId;
  Activity? activity;
  bool? isAttended;
  List<ParticipantEntity> participantsList = [];
  int pn = 0;

  void _clear() {
    clubId = null;
    actId = null;
    activity = null;
    isAttended = null;
    participantsList.clear();
    pn = 0;
  }

  void _clearForReload() {
    activity = null;
    isAttended = null;
    participantsList.clear();
    pn = 0;
  }

  Future<bool> initActivityDetail(int actId, int clubId) async {
    _clear();
    this.actId = actId;
    this.clubId = clubId;

    bool ret = await getActivityDetail();
    if (ret == false) return false;

    ret = await getParticipants();
    if (ret == false) return false;

    notifyListeners();
    return true;
  }

  Future<bool> _reloadActivityDetail() async {
    _clearForReload();
    await Future.delayed(const Duration(seconds: 1));

    bool ret = await getActivityDetail();
    if (ret == false) return false;

    ret = await getParticipants();
    if (ret == false) return false;

    notifyListeners();
    return true;
  }

  Future<bool> getActivityDetail() async {
    try {
      var data = await ActivityApi.getActivityDetail(actId!);
      activity = Activity.fromMap(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> getParticipants() async {
    try {
      var data = await ActivityApi.getParticipant(actId!, pn);
      isAttended = data['attend'];
      var list = data['list'];
      for (Map<String, dynamic> element in list) {
        participantsList.add(ParticipantEntity.fromMap(element));
      }
      pn++;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> attendTo() async {
    if (clubId == null || actId == null) return false;

    bool ret = await ActivityApi.attendActivity(clubId!, actId!);
    if (ret == false) return false;

    ret = await _reloadActivityDetail();
    if (ret == false) return false;

    notifyListeners();
    return true;
  }

  Future<bool> withdrawFrom() async {
    if (clubId == null || actId == null) return false;

    bool ret = await ActivityApi.withdrawActivity(clubId!, actId!);
    if (ret == false) return false;

    ret = await _reloadActivityDetail();
    if (ret == false) return false;

    notifyListeners();
    return true;
  }

  Future<bool> attendLateTo(String id) async {
    if (clubId == null || actId == null) return false;

    bool ret = await ActivityApi.attendLateActivity(clubId!, actId!, id);
    if (ret == false) return false;

    ret = await _reloadActivityDetail();
    if (ret == false) return false;

    notifyListeners();
    return true;
  }

  Future<bool> withdrawLateFrom(String id) async {
    if (clubId == null || actId == null) return false;

    bool ret = await ActivityApi.withdrawLateActivity(clubId!, actId!, id);
    if (ret == false) return false;

    ret = await _reloadActivityDetail();
    if (ret == false) return false;

    notifyListeners();
    return true;
  }

  Future<bool> removeActivity() async {
    //need pop and clubDetail reload
    if (clubId == null || actId == null) return false;
    log("== removeActivity ==");
    log("clubId : $clubId");
    log("activityId : $actId");

    dynamic ret = await ActivityApi.removeActivity(clubId!, actId!);
    if (ret == false) return false;

    ret = await _reloadActivityDetail();
    log("reloaded");
    if (ret == false) return false;

    notifyListeners();
    return true;
  }

  Future<bool> closeActivity() async {
    if (clubId == null || actId == null) return false;
    log("== closeActivity ==");
    log("clubId : $clubId");
    log("activityId : $actId");

    dynamic ret = await ActivityApi.closeActivity(clubId!, actId!);
    if (ret == false || ret == null) return false;

    ret = await _reloadActivityDetail();
    log("reloaded");
    if (ret == false) return false;

    notifyListeners();
    return true;
  }
}

class BoardRepo with ChangeNotifier {
  int? clubId;
  List<BoardPostEntity> postList = [];
  int pn = 0;

  void clear() {
    clubId = null;
    postList.clear();
    pn = 0;
  }

  void clearForReload() {
    postList.clear();
    pn = 0;
  }

  Future<bool> initPostList(int clubId) async {
    clear();
    this.clubId = clubId;

    bool ret = await getPostList();
    if (ret == false) return false;
    return true;
  }

  Future<bool> reloadPostList() async {
    clearForReload();

    await Future.delayed(const Duration(seconds: 1));
    bool ret = await getPostList();
    if (ret == false) return false;
    notifyListeners();
    return true;
  }

  Future<bool> getPostList() async {
    var data = await BoardApi.getPostList(clubId!, pn);
    if (data == null) {
      log("getPostList fail");
      return false;
    }

    var list = data['list'];
    for (Map<String, dynamic> element in list) {
      BoardPostEntity temp = BoardPostEntity.fromMap(element);
      postList.add(temp);
    }
    return true;
  }

  Future<bool> writePost(String title, String content, XFile? image) async {
    bool ret = await BoardApi.writePost(clubId!, title, content, image);
    if (ret == false) return false;

    ret = await reloadPostList();
    if (ret == false) return false;
    notifyListeners();
    return true;
  }
}

class BoardPostDetailRepo with ChangeNotifier {
  int? clubId;
  int? postId;
  BoardPost? postDetail;
  List<BoardComment> comments = [];

  void clear() {
    clubId = null;
    postId = null;
    postDetail = null;
    comments.clear();
  }

  void clearForReload() {
    postDetail = null;
    comments.clear();
  }

  Future<bool> initPostDetail(int clubId, int postId) async {
    clear();
    this.clubId = clubId;
    this.postId = postId;

    bool ret = await _getPostDetail();
    if (ret == false) return false;

    ret = await _getComments();
    if (ret == false) return false;
    return true;
  }

  Future<bool> reloadPostDetail() async {
    clearForReload();

    await Future.delayed(const Duration(seconds: 1));

    bool ret = await _getPostDetail();
    if (ret == false) return false;

    ret = await _getComments();
    if (ret == false) return false;
    notifyListeners();
    return true;
  }

  Future<bool> _getPostDetail() async {
    try {
      var data = await BoardApi.getPostDetail(postId!);
      log("===== post detail info =====");
      log("$data");
      postDetail = BoardPost.fromMap(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _getComments() async {
    try {
      var data = await BoardApi.getComments(postId!);
      var list = data['list'];
      for (dynamic element in list) {
        comments.add(BoardComment.fromMap(element));
      }
      log("===== comments info =====");
      log("$data");
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> writeComment(int? baseId, String content) async {
    bool ret = await BoardApi.writeComment(clubId!, postId!, baseId, content);
    log("$ret");
    if (ret == false) return false;

    ret = await reloadPostDetail();
    if (ret == false) return false;
    return true;
  }

  Future<bool> deletePost() async {
    return await BoardApi.deletePost(clubId!, postId!);
  }
}
