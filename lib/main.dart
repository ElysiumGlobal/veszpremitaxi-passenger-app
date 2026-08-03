import 'dart:async';
import 'dart:ui';

import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/navigation_utils/routes.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/debug/driver_flow_debug.dart';
import 'core/localization/localization.dart';
import 'core/service/firebase_notification_new.dart';
import 'firebase_options.dart';

Future<Locale> updateLocal() async {
  return const Locale('hu', 'HU');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    DriverFlowDebug.runtimeError('flutter', details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    DriverFlowDebug.runtimeError('platform', error, stack);
    debugPrint('Unhandled platform error: $error');
    debugPrintStack(stackTrace: stack);
    return true;
  };
  WidgetsBinding.instance.addObserver(DriverDebugLifecycleObserver());
  Locale initialLocale = const Locale('hu', 'HU');

  try {
    await AppPreference.initMySharedPreferences();
    await DriverFlowDebug.initialize();
    initialLocale = await updateLocal();
    DriverFlowDebug.send(
      'app_started',
      data: <String, dynamic>{
        'expected_collector_version': DriverFlowDebug.expectedCollectorVersion,
        'orientation': 'adaptive',
        'auth_mode': 'fixed_driver_pin',
        'durable_debug_queue': true,
      },
    );
  } catch (error, stack) {
    debugPrint('SharedPreferences initialization failed: $error');
    debugPrintStack(stackTrace: stack);
  }

  // A gyari forrasbol hianyzott ez a fajl. Emiatt a debug APK meg a
  // runApp() elott kilepett. Most a fajl is benne van, es a betoltes sem
  // tudja tobbe leallitani az alkalmazast.
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (error, stack) {
    debugPrint('Environment file load failed: $error');
    debugPrintStack(stackTrace: stack);
  }

  // A Firebase Core meg a FirebaseAuth hasznalata elott inicializalva van,
  // de egy regi telefonon vagy hibas Google Play Services mellett sem
  // tarthatja vegtelenul a nyitokepernyot.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));
  } catch (error, stack) {
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stack);
  }

  // Telefonon és tableten is engedjük a rendszer által választott tájolást.
  // A felület reszponzív; nincs kényszerített fekvő mód.
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(MyApp(initialLocale: initialLocale));

  // Ezek nem feltetelei annak, hogy az alkalmazas elinduljon. Korabban
  // barmelyik hibaja bezarta az appot meg az elso kepernyo elott.
  unawaited(_initializeOptionalServices());
}

Future<void> _initializeOptionalServices() async {
  try {
    await FireBaseNotification()
        .firebaseCloudMessagingLSetup()
        .timeout(const Duration(seconds: 10));
  } catch (error, stack) {
    debugPrint('Firebase messaging setup failed: $error');
    debugPrintStack(stackTrace: stack);
  }

  try {
    await FireBaseNotification()
        .setUpLocalNotification()
        .timeout(const Duration(seconds: 10));
  } catch (error, stack) {
    debugPrint('Local notification setup failed: $error');
    debugPrintStack(stackTrace: stack);
  }

  try {
    await Utils().setCurrentMarker();
  } catch (error, stack) {
    debugPrint('Current-location marker setup failed: $error');
    debugPrintStack(stackTrace: stack);
  }

  try {
    await Utils().setCarMarker();
  } catch (error, stack) {
    debugPrint('Car marker setup failed: $error');
    debugPrintStack(stackTrace: stack);
  }
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  const MyApp({required this.initialLocale, super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1280, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorObservers: <NavigatorObserver>[
            DriverDebugNavigatorObserver(),
          ],
          translations: Languages(),
          locale: initialLocale,
          fallbackLocale: const Locale('hu', 'HU'),
          supportedLocales: const [
            Locale('hu', 'HU'),
            Locale('en', 'US'),
            Locale('hi', 'IN'),
            Locale('ar', 'AE'),
            Locale('pt', 'PT'),
            Locale('he', 'IL'),
            Locale('ru', 'RU'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialBinding: AppBidding(),
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.whiteGrey,
            textSelectionTheme: TextSelectionThemeData(
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
                  child: child ?? const SizedBox.shrink(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class AppBidding extends Bindings {
  @override
  void dependencies() {
    Get.put<AccountController>(AccountController(), permanent: true);
    Get.put<HomeController>(HomeController(), permanent: true);
  }
}
