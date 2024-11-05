# band_front

# 회의 때 말할 것
클럽 리스트 조회 시 컨텍정보, 인원수 보내기

api err
1. 프로필
  이미지 포함 요청이든 아니든 변경요청 후 다시 데이터 요청받아와도 처음 값 그대로임
2. activity 참가 신청
  오류 진행 과정
  더미 A로 테스트 로그인
  더미 A의 모임 페이지 진입 후 활동 아디 1 진입
  참가 신청 직후 다시 참가자 요청
  dummy D (이름 최은) 하나만 받아옴
  전페이지에 나갔다 들어오거나, 다시 테스트 로그인하면 처음 받아온 값 그대로 나옴
3. create club err
  400 bad request, post맞나?

- 활동 목록 조회 수정 요청사항
name -> 활동 제목? 사람이름이 들어있음
설명 추가
날짜 추가
contact info 추가

- 내 클럽 목록 조회 수정 요청사항
인원수 추가
연락처 추가
권한은 뭐임??

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