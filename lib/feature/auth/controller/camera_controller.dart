import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class CameraImageController extends GetxController {
  RxBool isLoading = false.obs;
  CameraDescription? camera;
  CameraController? cameraController;
  Rx<XFile?> selfieFile = Rx<XFile?>(null);

  List<CameraDescription> cameras = [];

  Future<void> initializeController() async {
    isLoading.value = true;
    cameras = await availableCameras();

    if (cameras.isNotEmpty) {
      camera = cameras.last;
      if (camera != null) {
        cameraController = CameraController(camera!, ResolutionPreset.high);
        await cameraController?.initialize().then((value) {
          isLoading.value = false;
        });
      }
    }
    isLoading.value = false;

  }

  Future<void> takePicture() async {
    final XFile image = await cameraController!.takePicture();
    if (kDebugMode) {
      print('Picture taken: ${image.path}');
    }

    selfieFile.value = image;

    update();
  }
}
