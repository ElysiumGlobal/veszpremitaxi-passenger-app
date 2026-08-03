import 'dart:convert';

import '../../../core/api/api.dart';
import '../../../core/api/responce_handler.dart';
import '../../../utils/api_constants.dart';
import '../../../utils/log_utils.dart';
import '../../../widgets/app_snackbar.dart';
import '../model/emergency_model.dart';
import '../model/support_model.dart';
import '../model/ticket_support_model.dart';

class HelpCenterService {
  static Future addEmergency({
    required String name,
    required String phone,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.addEmergency,
        bodyData: {"name": name, "mobile_number": phone, "is_primary": true},
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

  static Future<SupportModel> contactSupport() async {
    try {
      final response = await Api().get(ApiConstants.contactSupport);
      await ResponseHandler.checkResponseError(response);
      return SupportModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("ERROR SUPPORT :$e , $st");
      rethrow;
    }
  }

  static Future<TicketSupportModel> getSupportDetails(String id) async {
    try {
      final response = await Api().get("${ApiConstants.getSupportDetails}$id");
      await ResponseHandler.checkResponseError(response);
      return TicketSupportModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("SUPPORT TICKET ERROR ::$e $st");
      rethrow;
    }
  }

  static Future supportDocumentUpdate({
    required String id,
    required int index,
    required List<String> imageList,
  }) async {
    try {
      final res = await Api().multiPartRequest(
        "${ApiConstants.getSupportDetails}$id/attachments/$index",
        imageList,
        fieldName: "file",
      );
      if (res['success'] == false) {
        AppSnackBar.showErrorSnackBar(message: res['message'], isError: true);
        throw "ERROR::$res";
      }
      return res;
    } catch (e, st) {
      LogUtils.printError("SUPPORT UPDATE IMAGE ERROR :$e , $st");
      rethrow;
    }
  }

  static Future supportDocDelete({
    required String id,
    required int index,
  }) async {
    try {
      final response = await Api().delete(
        "${ApiConstants.getSupportDetails}$id/attachments/$index",
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("SUPPORT TICKET Delete ::$e $st");
      rethrow;
    }
  }

  static Future raiseTicket({
    required String title,
    required String des,
    required List<String> imagePath,
  }) async {
    try {
      final res = await Api().multiPartRequest(
        mapBodyData: {"category": title, "subject": title, "message": des},

        ApiConstants.tripSupportTicket,
        imagePath,
        fieldName: "attachments[]",
      );
      if (res['success'] == false) {
        AppSnackBar.showErrorSnackBar(message: res['message'], isError: true);
        throw "ERROR::$res";
      }
      return res;
    } catch (e, st) {
      LogUtils.printError("EARNING REPORT ERROR $e , $st");
      rethrow;
    }
  }
}
