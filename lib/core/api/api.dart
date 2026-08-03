import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

import '../debug/driver_flow_debug.dart';
import '../../utils/api_constants.dart';
import '../../utils/app_preferences.dart';
import '../../utils/log_utils.dart';
import 'exception/app_exception.dart';
import 'logger_interceptor.dart';

Map<String, String> headers() {
  final Map<String, String> headers = <String, String>{};
  headers["Content-Type"] = "application/json";
  headers["accept"] = "*/*";
  String authorizationToken = AppPreference.getString(AppPreference.userToken);
  if (authorizationToken.isNotEmpty) {
    headers["Authorization"] = "Bearer $authorizationToken";
  }
  return headers;
}

class Api with LoadingMixin {
  static Api? _instance;

  static http.Client get dio =>
      InterceptedClient.build(interceptors: [LoggerInterceptor()]);

  factory Api() {
    if (_instance == null) {
      _instance = Api._();
      return _instance!;
    } else {
      return _instance!;
    }
  }

  Api._();

  Future<http.Response> post(
    String url, {
    Map<String, dynamic>? queryData,
    Map<String, dynamic>? bodyData,
    Map<String, String>? headerData,
    bool checkAuthorization = true,
    String? baseUrl,
    bool showToast = true,
  }) async {
    LogUtils.printAction("post  $bodyData");
    final String bookingId = DriverFlowDebug.bookingIdFrom(
      query: queryData,
      body: bodyData,
    );
    final Stopwatch stopwatch = Stopwatch()..start();
    DriverFlowDebug.apiRequest(
      method: 'POST',
      endpoint: url,
      bookingId: bookingId,
      query: queryData,
      body: bodyData,
    );

    try {
      final http.Response response = await dio
          .post(
            getUrl(url, queryParameters: queryData, baseUrl: baseUrl),
            body: jsonEncode(bodyData),
            headers: headerData ?? headers(),
          )
          .timeout(const Duration(seconds: 60));
      stopwatch.stop();
      DriverFlowDebug.apiResponse(
        method: 'POST',
        endpoint: url,
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBody: response.body,
        bookingId: bookingId,
      );
      return response;
    } on SocketException catch (error) {
      stopwatch.stop();
      DriverFlowDebug.apiError(
        method: 'POST',
        endpoint: url,
        error: error,
        durationMs: stopwatch.elapsedMilliseconds,
        bookingId: bookingId,
      );
      LogUtils.printError("SOCKET ERROR $error");
      handleLoading(false);
      final AppException exception = AppException(
        message: "Nincs megfelelő internetkapcsolat.",
        errorCode: -1,
      );
      if (showToast) exception.show();
      throw exception;
    } on TimeoutException catch (error) {
      stopwatch.stop();
      DriverFlowDebug.apiError(
        method: 'POST',
        endpoint: url,
        error: error,
        durationMs: stopwatch.elapsedMilliseconds,
        bookingId: bookingId,
      );
      handleLoading(false);
      final AppException exception = AppException(
        message: "A kapcsolat időtúllépés miatt megszakadt.",
        errorCode: -2,
      );
      if (showToast) exception.show();
      throw exception;
    } catch (error) {
      stopwatch.stop();
      DriverFlowDebug.apiError(
        method: 'POST',
        endpoint: url,
        error: error,
        durationMs: stopwatch.elapsedMilliseconds,
        bookingId: bookingId,
      );
      if (error is AppException) rethrow;
      throw AppException(message: "Váratlan hiba történt.", errorCode: -3);
    }
  }

  Future<http.Response> get(
    String url, {
    Map<String, dynamic>? queryData,
    Map<String, String>? headerData,
    bool checkAuthorization = true,
    String? baseUrl,
    bool showToast = true,
  }) async {
    log("GET kérés: $url");
    final String bookingId = DriverFlowDebug.bookingIdFrom(query: queryData);
    final Stopwatch stopwatch = Stopwatch()..start();
    DriverFlowDebug.apiRequest(
      method: 'GET',
      endpoint: url,
      bookingId: bookingId,
      query: queryData,
    );

    try {
      final http.Response response = await dio
          .get(
            getUrl(url, queryParameters: queryData, baseUrl: baseUrl),
            headers: headerData ?? headers(),
          )
          .timeout(const Duration(seconds: 60));
      stopwatch.stop();
      DriverFlowDebug.apiResponse(
        method: 'GET',
        endpoint: url,
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBody: response.body,
        bookingId: bookingId,
      );
      return response;
    } on SocketException catch (error) {
      stopwatch.stop();
      DriverFlowDebug.apiError(
        method: 'GET',
        endpoint: url,
        error: error,
        durationMs: stopwatch.elapsedMilliseconds,
        bookingId: bookingId,
      );
      handleLoading(false);
      final AppException exception = AppException(
        message: "Nincs megfelelő internetkapcsolat.",
        errorCode: -1,
      );
      if (showToast) exception.show();
      throw exception;
    } on TimeoutException catch (error) {
      stopwatch.stop();
      DriverFlowDebug.apiError(
        method: 'GET',
        endpoint: url,
        error: error,
        durationMs: stopwatch.elapsedMilliseconds,
        bookingId: bookingId,
      );
      handleLoading(false);
      final AppException exception = AppException(
        message: "A kapcsolat időtúllépés miatt megszakadt.",
        errorCode: -2,
      );
      if (showToast) exception.show();
      throw exception;
    } catch (error) {
      stopwatch.stop();
      DriverFlowDebug.apiError(
        method: 'GET',
        endpoint: url,
        error: error,
        durationMs: stopwatch.elapsedMilliseconds,
        bookingId: bookingId,
      );
      handleLoading(false);
      if (error is AppException) rethrow;
      final AppException exception = AppException(
        message: "Váratlan hiba történt.",
        errorCode: -3,
      );
      if (showToast) exception.show();
      throw exception;
    }
  }

  Future<http.Response> delete(
    String url, {
    Map<String, dynamic>? queryData,
    Map<String, dynamic>? bodyData,
    Map<String, String>? headerData,
    String? baseUrl,
  }) async {
    final String bookingId = DriverFlowDebug.bookingIdFrom(
      query: queryData,
      body: bodyData,
    );
    final Stopwatch stopwatch = Stopwatch()..start();
    DriverFlowDebug.apiRequest(
      method: 'DELETE',
      endpoint: url,
      bookingId: bookingId,
      query: queryData,
      body: bodyData,
    );
    try {
      final http.Response response = await dio.delete(
        getUrl(url, queryParameters: queryData, baseUrl: baseUrl),
        body: jsonEncode(bodyData),
        headers: headerData ?? headers(),
      );
      stopwatch.stop();
      DriverFlowDebug.apiResponse(
        method: 'DELETE',
        endpoint: url,
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
        responseBody: response.body,
        bookingId: bookingId,
      );
      return response;
    } catch (error) {
      stopwatch.stop();
      DriverFlowDebug.apiError(
        method: 'DELETE',
        endpoint: url,
        error: error,
        durationMs: stopwatch.elapsedMilliseconds,
        bookingId: bookingId,
      );
      rethrow;
    }
  }

  Future<dynamic> sendMultipartRequestPost(
    String url, {
    Map<String, String>? queryData,
    Map<String, String>? bodyData,

    String? profileImage,
    required String imageName,
  }) async {
    var client = http.Client();

    print("BODY::$bodyData");
    try {
      var request = http.MultipartRequest(
        'POST',
        getUrl(url, queryParameters: queryData),
      );
      request.headers.addAll(headers());
      try {
        if ((profileImage?.isNotEmpty ?? false)) {
          request.files.addAll([
            if (profileImage != null)
              await http.MultipartFile.fromPath(
                imageName,
                profileImage.isNotEmpty ? profileImage : "",
              ),
          ]);
        }
      } catch (e, st) {
        client.close();
        log("image upload error $e :$st");
      }

      if (bodyData != null) request.fields.addAll(bodyData);
      http.StreamedResponse response = await request.send();
      String jsonDataString = await response.stream.bytesToString();
      client.close();
      final jsonData = jsonDecode(jsonDataString);
      LogUtils.printSuccess(
        "API RESPONSE~MULTIPART~~~~~~${response.statusCode}_____${jsonData}",
      );

      return jsonData;
    } catch (exception) {
      print("ERROR:::$exception");
      client.close();
    }
  }

  Future<dynamic> sendMultipartRequestPost1(
    String url, {
    Map<String, String>? queryData,
    Map<String, String>? bodyData,

    List<String>? profileImage,
    required List<String> imageName,
  }) async {
    var client = http.Client();

    print("::${url}:BODY::$bodyData");
    try {
      var request = http.MultipartRequest(
        'POST',
        getUrl(url, queryParameters: queryData),
      );
      request.headers.addAll(headers());

      try {
        if ((profileImage?.isNotEmpty ?? false)) {
          for (int i = 0; i < imageName.length; i++) {
            debugPrint("NAME :::${imageName[i]}:::${profileImage?[i]}");
            request.files.addAll([
              if (profileImage != null)
                await http.MultipartFile.fromPath(
                  imageName[i],
                  profileImage.isNotEmpty ? profileImage[i] : "",
                ),
            ]);
          }
        }
      } catch (e, st) {
        client.close();
        log("image upload error $e :$st");
      }

      if (bodyData != null) request.fields.addAll(bodyData);
      http.StreamedResponse response = await request.send().timeout(
        Duration(seconds: 130),
      );
      String jsonDataString = await response.stream.bytesToString();
      client.close();
      final jsonData = jsonDecode(jsonDataString);
      LogUtils.printSuccess(
        "API RESPONSE~MULTIPART~~~~~~${response.statusCode}_____${jsonData}",
      );

      return jsonData;
    } catch (exception) {
      print("ERROR:::$exception");
      client.close();
    }
  }

  Future<dynamic> multiPartRequest(
    String url,
    List<String> files, {
    Map<String, String> mapBodyData = const {},
    required String fieldName,
  }) async {
    final multiPartRequest = http.MultipartRequest("POST", getUrl(url));
    if (mapBodyData.isNotEmpty) {
      multiPartRequest.fields.addAll(mapBodyData);
    }
    multiPartRequest.headers.addAll(headers());
    print("BODY DATA:::$mapBodyData:::::${multiPartRequest.headers}");
    try {
      if (files.isNotEmpty) {
        for (int i = 0; i < files.length; i++) {
          multiPartRequest.files.addAll([
            await http.MultipartFile.fromPath(fieldName, files[i]),
          ]);
        }
      }
    } catch (e, st) {
      log("image upload error $e :$st");
    }

    print(
      "object multiPartRequest ${multiPartRequest.fields} --- ${multiPartRequest.files}",
    );
    final request = await multiPartRequest.send();

    var bytes = await request.stream.bytesToString();

    print("STATES CODE:::::${request.statusCode}");
    final jsonData = jsonDecode(bytes);
    print("response $jsonData");
    print("response1 ${request.statusCode}");
    return jsonData;
  }
}

Uri getUrl(
  String endpoint, {
  Map<String, dynamic>? queryParameters,
  String? baseUrl,
}) {
  String url = "${baseUrl ?? ApiConstants.baseUrl}$endpoint";
  if (queryParameters != null && queryParameters.isNotEmpty) {
    url = "$url?";
    for (int i = 0; i < queryParameters.entries.length; i++) {
      final element = queryParameters.entries.elementAt(i);
      url += '${element.key}=${element.value}';
      if (i < queryParameters.entries.length - 1) {
        url += '&';
      }
    }
  }
  log(Uri.parse(url).toString());
  return Uri.parse(url);
}

Uri parseUrl(String url) {
  log(Uri.parse(url).toString());
  return Uri.parse(url);
}
