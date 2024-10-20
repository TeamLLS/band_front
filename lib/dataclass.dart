////////////////////////모임, 속해있는 인원들//////////////////////////////////

class Member {
  final int id;
  final int clubId;
  final String username;
  final Role role;
  final String name;
  final String gender;
  final String image;
  final String description;
  final String contactInfo;
  final MemberStatus status;
  final DateTime createdAt;
  final DateTime? deletedAt; // nullable field

  Member({
    required this.id,
    required this.clubId,
    required this.username,
    required this.role,
    required this.name,
    required this.gender,
    required this.image,
    required this.description,
    required this.contactInfo,
    required this.status,
    required this.createdAt,
    this.deletedAt, // nullable field
  });
}

enum Role {
  owner,
  manager,
  regular,
}

enum MemberStatus {
  active,
  inactive,
  terminated,
}

class Club {
  final int id;
  final String name; //리스트에 표기
  final String image; //turn to image, 리스트에 표기
  final String description;
  final String contactInfo;
  final ClubStatus status; //리스트에 표기
  final DateTime createdAt;
  final DateTime? deletedAt; // nullable field
  //인원 수, 리스트에 표기

  Club({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.contactInfo,
    required this.status,
    required this.createdAt,
    this.deletedAt, // nullable field
  });
}

enum ClubStatus {
  open,
  closed,
  recruiting,
}

////////////////////Activiy list////////////////////////////////////////////////
// ActivityStatus enum 정의
enum ActivityStatus {
  recruiting,
  completed,
}

// Activity 클래스 정의
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

////////////////////profile data////////////////////////////////////////////////

class Profile {
  final int userId;
  final String username;
  final String name;
  final int age;
  final String gender;
  final String phNum;
  final String email;
  final String description;
  final String image;

  Profile({
    required this.userId,
    required this.username,
    required this.name,
    required this.age,
    required this.gender,
    required this.phNum,
    required this.email,
    required this.description,
    required this.image,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['userId'],
      username: json['username'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      phNum: json['phNum'],
      email: json['email'],
      description: json['description'],
      image: json['image'],
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'userId': userId,
  //     'username': username,
  //     'name': name,
  //     'age': age,
  //     'gender': gender,
  //     'phNum': phNum,
  //     'email': email,
  //     'description': description,
  //     'image': image,
  //   };
  // }
}
