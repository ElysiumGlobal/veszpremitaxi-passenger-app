import 'dart:convert';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/core/api/responce_handler.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/log_utils.dart';

import '../../../widgets/app_snackbar.dart';
import '../model/bank_details_model.dart';
import '../model/driver_transaction_model.dart';
import '../model/earning_cancel_model.dart';
import '../model/earning_details_model.dart';
import '../model/earning_overview_model.dart';
import '../model/earning_refund_model.dart';
import '../model/earning_transaction_mode.dart';
import '../model/wallet_transaction_details_model.dart';
import '../model/wallet_transaction_model.dart';

class WalletService {
  static Future addBankDetails({
    required String name,
    required String accNumber,
    required String ifscCode,
    required String bank,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.addBankAccount,
        bodyData: {
          "account_holder_name": name,
          "account_number": accNumber,
          "ifsc_code": ifscCode,
          "bank_name": bank,
        },
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("BANK ADD ERROR ::$e, $st");
      rethrow;
    }
  }

  static Future<BankDetailsModel> getBankDetails() async {
    try {
      final response = await Api().get(ApiConstants.showBank);
      await ResponseHandler.checkResponseError(response);

      return BankDetailsModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("BANK Get ERROR ::$e, $st");

      rethrow;
    }
  }


  static Future addUpiId({required String upiId}) async {
    try {
      final response = await Api().post(
        ApiConstants.addUpiId,
        bodyData: {"upi_id": upiId},
      );

      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError(" Add Upi ERROR ::$e, $st");

      rethrow;
    }
  }

  static Future<EarningTransactionModel> getWalletTransaction() async {
    try {
      final response = await Api().get(ApiConstants.walletOverView);
      await ResponseHandler.checkResponseError(response);

      return EarningTransactionModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError(" Wallet TransactionError  ::$e, $st");

      rethrow;
    }
  }

  static Future withDrawMoney({
    required String amount,
    required String accountId,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.withDrawMoney,
        bodyData: {"amount": amount, "account_id": accountId},
      );
      print("Response:::${response.body}");
      await ResponseHandler.checkResponseError(response);

      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError(" With Draw Error  ::$e, $st");

      rethrow;
    }
  }

  static Future<DriverTransactionModel> getEarningTransactionList({
    required Map<String, dynamic> query,
  }) async {
    try {
      final response = await Api().get(
        ApiConstants.getEarningTransactionList,
        queryData: query,
      );

      await ResponseHandler.checkResponseError(response);

      return DriverTransactionModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError(" get  Transaction Error  ::$e, $st");

      rethrow;
    }
  }

  static Future<EarningOverViewModel> getEarningOverViewData(
    Map<String, dynamic> query,
  ) async {
    try {
      final response = await Api().get(
        ApiConstants.earningOverview,
        queryData: query,
      );

      await ResponseHandler.checkResponseError(response);

      return EarningOverViewModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("GET EARNING OVERVIEW ERROR :$e, $st");
      rethrow;
    }
  }

  static Future<WalletTransactionModel> getWalletTransactionList(
    Map<String, dynamic> query,
  ) async {
    try {

      final response = await Api().get(
        ApiConstants.getWalletTransactionList,
        queryData: query,
      );
      await ResponseHandler.checkResponseError(response);
      return WalletTransactionModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("WALLET TRANSACTION LIST ERROR :$e, $st");
      rethrow;
    }
  }

  static Future<WalletTransactionDetailsModel> getWalletTransactionDetils({
    required String transactionId,
  }) async {
    try {
      Map<String, dynamic> query = {"transaction_id": transactionId};
      final response = await Api().get(
        ApiConstants.getWalletTransactionDetails,
        queryData: query,
      );
      await ResponseHandler.checkResponseError(response);
      return WalletTransactionDetailsModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("WALLET TRANSACTION LIST ERROR :$e, $st");
      rethrow;
    }
  }

  static Future earningReportIssue({
    required String bookingId,
    required String disputeReason,
    String msg = "",
    required List<String> imageList,
    required String transactionId,
  }) async {
    try {
      Map<String, String> bodyData = {
        "message": msg,
        "subject": disputeReason,
        "booking_id": bookingId,
        "category": "after_ride",
        "transection_id": transactionId,
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
      LogUtils.printError("EARNING REPORT ERROR $e , $st");
      rethrow;
    }
  }

  static Future<EarningDetailsModel> getEarningDetailsData({
    required String bookingCode,
  }) async {
    try {
      Map<String, dynamic> query = {"booking_code": bookingCode};
      final response = await Api().get(
        ApiConstants.earningDetails,
        queryData: query,
      );
      await ResponseHandler.checkResponseError(response);

      return EarningDetailsModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("EARNING DETAILS ERROR $e , $st");

      rethrow;
    }
  }

  static Future<EarningcancelModel> getEarningFailerData({
    required String transactionId,
  }) async {
    try {
      Map<String, dynamic> query = {"transaction_id": transactionId};
      final response = await Api().get(
        ApiConstants.earningCancelDetails,
        queryData: query,
      );
      await ResponseHandler.checkResponseError(response);

      return EarningcancelModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("EARNING TRANSACTION ERROR::$e, $st");
      rethrow;
    }
  }

  static Future<EarningRefundModel> getEarningRefundData({
    required String transactionId,
  }) async {
    try {
      Map<String, dynamic> query = {"transaction_id": transactionId};
      final response = await Api().get(
        ApiConstants.earningRefundApprove,
        queryData: query,
      );
      await ResponseHandler.checkResponseError(response);
      return EarningRefundModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("EARNING TRANSACTION ERROR::$e, $st");
      rethrow;
    }
  }

  static Future addMoneyWallet({
    required String paymentMethod,
    required String amount,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.addMoneyWallet,
        bodyData: {
          "payment_method": paymentMethod,
          "amount": amount,
          "currency": Constants().currency,
        },
      );

      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }
}
