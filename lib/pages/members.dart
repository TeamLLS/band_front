import 'package:flutter/material.dart';
import '../dataclass.dart';
import '../main.dart';

class Members extends StatelessWidget {
  const Members({super.key});

  @override
  Widget build(BuildContext context) {
    // 예시로 사용할 회원 목록 데이터 (실제 데이터는 서버나 API에서 가져올 수 있음)
    final List<Map<String, dynamic>> members = [
      {
        'memberId': 1,
        'clubId': 101,
        'username': 'john_doe',
        'roleName': 'Admin',
        'name': 'John Doe',
        'age': 30,
        'gender': 'Male',
        'statusName': 'Active',
      },
      {
        'memberId': 2,
        'clubId': 102,
        'username': 'jane_smith',
        'roleName': 'Member',
        'name': 'Jane Smith',
        'age': 25,
        'gender': 'Female',
        'statusName': 'Inactive',
      },
      // 더 많은 회원 데이터를 추가 가능
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("회원 목록")),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        itemCount: members.length, // 회원 수에 맞게 리스트 길이 설정
        itemBuilder: (context, index) {
          final member = members[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text(member['name']), // 회원 이름
              subtitle: Text(
                  'Username: ${member['username']} | Role: ${member['roleName']}'), // 추가 정보 표시
              trailing: Text(member['statusName']), // 회원 상태 표시
              onTap: () {
                // 회원 선택 시 추가 액션 수행 (예: 회원 상세 정보로 이동)
              },
            ),
          );
        },
      ),
    );
  }
}
