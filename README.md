# band_front

# 회의 때 말할 것
- 내 클럽 리스트 조회
페이지당 보내는 클럽 갯수 더 늘려주세요


# issueing

# 메모
form 필요한건 한꺼번에 해야겠다
- 프로필변경
- 클럽생성
- 클럽정보변경




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
