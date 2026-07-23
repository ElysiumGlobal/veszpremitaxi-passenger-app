import 'package:get/get.dart';

class Navigation {
  static Future pushNamed(
    String routeName, {
    dynamic arg,
    Map<String, String>? params,
  }) async {
    return await Get.toNamed<dynamic>(
      routeName,
      arguments: arg,
      parameters: params,
    );
  }

  static void popAndPushNamed(
    String routeName, {
    dynamic arg,
    Map<String, String>? params,
  }) {
    Get.offAndToNamed<dynamic>(routeName, arguments: arg, parameters: params);
  }

  static Future<void> replace(String routeName, {dynamic arguments}) async {
    await Get.offNamed<dynamic>(routeName, arguments: arguments);
  }

  static void pop({Map<dynamic, dynamic>? data}) {
    Get.back<dynamic>(result: data);
  }

  static void doublePop() {
    Get
      ..back<dynamic>()
      ..back<dynamic>();
  }

  static void popupUtil(String routeName) {
    Get.until((route) => Get.currentRoute == routeName);
  }

  static void replaceAll(
    String routeName, {
    dynamic arg,
    Map<String, String>? params,
  }) {
    Get.offAllNamed(routeName, arguments: arg, parameters: params);
  }
}
