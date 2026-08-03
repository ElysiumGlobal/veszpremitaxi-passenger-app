import 'dart:convert';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/core/api/responce_handler.dart';
import 'package:e_taxi/utils/api_constants.dart';

import '../model/incentive_model.dart';

class IncentiveService {
  static Future<IncentiveModel> getIncentive({required String date}) async {
    try {
      final response = await Api().get("${ApiConstants.incentive}$date");
      await ResponseHandler.checkResponseError(response);
      return IncentiveModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }
}
