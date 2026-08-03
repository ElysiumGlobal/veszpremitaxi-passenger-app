import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'exception/app_exception.dart';

class ResponseHandler {
  static Future<void> checkResponseError(
    http.Response response, {
    bool showException = true,
    String? errorMessageValue,
    String? apiTag,
  }) async {
    switch (response.statusCode) {
      case 200:
        return;
      case 201:
        return;
      case 204:
        return;
      case 400:
        log('error :${jsonDecode(response.body)}');
        var exception = AppException(
          message:
              (jsonDecode(response.body)['message'] ?? "Something went wrong..!"),
          errorCode: 400,
        );
        if (showException) exception.show();
        throw exception;
      case 401:
        var exception = AppException(
          message:
              (jsonDecode(response.body)['message'] ??
              errorMessageValue ??
              "Something went wrong..!"),
          errorCode: 401,
        );
        if (showException) exception.show();
        throw exception;
      case 500:
        log('error :${jsonDecode(response.body)}');
        var exception = AppException(
          message:
              (jsonDecode(response.body)['message'] ?? "Something went wrong..!"),
          errorCode: 500,
        );
        if (showException) exception.show();
        throw exception;
      case 406:
        throw AppException(
          message:
              (jsonDecode(response.body)['message'] ?? "Something went wrong..!"),
          errorCode: 406,
        );
      case 402:
        throw AppException(
          message:
              (jsonDecode(response.body)['message'] ?? "Something went wrong..!"),
          errorCode: 402,
        );
      case 409:
        var exception = AppException(
          message:
              (jsonDecode(response.body)['message'] ?? "Something went wrong..!"),
          errorCode: 409,
        );
        if (showException) exception.show();
        throw exception;

      default:
        final tag = apiTag ?? 'unknown API';
        final bodyPreview = response.body.length > 200
            ? '${response.body.substring(0, 200)}...'
            : response.body;
        log('[ERROR_TRACE] ResponseHandler.checkResponseError');
        log('[ERROR_TRACE] API: $tag');
        log('[ERROR_TRACE] Status: ${response.statusCode}');
        log('[ERROR_TRACE] Body preview: $bodyPreview');

        String message = "Something went wrong..!";
        final trimmedBody = response.body.trimLeft();
        final isHtml = trimmedBody.startsWith('<!DOCTYPE') ||
            trimmedBody.startsWith('<html');
        if (isHtml) {
          message =
              'Server returned HTML instead of JSON (status ${response.statusCode}). Backend may be down or restarting.';
          log('[ERROR_TRACE] Parse skipped — response is HTML, not JSON');
        } else {
          try {
            final decoded = jsonDecode(response.body);
            if (decoded is Map && decoded['message'] != null) {
              message = decoded['message'].toString();
            }
          } catch (e) {
            log('[ERROR_TRACE] jsonDecode failed in ResponseHandler: $e');
            message =
                'Invalid server response (status ${response.statusCode})';
          }
        }

        var exception = AppException(
          message: message,
          errorCode: response.statusCode,
        );
        if (showException) exception.show();
        throw exception;
    }
  }
}
