import 'dart:developer';

import 'package:band_front/cores/api.dart';
import 'package:band_front/cores/router.dart';
import 'package:band_front/cores/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../cores/data_class.dart';
import '../cores/repository.dart';

//TODO : 활동 참가, 취소 api 오류 해결하기
//회원 추가 참가 / 취소 추가하기

class ActivityDetailView extends StatefulWidget {
  ActivityDetailView({super.key, required this.actId, required this.clubId});
  int actId;
  int clubId;

  @override
  State<ActivityDetailView> createState() => _ActivityDetailViewState();
}

class _ActivityDetailViewState extends State<ActivityDetailView> {
  bool isLoaded = false;

  void _showSnackBar(String text) => showSnackBar(context, text);

  //TODO: 다이얼로그 액션 시 현재 화면 리로드
  void _showActivityHandleView() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("모임 활동 변경"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              elevatedBtnUnit(
                onPressed: () async {
                  await context
                      .read<ActivityDetailRepo>()
                      .closeActivity()
                      .then((ret) async {
                    if (ret == false) {
                      _showSnackBar("잘못된 접근입니다.");
                      context.pop();
                    } else {
                      await context.read<ClubDetailRepo>().reloadClubDetail();
                      _showSnackBar("활동 마감되었습니다");
                      context.pop();
                      context.pop();
                    }
                  });
                },
                borderColor: Colors.orange,
                text: "   활동 마감하기   ",
              ),
              const SizedBox(height: 32),
              elevatedBtnUnit(
                onPressed: () async {
                  await context
                      .read<ActivityDetailRepo>()
                      .removeActivity()
                      .then((ret) async {
                    if (ret == false) {
                      _showSnackBar("잘못된 접근입니다.");
                      context.pop();
                    } else {
                      await context.read<ClubDetailRepo>().reloadClubDetail();
                      _showSnackBar("활동 등록을 취소하였습니다.");
                      context.pop();
                      context.pop();
                    }
                  });
                },
                borderColor: Colors.red,
                text: "   활동 취소하기    ",
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("닫기"),
            ),
          ],
        );
      },
    );
  }

  void _showLateAttendView() {
    TextEditingController lateAttend = TextEditingController();
    TextEditingController lateWithdraw = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("추가 참가자 관리"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("참가자 추가 등록"),
                  IconButton(
                    onPressed: () async {
                      await attendLateBtnListener(lateAttend.text);
                    },
                    icon: const Icon(Icons.check, color: Colors.green),
                  ),
                ],
              ),
              desUnit(child: inputOnelineTextUnit(lateAttend)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("불참 참가자 등록"),
                  IconButton(
                    onPressed: () async {
                      await withdrawLateBtnListener(lateWithdraw.text);
                    },
                    icon: const Icon(Icons.check, color: Colors.red),
                  ),
                ],
              ),
              desUnit(child: inputOnelineTextUnit(lateWithdraw)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("닫기"),
            ),
          ],
        );
      },
    );
  }

  Future<void> attendLateBtnListener(String id) async {
    if (id == "") return;
    await context.read<ActivityDetailRepo>().attendLateTo(id).then((ret) {
      if (ret == false) {
        _showSnackBar("등록 실패..");
        return;
      }
      _showSnackBar("등록 성공");
      context.pop();
    });
  }

  Future<void> withdrawLateBtnListener(String id) async {
    if (id == "") return;
    await context.read<ActivityDetailRepo>().withdrawLateFrom(id).then((ret) {
      if (ret == false) {
        _showSnackBar("something went wrong..");
        return;
      }
      _showSnackBar("불참 처리되었습니다.");
      context.pop();
    });
  }

  Future<void> appliBtnListener(String status, bool isAttended) async {
    if (status != "모집중") return;

    if (isAttended == false) {
      await _attendHandler();
    } else {
      await _withdrawHandler();
    }
  }

  Future<void> _attendHandler() async {
    bool ret = await context.read<ActivityDetailRepo>().attendTo();

    if (ret == false) _showSnackBar("신청 불가..");
    _showSnackBar("참가 신청되었습니다!");
    return;
  }

  Future<void> _withdrawHandler() async {
    bool ret = await context.read<ActivityDetailRepo>().withdrawFrom();

    if (ret == false) _showSnackBar("오류...");
    _showSnackBar("신청이 취소되었습니다");
    return;
  }

  @override
  void initState() {
    super.initState();
    _initActivityDetailView();
  }

  Future<void> _initActivityDetailView() async {
    bool ret = await context
        .read<ActivityDetailRepo>()
        .initActivityDetail(widget.actId, widget.clubId);

    if (ret == false) {
      _showSnackBar("활동 상세 정보를 불러오지 못했습니다...");
      return;
    }
    setState(() {
      log("===== current activity id =====");
      log("${widget.actId}");
      log("===============================");
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoaded == false) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Activity activity = context.watch<ActivityDetailRepo>().activity!;
    List<ParticipantEntity> participants =
        context.watch<ActivityDetailRepo>().participantsList;
    bool isAttended = context.watch<ActivityDetailRepo>().isAttended!;
    String myRole = context.watch<ClubDetailRepo>().role!;
    String startTime = formatToMDHM(activity.startTime);
    String endTime = formatToMDHM(activity.endTime);
    String deadline = activity.deadline == null
        ? ""
        : "~ ${formatToMDHM(activity.deadline!)}";

    double parentWidth = MediaQuery.of(context).size.width;

    Image image = activity.image == null
        ? Image.asset(
            "assets/images/empty.png",
            height: parentWidth * 0.7,
            width: parentWidth,
            fit: BoxFit.cover,
          )
        : Image.network(
            activity.image!,
            fit: BoxFit.cover,
            height: parentWidth * 0.7,
            width: parentWidth,
          );

    String appliText;
    Color appliColor;
    Color statColor;
    if (activity.status == "모집중") {
      statColor = Colors.green;
      if (isAttended == false) {
        appliText = "참가 신청";
        appliColor = Colors.green;
      } else {
        appliText = "신청 취소";
        appliColor = Colors.red;
      }
    } else if (activity.status == "모집 종료") {
      statColor = Colors.red;
      appliText = "마감된 활동입니다.";
      appliColor = Colors.grey;
    } else {
      statColor = Colors.grey;
      appliText = "취소된 활동입니다.";
      appliColor = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(activity.status, style: TextStyle(color: statColor)),
          ),
          myRole == "일반"
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () {
                    if (activity.status == "모집중") {
                      _showActivityHandleView();
                    } else if (activity.status == "모집 종료") {
                      _showLateAttendView();
                    }
                  },
                  icon: const Icon(Icons.settings),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Stack(children: [
            image,
            Positioned(
              bottom: 4,
              right: 8,
              child: ElevatedButton(
                onPressed: () => context.push(RouterPath.activityLocation),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.green[200]),
                ),
                child: const Icon(Icons.place),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: desUnit(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("장소  :  ${activity.location}"),
                        Text(
                          "시간  :  $startTime ~ $endTime",
                        ),
                        Text("모집 기간  :  $deadline"),
                        Text("현재 인원  :  ${activity.participantNum}"),
                        const Divider(),
                        desTextUnit(
                          maxLine: 5,
                          description: activity.description,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('참가자 현황'),
              ),
              const Divider(color: Colors.black, thickness: 1),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Card(
                      elevation: 5.0, // 그림자 효과
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(participants[index].memberName),
                        subtitle: Text(participants[index].username),
                      ),
                    ),
                  );
                },
              ),
            ]),
          ),
        ]),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
        child: elevatedBtnUnit(
          text: appliText,
          borderColor: appliColor,
          onPressed: () async {
            await appliBtnListener(activity.status, isAttended);
          },
        ),
      ),
    );
  }
}
