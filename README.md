# band_front

# 보고서 작성 내용
api 추가에 따른 기능 통폐합

- 출처
github 링크

- 제출 내용
ppt 보고서
시연 영상


# 촬영 시나리오
- 주요 기능
1. 로그인
2. 프로필 화면 및 수정 화면 (이 다음부터 수정 과정은 스킵)
3. 모임 생성
4. 회원 등록 및 방출 (이 다음부터 삭제, 취소 과정은 스킵)
5. 활동 등록 (편의 위해 모두 현재 시각으로)
6. 활동 상세 - 위치정보
7. 활동 신청
8. 활동 마감  (편의 위해 같은 종류 작업 한꺼번에)
9. 추가 신청 팝업 
10. 장부 개설
11. 납부 미납 액션
12. 장부 마감
13. 지출 내역 작성
14. 예산 과거 내역 조회
15. 게시판 작성, 조회, 댓글

- 통계 기능
1. 회원 변화 추이 및 조회 날짜 선택 (이 다음부터 날짜 선택 과정 스킵)
2. 활동량
3. 예산 변화
4. 관리 페이지 -> 회원 관리 및 개인 통계



- 작성할 것






# api 테스트 목록
-- user server
1. 내 프로필 조회 v
2. 상대 프로필 조회 v
3. 프로필 변경
이미지 포함 변경 v
이미지 없이 변경 x -> 우선순위 낮음
변경 후 리로딩 v

-- club server
1. 클럽 생성
이미지 포함 등록 v
이미지 제외 등록 v
리로딩 v
2. 클럽 정보 변경 v
리로딩 v
3. 클럽 정보 조회 v
4. 클럽 해체	v
리로딩 v
팝업 띄우기 v
5. 내 클럽 리스트 조회 v
* 스크롤 로직 개선 -> 우선순위 낮음
6. 회원 등록	v
리로딩 v
팝업으로 입력받기 v
7. 클럽 회원 조회 v
8. 회원 권한 변경 v
리로딩 v
9. 회원 탈퇴
* ui 생성 필요
10. 회원 강퇴 v
리로딩 v

-- activity server
1. 활동 생성 v
이미지 포함 등록 v
이미지 제외 등록 x -> 수정 필요(우선순위 낮음)
리로딩 v
2. 활동 목록 조회 v
* 활동목록 연락처추가 << 예정, 등록할때 연락처까지 기재(nullalbe)
3. 활동 조회 v
* 위치정보 표시
4. 활동 취소 v
리로딩 v
5. 활동 종료 v
리로딩 v
6. 활동 참가	v
참여자 리로딩 v
7. 활동 불참	v
참여자 리로딩 v
8. 활동 추가참가 v
리로딩 v
9. 활동 추가불참 v
리로딩 v
10. 참가자 조회	v
11. 참가 활동 조회 x

-- budget server
1. 예산 조회 v
필터링 v
쉼표, 원표시 앞으로 v
2. 예산 갱신 v
3. 예산 기록 조회 v
4. 장부 생성 v
마감일 지정
5. 리로딩 후 팝 v
7. 장부 취소	v
리로딩 v
8. 장부 만료	v
리로딩 x
9. 장부 목록 조회 v
10. 장부 조회	
생성 후 모든 회원 등록 v
11. 납부 대상 등록-전체 v
12. 납부 대상 등록-선택 
13. 회원 납부	v
리로딩 v
14. 회원 미납	v
리로딩 v
15. 회원 연체 납부 v
16. 납부 대상 제외 v
리로딩 v
17. 납부 대상 목록 조회 v
18. 내 장부 목록 조회 v

-- data server
회원수 변화 조회
활동수 변화 조회
예산 변화 조회	
참가율 변화 조회
납부율 변화 조회
회원 순위 조회	
회원 점수 조회	
예외 처리 v
날짜 처리 V
* 옵션 처리


# memeo


# 자고일어나서 하기
장부 인터렉션 기능 완성
그랲
(추가된다면)게시판
앨범 -> 내 활동
double parentWidth = MediaQuery.of(context).size.width;



# 회의 때 말할 것
12/14
1. 게시글 삭제 api
1-1. 오류 내역 : 200은 되나 실제로 삭제되지 않는다
[log] ===== post detail info =====
[log] {image: https://d310q11a7rdsb8.cloudfront.net/club/DummyClub/board/image/a_1734094164646.jpg, id: 4, clubId: 1, createdBy: Dummy_userA, createdAt: 2024-12-13T12:49:32.351190Z, title: a, content: a, memberId: 1, memberName: 허연준}
[log] 200
[log] ===== comments info =====
[log] {list: [{id: 24, postId: 4, createdBy: Dummy_userA, createdAt: 2024-12-13T17:28:59.155182Z, content: a, memberId: 1, memberName: 허연준, comments: [{id: 25, postId: 4, createdBy: Dummy_userA, createdAt: 2024-12-13T17:29:05.303551Z, content: b, memberId: 1, memberName: 허연준, comments: []}]}, {id: 25, postId: 4, createdBy: Dummy_userA, createdAt: 2024-12-13T17:29:05.303551Z, content: b, memberId: 1, memberName: 허연준, comments: [{id: 26, postId: 4, createdBy: Dummy_userA, createdAt: 2024-12-13T17:29:17.576324Z, content: c, memberId: 1, memberName: 허연준, comments: []}]}]}
[log] ===== delete post in api =====
[log] clubId : 1
[log] postId : 4
[log] 게시글 삭제 성공
[log] 200

1-2. 오류 코드
// 게시글 삭제
  static Future<bool> deletePost(int clubId, int postId) async {
    log("===== delete post in api =====");
    log("clubId : $clubId");
    log("postId : $postId");
    Uri url = Uri.parse("${_authInfoApi.url}/board/$clubId/post/$postId");
    Map<String, String> header = {'username': _authInfoApi.username!};

    // DELETE 요청 전송
    final response = await http.delete(url, headers: header);

    // 요청 결과 확인
    if (response.statusCode == 200) {
      log("게시글 삭제 성공");
      return true;
    } else {
      log("게시글 삭제 실패: ${response.statusCode}");
      log("응답 내용: ${response.body}");
      return false;
    }
  }


12/13
1. 회원 납부 상태가 "연체 납부"인 경우에 "회원 미납" api로 납부 상태 변경 시도 시 200은 오나 납부 상태가 미납으로 변경되지 않음.

2. 활동 추가참가 api 오류
2-1. 오류 로그
[log] [[[ profile downloaded ]]]
[log] logged in with kakao_3778335311
[log] ===== current club id =====
[log] 38
[log] ===========================
[log] ===== current activity id =====
[log] 133
[log] ===============================
[log] ===== argument check in api =====
[log] clubId : 38
[log] activityId : 133
[log] username : Dummy_userB
[log] username in header : kakao_3778335311
[log] 404 failed
[log] body : {"clubId":38,"error":"NOT_MEMBER_EXCEPTION","message":"회원 아님","username":null}
[log] err from handling response

2-2. 오류 코드
  static Future<bool> attendLateActivity(
    int clubId,
    int activityId,
    String id,
  ) async {
    log("===== argument check in api =====");
    log("clubId : $clubId");
    log("activityId : $activityId");
    log("username : $id");
    log("username in header : ${_authInfoApi.username}");
    Uri url = Uri.parse(
      "${_authInfoApi.url}/activity/$clubId/$activityId/attend/additional?tartget=$id",
    );
    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic ret = await HttpInterface.requestPostWithoutBody(url, header);
    if (ret == null) return false;
    return true;
  }




12/11
1. 회원 납부
1-1. 오류 로그
[log] ===== setPaid api =====
[log] paymentId : 34
[log] memberId : 11
[log] body : {time: 2024-12-10T20:31:13.282460Z}
[log] 415 failed
[log] body : {"timestamp":"2024-12-11T05:31:13.545+09:00","status":415,"error":"Unsupported Media Type","path":"/paymember/34/11/pay"}

1-2. 코드
  static Future<bool> setPaid(int paymentId, int memberId) async {
    Uri url =
        Uri.parse("${_authInfoApi.url}/paymember/$paymentId/$memberId/pay");
    Map<String, String> header = {'username': _authInfoApi.username!};
    Map<String, dynamic> body = {
      'time': DateTime.now().toUtc().toIso8601String(),
    };

    log("===== setPaid api =====");
    log("paymentId : $paymentId");
    log("memberId : $memberId");
    log("body : $body");

    return await HttpInterface.requestPatch(url, header, body);
  }

1-3. content type json 포함 시
[log] ===== setPaid api =====
[log] paymentId : 34
[log] memberId : 11
[log] body : {time: 2024-12-10T20:34:30.501682Z}
[log] 400 failed
[log] body : {"timestamp":"2024-12-11T05:34:30.945+09:00","status":400,"error":"Bad Request","path":"/paymember/34/11/pay"}


12/9
1. 예산 기록 조회, 
리스트 2개씩만 오나요 아직?

2. 참가율 변화 조회, 납부율 변화 조회, 회원 점수 조회
개인 통계인가염

12/6
1. 회원 연체 납부
api 기재 내역
PATCH /paymember/{장부 Id}/{회원 ID}/late-pay
header: {  
  Authorization: Bearer ${accessToken value},
}
body: {
 {납부 시간} (Instnat, ISO 8601)
}
바디 있는거맞아여?


2. 장부 생성, 납부대상 등록 - 전체
장부 생성 시 기본적으로 모든 멤버를 납부대상으로 등록하고 제외할 멤버를 따로 상호작용을 통해 제외시키는게 사용자 입장에서 편할거같은데 가능한가여? 안되면 장부 생성 시 응답으로 장부 id 반환해주심 제가할게여


3. 회원수 변화 조회
time이 Null일 때 500 오류, time을 줬을 때는 정상 동작합니다.
  static Future<dynamic> getMemberStatistics(int clubId, DateTime? time) async {
    Uri url;
    if (time == null) {
      log("time null in api");
      url = Uri.parse("${_authInfoApi.url}/data/club/$clubId/member");
    } else {
      String timeParam = time.toUtc().toIso8601String();
      url = Uri.parse(
        "${_authInfoApi.url}/data/club/$clubId/member?fromTime=$timeParam",
      );
    }

    Map<String, String> header = {'username': _authInfoApi.username!};

    dynamic data = await HttpInterface.requestGet(url, header);
    if (data == null) {
      log("err from getMemberStatistics");
      return;
    }

    log("===== getMemberStatistics in api =====");
    log("$data");

    return data;
  }

4.활동수 변화 조회
trend와 actCloseCount랑 다른 점이 없는거같아서 걍 Count 필드들로 그래프 구성했어여

5. 데이터 서버가 조금 아픈거같아여;;
잘 뜨는데 가끔씩 연결이 안됨
[log] 503 failed
[log] body : {"message":"Service Unavailable"}






12/5
- 활동 조회
장소랑 설명 바껴서 와여

- 활동 종료, 활동 취소 api 오류
DummyA(관리자)로 적용 시
[log] 404 failed
[log] body : {"clubId":3,"error":"NOT_MEMBER_EXCEPTION","message":"회원 아님","username":"Dummy_userA"}
카카오계정 로그인 후 모임 생성(회장) 및 활동 만들고 취소/종료
[log] 404 failed
[log] body : {"clubId":8,"error":"NOT_MEMBER_EXCEPTION","message":"회원 아님","username":"kakao_3778335311"}

- 예산 조회
처음 time에 null값 주고 조회 시 0원 나옴

- 장부 등록 api
url paybook으로 바꾸고 deadline까지(utc) 넣었는데 안되영
등록 시 200
  static Future<dynamic> registPayment(
    int clubId,
    int amount,
    String name,
    String description,
    DateTime deadline, //need to utc
  ) async {
    Uri url = Uri.parse("${_authInfoApi.url}/paybook");
    Map<String, String> header = {
      "Content-Type": "application/json",
      'username': _authInfoApi.username!,
    };
    Map<String, dynamic> body = {
      "clubId": clubId,
      "amount": amount,
      "name": name,
      "description": description,
      "deadline": deadline.toIso8601String(),
    };

    log("regist info - amount : $amount, name : $name, des : $description, clubId : $clubId");

    dynamic data = await HttpInterface.requestPost(url, header, body);
    if (data == null) {
      log("err from registPayment");
      return;
    }

    return data;
  }

- 납부 대상 목록 조회
입금액은 필드에 포함 못한다고 했었는데 맞나영

12/2
예산 기록 조회
필드에 갱신 액수가 증감된 후 예산의 값을 보내주세여 -> X

- 활동 상세, 활동 참가, 취소 api 오류
1. Dummy user A로 참가 및 취소 수행 시 attend만 변경되고 리스트에서 제거되지 않음.
[log] {attend: true, list: [{id: 1, activityId: 1, username: Dummy_userA, memberId: 1, memberName: 허연준, status: 참가, changedAt: 2024-11-29T06:32:14.465080Z}, {id: 2, activityId: 1, username: Dummy_userB, memberId: 2, memberName: 임윤빈, status: 참가, changedAt: 2024-11-29T06:32:14.485275Z}]}
[log] {attend: false, list: [{id: 1, activityId: 1, username: Dummy_userA, memberId: 1, memberName: 허연준, status: 불참, changedAt: 2024-12-02T18:42:32.293819Z}, {id: 2, activityId: 1, username: Dummy_userB, memberId: 2, memberName: 임윤빈, status: 참가, changedAt: 2024-11-29T06:32:14.485275Z}]}

2. participant list에 2명이 있음에도 활동 상세 api에서 participantNum이 0명으로 나옴. 또한 참가 취소 시 -1명이 됨.

3. "활동 종료, 활동 취소, 활동 추가참가, 추가불참" api는 활동을 개설한 주최자가 수행해야 할 기능인 것 같은데 맞는지?
-> 맞다면 "활동 조회"에 주최자 명시 요망

- 모든 api에 대해
image 필드에는 null을 넣어 보내도 되는가?




# issueing
12/11
- 구축된 api 점검 및 피드백 적용 진행 중
- 통계 화면 구축 완료


- 그래프 축의 숫자가 계속 바뀔텐데, 간격은 어느정도로?

12/ 4
회비 장부에 담당자, 모금 기간, 종료 기간 각 회원 별 입금 날짜 기입 완료
납부 상태 추가 및 미납자 정보 api 대기 중

모임 활동에 위치 정보 필드 요청해서 이를 구현

질문거리
1번 화면처럼 간단한 화면들이 여러 개 연결되어있을 때 문서를 어떤 식으로 작성해야 하나




# TODO
- 장부 상세 페이지
쉼표, 원표시앞에
name : 장부 이름(appbar에)
별도로 담당자 이름 옴
-> 확인해볼것 추가해뒀대

# api 요청사항
- 클럽 정보 변경 api
연락처도 변경해야되지않을까?(우선순위 낮음)

- 운영 종료된 모임은 따로 받을수있나?(우선순위 낮음)

- 내 클럽 목록 조회 수정 요청사항
인원수 추가, 연락처 추가

- 예산 기록 조회
필드에 갱신 액수가 증감된 후 예산의 값을 보내주세여

* 프런트측 장부 조회 페이지 구축 시 아래 두 api를 합쳐서 구현해서, 제가 요청하는 필드가 api를 설계하신 의도와 다를 수 있어요
- 장부 조회
status 추가 : 입금액이 회비에 못미치면 ex) 진행 중
현재 납부액
총액
미납 인원 (진행중 까지)
납부 인원
제외 인원

- 납부 대상 목록 조회
페이징 기능 빼고 전 인원 리스트를 모두 받기(페이징이 필요할정도로 부하가 되지는 않을듯)
-> 미납자 조회를 프런트에서 가능
입금 날짜
금액

# 발생한 오류
12/9
3. 저번에 말했던 클럽 정보 변경 오류 상세
3-1. argument 출력 및 오류 로그
[log] ===== changeClubDetail in api =====
[log] clubId : 2
[log] name : ㄴ
[log] description : ㄴ
[log] status : ACTIVE
[log] image : exist
[log] ============ Upload failed, response is ============
[log] {"timestamp":"2024-12-09T03:37:13.946+09:00","status":500,"error":"Internal Server Error","path":"/club"}
[log] false

3-2. 상황 설명
모든 파라미터에 값은 주어져 있음.
운영중, 운영종료, 모집중 모두 실패

3-3. 코드 상세
  static Future<bool> changeClubDetail(
    int clubId,
    String? name,
    String? description,
    String? status,
    XFile? image,
  ) async {
    Uri url = Uri.parse("${_authInfoApi.url}/club");
    var request = http.MultipartRequest('PATCH', url);

    //insert header
    request.headers['username'] = _authInfoApi.username!;

    //insert body
    if (image != null) {
      var file = await http.MultipartFile.fromPath('image', image.path);
      request.files.add(file);
      request.fields['imageChanged'] = "true";
    } else {
      request.fields['imageChanged'] = "false";
    }
    if (name != null) {
      request.fields['name'] = name;
      request.fields['nameChanged'] = "true";
    } else {
      request.fields['nameChanged'] = "false";
    }
    if (description != null) {
      request.fields['description'] = description;
      request.fields['descriptionChanged'] = "true";
    } else {
      request.fields['descriptionChanged'] = "false";
    }
    if (status != null) {
      request.fields['status'] = status;
      request.fields['statusChanged'] = "true";
    } else {
      request.fields['statusChanged'] = "false";
    }

    return await HttpInterface.requestMultipart(request);
  }




1. 클럽 정보 변경 api
연락처도 변경해야되지않을까?

image랑 location 전부 null 가능해요

변경 시도 시 오류
1) status를 문자열 ACTIVE로 해서
[log] ============ Upload failed, response is ============
[log] {"timestamp":"2024-11-13T04:07:02.870+09:00","status":500,"error":"Internal Server Error","path":"/club"}
[log] false

2) status를 문자열 운영중 으로 해서
[log] ============ Upload failed, response is ============
[log] {"timestamp":"2024-11-13T04:08:24.738+09:00","status":400,"error":"Bad Request","path":"/club"}
[log] false;

2. 예산 조회 에러
데이터가 없는 날짜 이전을 조회하면 에러

3. 장부 생성 api 오류
200 success 왔으나 "장부 목록 조회 api"로 조회 시 보이지 않음.
각 항목 int, String, String으로 잘 전달 됨.

static Future<dynamic> registPayment(
    int clubId,
    int amount,
    String name,
    String description,
  ) async {
    Uri url = Uri.parse("${_authInfoApi.url}/budget");
    Map<String, String> header = {
      "Content-Type": "application/json",
      'username': _authInfoApi.username!,
    };
    Map<String, dynamic> body = {
      "clubId": clubId,
      "amount": amount,
      "name": name,
      "description": description,
    };

    log("regist info - amount : $amount, name : $name, des : $description, clubId : $clubId");

    dynamic data = await HttpInterface.requestPost(url, header, body);
    if (data == null) {
      log("err from registPayment");
      return;
    }

    return data;
  }




# 메모
form 필요한건 한꺼번에 해야겠다
- 프로필변경
- 클럽생성
- 클럽정보변경

api 대신 파이썬으로 데잍 ㅓ생성
실물자료는 없냐?
마르코프체인은 이해했냐?
스탶

납부정보에
미에있는사람 
입금액 작으면 진행 중
입금 날짜
계좌랑 정보가 대조되어야됨 -> 
시간 금액
납부 장부의 총액
미납자 몇명인지

후원 목적으로 더 많이 내는 사람
미납자 명수, 누군지, 미납자에게 알람

납부 빨리하는사람은 포인트업
db에 들가는 모든 정보에 포인트
포인트테이블
관리자가 포인트 설정할수있


활동 - 온라인, 오프라인
사용자 편의에 맞춰라

앱에서 db 모니터링
스케줄링으로 한번씩 요청하자 얼마마다
마코프체인은 메모리를 두던지 해라

# 이벤트 정리 (회원 활동 위주)
데이터 기반 수치로 어떤 것을 나타낼까
1. 열정 회원, 관심 회원(곧 탈퇴할 회원), 스태프로 적합한 회원(예산을 다루므로 신뢰가 가야 한다)
2. 시행할 이벤트의 규모, 준비 기간, 비용 등을 결정할 수 있도록
모임 규모가 크고 활동이 많아도 소비력이 낮은 회원들이 주를 이룬다면(학생들 등) 높은 비용이 필요한 이벤트를 개최해도 참여율이 저조할 것이다. 반대로 모임 규모가 작고 활동이 적어도 소비력이 높은 회원들이 주를 이룬다면(회사를 다니는 청년 또는 중년층은 시간이 없으나 경제력은 있을 것) 비용을 높게 잡고 이벤트 개최까지의 준비 기간을 길게 해서(월차 등의 일정을 맞추도록) 이벤트를 개최할 수 있도록


## issueing
데이터 기반 수치로 어떤 것을 나타낼까
-> 열정 회원, 관심 회원(곧 탈퇴할 회원), 스태프로 적합한 회원(예산을 다루므로 신뢰가 가야 한다)

다른게 또 있을까
-> 시행할 이벤트의 규모, 준비 기간, 비용 등을 결정할 수 있도록
모임 규모가 크고 활동이 많아도 소비력이 낮은 회원들이 주를 이룬다면(학생들 등) 높은 비용이 필요한 이벤트를 개최해도 참여율이 저조할 것이다. 반대로 모임 규모가 작고 활동이 적어도 소비력이 높은 회원들이 주를 이룬다면(회사를 다니는 청년 또는 중년층은 시간이 없으나 경제력은 있을 것) 비용을 높게 잡고 이벤트 개최까지의 준비 기간을 길게 해서(월차 등의 일정을 맞추도록) 이벤트를 개최할 수 있도록

마르코프 체인 기반 시나리오 생성
지금 적혀있는 이벤트들은 마르코프 체인이나 데이터 생성 시 사용하기엔 부적절한듯
예를 들어 납부, 미납, 연체 납부 처럼 구분이 되어있어야 적절한 attribute가 되는데, 다 뭉뚱그려서 status change로 되어있어서 api 분류로 속성을 정하는게 낫겠다

모임에 대한 회원 등록(참가) ~~ 회원 탈퇴(강퇴)까지의 마르코프 체인을 위한 전이 행렬
- 활동 관련 state 정의
0. 활동 등록
1. 등록한 활동 취소
2. 활동 참가
3. 활동 불참
4. 활동 추가 참가
5. 활동 참가 취소

상태 전이가 불가능한 요소들
(0,5)
(1,1)
(1,5)
(2,1)
(3,1)
(3,5)
(4,1)
(5,1)

조건
활동 등록 : 등록 취소가 일어나지 않는 한 해당 활동을 수행했다고 판단
불참 -> 불참 : 유령 회원으로 있는 경우

- 예산 관련 state 정의
0. 회비 미납
1. 회비 납부
2. 회비 연체
3. 회비 연체 납부

상태 전이 행렬
    미납  납부  연체  연납
미납  ?    ?    ?    0
납부  ?    0    0    0
연체  0    0    ?    ?
연납  ?    0    0    0

조건
미납 : 기본적으로 장부 생성 시 모두 미납 상태
연체 : 미납 상태로 데드라인 넘었을 경우. 끝까지 안낼경우 끝까지 연체 상태
납부 -> 미납 : 장부가 새로 생성되었을 경우를 나타냄

=> 이 두 가지 요소로 staff로 적합한지를 평가, 척도를 만들어서 그에 대한 분포도 만들자(x축을 척도로 한 확률 분포 함수)
* 일반 회원으로 강등은 없음. 추방을 하자


## legacy

- 영향을 주는 이벤트
  애매함
  장부 생성
  장부 취소
  장부 만료

  나머지 필요 없음


- club server
클럽 생성
클럽 해체
=> 제외한다

회원 등록(참가)
회원 권한 변경
회원 탈퇴
회원 강퇴

ClubCreated - ClubClosed
MemberCreated - MemberBanned
BudgetCreated - BudgetClosed

ClubChanged
MemberRoleChanged
MemberWithdrawn


- activity server
활동 등록
활동 취소
활동 종료
활동 참가
활동 불참
활동 추가참가
활동 추가불참

ActivityCreated - ActivityCanceled - ActivityClosed
ParticipantConfrimed - ParticipantCreated - ParticipantStatusChanged


- budget server
예산 갱신

장부 생성
장부 취소
장부 만료

납부 대상 등록
납부 대상 제외

납부
미납
연체 납부

BudgetUpdated

PayBookCreated
PayBookCanceled
PayBookClosed

PayMemberConfirmed
PayMemberCreated
PayMemberStatusChanged


# setting
1. regist android platform
1) 해시 키 등록 - KakaoSdk.origin으로 생성 가능
2) app/build.gradle의 applicationId에서 패키지명 찾아 입력
3) web에서 redirect url 등록
4) dash board에서 카카오 로그인, redirect url(필요 시) 설정
5) 앱 키를 플러터 어플에 기재

2. android setting
1) settings.gradle
maven { url = "https://devrepo.kakao.com/nexus/content/groups/public/" }

2) app/build.gradle.kts(Module)
-> android/app에
repositories {
    google()
    mavenCentral()
    maven { url "https://devrepo.kakao.com/nexus/content/groups/public/" }
}
dependencies {
  //implementation "com.kakao.sdk:v2-all:2.20.6" // 전체 모듈 설치, 2.11.0 버전부터 지원
  implementation "com.kakao.sdk:v2-user:2.20.6" // 카카오 로그인 API 모듈
  //implementation "com.kakao.sdk:v2-share:2.20.6" // 카카오톡 공유 API 모듈
  //implementation "com.kakao.sdk:v2-talk:2.20.6" // 카카오톡 채널, 카카오톡 소셜, 카카오톡 메시지 API 모듈
  //implementation "com.kakao.sdk:v2-friend:2.20.6" // 피커 API 모듈
  //implementation "com.kakao.sdk:v2-navi:2.20.6" // 카카오내비 API 모듈
  implementation "com.kakao.sdk:v2-cert:2.20.6" // 카카오톡 인증 서비스 API 모듈
}

3) android minsdk 설정
-> android/app/build.gradle
minSdk = 23

4) activity 설정
<activity 
            android:name="com.kakao.sdk.auth.AuthCodeHandlerActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <!-- Redirect URI: "kakao${NATIVE_APP_KEY}://oauth" -->
                <data 
                    android:host="oauth"
                    android:scheme="kakao73a1fd675447ff78421025b9d793648d" />
            </intent-filter>
        </activity>

3. listview포함한 singlescrollview
-> physics: const NeverScrollableScrollPhysics(),
-> shrinkWrap: true,

4. ios configuration
1) app 등록
2) allowlist 설정
    ios/Runner/info.plist의 dic의 맨 아래
    <key>LSApplicationQueriesSchemes</key>
  	<array>
      	<string>kakaokompassauth</string>
      	<string>kakaolink</string>
      	<string>kakaoplus</string>
  	</array>
3) 

5. imagePicker lib setting
Android에서는 카메라나 저장소 접근 권한을 요청해야 합니다. AndroidManifest.xml 파일에 다음 권한을 추가합니다.
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>

권한 설정 (iOS)
iOS에서는 Info.plist 파일에 다음 권한을 추가해야 합니다.
<key>NSPhotoLibraryUsageDescription</key>
<string>이 앱이 사진을 사용할 수 있도록 허용합니다.</string>
<key>NSCameraUsageDescription</key>
<string>이 앱이 카메라를 사용할 수 있도록 허용합니다.</string>
이제 이미지를 선택할 수 있는 기능이 완성되었습니다. 앱을 실행하고 "이미지 선택" 버튼을 클릭하여 이미지를 선택할 수 있습니다.


6. geocoding setting
google map key : AIzaSyBycfPyrH12BjWPPgLzx_FxsOwH3YGb2EE

https://console.cloud.google.com/welcome?inv=1&invt=AbjJ7w&project=doguber-fcm-test
Google Developers Console 로 이동합니다 .
Google 지도를 활성화할 프로젝트를 선택하세요.
탐색 메뉴를 선택한 다음 "Google 지도"를 선택하세요.
Google Maps 메뉴에서 "API"를 선택하세요.
Android용 Google 지도를 활성화하려면 "추가 API" 섹션에서 "Android용 Maps SDK"를 선택한 다음 "활성화"를 선택하세요.
iOS용 Google 지도를 활성화하려면 "추가 API" 섹션에서 "iOS용 Maps SDK"를 선택한 다음 "활성화"를 선택하세요.
웹용 Google Maps를 사용하려면 "Maps JavaScript API"를 활성화하세요.
활성화한 API가 "활성화된 API" 섹션에 있는지 확인하세요.


6-1. Android
android/app/build.gradle 파일에서 minSdkVersion이 19 이상인지 확인합니다.
android {
    defaultConfig {
        minSdkVersion 19
    }
}

AndroidManifest.xml에 인터넷 권한 추가
<uses-permission android:name="android.permission.INTERNET" />

6-2. iOS
ios/Runner/Info.plist에 아래 내용을 추가하여 네트워크 요청을 허용합니다.
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

iOS의 경우, pod install을 다시 실행하여 네이티브 종속성을 업데이트합니다.
cd ios
pod install

# 오류
1. 카카오 로그인 "동의하고 계속하기"이후 진행 안됨 이슈
-> 카톡 없을 경우 웹 로그인
https://devtalk.kakao.com/t/android-sdk-v2/137261

themeactivity 설정
-> AndroidManifest.xml

-> app/build.gradle
implementation 'androidx.appcompat:appcompat:1.6.1' // Ensure you have AppCompat dependency
implementation 'com.google.android.material:material:1.9.0' // Material Components dependency

2. The iOS deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 11.0, but the range of supported deployment target versions is 12.0 to 18.0.99.
podfile 변경


3. No profiles for 'com.example.bandFront' were found: Xcode couldn't find any iOS App Development provisioning profiles matching 'com.example.bandFront'. Automatic signing is disabled and unable to generate a profile.

https://code-boki.tistory.com/110

이거따라하셈. 첨에 신뢰하지않는 어쩌구 뜨면 설정-> 일반 -> vpn&device management에서 allow해주면됨
한번해주면 이후로 잘된당!

4. initState에서 provider 사용 시 read만 가능. 예제는 Profileview qhrl

5. api image err
0) 조건 : 내 카카오톡 유저로 로그인 -> 프로필 페이지 작성, 클럽 생성

1) 플러터에서 이미지를 다룰 수 있는 데이터타입 파악
ByteData: 이미지 파일을 바이트 배열로 변환 -> Uint8List 타입으로 변환해서 전송해야 함
Uint8List: 이미지 데이터 -> 바이트 배열, multipartFile로 전송, 서버에서 이미지 파일로 판정
base64 : 이미지 데이터 -> 문자열, form-data(json)으로 매핑해서 전송, 서버에서 디코딩 필요

2) http에서 이미지를 다루는 데이터타입 파악
File: Dart의 dart:io 라이브러리에서 제공하는 파일 객체, 로컬 저장소
MultipartFile: 이미지 파일을 서버로 업로드할 때 사용되는 타입

3) http에서 이미지를 보내는 방법
http.MultipartRequest : 이미지 파일or이미지 바이트를 http.MultipartFile로 변환
Base64 문자열 인코딩으로 이미지 전송 : form-data로 전송 가능

4) multipart와 form data 섞어서 요청하는 방법


3) 테스트 api 생성 후 전송 전 로그 작성(Username 포함)
test 함수 첫 실행 -> 잘됨
같은 로직을 가진 changeMyProfile 함수 실행 -> 실패
test 함수 다시 실행 -> 실패
이미지를 제외한 데이터 변경 -> 성공

상세 과정
1) 모든 필드 true, 필드 하드코딩, UI에서 이미지파일만 선택 후 요청, 성공
2) UI에서 입력을 받아 이미지 제외 텍스트만 변경 시도, 성공, 텍스트 바뀌고 이미지는 기본 이미지?(곰돌이프사, 로컬에없는이미지)로 변경됨
3) UI에서 이미지 포함 모든 필드 변경 시도, 실패
4) 다시 모든 필드 true, 필드 하드코딩, 이미지파일만 선택 후 요청, 실패
5) UI에서 입력을 받아 이미지 제외 텍스트만 변경 시도, 성공


MultipartFile.fromPath(XFile.path) -> 실패
MultipartFile.fromBytes(File(imageFile.path)) -> ㄴㄴ
