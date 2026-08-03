import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../utils/app_string.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_button.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({
    required this.latLng,
    required this.location,
    required this.name,
    super.key,
  });

  final String location;
  final LatLng latLng;
  final String name;

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  String titleName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppString.savedLocation.tr,
        centerTitle: false,
      ),
      body: Column(
        children: [
          CustomTextField(
            controller: TextEditingController(),
            title: AppString.nameOfLocation.tr,
            onChanged: (value) {
              titleName = value;
            },
          ),
          16.verticalSpace,
          CustomTextField(
            controller: TextEditingController(text: widget.location),
            readOnly: true,
            title: AppString.addLocation.tr,
          ),
        ],
      ).paddingAll(16.w),
      bottomNavigationBar: SafeArea(
        child: CustomButton(
          text: AppString.addLocation.tr,
          onTap: () {
            if (titleName.isEmpty) {
              AppSnackBar.showErrorSnackBar(
                message: AppString.enterNameOfLocation.tr,
              );
              return;
            }

            Get.find<AccountController>().addLocation(
              title: titleName,
              address: widget.location,
              latLang: widget.latLng,
              name: widget.name,
            );
          },
        ).paddingOnly(left: 16.w, right: 16.w, bottom: 16.w),
      ),
    );
  }
}
