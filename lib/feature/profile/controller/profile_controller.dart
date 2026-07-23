import 'dart:convert';
import 'dart:developer';

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

        if (isRedirect &&
            data.currentBooking != null &&
            (data.isCash ?? 0) == 0) {
          try {
            riderBookingModel.value = NewRideModel.fromJson({
              "data": jsonEncode(data.currentBooking?.toJson()),
            });
            log("PRofile::${data.currentBooking?.toJson()}");
            AppConstant().bookingId =
                riderBookingModel.value?.data?.booking?.id ?? "";
            persistBookingFareFromModel(riderBookingModel.value?.data);

            await Future.delayed(Duration(seconds: 1));
            Get.find<HomeController>().socketData(isFirstTime: true);
          } catch (e) {
            LogUtils.printError("ASdasdsadasdd:::$e");
          }
        }
      },
    );
    isCall = false;
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
