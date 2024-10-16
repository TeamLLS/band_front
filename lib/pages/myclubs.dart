import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../dataclass.dart';
import '../router.dart';

class MyClubsPage extends StatefulWidget {
  const MyClubsPage({super.key});

  @override
  State<MyClubsPage> createState() => _MyClubsPageState();
}

class _MyClubsPageState extends State<MyClubsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //사설 버튼을 통한 endDrawer를 위해 필요
  List<Club> testClubList = List.generate(
    20,
    (index) => Club(
      id: index,
      name: '$index',
      image: '$index',
      description: '$index',
      contactInfo: '$index',
      status: ClubStatus.open,
      createdAt: DateTime.now(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("어그래 안녕"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {},
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
      body: ListView.builder(
        itemCount: testClubList.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.fromLTRB(40, 0, 40, 40),
            //height: MediaQuery.of(context).size.height * 0.2,
            color: Colors.white,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double parentWidth = constraints.maxWidth;
                return Container(
                  height: parentWidth,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/test1.png',
                        fit: BoxFit.cover,
                        height: parentWidth * 0.6,
                      ),
                      Text("data"),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      endDrawer: Drawer(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 40, 8, 16),
            child: Column(
              children: [
                InkWell(
                  onTap: () => context.go(RouterPath.myProfilePage),
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.2,
                    backgroundImage:
                        const AssetImage('assets/images/empty.png'),
                  ),
                ),
                ElevatedButton(onPressed: () {}, child: Text('app setting')),
                ElevatedButton(onPressed: () {}, child: Text('log out')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
