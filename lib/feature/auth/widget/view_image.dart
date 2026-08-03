import 'dart:io';

import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/cacheNetworkImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ViewImage extends StatelessWidget {
  const ViewImage({required this.image, required this.title, super.key});

  final String title;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: title, centerTitle: false),
      body: Stack(
        fit: StackFit.expand,
        children: [
          image.contains("http")
              ? NetworkImageWidget(
                  image: image,
                  radius: 0,
                  boxFit: BoxFit.contain,
                )
              : Image.file(File(image), fit: BoxFit.contain),
          Positioned(
            top: 16.h,
            right: 16.w,
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                height: 40.h,
                width: 40.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mainPrimaryColor,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.close, color: AppColors.whiteColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
