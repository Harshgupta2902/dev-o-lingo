import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart'; // add in pubspec
import 'package:lingolearn/auth_module/view/login_view.dart';
import 'package:lingolearn/utilities/firebase/core_prefs.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';

class CoreNotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Stable channel for Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'pushnotification', // id (must match below)
    'App Notifications',
    description: 'General notifications for Dev-O-Lingo',
    importance: Importance.high,
  );

  Future<void> clearFCMToken() async {
    await _firebaseMessaging.deleteToken();
  }

  Future<void> init() async {
    // Request permissions
    await _firebaseMessaging.requestPermission();

    // Token management
    await getToken();
    await _firebaseMessaging.subscribeToTopic('notification');

    // Android init (use your small icon name in mipmap/drawable)
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_notification');

    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Create channel on Android once
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Initialize click handler
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        try {
          final payload = details.payload;
          if (payload == null || payload.isEmpty) return;
          final Map map = json.decode(payload);
          onNotificationClicked(payload: map);
        } catch (e) {
          log("onDidReceiveNotificationResponse error $e");
        }
      },
    );
  }

  // Optional: logs; not strictly needed once main.dart listeners are set
  void fcmListener({Function()? onTap}) {
    log("FCM TOKEN => ${getFCMToken()}");
  }

  void onNotificationClicked({required Map payload}) {
    try {
      if (payload.containsKey('path') && payload.containsKey('arguments')) {
        final arguments = json.decode(payload['arguments']);
        if (arguments != null) {
          MyNavigator.pushNamed(payload['path'], extra: arguments);
          return;
        }
      }
      if (payload.containsKey('path')) {
        MyNavigator.pushNamed(payload['path']);
      }
    } catch (e) {
      log("onNotificationClicked parse error: $e");
    }
  }

  /// Create a local notification (works foreground + background)
  static Future<void> createNotification(
    RemoteMessage message, {
    bool fromBackground = false,
  }) async {
    try {
      final title = message.notification?.title ??
          (message.data['title'] ?? 'Notification');
      final body = message.notification?.body ?? (message.data['body'] ?? '');
      final dataPayload = message.data;
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Try to get an image URL from either the notification or data keys
      final imageUrl = _extractImageUrl(message);

      // Build Android style with optional big picture
      AndroidNotificationDetails androidDetails;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final bigPicPath = await _downloadToFile(imageUrl, 'big_${id}.jpg');
        final largeIconPath = bigPicPath; // reuse

        final style = BigPictureStyleInformation(
          FilePathAndroidBitmap(bigPicPath),
          largeIcon: FilePathAndroidBitmap(largeIconPath),
          contentTitle: title,
          summaryText: body,
          hideExpandedLargeIcon: false,
        );

        androidDetails = AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: style,
          // Use a neutral color; Android ignores if not supported
          color: Colors.white,
          icon: '@mipmap/ic_notification',
        );
      } else {
        androidDetails = const AndroidNotificationDetails(
          'pushnotification',
          'App Notifications',
          channelDescription: 'General notifications for Dev-O-Lingo',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_notification',
        );
      }

      const iosDetails = DarwinNotificationDetails(
        // For rich images on iOS via local notifications you typically need attachments;
        // since we're primarily handling rich images via APNs (see payload spec below),
        // we keep this simple here.
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: json.encode(dataPayload),
      );
    } catch (e) {
      log("Notification Create Error $e");
    }
  }

  Future<void> getToken() async {
    await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();
    if (token == null) return;

    setFCMToken(token);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      authController.updateFCMToken(getEmailId(), getUuid(), newToken);
      setFCMToken(newToken);
      log("🔄 Token rotated automatically: $newToken");
    });
  }

  /// ---- helpers ----
  static String? _extractImageUrl(RemoteMessage m) {
    // FCM supports 'image' inside notification for Android; many backends also send 'image'/'imageUrl' inside data.
    final nImage =
        m.notification?.android?.imageUrl ?? m.notification?.apple?.imageUrl;
    final dImage = m.data['image'] ??
        m.data['imageUrl'] ??
        m.data['picture'] ??
        m.data['big_picture'];
    return (nImage?.toString().isNotEmpty == true)
        ? nImage.toString()
        : (dImage?.toString().isNotEmpty == true)
            ? dImage.toString()
            : null;
  }

  static Future<String> _downloadToFile(String url, String filename) async {
    final dir = await getTemporaryDirectory();
    final savePath = '${dir.path}/$filename';
    final dio = Dio();
    await dio.download(url, savePath,
        options: Options(responseType: ResponseType.bytes));
    return savePath;
  }
}
