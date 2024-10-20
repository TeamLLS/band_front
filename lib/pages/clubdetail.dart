import 'package:band_front/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../dataclass.dart';

class ClubDetail extends StatelessWidget {
  ClubDetail({super.key, required this.clubId});
  final int clubId;

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
      appBar: AppBar(title: Text('test')),
      body: LayoutBuilder(builder: (context, constraints) {
        double width = constraints.maxWidth;

        return Column(
          children: [
            Image.asset(
              'assets/images/test1.png',
              fit: BoxFit.cover,
              height: width * 0.7,
              width: width,
            ),
            Container(
              width: width,
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Column(children: [
                  Text("club name & member number"),
                  Text("description"),
                  Text("contact & status"),
                ]),
              ),
            ),
            Container(
              width: width,
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 12),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
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
            const Text('activity list'),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
              child: Divider(color: Colors.black, thickness: 1),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: testActList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                    title: Text(testActList[index].name),
                  );
                },
              ),
            )
          ],
        );
      }),
    );
  }
}
