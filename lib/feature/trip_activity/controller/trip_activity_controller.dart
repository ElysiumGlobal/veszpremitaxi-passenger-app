import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/feature/trip_activity/service/trip_service.dart';
import 'package:e_taxi/utils/common_api_caller.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:get/get.dart';

import '../model/trip_activity_model.dart';

class TripController extends GetxController with LoadingApiMixin, LoadingMixin {
  Rx<TripActivityModel> todayTripModel = TripActivityModel().obs;
  int page = 1;
  RxBool todayPaginationLoading = false.obs;
  RxBool todayTripLoading = false.obs;
  bool isMoreTodayAvailable = true;

  Future<void> getTodayTrip({bool isFirstTime = true}) async {
    if (todayPaginationLoading.value && isFirstTime == false) {
      return;
    }

    if (isFirstTime) {
      page = 1;
      isMoreTodayAvailable = true;
      todayTripLoading(true);
    } else {
      todayPaginationLoading(true);
    }
    Map<String, dynamic> query = {"period": "today", "page": page};

    if (todayFilterOn.value) {
      if (todayTripTypeF.value != -1) {
        if (todayTripTypeF.value == 0) {
          query['status'] = _tripType[todayTripTypeF.value];
        } else {
          query['cancelled_by'] = _tripType[todayTripTypeF.value];
          query['status'] = "cancelled";
        }
      }
      if (todayPaymentModeF.value != -1) {
        query['payment_mode'] = _todayPayment[todayPaymentModeF.value];
      }
      if (todayAmountF.value != -1) {
        query['amount_min'] = todayAmountF.value != 4
            ? _amount[todayAmountF.value].split("-").first
            : todayMinAmountF;
        query['amount_max'] = todayAmountF.value != 4
            ? _amount[todayAmountF.value].split("-").last
            : todayMaxAmountF;
      }
      if (todayDistanceF.value != -1) {
        query['distance_min'] = _distance[todayDistanceF.value]
            .split("-")
            .first;
        query['distance_max'] = _distance[todayDistanceF.value].split("-").last;
      }
    }

    await processApi(
      () => TripService.getTripList(query),
      result: (data) {
        if (isFirstTime) {
          todayTripModel.value = data;

          if ((todayTripModel.value.data?.summary?.totalOnlineHours ?? "")
              .isNotEmpty) {
            Get.find<AccountController>().updateOnlineTime(
              todayTripModel.value.data?.summary?.totalOnlineHours ?? "",
            );
          }
        } else {
          (todayTripModel.value.data?.trips ?? []).addAll(
            data.data?.trips ?? [],
          );
        }
        todayTripModel.value.data?.summary = data.data?.summary;

        if ((data.data?.trips ?? []).length != 10) {
          isMoreTodayAvailable = false;
        }
        page++;

        todayTripModel.refresh();
      },
    );

    todayTripLoading(false);
    todayPaginationLoading(false);
  }


  Rx<TripActivityModel> weeklyTripModel = TripActivityModel().obs;
  int pageWeekly = 1;
  RxBool weeklyPaginationLoading = false.obs;
  RxBool weeklyTripLoading = false.obs;
  bool weeklyMoreAvailable = true;

  Future<void> getWeekTrip({bool isFirstTime = true}) async {
    if (weeklyPaginationLoading.value && isFirstTime == false) {
      return;
    }

    if (isFirstTime) {
      pageWeekly = 1;

      weeklyMoreAvailable = true;
      weeklyTripLoading(true);
    } else {
      weeklyPaginationLoading(true);
    }

    Map<String, dynamic> query = {"period": "weekly", "page": pageWeekly};

    if (weeklyFilterOn.value) {
      if (weeklyDateF.value != -1) {
        query['date_from'] = weeklyDateF.value != 3
            ? Utils().dateSendServer1(
                _date[weeklyDateF.value].split("@@").first,
              )
            : weeklyStartDateF.value;
        query['date_to'] = weeklyDateF.value != 3
            ? Utils().dateSendServer1(_date[weeklyDateF.value].split("@@").last)
            : weeklyEndDateF.value;
      }

      if (weeklyTripTypeF.value != -1) {
        if (weeklyTripTypeF.value == 0) {
          query['status'] = _tripType[weeklyTripTypeF.value];
        } else {
          query['cancelled_by'] = _tripType[weeklyTripTypeF.value];
          query['status'] = "cancelled";
        }
      }
      if (weeklyPaymentModeF.value != -1) {
        query['payment_mode'] = _todayPayment[weeklyPaymentModeF.value];
      }
      if (weeklyAmountF.value != -1) {
        query['amount_min'] = weeklyAmountF.value != 4
            ? _amount[weeklyAmountF.value].split("-").first
            : weeklyMinAmountF;
        query['amount_max'] = weeklyAmountF.value != 4
            ? _amount[weeklyAmountF.value].split("-").last
            : weeklyMaxAmountF;
      }
      if (weeklyDistanceF.value != -1) {
        query['distance_min'] = _distance[weeklyDistanceF.value]
            .split("-")
            .first;
        query['distance_max'] = _distance[weeklyDistanceF.value]
            .split("-")
            .last;
      }
    }

    await processApi(
      () => TripService.getTripList(query),
      result: (data) {
        if (isFirstTime) {
          weeklyTripModel.value = data;
        } else {
          (weeklyTripModel.value.data?.trips ?? []).addAll(
            data.data?.trips ?? [],
          );
        }


        weeklyTripModel.value.data?.summary = data.data?.summary;
        if ((data.data?.trips ?? []).length != 10) {
          weeklyMoreAvailable = false;
        }
        page++;

        weeklyTripModel.refresh();
      },
    );
    weeklyPaginationLoading(false);
    weeklyTripLoading(false);
  }

  List<String> _tripType = ["completed", 'driver', 'user'];
  List<String> _todayPayment = ['cash', 'wallet', 'online'];
  List<String> _amount = ['0-25', '25-50', '50-100', '100-'];
  List<String> _distance = ['0-5', '5-10', '10-15', '15-'];

  List<String> _date = [
    "${DateTime(DateTime.now().year, DateTime.now().month, 1)}@@${DateTime.now()}",
    "${DateTime.now().subtract(Duration(days: 30))}@@${DateTime.now()}",
    "${DateTime.now().subtract(Duration(days: 90))}@@${DateTime.now()}",
  ];
  RxInt todayTripTypeF = (-1).obs;
  RxInt todayPaymentModeF = (-1).obs;
  RxInt todayAmountF = (-1).obs;
  RxInt todayDistanceF = (-1).obs;
  RxString todayStartDate = "".obs;
  RxString todayEndDate = "".obs;
  RxBool todayFilterOn = false.obs;
  String todayMinAmountF = "";
  String todayMaxAmountF = "";

  void clearTodayFilter() {
    todayTripTypeF = (-1).obs;
    todayPaymentModeF = (-1).obs;
    todayAmountF = (-1).obs;
    todayStartDate = "".obs;
    todayEndDate = "".obs;
    todayFilterOn = false.obs;
    todayMinAmountF = "";
    todayMaxAmountF = "";
  }


  RxString weeklyStartDateF = "".obs;
  RxString weeklyEndDateF = "".obs;
  RxInt weeklyTripTypeF = (-1).obs;
  RxInt weeklyPaymentModeF = (-1).obs;
  RxInt weeklyAmountF = (-1).obs;
  String weeklyMinAmountF = '';
  String weeklyMaxAmountF = '';
  RxInt weeklyDistanceF = (-1).obs;
  RxInt weeklyDateF = (-1).obs;
  RxBool weeklyFilterOn = false.obs;

  void clearWeeklyFilter() {
    weeklyStartDateF = "".obs;
    weeklyEndDateF = "".obs;
    weeklyTripTypeF = (-1).obs;
    weeklyPaymentModeF = (-1).obs;
    weeklyAmountF = (-1).obs;
    weeklyMinAmountF = '';
    weeklyMaxAmountF = '';
    weeklyDistanceF = (-1).obs;
    weeklyDateF = (-1).obs;
    weeklyFilterOn = false.obs;
  }

  Future<Map> tripSupportTicket({
    required List<String> imageList,
    required String bookingId,
    required String msg,
    required String subject,
  }) async {
    Map res = {};

    await processApi(
      () => TripService.tripSupport(
        imageList: imageList,
        bookingId: bookingId,
        msg: msg,
        subject: subject,
      ),
      result: (data) {
        res = data;
      },
      loading: handleLoading,
    );

    return res;
  }
}
