import "dart:convert";
import "dart:developer";

import "package:e_taxi/utils/log_utils.dart";
import "package:http/http.dart" as http;
import "package:http_interceptor/http/intercepted_client.dart";

import "../../utils/api_constants.dart";
import "../../utils/app_preferences.dart";
import "logger_interceptor.dart";

Future<Map<String, String>> headers() async {
  final Map<String, String> headers = <String, String>{};
  headers["accept"] = "*/*";
  headers["Content-Type"] = "application/json";
  if ((AppPreference.getString(AppPreference.userToken)).isNotEmpty) {
    headers["Authorization"] =
        "Bearer ${AppPreference.getString(AppPreference.userToken)}";
  }

  return headers;
}

class Api {
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
    Map<String, dynamic>? bodyData = const <String, dynamic>{},
    Map<String, String>? header,
  }) async {
    LogUtils.showLogs(message: "POST $url");
    final response = await dio.post(
      getUrl(url, queryParameters: queryData),
      body: jsonEncode(bodyData),
      headers: header ?? await headers(),
    );
    return response;
  }

  Future<dynamic> sendMultipartRequestPost1(
    String url, {
    Map<String, String>? queryData,
    Map<String, String>? bodyData,

    List<String>? profileImage,
    required List<String> imageName,
  }) async {
    var client = http.Client();

    LogUtils.printWhite("BODY::$bodyData");
    try {
      var request = http.MultipartRequest(
        'POST',
        getUrl(url, queryParameters: queryData),
      );
      request.headers.addAll(await headers());
      try {
        if ((profileImage?.isNotEmpty ?? false)) {
          for (int i = 0; i < imageName.length; i++) {
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
      http.StreamedResponse response = await request.send();
      String jsonDataString = await response.stream.bytesToString();
      client.close();
      final jsonData = jsonDecode(jsonDataString);
      LogUtils.printSuccess(
        "API RESPONSE~MULTIPART~~~~~~${response.statusCode}_____$jsonData",
      );

      return jsonData;
    } catch (exception) {
      LogUtils.printError("ERROR:::$exception");
      client.close();
    }
  }

  Future<http.Response> delete(
    String url, {
    Map<String, dynamic>? queryData,
    Map<String, dynamic>? bodyData = const <String, dynamic>{},
    Map<String, String>? header,
  }) async {
    final response = await dio.delete(
      getUrl(url, queryParameters: queryData),
      body: jsonEncode(bodyData),
      headers: header ?? await headers(),
    );
    return response;
  }

  Future<http.Response> get(
    String url, {
    Map<String, dynamic>? queryData,
    Map<String, String>? getHeaders,
  }) async {
    LogUtils.showLogs(message: "GET $url");
    final response = await dio.get(
      getUrl(url, queryParameters: queryData),
      headers: getHeaders ?? await headers(),
    );

    return response;
  }
}

Uri getUrl(String endpoint, {Map<String, dynamic>? queryParameters}) {
  String url = "${ApiConstants.baseUrl}$endpoint";
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
  LogUtils.showLogs(message: Uri.parse(url).toString());
  return Uri.parse(url);
}

Uri parseUrl(String url) {
  LogUtils.showLogs(message: Uri.parse(url).toString());
  return Uri.parse(url);
}
