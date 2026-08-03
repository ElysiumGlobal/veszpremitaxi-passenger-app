import 'package:e_taxi/feature/auth/controller/register_controller.dart';
import 'package:e_taxi/utils/validation_utils.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/utils.dart';
import '../../../widgets/appbar.dart';
import '../widget/selectVehicle_widget.dart';
import '../widget/selection_section_widget.dart';

class VehicleSetupScreen extends StatefulWidget {
  const VehicleSetupScreen({super.key});

  @override
  State<VehicleSetupScreen> createState() => _VehicleSetupScreenState();
}

class _VehicleSetupScreenState extends State<VehicleSetupScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      controller.getRideTypeList();
    });
  }

  RxInt selectedIndex = (-1).obs;
  List iconList = [
    ImagesAsset.bikeSvg,
    ImagesAsset.carSvg,
    ImagesAsset.rickshawSvg,
  ];
  List titleList = [AppString.bike, AppString.taxi, AppString.rickshaw];

  TextEditingController numberController = TextEditingController();
  final controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: AppString.vehicleDetails.tr,
        leading: SizedBox(width: 16.w),
        leadingSize: 16.w,
      ),
      body: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectionSectionWidget(index: 2),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      string: AppString.whichVehicleDrive.tr,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ).paddingSymmetric(vertical: 24.h),
                    Obx(
                      () => controller.rideTypeList.isEmpty
                          ? Skeletonizer(
                              enabled: true,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ...List.generate(3, (index) {
                                    return Obx(
                                      () => Expanded(
                                        child:
                                            SelectvehicleWidget(
                                              isFile: true,
                                              icon: iconList[index],
                                              title: titleList[index],
                                              isSelected:
                                                  index == selectedIndex.value,
                                              onTap: () {
                                                selectedIndex.value = index;
                                              },
                                            ).paddingOnly(
                                              right: index != 2 ? 16.w : 0,
                                            ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            )
                          : MasonryGridView.count(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              mainAxisSpacing: 16.w,
                              crossAxisSpacing: 16.w,
                              itemCount: controller.rideTypeList.length,
                              itemBuilder: (context, index) {
                                final data = controller.rideTypeList[index];
                                return Obx(
                                  () => SelectvehicleWidget(
                                    icon: data.icon ?? "",
                                    title: data.name ?? "",
                                    isSelected: index == selectedIndex.value,
                                    onTap: () {
                                      selectedIndex.value = index;
                                    },
                                  ),
                                );
                              },
                            ),
                    ),

                    CustomTextField(
                      title: AppString.registerNumber.tr,
                      controller: numberController,
                      hintText: "GJ-00-DD-0000",
                      prefixIcon: ImagesAsset.vehicle,
                    ).paddingSymmetric(vertical: 24.h),
                    CustomButton(
                      text: AppString.continueString.tr,
                      onTap: () {
                        if (selectedIndex.value == -1) {
                          AppSnackBar.showErrorSnackBar(
                            message: "Select the RideType",
                            isError: true,
                          );
                          return;
                        }

                        if (numberController.text
                            .trim()
                            .isValidIndianVehicle()) {
                          return;
                        }
                        controller.vehicleDateUpload(
                          noPlate: numberController.text.trim(),
                          rideType: int.parse(
                            controller.rideTypeList[selectedIndex.value].id ??
                                "0",
                          ),
                        );


                      },
                    ),
                  ],
                ).paddingSymmetric(horizontal: 16.w),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
