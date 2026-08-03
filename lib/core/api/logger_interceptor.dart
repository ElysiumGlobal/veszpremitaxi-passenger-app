import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:http_interceptor/models/interceptor_contract.dart';

import '../../utils/app_preferences.dart';
import '../../utils/navigation_utils/navigation.dart';
import '../../utils/navigation_utils/routes.dart';

class LoggerInterceptor extends InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    log('----- Request -----');
    log(request.toString());
    log(request.headers.toString());
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    try {
      log('----- Response -----');
      log('Code: ${response.statusCode}');
      var data = {};
      if (response is Response) {
        data = jsonDecode(response.body);
      }

      if (response.statusCode == 401 &&
          (data['message'] == "Invalid or expired token" ||
              data['message'] == "User logged in on another device")) {
        await AppPreference.clearSharedPreferences();
        Navigation.replaceAll(Routes.registerScreen);
      }
      return response;
    } catch (e) {
      return response;
    }
  }
}
