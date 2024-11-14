import 'dart:developer';

import 'package:band_front/cores/api.dart';
import 'package:band_front/cores/widget_utils.dart';
import 'package:flutter/material.dart';

import '../cores/data_class.dart';

class ActivityDetailViewModel {
  late int actId;
  Activity? activity;
  bool? canAttend;
  List<ParticipantEntity>? participantsList;
  int pn = 0;

  Future<void> getActivityDetail() async {
    var data = await ActivityApi.getActivityDetail(actId);
    activity = Activity.fromMap(data);
    return;
  }

  Future<void> getParticipants() async {
    var data = await ActivityApi.getParticipant(actId, pn);
    canAttend = data['attend'];
    var list = data['list'];
    log("$canAttend");
    List<ParticipantEntity> receivedParticipants = [];

    for (Map<String, dynamic> element in list) {
      receivedParticipants.add(ParticipantEntity.fromMap(element));
    }
    participantsList = receivedParticipants;
    pn++;
    return;
  }
}

class ActivityDetailView extends StatefulWidget {
  ActivityDetailView({
    super.key,
    required this.actId,
    required this.clubId,
  });
  int actId;
  int clubId;

  @override
  State<ActivityDetailView> createState() => _ActivityDetailViewState();
}

class _ActivityDetailViewState extends State<ActivityDetailView> {
  ActivityDetailViewModel _viewModel = ActivityDetailViewModel();

  Future<void> initActivityDetailView() async {
    _viewModel.actId = widget.actId;
    await _viewModel.getActivityDetail();
    await _viewModel.getParticipants();
    setState(() {});
  }

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().substring(2).padLeft(2, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> attend() async {
    if (_viewModel.canAttend == false) {
      return;
    }

    dynamic result = await ActivityApi.attendActivity(
      widget.clubId,
      widget.actId,
    );
    if (result != true) {
      log("attend err, result : $result");
      return;
    }

    await _viewModel.getParticipants();

    setState(() {
      showSnackBar(context, "참가 신청되었습니다!");
    });
  }

  @override
  void initState() {
    super.initState();
    initActivityDetailView();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.activity == null ||
        _viewModel.canAttend == null ||
        _viewModel.participantsList == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Activity activity = _viewModel.activity!;
    List<ParticipantEntity> participants = _viewModel.participantsList!;
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

    return Scaffold(
      appBar: AppBar(
        title: Text("${activity.name}과 듀오"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(activity.status),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.people),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(activity.participantNum.toString()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          image,
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: desUnit(
                  child: Container(
                    width: parentWidth,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        " ${formatDateTime(activity.startTime)} ~ ${formatDateTime(activity.startTime)}",
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: desUnit(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: desTextUnit(
                      maxLine: 5,
                      description: activity.description,
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
          onPressed: () async => attend(),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              _viewModel.canAttend == true ? Colors.green : Colors.grey,
            ),
          ),
          child: const Text("신청하기"),
        ),
      ),
    );
  }
}
