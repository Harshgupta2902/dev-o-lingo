import 'dart:async';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lingolearn/auth_module/view/onboarding_view.dart';
import 'package:lingolearn/utilities/constants/functions.dart';
import 'package:lingolearn/utilities/firebase/analytics_service.dart';
import 'package:lingolearn/utilities/firebase/core_prefs.dart';
import 'package:lingolearn/utilities/firebase/crashlytics_service.dart';
import 'package:lingolearn/utilities/firebase/notification_service.dart';
import 'package:lingolearn/utilities/navigation/route_generator.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';
import 'package:lingolearn/utilities/theme/smooth_rectangular_border.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  CoreNotificationService().onNotificationClicked(payload: message.data);
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await GetStorage.init();
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAu3tlWvw0CMf_of22qICoO-UAX6EWJtyA",
        appId: "1:350194043113:android:d506e597c8ad4ed15b4878",
        messagingSenderId: "350194043113",
        projectId: "lingolearn-d228a",
      ),
    );
  }

  setStaticPref();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterError.onError = (FlutterErrorDetails details) {
    if ((details.library == 'image resource service' ||
            details.library == 'Invalid image data') &&
        (details.exception.toString().contains('404') ||
            details.exception.toString().contains('403'))) {
      debugPrint('Suppressed cachedNetworkImage Exception');
      return;
    }
    FlutterError.presentError(details);
  };

  await CoreNotificationService().init();
  if (kReleaseMode) {
    CrashlyticsService().init();
  }
  FirebaseAnalytics.instance;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseAnalyticsService().init("");
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    try {
      final Map payload = message.data;
      CoreNotificationService().onNotificationClicked(payload: payload);
    } catch (e) {
      logger.e("onDidReceiveNotificationResponse error $e");
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    try {
      CoreNotificationService().onNotificationClicked(payload: message.data);
      (message.data);
    } catch (e) {
      logger.e("onMessage error $e");
    }
  });

  // final uid = getUuid();
  // authController.fetchUserData(uid);

  runApp(const MyApp());
  FlutterNativeSplash.remove();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
  final FirebaseAnalyticsObserver analyticsObserver = FirebaseAnalyticsObserver(
    analytics: FirebaseAnalytics.instance,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver;
    super.initState();
    CoreNotificationService().fcmListener();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final boldText = MediaQuery.boldTextOf(context);
        final newMediaQueryData = MediaQuery.of(context).copyWith(
          boldText: boldText,
          textScaler: const TextScaler.linear(1.0),
        );
        return MediaQuery(
          data: newMediaQueryData,
          child: child!,
        );
      },
      title: 'Dev-O-Lingo',
      routerConfig: goRouterConfig,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        primaryColor: AppColors.primaryColor,
        fontFamily: 'Nunito',
        switchTheme: const SwitchThemeData(
          splashRadius: 0,
        ),
        popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
        dividerColor: Colors.grey.shade400,
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.vertical(
              top: SmoothRadius(cornerRadius: 16, cornerSmoothing: 1.0),
            ),
          ),
          showDragHandle: true,
          dragHandleSize: Size(60, 4),
          clipBehavior: Clip.hardEdge,
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: Colors.green,
          thumbColor: AppColors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: InputBorder.none,
          border: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: true,
          fillColor: AppColors.whiteSmoke,
          hintStyle: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.paleSky),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 10,
                cornerSmoothing: 1.0,
              ),
            ),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 10,
              ),
            ),
            foregroundColor: Colors.white,
            textStyle: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(letterSpacing: 0.15),
            backgroundColor: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
