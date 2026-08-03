import 'dart:convert';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/core/api/responce_handler.dart';
import 'package:e_taxi/core/debug/driver_flow_debug.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../auth/model/ride_type_list_model.dart';

Map<String, dynamic> _debugResponseSummary(String body) {
  try {
    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map) {
      return <String, dynamic>{'decoded_type': decoded.runtimeType.toString()};
    }

    final dynamic data = decoded['data'];
    final dynamic booking = data is Map
        ? (data['booking'] ?? data)
        : decoded['booking'];
    final dynamic rawErrors = decoded['errors'];
    final Map<String, dynamic> errors = <String, dynamic>{};
    if (rawErrors is Map) {
      for (final dynamic key in rawErrors.keys) {
        final dynamic value = rawErrors[key];
        errors[key.toString()] = value is Iterable
            ? value.map((dynamic item) => item.toString()).toList()
            : value?.toString() ?? '';
      }
    }

    return <String, dynamic>{
      'success': decoded['success'],
      'message': decoded['message']?.toString() ?? '',
      'errors': errors,
      'top_level_keys': decoded.keys.map((dynamic key) => key.toString()).toList(),
      'booking_id': booking is Map
          ? (booking['id'] ?? booking['booking_id'] ?? '').toString()
          : '',
      'booking_status': booking is Map
          ? (booking['status'] ?? '').toString()
          : '',
      'driver_id': booking is Map
          ? (booking['driver_id'] ?? '').toString()
          : '',
    };
  } catch (_) {
    return <String, dynamic>{'decoded': false, 'body_length': body.length};
  }
}

class HomeServices {
  static Future userOnlineOffline(LatLng latLng, int online) async {
    try {
      final response = await Api().post(
        ApiConstants.onlineOffline,
        bodyData: {
          "latitude": latLng.latitude,
          "longitude": latLng.longitude,
          "online": online,
        },
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("ONLINE OFFLINE ERROR ---$e, $st");
      rethrow;
    }
  }

  static Future updateDriverLocation(LatLng latLng) async {
    try {
      final response = await Api().post(
        ApiConstants.driverLocationUpdate,
        bodyData: {"latitude": latLng.latitude, "longitude": latLng.longitude},
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("Driver Location Update Error ---$e, $st");

      rethrow;
    }
  }


  static Future pendingRideOffer({
    required bool onlineHeartbeat,
    LatLng? currentLocation,
  }) async {
    try {
      final Map<String, dynamic> query = <String, dynamic>{
        'online': onlineHeartbeat ? 1 : 0,
      };
      if (currentLocation != null) {
        query['latitude'] = currentLocation.latitude;
        query['longitude'] = currentLocation.longitude;
      }
      final response = await Api().get(
        ApiConstants.pendingRideOffer,
        queryData: query,
      );
      DriverFlowDebug.send(
        'pending_offer_http_response',
        data: <String, dynamic>{
          'http_status': response.statusCode,
          'body_length': response.body.length,
          'response_summary': _debugResponseSummary(response.body),
        },
      );
      await ResponseHandler.checkResponseError(
        response,
        showException: false,
      );
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("PENDING RIDE OFFER ERROR ---$e, $st");
      rethrow;
    }
  }

  static Future updateBookingRideStatus({
    required double totalDistance,
    required String bookingId,
    required int status,
    required String address,
    required LatLng latLng,
    required String otp,
    required String cancelReason,
    int? etaMinutes,
  }) async {

    try {
      final Map<String, dynamic> body = <String, dynamic>{
        "status": status,
        "dropoff_latitude": latLng.latitude,
        "dropoff_longitude": latLng.longitude,
        "dropoff_address": address,
        "reason": cancelReason,
        "total_distance": totalDistance * (0.001),
      };
      if (otp.trim().isNotEmpty) {
        body["otp"] = otp.trim();
      }
      if (status == 1 && etaMinutes != null) {
        body["eta_minutes"] = etaMinutes;
      }

      final response = await Api().post(
        "${ApiConstants.updateBookingRideStatus}$bookingId/update-status",
        bodyData: body,
      );
      DriverFlowDebug.send(
        'status_http_response',
        bookingId: bookingId,
        data: <String, dynamic>{
          'status_no': status,
          'http_status': response.statusCode,
          'body_length': response.body.length,
          'response_summary': _debugResponseSummary(response.body),
        },
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      DriverFlowDebug.send(
        'status_http_exception',
        bookingId: bookingId,
        data: <String, dynamic>{
          'status_no': status,
          'error': e.toString(),
          'stack': st.toString(),
        },
      );
      LogUtils.printError("ERROR IN RIDE UPDATE :$e, $st");
      rethrow;
    }
  }

  static Future customerOtpVerify({
    required String otp,
    required String bookingId,
  }) async {
    final digits = otp.replaceAll(RegExp(r'[^0-9]'), '');
    final candidates = <String>[];

    void addCandidate(String value) {
      if (value.isNotEmpty && !candidates.contains(value)) {
        candidates.add(value);
      }
    }

    if (digits.length >= 6) {
      addCandidate(digits.substring(digits.length - 6));
      addCandidate(digits.substring(digits.length - 4));
    } else {
      addCandidate(digits.padLeft(6, '0'));
      addCandidate(digits);
    }

    dynamic lastResponse;
    Object? lastError;
    StackTrace? lastStack;

    for (var index = 0; index < candidates.length; index++) {
      final candidate = candidates[index];
      try {
        DriverFlowDebug.send(
          'otp_verify_requested',
          bookingId: bookingId,
          data: <String, dynamic>{
            'otp_length': candidate.length,
            'attempt': index + 1,
            'candidate_count': candidates.length,
          },
        );
        final response = await Api().post(
          ApiConstants.customerOtpVerify,
          bodyData: {
            'booking_id': bookingId,
            'otp': candidate,
          },
        );
        lastResponse = response;
        final summary = _debugResponseSummary(response.body);
        DriverFlowDebug.send(
          'otp_verify_http_response',
          bookingId: bookingId,
          data: <String, dynamic>{
            'http_status': response.statusCode,
            'body_length': response.body.length,
            'attempt': index + 1,
            'submitted_length': candidate.length,
            'response_summary': summary,
          },
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return jsonDecode(response.body);
        }
      } catch (error, stack) {
        lastError = error;
        lastStack = stack;
      }
    }

    if (lastResponse != null) {
      await ResponseHandler.checkResponseError(
        lastResponse,
        showException: false,
      );
    }

    DriverFlowDebug.send(
      'otp_verify_http_exception',
      bookingId: bookingId,
      data: <String, dynamic>{
        'error': lastError?.toString() ?? 'OTP verification failed',
        'stack': lastStack?.toString() ?? '',
      },
    );
    throw lastError ?? Exception('OTP verification failed');
  }

  static Future confirmCashCollected({
    required String bookingId,
    required double cashAmount,
    required double tipAmount,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.collectCash,
        bodyData: {
          "booking_id": bookingId,
          "cash_amount": cashAmount,
          "tip_amount": tipAmount,
        },
      );
      DriverFlowDebug.send(
        'cash_payment_http_response',
        bookingId: bookingId,
        data: <String, dynamic>{
          'http_status': response.statusCode,
          'body_length': response.body.length,
          'response_summary': _debugResponseSummary(response.body),
        },
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (error, stack) {
      DriverFlowDebug.send(
        'cash_payment_http_exception',
        bookingId: bookingId,
        data: <String, dynamic>{
          'error': error.toString(),
          'stack': stack.toString(),
        },
      );
      rethrow;
    }
  }

  static Future driverReview({
    required int bookingId,
    required double rating,
    required String comment,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.reviewDriver,
        bodyData: {
          "booking_id": bookingId,
          "rating": rating,
          "comment": comment,
        },
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("Driver Review FAILED::$e, $st}");
      rethrow;
    }
  }

  static Future driverAcceptPayment({
    required int paymentId,
    required double amount,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.driverPaymentAccept,
        bodyData: {"payment_method_id": paymentId, "amount": amount},
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("Driver Review FAILED::$e, $st}");
      rethrow;
    }
  }

  static Future reportIssueSubmit({
    required int bookingId,
    required String issueType,
    required String description,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.reportIssue,
        bodyData: {
          "booking_id": bookingId,
          "issue_type": issueType,
          "custom_issue": description,
        },
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("REPORT ISUE ERROR :::$e,$st");
      rethrow;
    }
  }

  static Future driverConfirmCashPayment({
    required String transactionId,
    required String status,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.driverPaymentAccept,
        bodyData: {"transaction_id": transactionId, "status": status},
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
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
}
