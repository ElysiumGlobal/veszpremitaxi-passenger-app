import 'dart:convert';
import 'dart:io';

import 'package:e_taxi/core/debug/driver_flow_debug.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

import '../../firebase_options.dart';
import '../../utils/navigation_utils/routes.dart';

const AndroidNotificationChannel _incomingRideChannel =
    AndroidNotificationChannel(
  'incoming_ride_channel_v2',
  'Beérkező fuvarok',
  description: 'Azonnali értesítés új Veszprémi Taxi fuvarajánlat esetén.',
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('fuvar_erkezett'),
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Adatüzenetnél az Android nem rajzol automatikusan értesítést. A sofőr
  // ezért háttérben és lezárt képernyőn is saját, magas prioritású jelzést kap.
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();
  const InitializationSettings settings = InitializationSettings(
    android: AndroidInitializationSettings('notification'),
    iOS: DarwinInitializationSettings(),
  );
  await notifications.initialize(settings);
  await notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_incomingRideChannel);

  final Map<String, dynamic> data = message.data;
  final String eventType =
      (data['event_type'] ?? data['event'] ?? data['type'] ?? '').toString();
  final String bookingId = (data['booking_id'] ?? '').toString();
  final bool isRide = eventType == 'new_ride_request' ||
      eventType == 'incoming_ride' ||
      bookingId.isNotEmpty;
  if (!isRide) return;

  final NotificationDetails details = NotificationDetails(
    android: AndroidNotificationDetails(
      _incomingRideChannel.id,
      _incomingRideChannel.name,
      channelDescription: _incomingRideChannel.description,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('fuvar_erkezett'),
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      visibility: NotificationVisibility.public,
      icon: 'notification',
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  await notifications.show(
    7000 + (bookingId.hashCode.abs() % 1000),
    message.notification?.title ?? 'Új fuvar érkezett',
    message.notification?.body ??
        'Nyisd meg a Veszprémi Taxi Sofőr alkalmazást.',
    details,
    payload: jsonEncode(data),
  );
}

class FireBaseNotification {
  static final FireBaseNotification _instance = FireBaseNotification._();

  factory FireBaseNotification() => _instance;

  FireBaseNotification._();

  FirebaseMessaging? _firebaseMessaging;
  AndroidNotificationChannel channel = _incomingRideChannel;

  static BehaviorSubject<Map<String, dynamic>> selectNotificationSubject =
      BehaviorSubject<Map<String, dynamic>>();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String FcmToken = '';
  bool _messagingConfigured = false;
  bool _localNotificationsConfigured = false;

  FirebaseMessaging get firebaseMessaging =>
      _firebaseMessaging ??= FirebaseMessaging.instance;

  void removeListner() {
    selectNotificationSubject = BehaviorSubject<Map<String, dynamic>>();
  }

  Future<String> getTokenSafely({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final String? token = await firebaseMessaging.getToken().timeout(timeout);
      FcmToken = token?.trim() ?? '';
      DriverFlowDebug.send(
        'driver_fcm_token_resolved',
        data: <String, dynamic>{
          'token_present': FcmToken.isNotEmpty,
          'token_length': FcmToken.length,
        },
      );
      return FcmToken;
    } catch (error, stack) {
      DriverFlowDebug.send(
        'driver_fcm_token_error',
        data: <String, dynamic>{
          'error': error.toString(),
          'stack': stack.toString(),
        },
      );
      return FcmToken;
    }
  }

  Future<void> firebaseCloudMessagingLSetup() async {
    if (_messagingConfigured) return;
    _messagingConfigured = true;

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await getTokenSafely();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    firebaseMessaging.onTokenRefresh.listen((String token) {
      FcmToken = token.trim();
      DriverFlowDebug.send(
        'driver_fcm_token_refreshed',
        data: <String, dynamic>{
          'token_present': FcmToken.isNotEmpty,
          'token_length': FcmToken.length,
        },
      );
    });

    final RemoteMessage? initialMessage =
        await firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      await selectNotification(jsonEncode(initialMessage.data));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.data.containsKey('chat_id') &&
          Get.currentRoute.startsWith(Routes.chatScreen)) {
        return;
      }
      await _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      selectNotification(jsonEncode(message.data), isTerminate: true);
    });
  }

  Future<void> setUpLocalNotification() async {
    if (_localNotificationsConfigured) return;
    _localNotificationsConfigured = true;

    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('notification'),
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String payload = response.payload ?? '';
        if (payload.isNotEmpty) {
          selectNotification(payload);
        }
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> selectNotification(
    String? payload, {
    bool isTerminate = false,
  }) async {
    if (payload == null || payload.trim().isEmpty) return;
    final dynamic decoded = jsonDecode(payload);
    if (decoded is Map) {
      selectNotificationSubject.add(Map<String, dynamic>.from(decoded));
    }
  }

  Future<void> removeListen() async {
    selectNotificationSubject = BehaviorSubject<Map<String, dynamic>>();
  }

  Future<void> notificationPermission() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
  }

  Future<void> showIncomingRideAlert({required String bookingId}) async {
    try {
      await setUpLocalNotification();
      final NotificationDetails details = NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('fuvar_erkezett'),
          enableVibration: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.call,
          visibility: NotificationVisibility.public,
          ticker: 'Új fuvar érkezett',
          icon: 'notification',
        ),
      );
      await flutterLocalNotificationsPlugin.show(
        7000 + (bookingId.hashCode.abs() % 1000),
        'Új fuvar érkezett',
        'Nyisd meg a fuvarajánlatot és fogadd el időben.',
        details,
        payload: jsonEncode(<String, dynamic>{
          'type': 'incoming_ride',
          'event_type': 'new_ride_request',
          'booking_id': bookingId,
        }),
      );
    } catch (error, stack) {
      DriverFlowDebug.runtimeError('incoming_ride_alert', error, stack);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    await setUpLocalNotification();
    final String title = message.notification?.title ??
        (message.data['title'] ?? 'Veszprémi Taxi').toString();
    final String body = message.notification?.body ??
        (message.data['body'] ?? 'Új értesítés érkezett.').toString();
    final String bookingId = (message.data['booking_id'] ?? '').toString();

    final NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('fuvar_erkezett'),
        enableVibration: true,
        fullScreenIntent: bookingId.isNotEmpty,
        category: bookingId.isNotEmpty
            ? AndroidNotificationCategory.call
            : AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
        icon: 'notification',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      bookingId.isEmpty ? 0 : 7000 + (bookingId.hashCode.abs() % 1000),
      title,
      body,
      details,
      payload: jsonEncode(message.data),
    );
  }
}
