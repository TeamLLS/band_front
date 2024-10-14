import 'package:flutter/material.dart';
import '../dataclass.dart';

class ClubDetail extends StatelessWidget {
  ClubDetail({super.key, required this.clubId});
  final String clubId;

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
        return Column(
          children: [
            Image.asset('assets/images/empty.png'),
            const Text('description'),
            const Row(
              children: [
                Text('icon1'),
                Text('icon2'),
                Text('icon3'),
                Text('icon4'),
                Text('icon5'),
              ],
            ),
            const Text('activity list'),
            ListView.builder(
              itemCount: testActList.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(testActList[index].name));
              },
            )
          ],
        );
      }),
    );
  }
}
