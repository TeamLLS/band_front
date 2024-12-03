# band_front

# 자고일어나서 하기
장부 인터렉션 기능 완성
그랲
(추가된다면)게시판
앨범 -> 내 활동

# 회의 때 말할 것
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

- 장부 등록, 조회
등록 시 200



12/2
- 납부 대상 목록 조회
입금액은 필드에 포함 못한다고 했었는데 맞나영

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
