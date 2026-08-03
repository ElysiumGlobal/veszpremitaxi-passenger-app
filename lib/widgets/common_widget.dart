import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CustomWidget {
  static Future<XFile?> takeImage(ImageSource source) async {
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
    );
    return file;
  }

  static Widget iconChange({required Widget child}) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scaleByVector3(
          Vector3(
            Get.locale == Locale('ar', 'AE') ? -1.0 : 1.0, // x-axis
            1.0, // y-axis
            1.0, // z-axis
          ),
        ),
      child: child,
    );
  }
}
