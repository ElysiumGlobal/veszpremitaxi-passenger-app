import 'dart:convert';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/core/api/responce_handler.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:e_taxi/utils/log_utils.dart';

import '../../../widgets/app_snackbar.dart';
import '../model/trip_activity_model.dart';

class TripService {
  static Future<TripActivityModel> getTripList(
    Map<String, dynamic> query,
  ) async {
    try {
      final response = await Api().get(
        "${ApiConstants.getTripDetails}",
        queryData: query,
      );

      await ResponseHandler.checkResponseError(response);
      return TripActivityModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("Todat trip Error ::$e, $st");
      rethrow;
    }
  }

  static Future tripSupport({
    required List<String> imageList,
    required String bookingId,
    required String subject,
    required String msg,
  }) async {
    try {
      Map<String, String> bodyData = {
        "subject": subject,
        "message": msg,
        "category": "booking",
        "booking_id": bookingId,
      };
      final res = await Api().multiPartRequest(
        ApiConstants.tripSupportTicket,
        imageList,
        fieldName: "attachments[]",
        mapBodyData: bodyData,
      );

      if (res['success'] == false) {
        AppSnackBar.showErrorSnackBar(message: res['message'], isError: true);
        throw "ERROR::$res";
      }
      return res;
    } catch (e, st) {
      LogUtils.printError("TRIP TICKET ERROR $e , $st");
      rethrow;
    }
  }
}
