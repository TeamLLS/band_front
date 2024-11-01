import 'package:flutter/material.dart';
import '../dataclass.dart';
import '../main.dart';

class Members extends StatelessWidget {
  const Members({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원 목록"),
        actions: [
          ElevatedButton.icon(
            onPressed: () {},
            label: const Icon(Icons.person_add),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.yellow),
            ),
          ),
          const VerticalDivider(color: Colors.white),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        itemCount: testMembers.length,
        itemBuilder: (context, index) {
          final member = testMembers[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text(member.getRoleString()),
              subtitle: Text('${member.username}  |  ${member.gender}'),
              trailing: Text(member.getStatusString()),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
