import 'dart:convert';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/core/api/responce_handler.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:e_taxi/utils/log_utils.dart';

import '../model/support_chat_model.dart';
import '../model/trip_details_model.dart';

class TripService {
  static Future<TripDetailsModel> getTripList(int page) async {
    try {
      final response = await Api().get("${ApiConstants.getTripList}$page");
      await ResponseHandler.checkResponseError(response);
      return TripDetailsModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("Get Trip LIST ERROR :$e, $st");
      rethrow;
    }
  }

  static Future<SupportChatModel> getSupportChatHistory({
    required String bookingId,
  }) async {
    try {
      final response = await Api().get(
        "${ApiConstants.supportChatHistory}$bookingId",
      );
      await ResponseHandler.checkResponseError(response);
      return SupportChatModel.fromJson(jsonDecode(response.body));
    } catch (e, st) {
      LogUtils.printError("UPPORT CHAT ERROR $e, $st");
      rethrow;
    }
  }

  static Future<ChatModel> sendSupportChatMessage({
    required String bookingId,
    required int userId,
    required String message,
    required String subject,
  }) async {
    try {
      final channel = 'private-support.booking.$bookingId';
      final response = await Api().post(
        ApiConstants.sendSupportChatMessage,
        bodyData: {
          'event': 'client-send-message',
          'data': {
            'message': message,
            'message_type': 'text',
            'subject': subject,
            'priority': 'high',
            'metadata': <String, dynamic>{},
          },
          'channel': channel,
          'user_id': userId,
        },
      );
      await ResponseHandler.checkResponseError(response);

      final decoded = jsonDecode(response.body);
      final data = decoded is Map ? decoded['data'] : null;
      final supportChat = data is Map ? data['support_chat'] : null;
      if (supportChat is! Map) {
        throw const FormatException('Missing support_chat response data');
      }
      return ChatModel.fromJson(Map<String, dynamic>.from(supportChat));
    } catch (e, st) {
      LogUtils.printError('SUPPORT CHAT SEND ERROR $e, $st');
      rethrow;
    }
  }

  static Future refundRequest({
    required String bookingId,
    required String reason,
    required String des,
  }) async {
    try {
      final response = await Api().post(
        ApiConstants.refundRequest,
        bodyData: {
          "booking_id": bookingId,
          "reason": reason,
          "description": des,
        },
      );
      await ResponseHandler.checkResponseError(response);
      return jsonDecode(response.body);
    } catch (e, st) {
      LogUtils.printError("refund request   ERROR $e, $st");
      rethrow;
    }
  }
}
