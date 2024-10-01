# band_front


# 오류
1. 카카오 로그인 "동의하고 계속하기"이후 진행 안됨 이슈
https://devtalk.kakao.com/t/android-sdk-v2/137261

1) settings.gradle에 다음 줄 추가
maven { url = "https://devrepo.kakao.com/nexus/content/groups/public/" }

2) build.gradle.kts(Module) 파일에 dependencies 추가
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