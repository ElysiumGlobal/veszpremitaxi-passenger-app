import 'dart:convert';
import 'dart:developer';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/core/api/responce_handler.dart';
import 'package:e_taxi/core/debug/passenger_flow_debug.dart';
import 'package:e_taxi/feature/home/model/address_model.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../widgets/app_snackbar.dart';
import '../model/banner_model.dart';
import '../model/create_booking_model.dart';
import '../model/offer_model.dart';
import '../model/ride_type_list_model.dart';
import '../model/user_account_list_model.dart';

class HomeService {
  static Future addAddress({
    required String name,
    required String address,
    required LatLng latLng,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.addAddress,
        bodyData: {
          "name": name,
          "address": address,
          "latitude": latLng.latitude,
          "longitude": latLng.longitude,
        },
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("add Address Error ==>$e, $st");
      rethrow;
    }
  }

  static Future<UserAddressModel> getAddress() async {
    try {
      final res = await Api().get(ApiConstants.getAddress);
      await ResponseHandler.checkResponseError(res);
      return UserAddressModel.fromJson(jsonDecode(res.body));
    } catch (e, st) {
      LogUtils.printError("Get Address Error:::$e, $st");
      rethrow;
    }
  }

  static Future<BookingCreateModel> bookingEstimate({
    required LatLng originLatLng,
    required LatLng destinationLatLng,
    String? rideTypeId,
  }) async {
    const apiTag =
        'POST ${ApiConstants.baseUrl}${ApiConstants.bookingEstimate}';
    try {
      final body = <String, dynamic>{
        "pickup_latitude": originLatLng.latitude,
        "pickup_longitude": originLatLng.longitude,
        "dropoff_latitude": destinationLatLng.latitude,
        "dropoff_longitude": destinationLatLng.longitude,
      };

      if (rideTypeId != null && rideTypeId.trim().isNotEmpty) {
        body['ride_type_id'] = rideTypeId.trim();
      }

      final response = await Api().post(
        ApiConstants.bookingEstimate,
        bodyData: body,
      );
      await ResponseHandler.checkResponseError(
        response,
        showException: false,
        apiTag: apiTag,
      );
      return BookingCreateModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("BOOKING ESTIMATE ERROR ==> $e, $st");
      rethrow;
    }
  }

  static Future<BookingCreateModel> bookingCreate({
    required int bookingContactId,
    required String originAddress,
    required String destinationAddress,
    required LatLng originLatLng,
    required LatLng destinationLatLng,
    required String rideTypeId,
    required String paymentMethod,
  }) async {
    const apiTag = 'POST ${ApiConstants.baseUrl}${ApiConstants.bookingCreate}';
    try {
      log('[ERROR_TRACE] HomeService.bookingCreate → calling $apiTag');
      final response = await Api().post(
        ApiConstants.bookingCreate,
        bodyData: {
          "pickup_latitude": originLatLng.latitude,
          "pickup_longitude": originLatLng.longitude,
          "pickup_address": originAddress,
          "dropoff_latitude": destinationLatLng.latitude,
          "dropoff_longitude": destinationLatLng.longitude,
          "dropoff_address": destinationAddress,
          "booking_contact_id": bookingContactId,
          "ride_type_id": rideTypeId,
          "payment_method": paymentMethod,
        },
      );

      log('[ERROR_TRACE] HomeService.bookingCreate ← status: ${response.statusCode}');
      await ResponseHandler.checkResponseError(
        response,
        showException: false,
        apiTag: apiTag,
      );
      return BookingCreateModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      log('[ERROR_TRACE] HomeService.bookingCreate FAILED at $apiTag');
      LogUtils.printError("BOOKING CREATE ERROR ==> $e, $st");
      rethrow;
    }
  }

  static Future getStripeQrPaymentStatus({required String bookingId}) async {
    try {
      final response = await Api().get(
        "${ApiConstants.stripeQrPayment}/$bookingId/status",
      );
      await ResponseHandler.checkResponseError(
        response,
        showException: false,
      );
      return jsonDecode(response.body);
    } catch (error, stack) {
      PassengerFlowDebug.send(
        'passenger_stripe_qr_status_http_exception',
        bookingId: bookingId,
        data: <String, dynamic>{
          'error': error.toString(),
          'stack': stack.toString(),
        },
      );
      rethrow;
    }
  }

  static Future updatePickUpLocation({
    required String bookingId,
    required String address,
    required LatLng latLng,
  }) async {
    try {
      final response = await Api().post(
        "${ApiConstants.bookingPrefix}$bookingId/update-pickup",
        bodyData: {
          "pickup_latitude": latLng.latitude,
          "pickup_longitude": latLng.longitude,
          "pickup_address": address,
        },
      );

      await ResponseHandler.checkResponseError(response);

      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("Update Pick up Error ; $e, $st");
      rethrow;
    }
  }

  static Future vehicleBook({
    required String bookingId,
    required String vehicleId,
    required String paymentType,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.vehicleBook,
        bodyData: {
          "booking_id": bookingId,
          "ride_type_id": vehicleId,
          "payment_type": paymentType,
        },
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("Book Vehicle Error ; $e, $st");
      rethrow;
    }
  }

  static Future confirmRide(String bookingId) async {
    try {
      final response = await Api().post(
        "${ApiConstants.bookingPrefix}$bookingId/is-conform",
      );
      await ResponseHandler.checkResponseError(response);
      log("LOG CONFIRM RIDE::::::${response.body}");
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("Confirm RIde Error ; $e, $st");

      rethrow;
    }
  }

  static Future cancelRide(String bookingId, String reason) async {
    try {
      final response = await Api().post(
        ApiConstants.cancelRide,
        bodyData: {"booking_id": bookingId, "reason": reason},
      );
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = <String, dynamic>{};
      }
      final String message = decoded is Map
          ? (decoded['message'] ?? '').toString().toLowerCase()
          : '';
      final String bodyLower = response.body.toLowerCase();
      final bool alreadyCancelled = response.statusCode == 400 &&
          (message.contains('already canceled') ||
              message.contains('already cancelled') ||
              message.contains('már törölve') ||
              message.contains('már lemondva'));
      final bool knownPartialBackendCancel = response.statusCode == 500 &&
          bodyLower.contains('is_available') &&
          bodyLower.contains('mass assignment');

      PassengerFlowDebug.send(
        'passenger_cancel_http_response',
        bookingId: bookingId,
        data: <String, dynamic>{
          'http_status': response.statusCode,
          'already_cancelled': alreadyCancelled,
          'known_partial_backend_cancel': knownPartialBackendCancel,
          'message': message,
        },
      );

      if (alreadyCancelled || knownPartialBackendCancel) {
        return <String, dynamic>{
          'success': true,
          'already_cancelled': alreadyCancelled,
          'partial_backend_cleanup': knownPartialBackendCancel,
        };
      }

      await ResponseHandler.checkResponseError(response, showException: false);
      return decoded;
    } catch (e, st) {
      LogUtils.printError("Cancel Ride Error :$e, $st");
      rethrow;
    }
  }

  static Future<OfferModel> getOfferList({
    required int pageNo,
    required String bookingID,
    required String rideType,
  }) async {
    try {
      log("HERE:::");
      final response = await Api().get(
        "${ApiConstants.getOfferList}$pageNo&booking_id=$bookingID&ride_type_id=$rideType",
        getHeaders: {'content-type': 'application/json'},
      );
      log("response::${response.body}");
      await ResponseHandler.checkResponseError(response);
      return OfferModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("Get Code Error :$e, $st");

      rethrow;
    }
  }

  static Future applyCode({
    required String code,
    required int bookingId,
    required String rideTypeId,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.promoCodeApply,
        bodyData: {
          "promo_code": code,
          "booking_id": bookingId,
          "ride_type_id": rideTypeId,
        },
      );
      await ResponseHandler.checkResponseError(response);

      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("Applt Code Error :$e, $st");

      return;
    }
  }

  static Future<BannerModel> getBannerList({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryData = <String, dynamic>{};
      if (latitude != null && longitude != null) {
        queryData['latitude'] = latitude;
        queryData['longitude'] = longitude;
      }

      final response = await Api().get(
        ApiConstants.banner,
        queryData: queryData.isEmpty ? null : queryData,
      );

      await ResponseHandler.checkResponseError(response);

      return BannerModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  static Future removePromoCode(int bookingId) async {
    try {
      final response = await Api().post(
        ApiConstants.removePromoCode,
        bodyData: {"booking_id": bookingId},
      );

      await ResponseHandler.checkResponseError(response);

      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  static Future driverRating({
    required int bookingId,
    required double rating,
    required String comment,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.driverRating,
        bodyData: {
          "booking_id": bookingId,
          "rating": rating,
          "comment": comment,
        },
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map> paymentInt({
    required String bookingId,
    required double amount,
    required String method,
    required bool isSplit,
    required String tip,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.onlinePaymentInt,
        bodyData: {
          "booking_id": bookingId,
          "payment_method": method,
          "amount": amount,
          "currency": AppConstant().currency,
          "is_split": isSplit,
          "tip_amount": tip,
        },
      );

      await ResponseHandler.checkResponseError(response);

      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map> verifyPayment({required String transactionID}) async {
    try {
      final response = await Api().post(
        ApiConstants.verifyPayment,
        bodyData: {"transaction_id": transactionID},
      );

      await ResponseHandler.checkResponseError(response);

      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map> updatePaymentMode({
    required String paymentMode,
    required String bookingId,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.paymentModeUpdate,
        bodyData: {"booking_id": bookingId, "payment_method": paymentMode},
      );

      await ResponseHandler.checkResponseError(response);

      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("PAYMENT MODE UPADTE ERROR :$e, $st");

      rethrow;
    }
  }

  static Future<UserAccountListModel> getUserNameList() async {
    try {
      final response = await Api().get(ApiConstants.forMeGetList);
      await ResponseHandler.checkResponseError(response);
      return UserAccountListModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  static Future addUserName({
    required String name,
    required String phone,
    required String imagePath,
  }) async {
    try {
      final res = await Api().sendMultipartRequestPost1(
        ApiConstants.forMeAdd,
        bodyData: {'name': name, "mobile_number": phone},
        imageName: ['profile_pic'],
        profileImage: imagePath.isEmpty ? [] : [imagePath],
      );

      if (res['success'] == false) {
        AppSnackBar.showErrorSnackBar(message: res['message'], isError: true);
        throw "ERROR::$res";
      }
      return res;
    } catch (e) {
      rethrow;
    }
  }

  static Future<RideTypeListModel> getRideTypeList() async {
    try {
      final response = await Api().get(ApiConstants.rideTypeList);
      await ResponseHandler.checkResponseError(response);
      return RideTypeListModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  // static Future  acceptDemo({required String bookingId,required int isDemo})async{
  //   try{
  //       final response =await Api().post(ApiConstants.demoAccept,bodyData: {
  //         'booking_id':bookingId,
  //         'is_demo': isDemo
  //
  //
  //       });
  //     await ResponseHandler.checkResponseError(response);
  //     return  jsonDecode(response.body);
  //
  //   }catch(e){
  //     rethrow;
  //   }
  // }
}
