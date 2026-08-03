import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingController extends GetxController {
  var pageIndex = 0.obs;
  final pageController = PageController(initialPage: 0);

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
