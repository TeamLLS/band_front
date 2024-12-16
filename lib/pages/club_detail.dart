// dependencies
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

//pages
import '../cores/api.dart';
import '../cores/widget_utils.dart';
import '../cores/router.dart';
import '../cores/data_class.dart';
import '../cores/repository.dart';
import 'drawers.dart';

class ClubDetailView extends StatefulWidget {
  const ClubDetailView({super.key, required this.clubId, required this.role});
  final int clubId;
  final String role;

  @override
  State<ClubDetailView> createState() => _ClubDetailViewState();
}

class _ClubDetailViewState extends State<ClubDetailView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //사설 버튼을 통한 endDrawer를 위해 필요
  bool isLoaded = false; //존재 이유? init에서 clear를 수행해서 이전 정보가 흘러들어올 수 있다

  void _navigateToManage(Club club) {
    context.push(RouterPath.manage);
  }

  @override
  void initState() {
    super.initState();
    _initClubDetail();
  }

  Future<void> _initClubDetail() async {
    bool result = await context
        .read<ClubDetailRepo>()
        .initClubDetail(widget.clubId, widget.role);
    if (result == false) {
      log("init clubDetail failed");
      return;
    }
    setState(() {
      log("===== current club id =====");
      log("${widget.clubId}");
      log("===========================");
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoaded == false) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double parentWidth = MediaQuery.of(context).size.width;
    Club club = context.watch<ClubDetailRepo>().club!;
    List<ActivityEntity> actList = context.watch<ClubDetailRepo>().actList;
    String role = context.watch<ClubDetailRepo>().role!;
    Image image = club.image == null ||
            club.image == "https://d310q11a7rdsb8.cloudfront.net/null"
        ? Image.asset(
            'assets/images/empty.png',
            fit: BoxFit.cover,
            height: parentWidth * 0.7,
            width: parentWidth,
          )
        : Image.network(
            club.image!,
            fit: BoxFit.cover,
            height: parentWidth * 0.7,
            width: parentWidth,
          );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(club.name),
        actions: [
          role == "일반"
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.build_outlined),
                  onPressed: () => _navigateToManage(club),
                ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () async {
              bool result = await ClubApi.deleteMyFromClub(widget.clubId);
              log("$result");
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          image,
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
                child: menuBarUnit(
                  width: parentWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.campaign),
                        onPressed: () => context.push(RouterPath.clubBoard),
                      ),
                      IconButton(
                        icon: const Icon(Icons.people),
                        onPressed: () => context.push(
                          RouterPath.members,
                          extra: {'clubId': widget.clubId},
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bar_chart),
                        onPressed: () => context.push(RouterPath.statistics),
                      ),
                      IconButton(
                        icon: const Icon(Icons.account_balance_wallet),
                        onPressed: () => context.push(RouterPath.budget),
                      ),
                      IconButton(
                        icon: const Icon(Icons.event),
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
                child: Stack(
                  children: [
                    Center(child: Text('${club.name}의 활동 목록')),
                    Positioned(
                      top: -15,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.create),
                        onPressed: () =>
                            context.push(RouterPath.activityRegist),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.black, thickness: 1),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: actList.length,
                itemBuilder: (context, index) {
                  ActivityEntity actEntity = actList[index];
                  Image actEntityImage = actEntity.image == null ||
                          actEntity.image ==
                              "https://d310q11a7rdsb8.cloudfront.net/null"
                      ? Image.asset(
                          "assets/images/empty.png",
                          height: parentWidth * 0.6,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          actEntity.image!,
                          height: parentWidth * 0.6,
                          fit: BoxFit.cover,
                        );
                  Color statColor;
                  if (actEntity.status == "모집중") {
                    statColor = Colors.green;
                  } else if (actEntity.status == "모집 종료") {
                    statColor = Colors.red;
                  } else {
                    statColor = Colors.grey;
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                    child: InkWell(
                      child: desUnit(
                        child: LayoutBuilder(builder: (context, constraints) {
                          final double desWidth = constraints.maxWidth;

                          return Stack(
                            children: [
                              Center(child: actEntityImage),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                width: desWidth,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(actEntity.name),
                                            Text(
                                              actEntity.status,
                                              style: TextStyle(
                                                color: statColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(thickness: 0.5),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today),
                                            const VerticalDivider(),
                                            Text(
                                              formatToYMDHM(actEntity.time!),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.people),
                                            const VerticalDivider(),
                                            Text("${actEntity.participantNum}"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      onTap: () {
                        context.push(
                          RouterPath.activityDetail,
                          extra: {
                            'actId': actList[index].id,
                            'clubId': club.clubId,
                          },
                        );
                      },
                    ),
                  );
                },
              )
            ]),
          ),
        ]),
      ),
      endDrawer: const DrawerView(),
    );
  }
}
