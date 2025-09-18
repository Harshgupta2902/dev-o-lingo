import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lingolearn/home_module/controller/language_controller.dart';
import 'package:lingolearn/home_module/controller/user_stats_controller.dart';
import 'package:lingolearn/utilities/firebase/analytics_service.dart';
import 'package:lingolearn/utilities/firebase/core_prefs.dart';
import 'package:lingolearn/utilities/firebase/crashlytics_service.dart';
import 'package:lingolearn/utilities/firebase/notification_service.dart';
import 'package:lingolearn/utilities/navigation/route_generator.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';
import 'package:lingolearn/utilities/theme/smooth_rectangular_border.dart';

final languageController = Get.put(LanguageController());
final userStatsController = Get.put(UserStatsController());

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage m) async {
  await Firebase.initializeApp();

  try {
    // LOGGING (optional)
    log("BG FCM DATA => ${m.data}");

    // 🟣 Countdown ko yahin handle karo
    if (m.data['type'] == 'countdown') {
      final targetMs = int.tryParse(m.data['targetEpochMs'] ?? '');
      if (targetMs != null) {
        final id = await CoreNotificationService.showCountdownNotification(
          targetTime: DateTime.fromMillisecondsSinceEpoch(targetMs),
          title: m.data['title'] ?? "Test Reminder",
          bodyPrefix: m.data['bodyPrefix'] ?? "Your test begins in",
        );

        // Auto-dismiss at start + "Test started"
        final target = DateTime.fromMillisecondsSinceEpoch(targetMs);
        final wait = target.difference(DateTime.now());
        if (!wait.isNegative) {
          Timer(wait, () async {
            await CoreNotificationService.cancel(id);
            await CoreNotificationService.createNotification(
              RemoteMessage.fromMap({
                "data": {
                  "title": "Test started",
                  "body": "All the best!",
                  "path": "/test/start",
                  "arguments": "{}"
                }
              }),
            );
          });
        }
      }
      return;
    }

    // 🔵 Normal notifications fallback
    await CoreNotificationService.createNotification(m, fromBackground: true);
  } catch (e) {
    log("BG handler error: $e");
  }
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  // await AdsHelper.initialize();
  // Get.put(IAPService(), permanent: true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAu3tlWvw0CMf_of22qICoO-UAX6EWJtyA",
        appId: "1:350194043113:android:d506e597c8ad4ed15b4878",
        messagingSenderId: "350194043113",
        projectId: "lingolearn-d228a",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

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

  FirebaseAnalytics.instance;
  FirebaseAnalyticsService().init(getEmailId());
  await CoreNotificationService().init();
  if (kReleaseMode) {
    CrashlyticsService().init();
  }

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    try {
      CoreNotificationService().onNotificationClicked(payload: message.data);
    } catch (e) {
      log("onMessageOpenedApp error $e");
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage m) async {
    if (m.data['type'] == 'countdown') {
      final targetMs = int.tryParse(m.data['targetEpochMs'] ?? '');
      if (targetMs != null) {
        final notifId = await CoreNotificationService.showCountdownNotification(
          targetTime: DateTime.fromMillisecondsSinceEpoch(targetMs),
          title: m.data['title'] ?? "Test Reminder",
          bodyPrefix: m.data['bodyPrefix'] ?? "Your test begins in",
        );

        final target = DateTime.fromMillisecondsSinceEpoch(targetMs);
        final wait = target.difference(DateTime.now());
        if (!wait.isNegative) return;

        Timer(wait, () async {
          await CoreNotificationService.cancel(notifId);
          await CoreNotificationService.createNotification(
            RemoteMessage.fromMap({
              "data": {
                "title": "Test started",
                "body": "All the best!",
                "path": "/test/start",
                "arguments": "{}"
              }
            }),
          );
        });
      }
      return;
    }

    // fallback for normal messages
    await CoreNotificationService.createNotification(m);
  });

  if (getJwtToken() != null && getJwtToken() != "") {
    await languageController.getLanguageData();
    userStatsController.getUserStats();
  }

  runApp(const MyApp());
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
        scaffoldBackgroundColor: kSurface,
        primaryColor: kPrimary,
        fontFamily: 'Nunito',
        switchTheme: const SwitchThemeData(
          splashRadius: 0,
        ),
        popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
        dividerColor: Colors.grey.shade400,
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
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
          thumbColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: InputBorder.none,
          border: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: true,
          fillColor: kMuted,
          hintStyle:
              Theme.of(context).textTheme.bodyMedium?.copyWith(color: kPrimary),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kPrimary,
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
            backgroundColor: kPrimary,
          ),
        ),
      ),
    );
  }
}
