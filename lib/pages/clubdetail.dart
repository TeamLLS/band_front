// dependencies
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer';

//pages
import '../cores/api.dart';
import '../cores/widgetutils.dart';
import '../cores/router.dart';
import '../cores/dataclass.dart';
import '../cores/enumeration.dart';
import 'drawers.dart';

class ClubDetailViewModel {
  late int clubId;
  Club? club;
  List<ActivityEntity>? actList;
  int pn = 0;

  Future<bool> getClubDetailInfo() async {
    var data = await ClubApi.getClubDetail(clubId);
    if (data == null) {
      log("get club detail failed");
      return false;
    }
    club = Club.fromMap(data);
    return true;
  }

  Future<void> getActivityList() async {
    var data = await ActivityApi.getActivityList(clubId, pn);
    var list = data['list'];
    List<ActivityEntity> receivedActivities = [];

    for (Map<String, dynamic> element in list) {
      receivedActivities.add(ActivityEntity.fromMap(element));
    }
    actList = receivedActivities;
    pn++;
    return;
  }
}

class ClubDetailView extends StatefulWidget {
  const ClubDetailView({super.key, required this.clubId});
  final int clubId;

  @override
  State<ClubDetailView> createState() => _ClubDetailViewState();
}

class _ClubDetailViewState extends State<ClubDetailView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //사설 버튼을 통한 endDrawer를 위해 필요
  final ClubDetailViewModel _viewModel = ClubDetailViewModel();

  Future<void> initClubDetailView() async {
    _viewModel.clubId = widget.clubId;
    await _viewModel.getClubDetailInfo();
    await _viewModel.getActivityList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initClubDetailView();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.club == null || _viewModel.actList == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Club club = _viewModel.club!;
    List<ActivityEntity> actList = _viewModel.actList!;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(club.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.build_outlined),
            onPressed: () => context.push(RouterPath.manage),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () async {
              bool result = await ClubApi.deleteClub(widget.clubId);
              log("$result");
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        double parentWidth = constraints.maxWidth;

        return SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/images/empty.png',
                fit: BoxFit.cover,
                height: parentWidth * 0.7,
                width: parentWidth,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
                child: Column(children: [
                  desUnit(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.contact_support),
                            const VerticalDivider(),
                            Text(club.contactInfo ?? "연락처가 없습니다"),
                          ],
                        ),
                        const Divider(thickness: 0.5),
                        desTextUnit(
                          maxLine: 5,
                          description: club.description ?? "모임 설명이 없습니다",
                        ),
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: menuUnit(
                      width: parentWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(Icons.campaign),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.people),
                            onPressed: () => context.go(
                              RouterPath.members,
                              extra: {'clubId': widget.clubId},
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.photo_album),
                            onPressed: () {
                              // 사진첩 기능
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.account_balance_wallet),
                            onPressed: () {
                              // 장부 기능
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.event),
                            onPressed: () {
                              // 일정 관리 기능
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('${club.name}의 활동 목록'),
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: actList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                        child: InkWell(
                          onTap: () {
                            context.push(
                              RouterPath.activityDetail,
                              extra: {
                                'actId': actList[index].id,
                                'clubId': club.clubId,
                              },
                            );
                          },
                          child: desUnit(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${actList[index].name}과 듀오"),
                                      Text(actList[index].status),
                                    ],
                                  ),
                                  const Divider(thickness: 0.5),
                                  const Text('simple description'),
                                  const Row(
                                    children: [
                                      Icon(Icons.calendar_today),
                                      VerticalDivider(),
                                      Text('24.11.01 ~ 24.12.31'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.people),
                                      const VerticalDivider(),
                                      Text("${actList[index].participantNum}"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.phone),
                                      VerticalDivider(),
                                      Text('010-1234-5678'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ]),
              ),
            ],
          ),
        );
      }),
      endDrawer: const DrawerView(),
    );
  }
}
