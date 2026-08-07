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
      await ResponseHandler.checkResponseError(
        response,
        apiTag: 'wallet/wallet-info-transactions',
      );
      return WalletDataModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("WALLET ERROR:$e , $st");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getStripeTopupConfig() async {
    try {
      final response = await Api().get(ApiConstants.stripeWalletTopupConfig);
      await ResponseHandler.checkResponseError(
        response,
        apiTag: 'payments/wallet/stripe/config',
      );
      return _decodeObject(response.body);
    } catch (e, st) {
      LogUtils.printError("STRIPE WALLET CONFIG ERROR:$e , $st");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createStripeTopup({
    required int amount,
    required String clientRequestId,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.stripeWalletTopup,
        bodyData: {
          'amount': amount,
          'client_request_id': clientRequestId,
        },
      );
      await ResponseHandler.checkResponseError(
        response,
        apiTag: 'payments/wallet/stripe/topup',
      );
      return _decodeObject(response.body);
    } catch (e, st) {
      LogUtils.printError("STRIPE WALLET TOPUP CREATE ERROR:$e , $st");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getStripeTopupStatus(
    String topupId,
  ) async {
    try {
      final response = await Api().get(
        '${ApiConstants.stripeWalletTopup}/$topupId',
      );
      await ResponseHandler.checkResponseError(
        response,
        apiTag: 'payments/wallet/stripe/topup/{id}',
      );
      return _decodeObject(response.body);
    } catch (e, st) {
      LogUtils.printError("STRIPE WALLET TOPUP STATUS ERROR:$e , $st");
      rethrow;
    }
  }

  static Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw const FormatException('A szerver nem JSON objektumot adott vissza.');
  }
}
