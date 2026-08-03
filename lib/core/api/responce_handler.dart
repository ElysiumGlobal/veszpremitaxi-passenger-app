import 'dart:convert';

import 'package:http/http.dart' as http;

import 'exception/app_exception.dart';

class ResponseHandler {
  static Future<void> checkResponseError(
    http.Response response, {
    bool showException = true,
    String? errorMessageValue,
  }) async {
    switch (response.statusCode) {
      case 200:
        return;
      case 201:
        return;
      case 204:
        return;
      case 400:
        var exception = AppException(
          message: jsonDecode(response.body)['message'],
          errorCode: 400,
        );
        if (showException) exception.show();
        throw exception;
      case 401:
        var result = jsonDecode(response.body);
        var exception = AppException(
          message:
              result['message'] ??
              (errorMessageValue) ??
              "Valami hiba történt.",
          errorCode: 401,
        );
        if (showException) exception.show();
        throw exception;
      case 500:
        var result;
        if (!response.body.contains("<html lang")) {
          result = jsonDecode(response.body);
        }
        var exception = AppException(
          message: result['message'] ?? "Valami hiba történt.",
          errorCode: 500,
        );

        if (showException) exception.show();
        throw exception;
      case 406:
        var result = jsonDecode(response.body);
        throw AppException(
          message: result['message'] ?? "Valami hiba történt.",
          errorCode: 406,
        );
      case 402:
        var result = jsonDecode(response.body);
        throw AppException(
          message: result['message'] ?? "Valami hiba történt.",
          errorCode: 402,
        );
      case 409:
        var result = jsonDecode(response.body);
        throw AppException(
          message: result['message'] ?? "Valami hiba történt.",
          errorCode: 409,
        );
      default:
        var result = jsonDecode(response.body);

        var exception = AppException(
          message: result['message'] ?? "Valami hiba történt.",
          errorCode: response.statusCode,
        );
        if (showException) exception.show();
        throw exception;
    }
  }
}
