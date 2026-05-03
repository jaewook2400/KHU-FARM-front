# KHU:FARM (쿠팜)

> 생산자(농가) · 소매업자 · 소비자를 직접 연결하는 **못난이 과일 직거래 플랫폼**
> Flutter 기반 크로스플랫폼(iOS · Android) 모바일 애플리케이션

판로를 찾기 어려운 못난이 과일을 합리적인 가격으로 거래할 수 있도록, **3가지 사용자 역할(농가 / 소매업자 / 소비자)** 에 맞춘 별도의 플로우와 권한 체계를 단일 앱 내에서 제공합니다. 결제·배송·환불·리뷰·문의 등 커머스의 전 단계를 직접 구현했으며, 만보기 기반 친환경 리워드와 지역 날씨 정보 등 사이드 기능도 함께 통합했습니다.

---

## 📌 프로젝트 개요

| 항목 | 내용 |
| --- | --- |
| 프로젝트 유형 | 농산물 직거래 커머스 모바일 앱 |
| 플랫폼 | iOS / Android (Flutter) |
| 역할 구분 | 소비자(Consumer) · 소매업자(Retailer) · 농가(Farmer) |
| 담당 영역 | **프론트엔드 전반** — 화면 설계 · 라우팅 · 상태/스토리지 · API 연동 · 결제/푸시/위치 등 네이티브 통합 |
| 협업 | 백엔드 · 디자이너와 직접 커뮤니케이션하며 DTO·플로우 협의 |

---

## 🛠 기술 스택

**Framework / Language**
- Flutter (Dart, SDK ^3.7.2)

**상태 · 스토리지 · 인증**
- `flutter_secure_storage` — JWT(Access/Refresh) 안전 저장
- `shared_preferences` — 만보기 기준값 등 디바이스 로컬 캐시
- 자체 구현 토큰 만료 검사 + Refresh 자동화

**네트워크 · 데이터**
- `http` — REST API 통신, JWT 헤더 인터셉터
- 자체 정의 Model 레이어 (`fromJson`/`toJson`/`copyWith` 패턴)

**결제 / 배송 / 위치**
- `portone_flutter` — KG이니시스 PG 결제 연동
- `daum_postcode_search` — 다음 우편번호 검색
- `geolocator` — 위치 기반 날씨

**푸시 / 알림**
- `firebase_core`, `firebase_messaging` — FCM 토큰 발급·서버 동기화
- `flutter_local_notifications` — 포그라운드 로컬 알림 채널

**부가 기능**
- `pedometer`, `permission_handler` — 만보기 리워드(걸음 수 → 포인트)
- `flutter_quill` — 리치 에디터(상품 상세 작성)
- `image_picker` — 상품/리뷰 이미지 업로드
- `table_calendar` — 주문/관리 일정 뷰
- `flutter_inappwebview` — 약관/공지 웹뷰
- `flutter_native_splash`, `flutter_launcher_icons` — 네이티브 스플래시·아이콘

---

## 🧩 핵심 기능

### 1. 역할 기반 분기 (Multi-Role App)
하나의 앱에서 3가지 사용자 유형을 분리된 라우팅 트리로 제공합니다.

- **소비자** — 일반 구매, 찜/장바구니/주문/리뷰
- **소매업자** — B2B 도매 카테고리(`stock`) 추가 노출, 대량 주문 흐름
- **농가** — 위 기능 + **상품/주문/리뷰/문의 관리 페이지** 전용 트리

라우트는 [main.dart](lib/main.dart) 의 `routes` 맵에서 모든 화면을 명시적으로 등록(`/consumer/...`, `/retailer/...`, `/farmer/...`)하여, 역할별 진입점과 권한 경계를 명확히 분리했습니다.

### 2. 인증 / 자동 로그인 / 토큰 갱신
- Access Token(10시간 만료) + Refresh Token 이중 구조
- 앱 부팅 시 [auth_service.dart](lib/services/auth_service.dart) 의 `tryAutoLogin()` → `getValidAccessToken()` → `refreshAccessToken()` 체인으로 무중단 갱신
- 로그인 상태일 때만 FCM 토큰을 서버에 등록하여 비로그인 사용자에게 푸시가 발송되지 않도록 제어 ([main.dart:178](lib/main.dart#L178))

### 3. 커머스 전 흐름 직접 구현
결제와 환불의 모든 상태를 직접 화면화했습니다.

- **상품 탐색** — 카테고리(사과/감귤/배/선물), 일반 판매(`daily`), 도매(`stock`), 수확 캠페인(`harvest`)
- **장바구니 / 찜** — 옵션·수량 단위 관리, 일괄 주문
- **주문/결제** — 직접 주문 / 장바구니 주문 / 배송지 선택·추가·수정 / 다음 우편번호 / 공동현관 비밀번호(배송 완료 시 즉시 파기) / PortOne 결제
- **주문 후 흐름** — 주문 성공/실패, 주문 상세, 환불 신청, 리뷰 작성

### 4. 농가 전용 운영 콘솔
[farmer/mypage/manage](lib/screens/farmer/mypage/manage/) 하위에 입점 농가가 직접 운영할 수 있는 어드민 수준의 화면을 구현했습니다.

- **상품 관리** — 등록 / 옵션 추가 / 미리보기 / 수정 / 삭제 (FlutterQuill 기반 상세 작성)
- **주문 관리** — 신규 주문, 운송장 입력/수정, 배송 상태, 결제 취소, 환불 수락/거절
- **리뷰 / 문의 관리** — 상품별 리뷰·문의 조회 및 답변 등록

### 5. 친환경 리워드 — 만보기 연동
[pedometer_service.dart](lib/services/pedometer_service.dart) 에서 다음을 처리합니다.

- 싱글턴 + Broadcast Stream 패턴으로 앱 전역에서 걸음 수 구독
- `SharedPreferences` 에 일자별 기준값(baseline) 저장 → **앱 재실행 시에도 일일 걸음 수 정확히 복원**
- 자정 롤오버 처리: 새 날짜 진입 시 baseline 0으로 초기화 후 서버 동기화
- 사용자가 권한을 거부해도 앱이 죽지 않도록 graceful degradation

### 6. 지역 날씨 (공공데이터포털 연동)
[weather_service.dart](lib/services/weather_service.dart) 는 기상청 단기예보 API를 사용합니다.

- 위/경도 → 기상청 격자 좌표(LCC 투영) 변환을 클라이언트에서 직접 계산
- 기준 시각을 02시 발표분으로 고정하여 최저/최고기온 누락 방지
- 응답 파싱 시 `resultCode` 검사로 API 에러를 명시적으로 처리

### 7. FCM 푸시 + 로컬 알림 채널
[main.dart](lib/main.dart#L154) 에서 안드로이드 알림 채널(`fcm_default_channel`, `Importance.max`)을 명시 생성하고, iOS는 `DarwinInitializationSettings` 로 권한을 분기 요청합니다. 알림 수신 → 앱 상태별(Foreground/Background/Terminated) 분기는 [notifiaction_service.dart](lib/services/notifiaction_service.dart) 에서 일괄 처리합니다.

---

## 🗂 디렉터리 구조

```
lib/
├─ main.dart                  # 앱 진입점 + 전역 라우트 테이블
├─ constants.dart             # baseUrl, 카테고리, 택배사, 약관 전문
│
├─ model/                     # 도메인 모델 (fromJson/toJson)
│   ├─ user_info.dart
│   ├─ fruit.dart             # 상품
│   ├─ order.dart, seller_order.dart, order_status.dart
│   ├─ cart_order.dart, address.dart
│   ├─ delivery_tracking.dart, review.dart, inquiry.dart
│   ├─ notification.dart, weather_data.dart, farm.dart
│
├─ services/                  # 외부 의존성 / 사이드이펙트 격리
│   ├─ auth_service.dart      # JWT 발급·갱신·자동 로그인
│   ├─ storage_service.dart   # SecureStorage 래퍼 + 메모리 캐시
│   ├─ notifiaction_service.dart   # FCM 수신·핸들링
│   ├─ pedometer_service.dart # 걸음 수 싱글턴 스트림
│   ├─ weather_service.dart   # 기상청 격자 변환·예보 파싱
│   └─ postcode_service.dart  # 다음 우편번호
│
├─ screens/                   # 역할별 화면 트리
│   ├─ splash/                # 스플래시 + 자동 로그인 분기
│   ├─ account/               # 로그인 · 회원가입(3타입) · 계정찾기
│   ├─ order/                 # 공통 주문/결제/배송지 플로우
│   ├─ consumer/              # 소비자 전용 트리
│   │   ├─ main_screen.dart, daily/, harvest/, laicos.dart
│   │   ├─ cart.dart, dibs_list.dart, notification_list.dart
│   │   └─ mypage/ (info, order, review, csc)
│   ├─ retailer/              # 소매(B2B) 전용 트리 (+ stock/)
│   └─ farmer/                # 농가 전용 트리 (+ mypage/manage/)
│       └─ mypage/manage/     # 농가 어드민 콘솔
│           ├─ product/  (add/edit/delete + option, preview)
│           ├─ order/    (new/refund/cancel/delivery + card/)
│           ├─ review/   (답변 등록)
│           └─ inquiry/  (답변 등록)
│
└─ shared/                    # 디자인 시스템
    ├─ app_colors.dart
    ├─ text_styles.dart
    └─ widgets/  (alert, daily, top_norch_header)
```

---

## 🧠 설계 포인트

- **명시적 라우팅** — 코드 분할을 위한 동적 import 대신, 모든 라우트를 `main.dart` 한 곳에 등록하여 **권한 경계와 화면 흐름이 즉시 보이도록** 했습니다. 역할별 prefix(`/consumer`, `/retailer`, `/farmer`)로 트리 일관성을 유지합니다.
- **Service 레이어 분리** — 외부 의존성(저장소·결제·푸시·위치·만보기)은 모두 `services/` 에서 싱글턴으로 격리하여 화면 코드는 순수 Flutter 위젯/상태에만 집중합니다.
- **Model First** — 백엔드 응답을 그대로 쓰지 않고, 모든 도메인을 `model/` 에 정의해 **`fromJson` 단계에서 null safety / 기본값을 보장**합니다 (`json['xxx'] ?? 0` 패턴).
- **디자인 시스템** — Pretendard(본문) + RixInooAriDuri(로고) 2-폰트 체계, `app_colors.dart` / `text_styles.dart` 로 토큰화하여 화면 간 일관성 유지.
- **국제화 대비** — `flutter_localizations` + `supportedLocales: [en, ko]` 로 다국어 확장 가능 구조.
- **사용자 경험** — 네이티브 스플래시(Android 12 대응), 상태바 색상 강제(`SystemUiOverlayStyle`), 알림 아이콘 별도 제작(`ic_notification`).

---

## 🔗 외부 연동

| 영역 | 제공자 / 라이브러리 |
| --- | --- |
| 결제 | KG이니시스 (PortOne SDK) |
| 푸시 | Firebase Cloud Messaging |
| 주소 검색 | 다음(카카오) 우편번호 |
| 날씨 | 기상청 단기예보 (공공데이터포털) |
| 배송 추적 | CJ대한통운, 한진, 롯데, 우체국 등 19개 택배사 매핑 |

---

## 🚀 빌드 / 실행

```bash
flutter pub get
flutter run                              # 개발 실행
flutter pub run flutter_native_splash:create
flutter pub run flutter_launcher_icons   # 아이콘 생성
flutter build apk --release              # Android
flutter build ios  --release             # iOS
```

> ⚠️ Firebase 설정 파일(`google-services.json`, `GoogleService-Info.plist`)과 결제/공공데이터 API 키가 필요합니다.

---

## 📈 버전

`pubspec.yaml` 기준 현재 버전 **1.0.9+19** — 실서비스 출시 및 다수의 기능 업데이트를 거친 운영 단계 프로젝트입니다.
