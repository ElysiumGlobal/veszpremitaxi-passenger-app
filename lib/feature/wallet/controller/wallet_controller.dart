import 'dart:developer';

import 'package:e_taxi/feature/wallet/model/wallet_transaction_details_model.dart';
import 'package:e_taxi/feature/wallet/service/wallet_service.dart';
import 'package:e_taxi/utils/common_api_caller.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:get/get.dart';

import '../model/bank_details_model.dart';
import '../model/driver_transaction_model.dart';
import '../model/earning_cancel_model.dart';
import '../model/earning_details_model.dart';
import '../model/earning_overview_model.dart';
import '../model/earning_refund_model.dart';
import '../model/earning_transaction_mode.dart';
import '../model/wallet_transaction_model.dart';
import '../widget/payment_webview.dart';

class WalletController extends GetxController
    with LoadingMixin, LoadingApiMixin {
  Future<Map> addBankDetails({
    required String name,
    required String accNumber,
    required String ifscCode,
    required String bank,
  }) async {
    Map res = {};
    await processApi(
      () => WalletService.addBankDetails(
        name: name,
        accNumber: accNumber,
        bank: bank,
        ifscCode: ifscCode,
      ),
      result: (data) {
        res = data;

        accountDetails.value = accountDetails.value?.copyWith(
          id: data['data']['bank_account']['id'],
          bankName: data['data']['bank_account']['bank_name'],
          ifscCode: data['data']['bank_account']['ifsc_code'],
          accountNumber: data['data']['bank_account']['account_number'],
          accountHolderName:
              data['data']['bank_account']['account_holder_name'],
        );
        accountDetails.refresh();
      },
      loading: handleLoading,
    );
    return res;
  }

  Future<Map> addUpiId({required String upiId}) async {
    Map res = {};
    await processApi(
      () => WalletService.addUpiId(upiId: upiId),
      result: (data) {
        res = data;
      },
      loading: handleLoading,
    );
    return res;
  }

  Rxn<EarningTransactionModel> recentTransactionList =
      Rxn<EarningTransactionModel>();

  RxBool walletLoading = false.obs;

  Future<void> getWalletTransaction({bool isFirstTime = true}) async {
    walletLoading(true);
    await processApi(
      () => WalletService.getWalletTransaction(),
      result: (data) {
        recentTransactionList.value = data;
      },
    );
    walletLoading(false);
  }

  Future<Map> withDrawMoney({
    required String amount,
    required String accountId,
  }) async {
    Map res = {};

    await processApi(
      () => WalletService.withDrawMoney(amount: amount, accountId: accountId),
      result: (data) {
        res = data;
      },
      loading: handleLoading,
    );

    return res;
  }

  Future<void> addMoney({
    required String amount,
    required String method,
  }) async {
    handleLoading(true);

    processApi(
      () => WalletService.addMoneyWallet(paymentMethod: method, amount: amount),
      result: (data) async {
        await Get.to(
          () => PaymentWebViewScreen(webUrl: data['data']['payment_link']),
        );
        handleLoading(false);
        Get.back();
        getWalletTransaction();
      },
      error: (error, stack) {
        LogUtils.printError("????$error, $stack");
        handleLoading(false);
      },
    );
  }

  RxBool earingTransactionLoading = false.obs;

  RxList<Earning> earningTransactionList = <Earning>[].obs;
  int pageEarningNo = 1;
  RxBool earningPaginationLoading = false.obs;
  bool isMoreEarningAvailable = true;

  Future<void> getEarningTransactionList({bool isFirstTime = true}) async {
    if (earningPaginationLoading.value && isFirstTime == false) {
      return;
    }

    if (isFirstTime) {
      pageEarningNo = 1;
      isMoreEarningAvailable = true;
      earingTransactionLoading(true);

    } else {
      earningPaginationLoading(true);
    }

    Map<String, dynamic> query = {
      "payment_source": "all",
      "earning_type": "all",
      "amount": "all",
    };
    if (earningFilterOn.value) {
      if (earningPaymentF.value != -1) {
        query['payment_source'] = _paymentSource[earningPaymentF.value];
      }
      if (earningTypeF.value != -1) {
        query['earning_type'] = _earningType[earningTypeF.value];
      }
      if (earningAmountF.value != -1) {
        query['amount_min'] = earningAmountF.value != 4
            ? _amount[earningAmountF.value].split("-").first
            : earningMinAmount;
        query['amount_max'] = earningAmountF.value != 4
            ? _amount[earningAmountF.value].split("-").last
            : earningMaxAmount;
      }
    }

    await processApi(
      () => WalletService.getEarningTransactionList(query: query),
      result: (data) {
        if (isFirstTime) {
          earningTransactionList.value = data.data?.earnings ?? [];
        } else {
          earningTransactionList.addAll(data.data?.earnings ?? []);
        }
        if ((data.data?.earnings ?? []).length != 10) {
          isMoreEarningAvailable = false;
        }

        earningTransactionList.refresh();
      },
    );

    if (isFirstTime) {
      earingTransactionLoading(false);
    } else {
      earningPaginationLoading(false);
    }
  }

  List<String> _paymentSource = ["wallet", "cash", "incentive", "deduction"];
  List<String> _earningType = [
    "ride",
    'rider_trip',
    'refral_bonus',
    'pick_hour',
    'cancelation',
    'service',
  ];

  RxBool earningOverViewLoading = false.obs;

  Rxn<EarningOverViewModel> earningOverViewModel = Rxn<EarningOverViewModel>();

  Future<void> getEarningOverView(int index) async {
    earningOverViewLoading(true);

    Map<String, dynamic> query = {
      "from_date": Utils().getWeekRange(index)['start'],
      "to_date": Utils().getWeekRange(index)['end'],
      "selected_day": 7,
    };

    await processApi(
      () => WalletService.getEarningOverViewData(query),
      result: (data) {
        earningOverViewModel.value = data;
      },
      error: (error, stack) {
        log("ERROR : ::::$error,$stack");
      },
    );
    earningOverViewLoading(false);
  }

  List<String> _amount = ['0-25', '25-50', '50-100', '100-'];
  List<String> _status = ["completed", "pending", "failed"];
  List<String> _transactionType = [
    "credit",
    "debit",
    "referral_bonus",
    "driver_commission",
    "promo_credit",
    "adjustment",
  ];

  RxInt earningPaymentF = (-1).obs;
  RxInt earningTypeF = (-1).obs;
  RxInt earningAmountF = (-1).obs;
  RxBool earningFilterOn = false.obs;
  String earningMinAmount = "";
  String earningMaxAmount = "";

  clearEarningFilter() {
    earningPaymentF = (-1).obs;
    earningTypeF = (-1).obs;
    earningAmountF = (-1).obs;
    earningFilterOn = false.obs;
    earningMinAmount = "";
    earningMaxAmount = "";
  }

  List<String> _date = [
    "${DateTime(DateTime.now().year, DateTime.now().month, 1)}@@${DateTime.now()}",
    "${DateTime.now().subtract(Duration(days: 30))}@@${DateTime.now()}",
    "${DateTime.now().subtract(Duration(days: 90))}@@${DateTime.now()}",
  ];
  Rxn<EarningDetailsModel> earningDetailsModel = Rxn<EarningDetailsModel>();
  RxBool earningDetailsLoading = false.obs;
  RxBool earningDetailsError = false.obs;

  Future<void> getEarningDetailsData({required String bookingCode}) async {
    earningDetailsLoading(true);
    earningDetailsError(false);

    await processApi(
      () => WalletService.getEarningDetailsData(bookingCode: bookingCode),
      result: (data) {
        earningDetailsModel.value = data;
      },
      error: (error, stack) {
        earningDetailsError(true);
      },
    );

    earningDetailsLoading(false);
  }

  Rxn<EarningcancelModel> earningCancelModel = Rxn<EarningcancelModel>();

  Future<void> getEarningCancellationFee({
    required String transactionId,
  }) async {
    earningDetailsLoading(true);
    earningDetailsError(false);
    await processApi(
      () => WalletService.getEarningFailerData(transactionId: transactionId),
      result: (data) {
        earningCancelModel.value = data;
      },
      error: (error, stack) {
        earningDetailsError(true);
      },
    );

    earningDetailsLoading(false);
  }

  Rxn<EarningRefundModel> earningRefundModel = Rxn<EarningRefundModel>();

  Future<void> getEarningRefund({required String transactionId}) async {
    earningDetailsLoading(true);
    earningDetailsError(false);
    await processApi(
      () => WalletService.getEarningRefundData(transactionId: transactionId),
      result: (data) {
        earningRefundModel.value = data;
      },
      error: (error, stack) {
        earningDetailsError(true);
      },
    );

    earningDetailsLoading(false);
  }


  RxInt walletStatusF = (-1).obs;
  RxInt walletTypeF = (-1).obs;
  RxInt walletAmountF = (-1).obs;
  String walletMinAmount = "";
  String walletMaxAmount = "";

  RxInt walletDateF = (-1).obs;
  RxString walletStartDateF = "".obs;
  RxString walletEndDateF = "".obs;
  RxBool walletTransactionFiterOn = false.obs;

  Future<void> clearWalletTransaction() async {
    walletStatusF = (-1).obs;
    walletTypeF = (-1).obs;
    walletAmountF = (-1).obs;
    walletDateF = (-1).obs;
    walletStartDateF = "".obs;
    walletEndDateF = "".obs;
    walletMinAmount = "";
    walletMaxAmount = "";
    walletTransactionFiterOn = false.obs;
  }

  Rxn<WalletTransactionModel> walletTransactionModel =
      Rxn<WalletTransactionModel>();

  RxBool walletTransactionLoading = false.obs;

  Future<void> getWalletTransactionList({bool isFirstTime = true}) async {
    walletTransactionLoading(true);

    Map<String, dynamic> query = {};

    if (walletTransactionFiterOn.value) {
      if (walletDateF.value != -1) {
        query['from_date'] = walletDateF.value != 3
            ? Utils().dateSendServer1(
                _date[walletDateF.value].split("@@").first,
              )
            : walletStartDateF.value;
        query['to_date'] = walletDateF.value != 3
            ? Utils().dateSendServer1(_date[walletDateF.value].split("@@").last)
            : walletEndDateF.value;
      }
      if (walletAmountF.value != -1) {
        query['amount_min'] = walletAmountF.value != 4
            ? _amount[walletAmountF.value].split("-").first
            : walletMinAmount;
        query['amount_max'] = walletAmountF.value != 4
            ? _amount[walletAmountF.value].split("-").last
            : walletMaxAmount;
      }
      if (walletStatusF.value != -1) {
        query['status'] = _status[walletStatusF.value];
      }
      if (walletTypeF.value != -1) {
        query['type'] = _transactionType[walletTypeF.value];
      }
    }

    await processApi(
      () => WalletService.getWalletTransactionList(query),
      result: (data) {
        walletTransactionModel.value = data;
        print("DATA :::${data.toJson()}");
      },
      error: (error, stack) {
        print("ERROR ARE OCCUE :$error, $stack");
      },
    );

    walletTransactionLoading(false);
  }

  Rxn<WalletTransactionDetailsModel> walletDetailsModel =
      Rxn<WalletTransactionDetailsModel>();

  RxBool walletDetailsLoading = false.obs;
  RxBool walletDetailsError = false.obs;

  Future<void> getWalletTransactionDetails({
    required String transactionId,
  }) async {
    walletDetailsLoading(true);
    walletDetailsError(false);

    await processApi(
      () => WalletService.getWalletTransactionDetils(
        transactionId: transactionId,
      ),
      result: (data) {
        walletDetailsModel.value = data;
      },
      error: (error, stack) {
        walletDetailsError(true);
      },
    );
    walletDetailsLoading(false);
  }

  Future<Map> earningReportIssue({
    required String bookingId,
    required String disputeReason,
    String msg = "",
    required List<String> imageList,
    required String transactionId,
  }) async {
    Map res = {};

    await processApi(
      () => WalletService.earningReportIssue(
        imageList: imageList,
        bookingId: bookingId,
        msg: msg,
        disputeReason: disputeReason,
        transactionId: transactionId,
      ),
      result: (data) {
        res = data;
      },
      loading: handleLoading,
    );

    return res;
  }


  Rxn<AccountDetails> accountDetails = Rxn<AccountDetails>();

  Future getBankInfo({bool isRefresh = false}) async {
    if (accountDetails.value != null && isRefresh == false) {
      return;
    }

    await processApi(
      () => WalletService.getBankDetails(),
      result: (data) {
        accountDetails.value = data.data?.accountDetails;
      },
    );
  }
}
