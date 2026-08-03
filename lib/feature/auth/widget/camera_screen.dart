import 'dart:io';

import 'package:camera/camera.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/custome_img.dart';
import '../controller/camera_controller.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cameraImageController.initializeController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _cameraImageController.cameraController?.dispose();
  }

  final CameraImageController _cameraImageController = Get.put(
    CameraImageController(),
  );

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Obx(
        () => _cameraImageController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _cameraImageController.selfieFile.value != null
            ? Stack(
                children: [
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.1416),
                    child: Image.file(
                      File("${_cameraImageController.selfieFile.value?.path}"),
                      fit: BoxFit.cover,

                      height: Get.height,
                      width: Get.width,
                    ),
                  ),
                  Positioned(
                    bottom: 50.h,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _cameraImageController.selfieFile.value = null;
                            },
                            child: Container(
                              height: 70.w,
                              width: 70.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.whiteColor,
                              ),
                              alignment: Alignment.center,
                              child: SizedBox(
                                height: 30.w,
                                width: 40.w,
                                child: CustomImage(
                                  image: IconAsset.close,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              Get.back(
                                result: _cameraImageController.selfieFile.value,
                              );
                            },
                            child: Container(
                              height: 70.w,
                              width: 70.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.whiteColor,
                              ),
                              child: SizedBox(
                                height: 30.w,
                                width: 40.w,
                                child: CustomImage(
                                  image: IconAsset.done,
                                  color: AppColors.successColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: ScreenUtil().screenWidth,
                height: ScreenUtil().screenHeight,
                child: _cameraImageController.cameraController != null
                    ? Stack(
                        alignment: AlignmentGeometry.bottomCenter,
                        children: [
                          Container(
                            color: AppColors.blackColor,
                            alignment: Alignment.center,
                            child: Transform.scale(
                              scale: .56 / screenSize.aspectRatio,
                              child: AspectRatio(
                                aspectRatio: .56,
                                child: CameraPreview(
                                  _cameraImageController.cameraController!,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 50.h,
                            child:
                                _cameraImageController.selfieFile.value != null
                                ? TextButton(
                                    onPressed: () {},
                                    child: Text("Clear"),
                                  )
                                : GestureDetector(
                                    onTap: () async {
                                      _cameraImageController.takePicture();
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          height: 80,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              100.r,
                                            ),
                                            color: AppColors.clickCircle,
                                          ),
                                        ),
                                        Container(
                                          height: 65,
                                          width: 65,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              100.r,
                                            ),
                                            color: AppColors.blackColor,
                                          ),
                                        ),
                                        Container(
                                          height: 52,
                                          width: 52,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              100.r,
                                            ),
                                            color: AppColors.clickCircle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
      ),
    );
  }
}
