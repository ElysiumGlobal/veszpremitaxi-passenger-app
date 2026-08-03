import 'dart:convert';

import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import '../../../core/helper/network_service/network_info.dart';
import '../../../utils/api_constants.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';

class SplaceScreen extends StatefulWidget {
  const SplaceScreen({super.key});

  @override
  State<SplaceScreen> createState() => _SplaceScreenState();
}

class _SplaceScreenState extends State<SplaceScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      NetworkInfo.setListener();
      navigation();
    });
  }

  Future<void> getSetting() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.setting),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Constants().iosLink = data['data']['appleShareLink'] ?? '';
        Constants().androidLink = data['data']['androidShareLink'] ?? '';
        Constants().appStoreId = data['data']['appstoreId'] ?? '';
        Constants().currency = data['data']['currency'] ?? '';
      }
    } catch (_) {
      // A beállítások hibája nem tarthatja a nyitóképernyőn az appot.
    }
  }

  Future<void> navigation() async {
    await Future.delayed(const Duration(milliseconds: 350));

    final userToken = AppPreference.getString(AppPreference.userToken);
    if (userToken.isEmpty) {
      await getSetting();

      // A sofőröket az admin hozza létre, nincs sofőr-regisztrációs kör.
      Navigation.replace(Routes.registerScreen);
      return;
    }

    Navigation.replace(Routes.homeScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001428),
      body: Center(
        child: Image.asset(
          'assets/vap_driver_logo.png',
          width: 190.w,
          height: 190.w,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
