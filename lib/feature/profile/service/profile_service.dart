import 'dart:convert';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/core/api/responce_handler.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:e_taxi/utils/log_utils.dart';

import '../../../widgets/app_snackbar.dart';
import '../model/emergency_model.dart';
import '../model/notification_model.dart';
import '../model/user_model.dart';

class ProfileService {
  static Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await Api().get(ApiConstants.userProfile);
      await ResponseHandler.checkResponseError(response);
      return UserProfileModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("USER PROFILE ERROR:::$e, $st");
      rethrow;
    }
  }

  static Future updateProfile({
    required Map<String, String> body,
    required List<String> imageList,
    required List<String> imageName,
  }) async {
    try {
      final res = await Api().sendMultipartRequestPost1(
        ApiConstants.updateProfile,
        imageName: imageName,
        profileImage: imageList,
        bodyData: body,
      );

      if (res['success'] == false) {
        AppSnackBar.showErrorSnackBar(message: res['message'], isError: true);
        throw "ERROR::$res";
      }
      return res;
    } catch (e, st) {
      LogUtils.printError("Update Profile:::$e, $st");

      rethrow;
    }
  }

  static Future addEmergency({
    required String name,
    required String phone,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.addEmergency,
        bodyData: {"name": name, "mobile_number": phone},
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("Add Emergency Error:::$e, $st");

      rethrow;
    }
  }

  static Future<EmergencyModel> getEmergency() async {
    try {
      final response = await Api().get(ApiConstants.getEmergency);
      await ResponseHandler.checkResponseError(response);
      return EmergencyModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("Get Emergency Error:::$e, $st");

      rethrow;
    }
  }

  static Future deleteEmergency(int id) async {
    try {
      final response = await Api().delete("${ApiConstants.deleteEmergency}$id");
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("Delete Emergency Error:::$e, $st");

      rethrow;
    }
  }

  static Future<NotificationModel> getNotificationList({int page = 1}) async {
    try {
      final response = await Api().get(
        "${ApiConstants.getNotificationList}$page",
      );

      await ResponseHandler.checkResponseError(response);

      return NotificationModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("Notification Data Error:::$e, $st");

      rethrow;
    }
  }

  static Future deleteAccount() async {
    try {
      final response = await Api().post(ApiConstants.deleteAccount);
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  static Future logOutAccount() async {
    try {
      final response = await Api().post(ApiConstants.logOutAccount);
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }
}
