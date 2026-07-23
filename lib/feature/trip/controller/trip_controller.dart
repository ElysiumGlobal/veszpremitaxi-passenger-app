import 'dart:developer';

import 'package:e_taxi/feature/trip/model/trip_details_model.dart';
import 'package:e_taxi/utils/common_api_caller.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:get/get.dart';

import '../service/trip_service.dart';

class TripController extends GetxController with LoadingMixin, LoadingApiMixin {
  RxList<TripHistory> tripHistoryList = <TripHistory>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getTripHistory();
  }

  @override
  void onClose() {
    super.onClose();
  }

  RxBool loading = false.obs;

  RxBool isPagination = false.obs;
  bool moreAvailable = true;
  int pageNo = 1;

  Future<void> getTripHistory({bool isFirst = true}) async {
    if (isFirst) {
      if (tripHistoryList.isEmpty) {
        loading(true);
      }
      moreAvailable = true;
      isPagination.value = false;
      pageNo = 1;
    } else {}

    await processApi(
      () => TripService.getTripList(pageNo),
      result: (data) {
        if (isFirst) {
          tripHistoryList.value = data.data?.tripHistory ?? [];
        } else {
          tripHistoryList.addAll(data.data?.tripHistory ?? []);
        }
        if ((data.data?.tripHistory ?? []).length != 10) {
          moreAvailable = false;
        }

        pageNo++;
      },
    );
    loading(false);
    isPagination(false);
  }

  Future<void> refundReqSend({
    required String bookingId,
    required String reason,
    required String des,
    required int index,
  }) async {
    await processApi(
      () => TripService.refundRequest(
        bookingId: bookingId,
        reason: reason,
        des: des,
      ),
      result: (data) {
        log("DATA:::::$data");
        tripHistoryList[index].refundStatus = data['refund_request']['status'];
        tripHistoryList.refresh();
        handleLoading(false);
        Get.back();
        AppSnackBar.showErrorSnackBar(message: data['message']);
      },
      loading: handleLoading,
    );
  }
}
