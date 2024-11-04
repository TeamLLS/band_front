import 'enumeration.dart';

class Club {
  final int id;
  final String name; // 리스트에 표기
  final String? image; // nullable field, 리스트에 표기
  final String description;
  final String contactInfo;
  final ClubStatus status; // 리스트에 표기
  final DateTime createdAt;
  final DateTime? deletedAt; // nullable field
  final int memberCount; // 인원 수, 리스트에 표기

  Club({
    required this.id,
    required this.name,
    this.image,
    required this.description,
    required this.contactInfo,
    required this.status,
    required this.createdAt,
    this.deletedAt,
    required this.memberCount,
  });

  String getStatusString() => status.toString().split('.').last;

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
      contactInfo: json['contactInfo'],
      status: ClubStatus.values
          .firstWhere((e) => e.toString() == 'ClubStatus.${json['status']}'),
      createdAt: DateTime.parse(json['createdAt']),
      deletedAt:
          json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      memberCount: json['memberCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'contactInfo': contactInfo,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'memberCount': memberCount,
    };
  }
}

List<Club> testClubs = List.generate(10, (index) {
  return Club(
    id: index,
    name: 'club $index',
    image: null,
    description:
        'Description for club $index. sdlakfadjsfkldsafjhdsalfhdsajklfhdsakffsdjkhfdsakjlhfdsalkjfhdsajklfhsadkljfhsadjklfhdsakljfhdsakjlfhdasjklfhdsakljfhasdfkljhadsfkjsafhsdkajlfhasdkjlfhdsakljfhasdklfhasdlkjfhasdfklashfjklasdfhalsdkjfhakjlfhasdkjfhasdlkjfhsadkljfhasdklfhasdkljfhaskjlfhasdfkjlashfkljasfhaslfkhsfjklhasfkjlasdhfklasdjh',
    contactInfo: 'club$index@example.com',
    status: ClubStatus.values[index % ClubStatus.values.length],
    createdAt: DateTime.now().subtract(Duration(days: index * 40)),
    deletedAt: index % 2 == 0
        ? DateTime.now().subtract(Duration(days: index * 10))
        : null,
    memberCount: 10 + index * 5,
  );
});

class Activity {
  final int id;
  final int clubId;
  final String name;
  final String image;
  final String description;
  final DateTime time;
  final ActivityStatus status;
  final DateTime createdAt;
  DateTime? completedAt;

  Activity({
    required this.id,
    required this.clubId,
    required this.name,
    required this.image,
    required this.description,
    required this.time,
    required this.status,
    required this.createdAt,
  });

  // JSON에서 Activity 객체 생성
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      clubId: json['clubId'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
      time: DateTime.parse(json['time']),
      status: ActivityStatus.values[json['status']], // 문자열을 Enum으로 변환
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
class User {
  //for profile
  final int id;
  final String username;
  final String? email;
  final String? phNum;
  final String? image;
  final String? name;
  final String? gender;
  final int? birthYear;
  final String? description;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    this.email,
    this.phNum,
    this.image,
    this.name,
    this.gender,
    this.birthYear,
    this.description,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phNum: json['phNum'],
      image: json['image'],
      name: json['name'],
      gender: json['gender'],
      birthYear: json['birthYear'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phNum': phNum,
      'image': image,
      'name': name,
      'gender': gender,
      'birthYear': birthYear,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

User testUser = User(
  id: 1,
  username: 'testUser1',
  email: 'testuser1@example.com',
  phNum: '010-1234-5678',
  image: 'https://example.com/images/testuser1.jpg',
  name: 'Test User',
  gender: 'male',
  birthYear: 1990,
  description:
      'This is a test user for testing purposes.nfhkjsadfhasdkjlfhdasjlkfdashjlkfasdhjlkfsdhajk',
  createdAt: DateTime.now().subtract(Duration(days: 365 * 5)), // 5년 전 가입일
);

class Member {
  final int memberId;
  final int clubId;
  final String username; //print
  final Role roleName; //print
  final MemberStatus status; //print
  final String? name;
  final String? gender;
  final int? birthYear;
  final DateTime createdAt;
  final DateTime? terminatedAt;

  Member({
    required this.memberId,
    required this.clubId,
    required this.username,
    required this.roleName,
    required this.status,
    this.name,
    this.gender,
    this.birthYear,
    required this.createdAt,
    this.terminatedAt,
  });

  String getStatusString() => status.toString().split('.').last;
  String getRoleString() => roleName.toString().split('.').last;

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: json['id'],
      clubId: json['clubId'],
      username: json['username'],
      roleName:
          Role.values.firstWhere((e) => e.toString() == 'Role.${json['role']}'),
      status: MemberStatus.values
          .firstWhere((e) => e.toString() == 'MemberStatus.${json['status']}'),
      name: json['name'],
      gender: json['gender'],
      birthYear: json['birthYear'],
      createdAt: DateTime.parse(json['createdAt']),
      terminatedAt: json['terminatedAt'] != null
          ? DateTime.parse(json['terminatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': memberId,
      'club': clubId,
      'username': username,
      'role': roleName.toString().split('.').last,
      'status': status.toString().split('.').last,
      'name': name,
      'gender': gender,
      'birthYear': birthYear,
      'createdAt': createdAt.toIso8601String(),
      'terminatedAt': terminatedAt?.toIso8601String(),
    };
  }
}

List<Member> testMembers = List.generate(5, (index) {
  return Member(
    memberId: index,
    clubId: index,
    username: 'member$index',
    roleName: Role.values[index % Role.values.length],
    status: MemberStatus.values[index % MemberStatus.values.length],
    name: 'Member $index',
    gender: index % 2 == 0 ? 'male' : 'female',
    birthYear: 1990 + index,
    createdAt: DateTime.now().subtract(Duration(days: index * 300)),
    terminatedAt: index % 2 == 0
        ? null
        : DateTime.now().subtract(Duration(days: index * 100)),
  );
});
