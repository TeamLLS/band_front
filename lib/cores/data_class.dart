class Club {
  final int clubId;
  final String name; // 리스트에 표기
  final String? image; // nullable field, 리스트에 표기
  final String? description;
  final String? contactInfo;
  final String status; // 리스트에 표기
  final int memberNum; // 인원 수, 리스트에 표기

  ///{clubId: 1, v
  ///name: DummyClub, v
  ///description: for test, v
  ///image: https://d310q11a7rdsb8.cloudfront.net/common/club/default.png, v
  ///contactInfo: null, v
  ///status: 운영중, v
  ///memberNum: 0} v

  Club({
    required this.clubId,
    required this.name,
    this.image,
    this.description,
    this.contactInfo,
    required this.status,
    required this.memberNum,
  });

  factory Club.fromMap(Map<String, dynamic> map) {
    return Club(
      clubId: map['clubId'] as int,
      name: map['name'],
      image: map['image'],
      description: map['description'],
      contactInfo: map['contactInfo'],
      status: map['status'],
      memberNum: map['memberNum'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': clubId,
      'name': name,
      'image': image,
      'description': description,
      'contactInfo': contactInfo,
      'status': status,
      'memberCount': memberNum,
    };
  }
}

class ClubEntity {
  int clubId;
  int memberId;
  String? image;
  String clubName;
  String clubStatus;
  String role;
  String memberStatus;

  ClubEntity({
    required this.clubId,
    required this.memberId,
    this.image,
    required this.clubName,
    required this.clubStatus,
    required this.role,
    required this.memberStatus,
  });

  factory ClubEntity.fromMap(Map<String, dynamic> data) {
    return ClubEntity(
      clubId: data['clubId'] as int,
      memberId: data['memberId'] as int,
      image: data['image'],
      clubName: data['clubName'],
      clubStatus: data['clubStatus'],
      role: data['role'],
      memberStatus: data['memberStatus'],
    );
  }
}

class Activity {
  final int id;
  final int clubId;
  final String name;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String? image;
  final int participantNum;

  Activity({
    required this.id,
    required this.clubId,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.participantNum,
    this.image,
  });

  // 팩토리 메서드
  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as int,
      clubId: map['clubId'] as int,
      name: map['name'],
      description: map['description'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      status: map['status'],
      participantNum: map['participantNum'] as int,
      image: map['image'],
    );
  }
}

class ActivityEntity {
  final int id;
  final String name;
  final String image;
  final String status;
  final int participantNum;

  ActivityEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
    required this.participantNum,
  });

  factory ActivityEntity.fromMap(Map<String, dynamic> map) {
    return ActivityEntity(
      id: map['id'] as int,
      name: map['name'],
      image: map['image'],
      status: map['status'],
      participantNum: map['participantNum'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'status': status,
      'participantNum': participantNum,
    };
  }
}

class ParticipantEntity {
  final int id; //participantsID
  final int activityId;
  final String username;
  final int memberId;
  final String memberName;
  final String status;

  ParticipantEntity({
    required this.id,
    required this.activityId,
    required this.username,
    required this.memberId,
    required this.memberName,
    required this.status,
  });

  factory ParticipantEntity.fromMap(Map<String, dynamic> map) {
    return ParticipantEntity(
      id: map['id'] as int,
      activityId: map['activityId'] as int,
      username: map['username'],
      memberId: map['memberId'] as int,
      memberName: map['memberName'],
      status: map['status'],
    );
  }
}

class User {
  //for profile
  int userId;
  String username;
  String? name;
  int? age;
  String? gender;
  String? phNum;
  String? email;
  String? description;
  String? image;

  User({
    required this.userId,
    required this.username,
    this.email,
    this.name,
    this.gender,
    this.age,
    this.phNum,
    this.description,
    this.image,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'] as int,
      username: map['username'],
      email: map['email'],
      name: map['name'],
      gender: map['gender'],
      age: map['age'] != null ? map['age'] as int : null,
      phNum: map['phNum'],
      description: map['description'],
      image: map['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'username': username,
      'email': email,
      'phNum': phNum,
      'image': image,
      'name': name,
      'gender': gender,
      'description': description,
    };
  }
}

class Member {
  final int memberId;
  final int clubId;
  final String username; //표시
  final String roleName; //표시
  final String name; //표시
  final int age;
  final String gender;
  final int roleRank;
  final String status; //표시

  Member({
    required this.memberId,
    required this.clubId,
    required this.username,
    required this.roleName,
    required this.name,
    required this.age,
    required this.gender,
    required this.status,
    required this.roleRank,
  });

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      memberId: map['memberId'] as int,
      clubId: map['clubId'] as int,
      username: map['username'],
      roleName: map['roleName'],
      status: map['status'],
      name: map['name'],
      gender: map['gender'],
      age: map['age'] as int,
      roleRank: map['roleRank'] as int,
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
      'roleRank': roleRank,
    };
  }
}

//////////////////////////test//////////////////////////////////////////////////

List<Member> testMembers = List.generate(5, (index) {
  return Member(
    memberId: index,
    clubId: index,
    username: 'member$index',
    roleName: "role",
    status: "status",
    name: 'Member $index',
    gender: index % 2 == 0 ? 'male' : 'female',
    age: 11,
    roleRank: 3,
  );
});

List<Club> testClubs = List.generate(10, (index) {
  return Club(
    clubId: index,
    name: 'club $index',
    image: null,
    description:
        'Description for club $index. sdlakfadjsfkldsafjhdsalfhdsajklfhdsakffsdjkhfdsakjlhfdsalkjfhdsajklfhsadkljfhsadjklfhdsakljfhdsakjlfhdasjklfhdsakljfhasdfkljhadsfkjsafhsdkajlfhasdkjlfhdsakljfhasdklfhasdlkjfhasdfklashfjklasdfhalsdkjfhakjlfhasdkjfhasdlkjfhsadkljfhasdklfhasdkljfhaskjlfhasdfkjlashfkljasfhaslfkhsfjklhasfkjlasdhfklasdjh',
    contactInfo: 'club$index@example.com',
    status: "sss",
    memberNum: 10 + index * 5,
  );
});

User testUser = User(
  userId: 1,
  username: 'testUser1',
  email: 'testuser1@example.com',
  phNum: '010-1234-5678',
  image: null,
  name: 'Test User',
  gender: 'male',
  description:
      'This is a test user for testing purposes.nfhkjsadfhasdkjlfhdasjlkfdashjlkfasdhjlkfsdhajk',
);
