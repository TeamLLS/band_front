import 'dart:developer';

import 'package:band_front/cores/api.dart';
import 'package:band_front/cores/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cores/data_class.dart';
import '../cores/repository.dart';

//TODO : readme의 활동 상세, 활동 참가, 취소 api 오류 해결하기

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

  Future<void> appliBtnHandler(String status, bool isAttended) async {
    if (status != "모집중") return;

    if (isAttended == false) {
      await _attend();
    } else {
      await _withdraw();
    }
  }

  Future<void> _attend() async {
    bool ret = await context.read<ActivityDetailRepo>().attendto();

    if (ret == false) _showSnackBar("신청 불가..");
    _showSnackBar("참가 신청되었습니다!");
    return;
  }

  Future<void> _withdraw() async {
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
    setState(() => isLoaded = true);
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
    if (activity.status == "모집중") {
      if (isAttended == false) {
        appliText = "참가 신청";
        appliColor = Colors.green;
      } else {
        appliText = "신청 취소";
        appliColor = Colors.red;
      }
    } else if (activity.status == "모집종료") {
      appliText = "마감된 활동입니다.";
      appliColor = Colors.grey;
    } else {
      appliText = "취소된 활동입니다.";
      appliColor = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(activity.status),
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
                onPressed: () {},
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
                          "시간  :  ${formatToMDHM(activity.startTime)} ~ ${formatToMDHM(activity.endTime)}",
                        ),
                        Text("모집 기간  :  ~ ${formatToMDHM(activity.deadline)}"),
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
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(participants[index].memberName),
                      subtitle: Text(participants[index].username),
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
        child: ElevatedButton(
          onPressed: () async {
            await appliBtnHandler(activity.status, isAttended);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(appliColor),
          ),
          child: Text(appliText),
        ),
      ),
    );
  }
}
