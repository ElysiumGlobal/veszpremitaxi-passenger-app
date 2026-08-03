import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart' show XFile;
import 'package:e_taxi/feature/account/model/user_model.dart';
import 'package:e_taxi/core/debug/driver_flow_debug.dart';
import 'package:e_taxi/feature/account/service/account_service.dart';
import 'package:e_taxi/utils/common_api_caller.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../../core/service/location_utils.dart';
import '../../../utils/app_preferences.dart';
import '../../../utils/constants.dart';
import '../../../utils/log_utils.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../auth/model/place_adress_model.dart';
import '../../auth/service/auth_service.dart';
import '../../home/controller/home_controller.dart';
import '../../home/pages/home_screen.dart';
import '../model/cash_collection_model.dart';
import '../model/location_list_model.dart';
import '../model/notification_model.dart';
import '../model/performer_model.dart';

class AccountController extends GetxController
    with LoadingApiMixin, LoadingMixin {
  Rxn<UserModel> userModel = Rxn<UserModel>();
  final RxString lastServerRideStatus = ''.obs;
  final RxString lastServerRideBookingId = ''.obs;
  final RxString lastServerRidePaymentStatus = ''.obs;

  bool _isUsableCurrentRide(UserDataModel profile) {
    final ride = profile.currentRide;
    final booking = ride?.booking;
    if (ride == null || booking == null) return false;

    final String status = (booking.status ?? '').toLowerCase().trim();
    final String bookingId = (booking.id ?? ride.bookingId ?? '').trim();
    final String profileBookingId =
        (profile.data?.currentBookingId ?? '').trim();
    const activeStatuses = <String>{'accepted', 'arrived', 'started'};
    final String paymentStatus =
        (booking.paymentStatus ?? '').toLowerCase().trim();
    final bool paymentSettled = const <String>{
      'paid',
      'completed',
      'complete',
      'success',
      'successful',
      'settled',
      '1',
      'true',
    }.contains(paymentStatus);
    final bool completedAwaitingPayment =
        status == 'completed' && !paymentSettled;

    if (bookingId.isEmpty ||
        (!activeStatuses.contains(status) && !completedAwaitingPayment)) {
      return false;
    }
    if (profileBookingId.isEmpty || profileBookingId != bookingId) return false;

    final String updatedAt = (booking.updatedAt ?? '').trim();
    final DateTime? parsed = DateTime.tryParse(updatedAt);
    if (parsed != null) {
      final Duration age = DateTime.now().difference(parsed.toLocal()).abs();
      if ((status == 'accepted' || status == 'arrived') &&
          age > const Duration(minutes: 90)) {
        return false;
      }
      if (status == 'started' && age > const Duration(hours: 12)) {
        return false;
      }
    }
    return true;
  }

  Future<void> getUserData({
    bool isLoading = false,
    bool checkDocument = false,
    bool rideRedirect = false,
  }) async {
    String data = AppPreference.getProfileData();
    if (data.isNotEmpty) {
      userModel.value = UserModel.fromJson(jsonDecode(data));
    }

    if (isLoading) {
      handleLoading(true);
    }

    await processApi(
      () => AccountService.getUserProfile(),
      result: (data) {
        userModel.value = data.data;
        lastServerRideStatus.value =
            (data.currentRide?.booking?.status ?? '').toLowerCase().trim();
        lastServerRideBookingId.value =
            (data.currentRide?.booking?.id ?? data.currentRide?.bookingId ?? '')
                .toString()
                .trim();
        lastServerRidePaymentStatus.value =
            (data.currentRide?.booking?.paymentStatus ?? '')
                .toLowerCase()
                .trim();
        AppPreference.setProfileModel(jsonEncode(userModel.value?.toJson()));
        if ((userModel.value?.isVerified ?? "0") == "1") {
          AppPreference.setBoolean(AppPreference.profileApprove, value: true);
        }

        if (checkDocument) {
          if ((userModel.value?.isVerified ?? "0") == "0") {
            AppPreference.setBoolean(
              AppPreference.profileApprove,
              value: false,
            );
            Navigation.replaceAll(Routes.accountDeActiveScreen);
          }
        }

        final bool currentRideUsable = _isUsableCurrentRide(data);
        final currentRide = currentRideUsable ? data.currentRide : null;
        final String profileCurrentBookingId =
            (data.data?.currentBookingId ?? '').trim();
        final String responseRideId =
            (data.currentRide?.booking?.id ?? data.currentRide?.bookingId ?? '')
                .toString()
                .trim();

        if (!currentRideUsable && data.currentRide != null) {
          final bool responseConflictsWithCurrent =
              profileCurrentBookingId.isNotEmpty &&
              responseRideId.isNotEmpty &&
              responseRideId != profileCurrentBookingId;
          DriverFlowDebug.send(
            responseConflictsWithCurrent
                ? 'profile_ride_conflict_ignored'
                : 'stale_profile_ride_ignored',
            bookingId: responseRideId,
            data: <String, dynamic>{
              'status': data.currentRide?.booking?.status ?? '',
              'profile_current_booking_id': profileCurrentBookingId,
              'updated_at': data.currentRide?.booking?.updatedAt ?? '',
              'conflict': responseConflictsWithCurrent,
            },
          );

          // A backend néha a current_booking_id mellett még az előző, már
          // lezárt currentRide objektumot adja. Ilyenkor az új aktív azonosítót
          // soha nem törölhetjük a régi objektum miatt.
          if (!responseConflictsWithCurrent &&
              profileCurrentBookingId.isEmpty) {
            userModel.update((value) => value?.currentBookingId = '');
            userModel.refresh();
          }
        }

        if (currentRide == null &&
            profileCurrentBookingId.isEmpty &&
            Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          homeController.clearTerminalRideState(
            reason: data.currentRide == null
                ? 'profile_has_no_current_ride'
                : 'profile_stale_current_ride',
            bookingId: responseRideId,
          );
        } else if (currentRide == null &&
            profileCurrentBookingId.isNotEmpty) {
          DriverFlowDebug.send(
            'profile_current_booking_preserved_without_matching_ride',
            bookingId: profileCurrentBookingId,
            data: <String, dynamic>{
              'response_ride_id': responseRideId,
              'response_ride_status': data.currentRide?.booking?.status ?? '',
            },
          );
        }

        if (rideRedirect && currentRide != null) {
          try {
            final homeController = Get.find<HomeController>();
            final datashow = currentRide.booking;
            rideDataModel.value = currentRide;

            homeController.isDrawPoliLine.value = false;

            if (currentRide.booking?.status == "accepted") {

              homeController.statusData(
                statusNo: 1,
                bookingId: datashow?.id ?? "",
                data: data.completeTrip,
                profileCome: true,
              );
            } else if (currentRide.booking?.status == "arrived") {
              Navigation.pushNamed(Routes.mapNavigationScreen);

              homeController.statusData(
                statusNo: 2,
                bookingId: datashow?.id ?? "",
                data: data.completeTrip,
                profileCome: true,
              );
            } else if (currentRide.booking?.status == "started") {
              Navigation.pushNamed(Routes.mapNavigationScreen);

              homeController.statusData(
                statusNo: 3,
                bookingId: datashow?.id ?? "",
                data: data.completeTrip,
                profileCome: true,
              );
            } else if (currentRide.booking?.status == "completed") {
              Constants.transactionId.value = data.transsactionId ?? "";
              homeController.statusData(
                statusNo: 4,
                bookingId: datashow?.id ?? "",
                data: data.completeTrip,
                redirectProfile: true,
                profileCome: true,
              );
            }
          } catch (e, st) {
            print("ERROR ON REDIRECT ::$e, $st");
          }
        }
      },
    );

    handleLoading(false);
  }

  Future<String?> selectDate(DateTime? current) async {
    DateTime now = DateTime.now();
    DateTime? value = await Utils().selectDate(
      lastDate: DateTime(now.year - 18, now.month, now.day - 1),
      firstDate: current,
    );

    if (value != null) {
      return Utils().formatDate(value);
    } else {
      return null;
    }
  }

  void updateOnlineTime(String time) {
    final model = userModel.value;

    var static = model?.statistics;

    userModel.value = model?.copyWith(
      statistics: static?.copyWith(totalTimeOnline: time),
    );
  }

  Future<Map> updateProfile({
    required String name,
    required String dob,
    required String email,
    required String imagePath,
  }) async {
    Map res = {};
    await processApi(
      () => AccountService.updateProfile(
        name: name,
        dob: dob,
        email: email,
        imagePath: imagePath,
      ),
      result: (data) {
        res = data;

        userModel.value = userModel.value?.copyWith(
          email: email,
          name: name,
          dateOfBirth: dob,
          profilePhoto: data['driver']['profile_photo'],
        );

        userModel.refresh();
      },
      loading: handleLoading,
    );

    return res;
  }

  String? placeApi = Platform.isAndroid
      ? dotenv.env['GOOGLE_MAPS_API_KEY_Android']
      : dotenv.env['GOOGLE_MAPS_API_KEY_Ios'];

  RxBool searchLoading = false.obs;
  RxList<Prediction> searchList = <Prediction>[].obs;

  Future<void> searchPlace(String value) async {
    try {
      searchLoading(true);

      String url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$value&components=country:HU&";

      if (LocationService().currentUserLatLg.value != null) {
        url +=
            "location=${LocationService().currentUserLatLg.value?.latitude},${LocationService().currentUserLatLg.value?.longitude}&radius=25000&";
      }
      url +=
          "components=country:${LocationService().country.isEmpty ? 'IN' : LocationService().country}&key=$placeApi";

      var result = await http.post(Uri.parse(url));

      if (result.statusCode == 200) {
        AddressPlaceModel model = AddressPlaceModel.fromJson(
          jsonDecode(result.body),
        );

        searchList.value = model.predictions ?? [];
      }
    } catch (e, st) {
      LogUtils.printError("Error;$e , $st");
    } finally {
      searchLoading(false);
    }
  }

  RxBool tapLoading = false.obs;

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    tapLoading(true);
    try {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/details/json"
        "?place_id=$placeId"
        "&fields=geometry,formatted_address,name"
        "&key=$placeApi",
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {

          return data['result'];
        } else {
          throw Exception("Helyadat-hiba: ${data['status']}");
        }
      } else {
        throw Exception("Nem sikerült betölteni a hely részleteit.");
      }
    } catch (e, st) {
      LogUtils.printError(" get lat lng error ;;$e , $st");
      rethrow;
    } finally {
      tapLoading(false);
    }
  }

  Timer? debounce;

  Future<Map> userAccountDelete() async {
    Map res = {};
    await processApi(
      () => AccountService.accountDelete(),
      result: (data) {
        res = data;
      },
      loading: handleLoading,
    );
    return res;
  }

  Future<Map> userAccountLogout() async {
    Map res = {};
    await processApi(
      () => AccountService.accountLogout(),
      result: (data) {
        res = data;
      },
      loading: handleLoading,
    );
    return res;
  }


  RxList<NotificationList> notificationList = RxList<NotificationList>();

  int notificationPage = 1;
  bool isMoreNotiDataAvailable = true;
  RxBool notiPaginationLoading = false.obs;
  RxBool notificationLoading = false.obs;

  Future<void> getNotificaionList({bool isFirstTime = true}) async {
    if (isFirstTime == false && notiPaginationLoading.value) {
      return;
    }
    if (isFirstTime) {
      if (notificationList.isEmpty) {
        notificationLoading(true);
      }
      isMoreNotiDataAvailable = true;
      notificationPage = 1;
    }
    await processApi(
      () => AccountService.getNotificationList(page: notificationPage),
      result: (data) {
        print(">>>>${data.data?.notifications?.length}");
        if (isFirstTime) {
          notificationList.value = data.data?.notifications ?? [];
        } else {
          notificationList.addAll(data.data?.notifications ?? []);
        }

        if ((data.data?.notifications ?? []).length != 10) {
          isMoreNotiDataAvailable = false;
        }
        notificationPage++;
      },
    );
    notificationLoading(false);
    notiPaginationLoading(false);
  }

  Rxn<PerformerDataModel> performerModel = Rxn<PerformerDataModel>();
  RxBool performanceLoading = false.obs;

  Future<void> getPerformanceData() async {
    performanceLoading(true);

    await processApi(
      () => AccountService.getPerformancedata(),
      result: (data) {
        performerModel.value = data;
      },
    );
    performanceLoading(false);
  }

  RxList<LocationList> locationList = RxList<LocationList>();

  Future<void> addLocation({
    required String title,
    required String address,
    required LatLng latLang,
    required String name,
  }) async {
    await processApi(
      () => AccountService.addLocationData(
        title: title,
        address: address,
        latLang: latLang,
        name: name,
      ),
      result: (data) {
        locationList.add(
          LocationList(
            address: data['data']['address'],
            id: data['data']['id'],
            name: data['data']['name'],
            latitude: data['data']['latitude'],
            longitude: data['data']['longitude'],
            type: data['data']['type'],
            isDefault: data['data']['is_default'],
          ),
        );
        Navigation.popupUtil(Routes.saveLocationScreen);
        AppSnackBar.showErrorSnackBar(message: "A hely mentése sikerült.");
      },
      loading: handleLoading,
    );
  }

  RxBool locationLoading = false.obs;

  Future<void> getLocationList() async {
    if (locationList.isEmpty) {
      locationLoading(true);
    }
    await processApi(
      () => AccountService.getLocationList(),
      result: (data) {
        locationList.value = data.data ?? [];
      },
    );
    locationLoading(false);
  }

  Rxn<CashCollectedModel> cashPoint = Rxn<CashCollectedModel>();
  RxBool cashPointLoading = false.obs;

  Future<void> getCashPoint({bool isRefresh = false}) async {
    if (cashPoint.value == null && isRefresh == false) {
      cashPointLoading(true);
    } else {
      cashPointLoading(true);
    }

    await processApi(
      () => AccountService.getCashCollectionPoint(),
      result: (data) {
        cashPoint.value = data;
      },
    );
    cashPointLoading(false);
  }

  Future<bool> licenplateUpdate({required String licence}) async {
    bool res = false;
    await processApi(
      () => AccountService.licenceUpdate(licence: licence),
      result: (data) {
        res = true;
      },
      loading: handleLoading,
    );

    return res;
  }

  RxMap<String, XFile> userDoc = <String, XFile>{}.obs;

  Future<void> uploadDoc({
    required List<String> imageList,
    required List<String> fileNameList,
  }) async {
    try {
      handleLoading(true);

      await processApi(
        () => AuthService.registerThird(
          imageList: imageList,
          make: "",
          model: "",
          year: "",
          imageFileName: fileNameList,
        ),
        result: (data) async {
          log("DATA:::$data");
          await getUserData();
          userDoc.clear();
        },
      );
    } catch (e) {
    } finally {
      handleLoading(false);
    }
  }
}
