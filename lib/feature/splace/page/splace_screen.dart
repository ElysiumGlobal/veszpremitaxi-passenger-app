import 'dart:async';
import 'dart:convert';

import 'package:e_taxi/core/auth/firebase_session.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../../core/helper/network_service/network_info.dart';
import '../../../utils/constants.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';

class SplaceScreen extends StatefulWidget {
  const SplaceScreen({super.key});

  @override
  State<SplaceScreen> createState() => _SplaceScreenState();
}

class _SplaceScreenState extends State<SplaceScreen> {
  bool _showSecondImage = false;
  Timer? _imageTimer;
  bool _imagesPrecached = false;

  @override
  void initState() {
    super.initState();
    NetworkInfo.setListener();
    _imageTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        setState(() => _showSecondImage = true);
      }
    });
    _start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_imagesPrecached) return;
    _imagesPrecached = true;
    precacheImage(const AssetImage(ImagesAsset.firstLoadingScreen), context);
    precacheImage(const AssetImage(ImagesAsset.loadingScreen), context);
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    await Future.wait<void>([
      Future<void>.delayed(const Duration(milliseconds: 5000)),
      getSetting().timeout(
        const Duration(seconds: 3),
        onTimeout: () {},
      ),
    ]);

    if (!mounted) return;
    await redirect();
  }

  Future<void> getSetting() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.setting),
      );
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      AppConstant().iosLink = data['data']['appleShareLink'] ?? '';
      AppConstant().androidLink = data['data']['androidShareLink'] ?? '';
      AppConstant().appStoreId = data['data']['appstoreId'] ?? '';
      AppConstant().currency = 'HUF';
    } catch (_) {
      // A betöltőképernyő hálózati hiba esetén sem tarthatja fel az appot.
    }
  }

  Future<void> redirect() async {
    final onboarding = AppPreference.getBoolean(AppPreference.onboardingDone);

    if (!onboarding) {
      Navigation.replace(Routes.onboarding);
      return;
    }

    final userToken = AppPreference.getString(AppPreference.userToken);
    final userLogin = AppPreference.getBoolean(AppPreference.userLogin);

    if (userToken.isEmpty ||
        !userLogin ||
        !FirebaseSession.hasSignedInUser) {
      await AppPreference.setString(AppPreference.userToken, '');
      await AppPreference.setBoolean(AppPreference.userLogin, value: false);
      Navigation.replaceAll(Routes.loginScreen);
      return;
    }

    final bool phoneRequired = AppPreference.getBoolean(
      AppPreference.profileCompletionPending,
    );
    if (phoneRequired) {
      Navigation.replaceAll(Routes.phoneRequiredScreen);
      return;
    }

    Navigation.replaceAll(Routes.dashboardScreen);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.brandNavy,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.brandNavy,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: SizedBox.expand(
            key: ValueKey<bool>(_showSecondImage),
            child: Image.asset(
              _showSecondImage
                  ? ImagesAsset.loadingScreen
                  : ImagesAsset.firstLoadingScreen,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    );
  }
}
