//dependencies
import 'package:band_front/customwidgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//pages
import '../dataclass.dart';
import '../router.dart';

class MyClubsPage extends StatefulWidget {
  const MyClubsPage({super.key});

  @override
  State<MyClubsPage> createState() => _MyClubsPageState();
}

class _MyClubsPageState extends State<MyClubsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //사설 버튼을 통한 endDrawer를 위해 필요

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("나의 모임들"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.go(RouterPath.clubRegist),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          double parentWidth = constraints.maxWidth;

          return ListView.builder(
            itemCount: testClubs.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  context.go(
                    RouterPath.clubDetailPage,
                    extra: {'clubId': testClubs[index].id},
                  );
                },
                child: mainUnit(
                  child: Column(
                    children: [
                      testClubs[index].image != null
                          ? Image.network(
                              testClubs[index].image!,
                              fit: BoxFit.cover,
                              height: parentWidth * 0.5,
                            )
                          : Image.asset(
                              'assets/images/test1.png',
                              fit: BoxFit.cover,
                              height: parentWidth * 0.5,
                            ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(children: [
                          Row(children: [
                            const VerticalDivider(),
                            Text(testClubs[index].name),
                            Spacer(),
                            const Icon(Icons.people),
                            Text(testClubs[index].memberCount.toString()),
                            const VerticalDivider(),
                          ]),
                          const Divider(thickness: 0.5),
                          Row(children: [
                            const VerticalDivider(),
                            const Icon(Icons.contact_support),
                            const VerticalDivider(),
                            Text(testClubs[index].contactInfo),
                          ]),
                          // const Divider(thickness: 0.5),
                          // desTextUnit(
                          //   maxLine: 2,
                          //   description: testClubs[index].description,
                          // ),
                        ]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
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
                Container(
                  padding: EdgeInsets.only(top: 16),
                  width: parentWidth,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('app setting'),
                  ),
                ),
                SizedBox(
                  width: parentWidth,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('log out'),
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(Color(0xFFFF4040)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
