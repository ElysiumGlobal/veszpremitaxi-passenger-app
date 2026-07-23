import 'dart:convert';

import 'package:e_taxi/utils/api_constants.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import '../../../core/helper/network_service/network_info.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';

class SplaceScreen extends StatefulWidget {
  const SplaceScreen({super.key});

  @override
  State<SplaceScreen> createState() => _SplaceScreenState();
}

class _SplaceScreenState extends State<SplaceScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NetworkInfo.setListener();

    Future.delayed(Duration(seconds: 1), () {
      return redirect();
    });
  }

  Future<void> getSetting() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.setting),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        AppConstant().iosLink = data['data']['appleShareLink'] ?? "";
        AppConstant().androidLink = data['data']['androidShareLink'] ?? "";
        AppConstant().appStoreId = data['data']['appstoreId'] ?? "";
        AppConstant().currency = data['data']['currency'] ?? "";
      }
    } catch (e) {}
  }

  void updateLocal() {
    final index = AppPreference.getInt(AppPreference.languageIndex);
    Utils.updateLanguage(index);
  }

  Future<void> redirect() async {
    final onboarding = AppPreference.getBoolean(AppPreference.onboardingDone);

    if (onboarding == false) {
      getSetting();
      Navigation.replace(Routes.onboarding);
    } else {
      final useToken = AppPreference.getString(AppPreference.userToken);

      if (useToken.isEmpty) {
        getSetting();

        Navigation.replaceAll(Routes.loginScreen);
      } else {
        final userLogin = AppPreference.getBoolean(AppPreference.userLogin);

        if (userLogin == false) {
          getSetting();

          Navigation.replaceAll(Routes.loginScreen);
        } else {
          Navigation.replaceAll(Routes.dashboardScreen);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainPrimaryColor,
      body: Center(
        child: CustomImage(
          image: ImagesAsset.logoSplace,
          wt: 180.w,
          ht: 280.h,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
