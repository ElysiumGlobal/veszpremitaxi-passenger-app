import 'dart:developer';

import 'package:e_taxi/feature/incentive/service/incentive_service.dart';
import 'package:e_taxi/utils/common_api_caller.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:get/get.dart';

import '../model/incentive_model.dart';

class IncentiveController extends GetxController
    with LoadingMixin, LoadingApiMixin {
  Rx<DateTime> focusedDay = DateTime.now().obs;

  Rx<DateTime> selectedDay = DateTime.now().obs;
  RxString selectedDayMonth = ''.obs;

  RxBool loading = false.obs;
  Rxn<IncentiveModel> incentiveModel = Rxn<IncentiveModel>();

  RxList<Incentive> liveList = RxList<Incentive>();
  RxList<Incentive> upcomingList = RxList<Incentive>();
  RxList<Incentive> completedList = RxList<Incentive>();

  RxBool isError = false.obs;

  Future<void> getIncentive({required String date}) async {
    loading(true);
    isError(false);
    await processApi(
      () => IncentiveService.getIncentive(date: date),
      result: (data) {
        incentiveModel.value = data;

        liveList.value = (incentiveModel.value?.data?.incentives ?? [])
            .where((e) => (e.status ?? '') == "live" && e.isLive == true)
            .toList();
        completedList.value = (incentiveModel.value?.data?.incentives ?? [])
            .where(
              (e) => (e.status ?? '') == "completed" && e.isCompleted == true,
            )
            .toList();
        upcomingList.value = (incentiveModel.value?.data?.incentives ?? [])
            .where(
              (e) => (e.status ?? '') == "upcoming" && e.isUpcoming == true,
            )
            .toList();
      },
      error: (error, stack) {
        log("ERROR :::::::::$error====$stack");
        isError(true);
        liveList.clear();
        upcomingList.clear();
        completedList.clear();
      },
    );
    loading(false);
  }
}
