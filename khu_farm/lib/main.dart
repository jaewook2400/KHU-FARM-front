import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:khu_farm/screens/farmer/mypage/info/account_cancellation.dart';
import 'package:khu_farm/screens/farmer/mypage/info/account_cancelled.dart';
import 'package:khu_farm/screens/retailer/mypage/info/account_cancellation.dart';
import 'package:khu_farm/screens/retailer/mypage/info/account_cancelled.dart';
import 'screens/consumer/mypage/order/order_detail_refund.dart';
import 'services/notifiaction_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:khu_farm/screens/consumer/daily/daily_fruit.dart';
import 'package:khu_farm/screens/consumer/mypage/info/address_list.dart';
import 'package:khu_farm/screens/consumer/mypage/info/edit_address_success.dart';
import 'package:khu_farm/screens/consumer/mypage/info/edit_pw_success.dart';
import 'package:khu_farm/screens/consumer/mypage/order/add_review.dart';
import 'package:khu_farm/screens/consumer/mypage/order/order.dart';
import 'package:khu_farm/screens/consumer/mypage/review/review.dart';
import 'package:khu_farm/screens/farmer/laicos.dart';
import 'package:khu_farm/screens/farmer/mypage/csc/faq/faq_list.dart';
import 'package:khu_farm/screens/farmer/mypage/csc/personal_inquiry/add_inquiry.dart';
import 'package:khu_farm/screens/farmer/mypage/csc/personal_inquiry/personal_inquiry_list.dart';
import 'package:khu_farm/screens/farmer/mypage/info/add_address.dart';
import 'package:khu_farm/screens/farmer/mypage/info/address_list.dart';
import 'package:khu_farm/screens/farmer/mypage/info/edit_address.dart';
import 'package:khu_farm/screens/farmer/mypage/info/edit_address_success.dart';
import 'package:khu_farm/screens/farmer/mypage/info/edit_profile.dart';
import 'package:khu_farm/screens/farmer/mypage/info/edit_pw.dart';
import 'package:khu_farm/screens/farmer/mypage/info/edit_pw_success.dart';
import 'package:khu_farm/screens/farmer/mypage/info/info_list.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/inquiry/manage_inquiry_detail.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/inquiry/manage_product_inquiry.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/inquiry/manage_inquiry.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/inquiry/reply_success.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/order/delivery_number.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/order/delivery_status.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/order/manage_order.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/order/order_detail.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/order/refund_accept.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/order/refund_detail.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/order/refund_reject.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/product/add_product_success.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/product/delete_product.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/product/delete_product_success.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/product/edit_product.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/product/edit_product_detail.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/product/edit_product_preview.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/product/manage_product.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/review/manage_product_review.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/review/manage_review.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/review/manage_review_detail.dart';
import 'package:khu_farm/screens/farmer/mypage/manage/review/reply_success.dart';
import 'package:khu_farm/screens/farmer/mypage/order/add_review.dart';
import 'package:khu_farm/screens/farmer/mypage/order/order.dart';
import 'package:khu_farm/screens/farmer/mypage/review/review.dart';
import 'package:khu_farm/screens/order/add_address.dart';
import 'package:khu_farm/screens/order/address_list.dart';
import 'package:khu_farm/screens/order/cart_order.dart';
import 'package:khu_farm/screens/order/direct_order.dart';
import 'package:khu_farm/screens/address_search.dart';
import 'package:khu_farm/screens/order/edit_address.dart';
import 'package:khu_farm/screens/order/edit_address_success.dart';
import 'package:khu_farm/screens/order/order_fail.dart';
import 'package:khu_farm/screens/order/order_success.dart';
import 'package:khu_farm/screens/retailer/cart.dart';
import 'package:khu_farm/screens/retailer/daily/daily.dart';
import 'package:khu_farm/screens/retailer/daily/daily_fruit.dart';
import 'package:khu_farm/screens/retailer/dibs_list.dart';
import 'package:khu_farm/screens/retailer/harvest/harvest.dart';
import 'package:khu_farm/screens/retailer/laicos.dart';
import 'package:khu_farm/screens/retailer/mypage/csc/personal_inquiry/add_inquiry.dart';
import 'package:khu_farm/screens/retailer/mypage/csc/personal_inquiry/personal_inquiry_list.dart';
import 'package:khu_farm/screens/retailer/mypage/info/add_address.dart';
import 'package:khu_farm/screens/retailer/mypage/info/address_list.dart';
import 'package:khu_farm/screens/retailer/mypage/info/edit_address.dart';
import 'package:khu_farm/screens/retailer/mypage/info/edit_address_success.dart';
import 'package:khu_farm/screens/retailer/mypage/info/edit_pw.dart';
import 'package:khu_farm/screens/retailer/mypage/info/edit_pw_success.dart';
import 'package:khu_farm/screens/retailer/mypage/mypage.dart';
import 'package:khu_farm/screens/retailer/mypage/order/add_review.dart';
import 'package:khu_farm/screens/retailer/mypage/order/order.dart';
import 'package:khu_farm/screens/retailer/mypage/order/refund.dart';
import 'package:khu_farm/screens/retailer/mypage/order/refund_success.dart';
import 'package:khu_farm/screens/retailer/mypage/review/review.dart';
import 'package:khu_farm/screens/retailer/stock/stock.dart';
import 'package:khu_farm/screens/retailer/stock/stock_fruit.dart';
import 'screens/splash/splash.dart';
import 'screens/account/login.dart';
import 'screens/account/signup/usertype.dart';
import 'screens/account/signup/consumer_signup.dart';
import 'screens/account/signup/retailer_signup.dart';
import 'screens/account/signup/farmer_signup.dart';
import 'screens/account/signup/consumer_signup_success.dart';
import 'screens/account/signup/retailer_signup_success.dart';
import 'screens/account/signup/farmer_signup_success.dart';
import 'screens/account/find/account_find.dart';
import 'screens/account/find/id_found.dart';
import 'screens/account/find/temp_password.dart';
import 'screens/account/find/account_not_found.dart';
import 'screens/consumer/main_screen.dart';
import 'screens/consumer/notification_list.dart';
import 'screens/consumer/dibs_list.dart';
import 'screens/consumer/cart.dart';
import 'screens/consumer/daily/daily.dart';
import 'screens/consumer/harvest/harvest.dart';
import 'screens/consumer/laicos.dart';
import 'screens/consumer/mypage/mypage.dart';
import 'screens/consumer/mypage/info/info_list.dart';
import 'screens/consumer/mypage/info/edit_profile.dart';
import 'screens/consumer/mypage/info/edit_pw.dart';
import 'screens/consumer/mypage/info/edit_address.dart';
import 'screens/consumer/mypage/info/add_address.dart';
import 'screens/consumer/mypage/info/account_cancellation.dart';
import 'screens/consumer/mypage/info/account_cancelled.dart';
import 'screens/consumer/mypage/csc/personal_inquiry/personal_inquiry_list.dart';
import 'screens/consumer/mypage/csc/personal_inquiry/add_inquiry.dart';
import 'screens/consumer/mypage/csc/faq/faq_list.dart';
import 'screens/retailer/main_screen.dart';
import 'screens/farmer/main_screen.dart';
import 'screens/farmer/daily/daily.dart';
import 'screens/farmer/daily/daily_fruit.dart';
import 'screens/farmer/stock/stock.dart';
import 'screens/farmer/stock/stock_fruit.dart';
import 'package:khu_farm/screens/farmer/cart.dart';
import 'package:khu_farm/screens/farmer/dibs_list.dart';
import 'package:khu_farm/screens/farmer/notification_list.dart';
import 'screens/farmer/harvest/harvest.dart';
import 'screens/farmer/mypage/mypage.dart';
import 'screens/farmer/mypage/manage/manage_list.dart';
import 'screens/farmer/mypage/manage/product/add_product.dart';
import 'screens/farmer/mypage/manage/product/add_product_detail.dart';
import 'screens/farmer/mypage/manage/product/add_product_preview.dart';

void main() async {
  await init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // ← 상태바 배경 흰색
      statusBarIconBrightness: Brightness.dark, // ← 아이콘은 어두운색
      statusBarBrightness: Brightness.light, // ← iOS 대응용
    ),
  );

  runApp(const MyApp());
}

Future<void> setupNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'fcm_default_channel', // id
    'High Importance Notifications', // name (사용자에게 보이는 채널 이름)
    description: 'This channel is used for important notifications.', // description (사용자에게 보이는 채널 설명)
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _checkLoginStatusAndSaveFcmToken();
  await setupNotificationChannel();
}

Future<void> _checkLoginStatusAndSaveFcmToken() async {
  // StorageService에서 액세스 토큰(JWT)을 가져옵니다.
  final accessToken = await StorageService.getAccessToken();

  if (accessToken != null) { // JWT 토큰이 존재한다면 (즉, 로그인 상태라면)
    print('로그인 상태 확인: FCM 토큰을 서버에 저장합니다.');
    await saveFcmTokenToServer(); // FCM 토큰을 서버에 저장
  } else {
    print('로그아웃 상태 확인: FCM 토큰을 저장하지 않습니다.');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final firebaseMessaging;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();


  String notificationTitle = "No Title";
  String notificationBody = "No body";
  String notificationData = "No data";

  @override
  void initState() {
    super.initState();

    _initializeLocalNotifications();

    firebaseMessaging = FCM(flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);

    firebaseMessaging.setNotifications();
    firebaseMessaging.bodyCtrl.stream.listen(_changedBody);
    firebaseMessaging.titleCtrl.stream.listen(_changedTitle);
    firebaseMessaging.streamCtrl.stream.listen(_changedData);
  }

  void _initializeLocalNotifications() {
    // 1. 안드로이드 초기화 설정
    // 'ic_notification'은 방금 drawable 폴더에 추가한 아이콘 파일의 이름입니다. (.png 확장자 제외)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    // 2. iOS 초기화 설정 (필요한 경우 권한 설정 추가)
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 3. 초기화 설정 합치기
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // 4. 플러그인 초기화
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  _changedData(String msg) => setState(() => notificationData = msg);
  _changedTitle(String msg) => setState(() => notificationTitle = msg);
  _changedBody(String msg) => setState(() => notificationBody = msg);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        quill.FlutterQuillLocalizations.delegate, // ✅ 추가
      ],
      supportedLocales: const [
        Locale('en'), // 영어
        Locale('ko'), // 한국어
      ],
      title: 'KHU:FARM',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'default'
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup/usertype': (context) => const UserTypeScreen(),
        '/signup/consumer': (context) => const ConsumerSignupScreen(),
        '/signup/retailer': (context) => const RetailerSignupScreen(),
        '/signup/farmer': (context) => const FarmerSignupScreen(),
        '/signup/consumer/success':
            (context) => const ConsumerSignupSuccessScreen(),
        '/signup/retailer/success':
            (context) => const RetailerSignupSuccessScreen(),
        '/signup/farmer/success':
            (context) => const FarmerSignupSuccessScreen(),
        '/account/find': (context) => const AccountFind(),
        '/account/find/idfound': (context) => const IdFoundScreen(),
        '/account/find/temppw': (context) => const TempPasswordSentScreen(),
        '/account/find/notfound': (context) => const AccountNotFound(),
        '/order/direct': (context) => const DirectOrderScreen(),
        '/order/cart': (context) => const CartOrderScreen(),
        '/order/success': (context) => const OrderSuccessScreen(),
        '/order/fail': (context) => const OrderFailScreen(),
        '/order/address': (context) => const OrderAddressListScreen(),
        '/order/address/add': (context) => const OrderAddAddressScreen(),
        '/order/edit/address': (context) => const OrderEditAddressScreen(),
        '/order/edit/address/success': (context) => const OrderEditAddressSuccessScreen(),
        '/postcode/search': (context) => const AddressSearchScreen(),
        '/consumer/main': (context) => const ConsumerMainScreen(),
        '/consumer/notification/list':
            (context) => const ConsumerNotificationListScreen(),
        '/consumer/dib/list': (context) => const ConsumerDibsScreen(),
        '/consumer/cart/list': (context) => const ConsumerCartScreen(),
        '/consumer/daily': (context) => const ConsumerDailyScreen(),
        '/consumer/daily/fruit': (context) => const ConsumerDailyFruitScreen(),
        '/consumer/harvest': (context) => const ConsumerHarvestScreen(),
        '/consumer/laicos': (context) => const ConsumerLaicosScreen(),
        '/consumer/mypage': (context) => const ConsumerMypageScreen(),
        '/consumer/mypage/info': (context) => const ConsumerInfoListScreen(),
        '/consumer/mypage/info/edit/profile':
            (context) => const ConsumerEditProfileScreen(),
        '/consumer/mypage/info/edit/pw':
            (context) => const ConsumerEditPwScreen(),
        '/consumer/mypage/info/edit/pw/success':
            (context) => const ConsumerEditPasswordSuccessScreen(),
        '/consumer/mypage/info/edit/address':
            (context) => const ConsumerAddressListScreen(),
        '/consumer/mypage/info/edit/address/add':
            (context) => const ConsumerAddAddressScreen(),
        '/consumer/mypage/info/edit/address/edit': (context) => const ConsumerEditAddressScreen(),
        '/consumer/mypage/info/edit/address/success':
            (context) => const ConsumerEditAddressSuccessScreen(),
        '/consumer/mypage/info/cancel':
            (context) => const ConsumerAccountCancellationScreen(),
        '/consumer/mypage/info/cancel/success':
            (context) => const ConsumerAccountCancelledScreen(),
        '/consumer/mypage/order': (context) => const ConsumerOrderListScreen(),
        '/consumer/mypage/order/review/add': (context) => const ConsumerAddReviewScreen(),
        '/consumer/mypage/review': (context) => const ConsumerReviewListScreen(),
        '/consumer/mypage/inquiry/personal':
            (context) => const ConsumerPersonalInquiryListScreen(),
        '/consumer/mypage/inquiry/personal/add':
            (context) => const ConsumerAddInquiryScreen(),
        '/consumer/mypage/inquiry/faq':
            (context) => const ConsumerFAQListScreen(),
        '/retailer/main': (context) => const RetailerMainScreen(),
        '/retailer/dib/list': (context) => const RetailerDibsScreen(),
        '/retailer/cart/list': (context) => const RetailerCartScreen(),
        '/retailer/daily': (context) => const RetailerDailyScreen(),
        '/retailer/daily/fruit': (context) => const RetailerDailyFruitScreen(),
        '/retailer/stock': (context) => const RetailerStockScreen(),
        '/retailer/stock/fruit': (context) => const RetailerStockFruitScreen(),
        '/retailer/harvest': (context) => const RetailerHarvestScreen(),
        '/retailer/laicos': (context) => const RetailerLaicosScreen(),
        '/retailer/mypage': (context) => const RetailerMypageScreen(),
        '/retailer/mypage/info': (context) => const ConsumerInfoListScreen(),
        '/retailer/mypage/info/edit/pw':
            (context) => const RetailerEditPwScreen(),
        '/retailer/mypage/info/edit/pw/success':
            (context) => const RetailerEditPasswordSuccessScreen(),
        '/retailer/mypage/info/edit/address':
            (context) => const RetailerAddressListScreen(),
        '/retailer/mypage/info/edit/address/add':
            (context) => const RetailerAddAddressScreen(),
        '/retailer/mypage/info/edit/address/edit':
            (context) => const RetailerEditAddressScreen(),
        '/retailer/mypage/info/edit/address/success':
            (context) => const RetailerEditAddressSuccessScreen(),
        '/retailer/mypage/info/cancel':
            (context) => const RetailerAccountCancellationScreen(),
        '/retailer/mypage/info/cancel/success':
            (context) => const RetailerAccountCancelledScreen(),
        '/retailer/mypage/order': (context) => const RetailerOrderListScreen(),
        '/retailer/mypage/order/refund': (context) => const RetailerRefundScreen(),
        '/retailer/mypage/order/refund/success':
            (context) => const RetailerRefundSuccessScreen(),
        '/retailer/mypage/inquiry/personal':
            (context) => const RetailerPersonalInquiryListScreen(),
        '/retailer/mypage/inquiry/personal/add':
            (context) => const RetailerAddInquiryScreen(),
        '/farmer/mypage/inquiry/faq':
            (context) => const FarmerFAQListScreen(),
        '/retailer/mypage/order/review/add':
            (context) => const RetailerAddReviewScreen(),
        '/retailer/mypage/review': (context) => const RetailerReviewListScreen(),
        '/farmer/main': (context) => const FarmerMainScreen(),
        '/farmer/notification/list':
            (context) => const FarmerNotificationListScreen(),
        '/farmer/dib/list': (context) => const FarmerDibsScreen(),
        '/farmer/cart/list': (context) => const FarmerCartScreen(),
        '/farmer/daily': (context) => const FarmerDailyScreen(),
        '/farmer/daily/fruit': (context) => const FarmerDailyFruitScreen(),
        '/farmer/stock': (context) => const FarmerStockScreen(),
        '/farmer/stock/fruit': (context) => const FarmerStockFruitScreen(),
        '/farmer/harvest': (context) => const FarmerHarvestScreen(),
        '/farmer/laicos': (context) => const FarmerLaicosScreen(),
        '/farmer/mypage': (context) => const FarmerMypageScreen(),
        '/farmer/mypage/info': (context) => const FarmerInfoListScreen(),
        '/farmer/mypage/info/edit/profile': (context) => const FarmerEditProfileScreen(),
        '/farmer/mypage/info/edit/pw': (context) => const FarmerEditPwScreen(),
        '/farmer/mypage/info/edit/pw/success': (context) => const FarmerEditPasswordSuccessScreen(),
        '/farmer/mypage/info/edit/address': (context) => const FarmerAddressListScreen(),
        '/farmer/mypage/info/edit/address/edit': (context) => const FarmerEditAddressScreen(),
        '/farmer/mypage/info/edit/address/success': (context) => const FarmerEditAddressSuccessScreen(),
        '/farmer/mypage/info/edit/address/add': (context) => const FarmerAddAddressScreen(),
        '/farmer/mypage/info/cancel':
            (context) => const FarmerAccountCancellationScreen(),
        '/farmer/mypage/info/cancel/success':
            (context) => const FarmerAccountCancelledScreen(),
        '/farmer/mypage/manage': (context) => const FarmerManageListScreen(),
        '/farmer/mypage/manage/product': (context) => const FarmerManageProductListScreen(),
        '/farmer/mypage/manage/product/add': (context) => FarmerAddProductScreen(),
        '/farmer/mypage/manage/product/add/detail': (context) => FarmerAddProductDetailScreen(),
        '/farmer/mypage/manage/product/add/preview': (context) => FarmerAddProductPreviewScreen(),
        '/farmer/mypage/manage/product/add/success': (context) => const FarmerAddProductSuccessScreen(),
        '/farmer/mypage/manage/product/edit': (context) => FarmerEditProductScreen(),
        '/farmer/mypage/manage/product/edit/detail': (context) => const FarmerEditProductDetailScreen(),
        '/farmer/mypage/manage/product/edit/preview': (context) => const FarmerEditProductPreviewScreen(),
        '/farmer/mypage/manage/product/delete': (context) => const FarmerDeleteProductScreen(),
        '/farmer/mypage/manage/product/delete/success': (context) => const FarmerDeleteProductSuccessScreen(),
        '/farmer/mypage/manage/review': (context) => const FarmerManageReviewScreen(),
        '/farmer/mypage/manage/review/product': (context) => const FarmerManageProductReviewScreen(),
        '/farmer/mypage/manage/review/detail': (context) => const FarmerManageReviewDetailScreen(),
        '/farmer/mypage/manage/review/reply/success': (context) => const FarmerAddReviewReplySuccessScreen(),
        '/farmer/mypage/manage/inquiry': (context) => FarmerManageInquiryScreen(),
        '/farmer/mypage/manage/inquiry/product': (context) => const FarmerManageProductInquiryScreen(),
        '/farmer/mypage/manage/inquiry/detail': (context) => const FarmerManageInquiryDetailScreen(),
        '/farmer/mypage/manage/inquiry/reply/success': (context) => const FarmerAddInquiryReplySuccessScreen(),
        '/farmer/mypage/manage/order': (context) => const FarmerManageOrderListScreen(),
        '/farmer/mypage/manage/order/detail': (context) => const FarmerManageOrderDetailScreen(),
        '/farmer/mypage/manage/order/delnum': (context) => const FarmerManageOrderDeliveryNumberScreen(),
        '/farmer/mypage/manage/order/delstat': (context) => const FarmerManageOrderDeliveryStatusScreen(),
        '/farmer/mypage/manage/order/refund': (context) => const FarmerManageOrderRefundScreen(),
        '/farmer/mypage/manage/order/refund/accept': (context) => const FarmerAcceptRefundSuccessScreen(),
        '/farmer/mypage/manage/order/refund/reject': (context) => const FarmerRejectRefundSuccessScreen(),
        '/farmer/mypage/order': (context) => FarmerOrderListScreen(),
        '/farmer/mypage/order/review/add':
            (context) => const FarmerAddReviewScreen(),
        '/farmer/mypage/review': (context) => const FarmerReviewListScreen(),
        '/farmer/mypage/inquiry/personal':
            (context) => const FarmerPersonalInquiryListScreen(),
        '/farmer/mypage/inquiry/personal/add':
            (context) => const FarmerAddInquiryScreen(),
        '/farmer/mypage/inquiry/faq':
            (context) => const FarmerFAQListScreen(),
      },
    );
  }
}
