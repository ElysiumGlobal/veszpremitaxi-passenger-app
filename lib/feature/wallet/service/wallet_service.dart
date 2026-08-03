import 'dart:convert';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/core/api/responce_handler.dart';
import 'package:e_taxi/feature/wallet/model/walllet_model.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:e_taxi/utils/log_utils.dart';

class WalletService {
  static Future<WalletDataModel> getWalletData() async {
    try {
      final response = await Api().get(ApiConstants.getWalletData);
      await ResponseHandler.checkResponseError(response);
      return WalletDataModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("WALLET ERROR:$e , $st");
      rethrow;
    }
  }
}
