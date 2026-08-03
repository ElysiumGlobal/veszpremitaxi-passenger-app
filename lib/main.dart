import 'dart:ui';

import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/build_config.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/navigation_utils/routes.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/debug/passenger_flow_debug.dart';
import 'core/helper/language_provider/localization/language/english.dart';
import 'core/helper/notification_service/firebase_notification_service.dart';
import 'firebase_options.dart';

Future<Locale> updateLocal() async {
  return const Locale('hu', 'HU');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  if (BuildConfig.firebaseEnabled) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (BuildConfig.pushNotificationsEnabled) {
        await FireBaseNotification().firebaseCloudMessagingLSetup();
        await FireBaseNotification().setUpLocalNotification();
      }
    } catch (error, stack) {
      debugPrint('Firebase initialization failed: $error\n$stack');
    }
  }

  await AppPreference.initMySharedPreferences();
  await PassengerFlowDebug.initialize();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    PassengerFlowDebug.runtimeError(
      'flutter',
      details.exception,
      details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    PassengerFlowDebug.runtimeError('platform', error, stack);
    return false;
  };
  WidgetsBinding.instance.addObserver(PassengerDebugLifecycleObserver());
  PassengerFlowDebug.send(
    'app_started',
    data: <String, dynamic>{
      'firebase_enabled': BuildConfig.firebaseEnabled,
      'push_enabled': BuildConfig.pushNotificationsEnabled,
      'expected_collector_version':
          PassengerFlowDebug.expectedCollectorVersion,
      'durable_debug_queue': true,
    },
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  final locale = await updateLocal();

  try {
    await Utils().setCurrentMarker();
    await Utils().setRouteMarkers();
    await Utils().setCarMarker();
  } catch (error, stack) {
    debugPrint('Map marker initialization failed: $error\n$stack');
  }

  runApp(MyApp(initialLocale: locale));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  const MyApp({
    super.key,
    required this.initialLocale,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorObservers: <NavigatorObserver>[
            PassengerDebugNavigatorObserver(),
          ],
          translations: AppTranslations(),
          locale: initialLocale,
          fallbackLocale: const Locale('hu', 'HU'),
          supportedLocales: const [
            Locale('hu', 'HU'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            fontFamily: Constants.fontFamily,
            textSelectionTheme: const TextSelectionThemeData(
              selectionHandleColor: AppColors.mainPrimaryColor,
              selectionColor: AppColors.transparent,
            ),
          ),
          initialRoute: Routes.splash,
          getPages: Routes.pages,
          builder: (context, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: () {
                    Utils.hideKeyboardInApp(context);
                  },
                  child: child,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
