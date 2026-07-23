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
import 'core/helper/language_provider/localization/language/english.dart';
import 'core/helper/notification_service/firebase_notification_service.dart';
import 'firebase_options.dart';

Future updateLocal() async {
  final index = AppPreference.getInt(AppPreference.languageIndex);
  return Utils.updateLanguage(index);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  if (BuildConfig.firebaseEnabled) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FireBaseNotification().firebaseCloudMessagingLSetup();
    await FireBaseNotification().setUpLocalNotification();
  }
  await AppPreference.initMySharedPreferences();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  final local = await updateLocal();
  await Utils().setCurrentMarker();
  await Utils().setCarMarker();
  runApp(MyApp(initialLocale: local));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: initialLocale,
          // locale: Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          supportedLocales: const [
            Locale('en', 'US'), // English
            Locale('hi', 'IN'), // Hindi
            Locale('ar', 'AE'), // Arabic
            Locale('pt', 'PT'), // Portuguese
            Locale('he', 'IL'), // Hebrew
            Locale('ru', 'RU'), // Russian
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // initialBinding: AppBidding(),
          theme: ThemeData(
            fontFamily: Constants.fontFamily,
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
