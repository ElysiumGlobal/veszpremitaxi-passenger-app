import 'dart:convert';
import 'dart:developer';

import 'package:e_taxi/core/debug/passenger_flow_debug.dart';
import 'package:e_taxi/feature/profile/model/emergency_model.dart';
import 'package:e_taxi/feature/profile/model/user_model.dart';
import 'package:e_taxi/feature/profile/service/profile_service.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:get/get.dart';

import '../../../utils/common_api_caller.dart';
import '../../../utils/constants.dart';
import '../../../utils/log_utils.dart';
import '../../home/controller/home_controller.dart';
import '../../home/model/get_socket_model.dart';
import '../model/notification_model.dart';

class ProfileController extends GetxController
    with LoadingMixin, LoadingApiMixin {
  Rxn<UserModel> userModel = Rxn<UserModel>();

  bool isCall = false;

  Future<void> getUserData({bool isRedirect = false}) async {
    if (isCall) {
      return;
    }
    isCall = true;
    await processApi(
      () => ProfileService.getUserProfile(),
      result: (data) async {
        userModel.value = data.data;

        final currentBooking = data.currentBooking;
        final status = (currentBooking?.booking?.status ??
                currentBooking?.status ??
                '')
            .toLowerCase()
            .trim();
        final bookingId =
            '${currentBooking?.booking?.id ?? currentBooking?.bookingId ?? ''}'
                .trim();
        final serverCurrentBookingId =
            (data.data?.currentBookingId ?? '').trim();
        final String updatedAt =
            (currentBooking?.booking?.updatedAt ?? '').trim();
        final DateTime? parsedUpdatedAt = DateTime.tryParse(updatedAt);
        final Duration? bookingAge = parsedUpdatedAt == null
            ? null
            : DateTime.now().difference(parsedUpdatedAt.toLocal()).abs();
        const activeStatuses = <String>{
          'searching',
          'accepted',
          'arrived',
          'started',
        };
        // A backend jelenleg több válaszban üresen hagyja a
        // data.current_booking_id mezőt, miközben a current_booking objektum
        // friss és érvényes. Az üres segédmező önmagában nem teheti semmissé
        // a tényleges booking objektumot.
        final bool bookingIdIsAuthoritative = bookingId.isNotEmpty &&
            (serverCurrentBookingId.isEmpty ||
                bookingId == serverCurrentBookingId);
        final bool bookingTooOld = bookingAge != null &&
            ((status == 'searching' && bookingAge > const Duration(minutes: 30)) ||
                ((status == 'accepted' || status == 'arrived') &&
                    bookingAge > const Duration(minutes: 90)) ||
                (status == 'started' &&
                    bookingAge > const Duration(hours: 12)));

        PassengerFlowDebug.send(
          'passenger_profile_loaded',
          bookingId: bookingId,
          data: <String, dynamic>{
            'redirect_requested': isRedirect,
            'current_booking_present': currentBooking != null,
            'status': status,
            'is_cash': data.isCash ?? 0,
            'server_current_booking_id': serverCurrentBookingId,
            'booking_id_authoritative': bookingIdIsAuthoritative,
            'booking_too_old': bookingTooOld,
            'updated_at': updatedAt,
          },
        );

        if (currentBooking == null ||
            !bookingIdIsAuthoritative ||
            bookingTooOld) {
          _clearLocalBookingState(
            reason: currentBooking == null
                ? 'profile_has_no_current_booking'
                : (!bookingIdIsAuthoritative
                    ? 'profile_current_booking_id_mismatch'
                    : 'profile_current_booking_too_old'),
            bookingId: bookingId,
            status: status,
          );
          return;
        }

        if (!activeStatuses.contains(status)) {
          _clearLocalBookingState(
            reason: 'profile_terminal_or_unknown_status',
            bookingId: bookingId,
            status: status,
          );
          return;
        }

        if (isRedirect) {
          try {
            riderBookingModel.value = NewRideModel.fromJson({
              'data': jsonEncode(currentBooking.toJson()),
            });
            log('Profile current booking restored: $bookingId / $status');
            AppConstant().bookingId = bookingId;
            persistBookingFareFromModel(riderBookingModel.value?.data);

            PassengerFlowDebug.send(
              'active_booking_restored',
              bookingId: bookingId,
              data: <String, dynamic>{'status': status},
            );

            await Future<void>.delayed(const Duration(milliseconds: 350));
            Get.find<HomeController>().socketData(isFirstTime: true);
          } catch (error, stack) {
            LogUtils.printError('ACTIVE BOOKING RESTORE ERROR: $error, $stack');
            PassengerFlowDebug.send(
              'active_booking_restore_error',
              bookingId: bookingId,
              data: <String, dynamic>{'status': status, 'error': '$error'},
            );
          }
        }
      },
    );
    isCall = false;
  }


  void _clearLocalBookingState({
    required String reason,
    String bookingId = '',
    String status = '',
  }) {
    final staleBookingId = bookingId.isNotEmpty
        ? bookingId
        : (AppConstant().bookingId.isNotEmpty
            ? AppConstant().bookingId
            : '${riderBookingModel.value?.data?.booking?.id ?? ''}');

    AppConstant().bookingId = '';
    clearSavedBookingFare();
    riderBookingModel.value = null;

    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      homeController.tripType.value = 0;
      homeController.isDriverCome.value = false;
      homeController.changePolyLine = false;
    }

    PassengerFlowDebug.send(
      'stale_booking_cleared',
      bookingId: staleBookingId,
      data: <String, dynamic>{
        'reason': reason,
        'status': status,
      },
    );
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String address,
    String imagePath = "",
  }) async {
    Map<String, String> map = {
      "name": name,
      "email": email,
      "address": address,
    };

    processApi(
      () => ProfileService.updateProfile(
        body: map,
        imageList: imagePath.isEmpty ? [] : [imagePath],
        imageName: ['profile_photo'],
      ),
      result: (data) {
        userModel.update((data1) {
          data1?.email = data['user']['email'];
          data1?.name = data['user']['name'];
          data1?.address = data['user']['address'];
        });
        if ((data['user']['profile_photo']).toString().isNotEmpty) {
          userModel.update((value) {
            value?.profilePhoto = data['user']['profile_photo'];
          });
        }
        handleLoading(false);
        Get.back();
        AppSnackBar.showErrorSnackBar(message: "Profile Update");
        userModel.refresh();
      },
      loading: handleLoading,
    );
  }

  RxList<Contact> contactList = <Contact>[].obs;

  Future<void> getEmergencyContact() async {
    if (contactList.isNotEmpty) {
      return;
    }
    await processApi(
      () => ProfileService.getEmergency(),
      result: (data) {
        contactList.value = data.data?.contacts ?? [];
      },
    );
  }

  Future<Map> addEmergencyContact({
    required String name,
    required String phone,
  }) async {
    Map res = {};
    await processApi(
      () => ProfileService.addEmergency(name: name, phone: phone),
      result: (data) {
        res = data;

        var model = data['data']['contact'];
        contactList.add(
          Contact(
            id: model['id'],
            name: model['name'],
            mobileNumber: model['mobile_number'],
            formattedMobile: model['formatted_mobile'],
            isPrimary: model['is_primary'],
            createdAt: model['created_at'],
            updatedAt: model['updated_at'],
          ),
        );
        contactList.refresh();
      },
      loading: handleLoading,
    );

    return res;
  }

  Future<Map> deleteEmergency(int id, int index) async {
    Map res = {};
    await processApi(
      () => ProfileService.deleteEmergency(id),
      result: (data) {
        res = data;
        contactList.removeAt(index);
      },
      loading: handleLoading,
    );
    return res;
  }

  RxList<Notification> notificationList = RxList<Notification>();

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
      () => ProfileService.getNotificationList(page: notificationPage),
      result: (data) {
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

  Future<Map> deleteAccount() async {
    Map res = {};

    await processApi(
      () => ProfileService.deleteAccount(),
      result: (data) {
        res = data;
      },
      loading: handleLoading,
    );
    return res;
  }

  Future<Map> logOutAccount() async {
    Map res = {};

    await processApi(
      () => ProfileService.logOutAccount(),
      result: (data) {
        res = data;
      },
      loading: handleLoading,
    );
    return res;
  }
}
