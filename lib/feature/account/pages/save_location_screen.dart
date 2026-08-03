import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/no_data_widget.dart';

class SaveLocationScreen extends StatefulWidget {
  const SaveLocationScreen({super.key});

  @override
  State<SaveLocationScreen> createState() => _SaveLocationScreenState();
}

class _SaveLocationScreenState extends State<SaveLocationScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    accountController.getLocationList();
  }

  final accountController = Get.find<AccountController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppString.savedLocation.tr,
        centerTitle: false,
      ),
      body: Obx(
        () => accountController.locationLoading.value
            ? ListView.builder(
                itemBuilder: (context, index) {
                  return Skeletonizer(
                    child: Container(
                      height: 120.h,
                      width: double.infinity,
                      color: AppColors.whiteColor,
                    ),
                  );
                },
                itemCount: 3,
              )
            : accountController.locationList.isEmpty
            ? NoDataWidget(
                icon: ImagesAsset.noData,
                title: AppString.noDataAvailable.tr,
                subTitle: AppString.weNotFindAnything.tr,
                onTap: () {
                  accountController.getLocationList();
                },
              )
            : ListView.separated(
                itemBuilder: (context, index) {
                  final data = accountController.locationList[index];
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textFieldBorderColor),
                      borderRadius: BorderRadius.circular(12.r),
                      color: AppColors.whiteColor,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 40.w,
                          width: 40.w,
                          decoration: BoxDecoration(
                            color: AppColors.whiteGrey,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          alignment: Alignment.center,
                          child: CustomImage(image: IconAsset.save),
                        ),
                        16.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                string: data.type ?? "",
                                fontWeight: FontWeight.w500,
                              ),
                              CommonText(
                                string: data.address ?? "",
                                fontSize: 12.sp,
                                color: AppColors.bodyText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => 16.verticalSpace,
                itemCount: accountController.locationList.length,
              ),
      ).paddingAll(16.w),

      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,

        child: CustomButton(
          text: AppString.addLocation.tr,
          onTap: () {
            Navigation.pushNamed(Routes.searchAddressScreen);
          },
        ).paddingOnly(left: 16.w, right: 16.w, bottom: 16.w),
      ),
    );
  }
}
