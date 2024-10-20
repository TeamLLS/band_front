# band_front

# 회의 때 말할 것
프로필에 내가 속해 있는 클럽들 표시?

# issueing
https://www.eleken.co/blog-posts/tips-for-better-ux-readability-dos-and-donts

- 디자인
흰 바탕, 검은 글씨 통일
-> 구분감을 주기 위해 그림자를 많이 짙게 사용
포인트 색을 지정하여 포인트에만 사용


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




# 오류
1. 카카오 로그인 "동의하고 계속하기"이후 진행 안됨 이슈
-> 카톡 없을 경우 웹 로그인
https://devtalk.kakao.com/t/android-sdk-v2/137261

themeactivity 설정
-> AndroidManifest.xml

-> app/build.gradle
implementation 'androidx.appcompat:appcompat:1.6.1' // Ensure you have AppCompat dependency
implementation 'com.google.android.material:material:1.9.0' // Material Components dependency