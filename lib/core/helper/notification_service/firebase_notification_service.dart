import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../../../firebase_options.dart';
import '../../../utils/build_config.dart';
import '../../../utils/log_utils.dart';
import '../../../utils/navigation_utils/routes.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class FireBaseNotification {
  static final FireBaseNotification _fireBaseNotification =
      FireBaseNotification._();

  factory FireBaseNotification() {
    return _fireBaseNotification;
  }

  FireBaseNotification._();

  FirebaseMessaging? _firebaseMessaging;

  FirebaseMessaging get firebaseMessaging =>
      _firebaseMessaging ??= FirebaseMessaging.instance;
  late AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: "This channel is used for important notifications.",
    importance: Importance.high,
  );
  static BehaviorSubject<Map<String, dynamic>> selectNotificationSubject =
      BehaviorSubject<Map<String, dynamic>>();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String fcmToken = "";

  void removeListner() {
    selectNotificationSubject = BehaviorSubject<Map<String, dynamic>>();
  }

  Future<void> firebaseCloudMessagingLSetup() async {
    if (!BuildConfig.firebaseEnabled) return;

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    try {
      await firebaseMessaging.getToken().then((token) async {
        if (token != null) {
          fcmToken = token;
        }
        log('FCM TOKEN to be Registered: $token');
        LogUtils.printAction('FCM TOKEN to be Registered: $token');
      });
    } catch (e) {
      LogUtils.printAction("ERROR ON TOKEN NOTIFICATION FILE $e");
    }
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    var initialMessage = await firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      log(">>>>>IT S init>>>>>>>>>>>>notification> ");
      selectNotification(jsonEncode(initialMessage.data));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.data.containsKey("chat_id") &&
              Get.currentRoute.startsWith(Routes.chatScreen) ||
          message.data.containsKey("chat_id") &&
              Get.currentRoute.startsWith(Routes.chatSupportScreen)) {
      } else {
        _showLocalNotification(message);
      }
      log(
        "onMessage notification---->> onMessage data::${message.data}  notification::${message.notification?.title}",
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log(">>>>>IT S background >>>>>>>>>>>>notification> ");

      selectNotification(jsonEncode(message.data));
    });
  }

  Future<void> setUpLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        LogUtils.printAction("Notification tap");

        var data = jsonDecode(payload.payload ?? "");
        if (data != null) {
          selectNotificationSubject.add(data);
        }
      },
    );
    LogUtils.printAction("flutterLocalNotificationsPlugin Complete");
  }

  Future selectNotification(String? payload) async {
    LogUtils.printAction("NOTIFICATION TAP????????>>>>>>>>>>>>");
    if (payload != null && payload.isNotEmpty) {
      LogUtils.printAction('selectNotificationSubject: $payload');
      Map<String, dynamic> data = jsonDecode(payload);
      selectNotificationSubject.add(data);
    }
  }

  Future<void> notificationPermission() async {
    if (!BuildConfig.firebaseEnabled ||
        !BuildConfig.pushNotificationsEnabled) {
      return;
    }

    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
    await iOSPermission(firebaseMessaging);
  }

  Future<void> iOSPermission(firebaseMessaging) async {
    await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          icon: "notification",
        );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    if ((notification?.title ?? "").isNotEmpty) {
      await flutterLocalNotificationsPlugin.show(
        0,
        notification?.title ?? "",
        notification?.body ?? "",
        platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    }
  }
}
