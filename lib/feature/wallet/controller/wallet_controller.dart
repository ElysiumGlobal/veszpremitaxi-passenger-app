import 'dart:convert';

import 'package:e_taxi/feature/wallet/model/walllet_model.dart';
import 'package:e_taxi/feature/wallet/service/wallet_service.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/common_api_caller.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:get/get.dart';

class WalletController extends GetxController
    with LoadingMixin, LoadingApiMixin {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getWalletData(localLoad: true);
  }

  RxBool isLoading = false.obs;
  Rxn<WalletDataModel> walletModel = Rxn<WalletDataModel>();

  Future getWalletData({bool localLoad = false}) async {
    if (localLoad) {
      String dbData = AppPreference.getString(AppPreference.walletData);
      if (dbData.isNotEmpty) {
        walletModel.value = WalletDataModel.fromJson(jsonDecode(dbData));
      }
    }

    if ((walletModel.value?.data?.transactions?.data ?? []).isEmpty) {
      isLoading(true);
    }

    await processApi(
      () => WalletService.getWalletData(),
      result: (data) {
        walletModel.value = data;

        AppPreference.setString(
          AppPreference.walletData,
          jsonEncode(data.toJson()),
        );
      },
    );
    isLoading(false);
  }
}
