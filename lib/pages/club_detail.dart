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

  Future<void> _initClubDetail() async {
    bool result = await context
        .read<ClubDetail>()
        .initClubDetail(widget.clubId, widget.role);
    if (result == false) {
      log("init clubDetail failed");
      return;
    }
    setState(() => isLoaded = true);
  }

  @override
  void initState() {
    super.initState();
    _initClubDetail();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoaded == false) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Club club = context.watch<ClubDetail>().club!;
    List<ActivityEntity> actList = context.watch<ClubDetail>().actList;
    String role = context.watch<ClubDetail>().role!;

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
      body: LayoutBuilder(builder: (context, constraints) {
        double parentWidth = constraints.maxWidth;
        Image image = club.image == null
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

        return SingleChildScrollView(
          child: Column(
            children: [
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
                            icon: Icon(Icons.campaign),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.people),
                            onPressed: () => context.push(
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
                    child: Stack(
                      children: [
                        Center(child: Text('${club.name}의 활동 목록')),
                        Positioned(
                          top: -15,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.create),
                            onPressed: () {},
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
