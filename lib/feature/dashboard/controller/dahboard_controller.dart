import 'dart:convert';
import 'dart:developer';

import 'package:e_taxi/utils/log_utils.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../utils/api_constants.dart';
import '../../../utils/constants.dart';

class DashBoardController extends GetxController {
  RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    getSetting();
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
    } catch (e, st) {
      LogUtils.printError("text:$e, $st");
    }
  }
}
