// dependencies
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer';

//pages
import '../cores/widgetutils.dart';
import '../cores/router.dart';
import '../cores/dataclass.dart';
import '../cores/enumeration.dart';

class ClubDetail extends StatefulWidget {
  const ClubDetail({super.key, required this.clubId});
  final int clubId;

  @override
  State<ClubDetail> createState() => _ClubDetailState();
}

class _ClubDetailState extends State<ClubDetail> {
  //사설 버튼을 통한 endDrawer를 위해 필요
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Activity> testActList = List.generate(
    20,
    (index) => Activity(
      id: index,
      clubId: index,
      name: '$index',
      image: '$index',
      description: '$index',
      time: DateTime.now(),
      status: ActivityStatus.recruiting,
      createdAt: DateTime.now(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(testClubs[0].name),
        actions: [
          IconButton(
            icon: const Icon(Icons.build_outlined),
            onPressed: () => context.go(RouterPath.manage),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
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
                'assets/images/test1.png',
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
                            Text(testClubs[0].contactInfo),
                          ],
                        ),
                        const Divider(thickness: 0.5),
                        desTextUnit(
                          maxLine: 5,
                          description: testClubs[0].description,
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
                            onPressed: () => context.go(RouterPath.members),
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Text('activity list'),
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: testActList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                        child: desUnit(
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('제목제목'),
                                Divider(thickness: 0.5),
                                Text('가나다라마바사아자차카타파하'),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today),
                                    VerticalDivider(),
                                    Text('24.11.01 ~ 24.12.31'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.people),
                                    VerticalDivider(),
                                    Text('10명'),
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
                      );
                    },
                  )
                ]),
              ),
            ],
          ),
        );
      }),
      endDrawer: Drawer(
        child: LayoutBuilder(builder: (context, constraints) {
          double parentWidth = constraints.maxWidth;

          return Padding(
            padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
            child: Column(
              children: [
                InkWell(
                  onTap: () => context.go(RouterPath.myProfilePage),
                  child: Material(
                    elevation: 10,
                    shape: const CircleBorder(),
                    shadowColor: Colors.black.withOpacity(1),
                    child: CircleAvatar(
                      radius: parentWidth * 0.3,
                      backgroundImage:
                          const AssetImage('assets/images/empty.png'),
                    ),
                  ),
                ),
                ElevatedButton(onPressed: () {}, child: Text('app setting')),
                ElevatedButton(onPressed: () {}, child: Text('log out')),
              ],
            ),
          );
        }),
      ),
    );
  }
}
