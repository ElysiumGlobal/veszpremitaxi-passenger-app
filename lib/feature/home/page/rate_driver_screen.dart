import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/feature/home/widget/dialog.dart';
import 'package:e_taxi/feature/home/widget/driver_details_widget.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_button.dart';

class RateDriverScreen extends StatefulWidget {
  const RateDriverScreen({super.key});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  double userRating = 0.0;
  RxInt isTap = 0.obs;

  RxInt selectedEmoji = 0.obs;

  TextEditingController commentController = TextEditingController();
  List emoji = [
    ImagesAsset.emoji1,
    ImagesAsset.emoji2,
    ImagesAsset.emoji3,
    ImagesAsset.emoji4,
    ImagesAsset.emoji5,
    ImagesAsset.emoji6,
    ImagesAsset.emoji7,
    ImagesAsset.emoji8,
    ImagesAsset.emoji9,
    ImagesAsset.emoji10,
    ImagesAsset.emoji11,
    ImagesAsset.emoji12,
    ImagesAsset.emoji13,
    ImagesAsset.emoji14,
    ImagesAsset.emoji15,
    ImagesAsset.emoji16,
  ];

  final homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(
        title: AppString.rateDriver.tr,
        centerTitle: false,
        onBackTap: () {
          Navigation.popupUtil(Routes.dashboardScreen);
        },
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          Navigation.popupUtil(Routes.dashboardScreen);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.whiteColor,
                    border: Border.all(color: AppColors.textFieldBorderColor),
                  ),

                  child: DriverDetailsWidget(
                    firstText:
                        riderBookingModel
                            .value
                            ?.data
                            ?.driver
                            ?.vehicle
                            ?.numberPlate ??
                        "",
                    secoundText:
                        "${riderBookingModel.value?.data?.driver?.vehicle?.model ?? ""} ${riderBookingModel.value?.data?.driver?.vehicle?.make ?? ""}",
                    thirdText:
                        riderBookingModel.value?.data?.driver?.name ?? "",
                    image:
                        riderBookingModel.value?.data?.driver?.profilePhoto ??
                        "",
                    rating:
                        riderBookingModel.value?.data?.driver?.rating ?? "0",
                    radius: 100,
                  ),
                ),

                16.verticalSpace,

                Obx(
                  () => isTap.value == 0
                      ? Column(
                          children: [
                            CommonText(
                              string: AppString.howWasYourTrip.tr,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                            ),
                            8.verticalSpace,
                            CommonText(
                              string: AppString.feedbackDriverExp.tr,
                              color: AppColors.textCaptionColor,
                            ),

                            16.verticalSpace,

                            RatingBar.builder(
                              direction: Axis.horizontal,
                              glow: true,
                              allowHalfRating: false,
                              wrapAlignment: WrapAlignment.spaceBetween,
                              itemCount: 5,
                              itemPadding: EdgeInsets.symmetric(horizontal: 8),
                              initialRating: 0.0,
                              itemBuilder: (context, _) =>
                                  Icon(Icons.star, color: AppColors.amber),
                              onRatingUpdate: (rating) {
                                userRating = rating;
                              },
                            ),
                            37.verticalSpace,
                            CustomTextField(
                              title: AppString.comment.tr,
                              controller: commentController,
                              hintText: AppString.enterYourComment.tr,
                              maxLine: 5,
                              textfielHeight: 180,
                              minLine: 5,
                            ),
                          ],
                        )
                      : isTap.value == 1
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CommonText(
                              string: AppString.howWasRideEnergy.tr,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                            ),
                            8.verticalSpace,
                            Center(
                              child: CommonText(
                                string: AppString.shareYourMood.tr,
                                color: AppColors.textCaptionColor,
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                            ),

                            16.verticalSpace,
                            MasonryGridView.count(
                              mainAxisSpacing: 8.w,
                              crossAxisSpacing: 8.w,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: 4,

                              itemBuilder: (context, index) {
                                return Obx(
                                  () => GestureDetector(
                                    onTap: () {
                                      selectedEmoji.value = index;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(7.w),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        color: AppColors.whiteColor,
                                        border: Border.all(
                                          color: selectedEmoji.value == index
                                              ? AppColors.mainPrimaryColor
                                              : AppColors.textFieldBorderColor,
                                        ),
                                      ),
                                      child: CustomImage(image: emoji[index]),
                                    ),
                                  ),
                                );
                              },
                              itemCount: 16,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            CommonText(
                              string: "Wow 5 Star!",
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                            ),
                            8.verticalSpace,
                            CommonText(
                              string:
                                  "Do you want to any additional tip for Amit?",
                              color: AppColors.textCaptionColor,
                            ),
                            22.verticalSpace,
                            CustomTextField(
                              controller: TextEditingController(),
                            ),
                            32.verticalSpace,

                            Wrap(
                              spacing: 20.w,
                              runSpacing: 20.w,
                              direction: Axis.horizontal,
                              children: [
                                ...List.generate(4, (index) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24.w,
                                      vertical: 8.w,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.textFieldBorderColor,
                                      ),
                                      borderRadius: BorderRadius.circular(24.r),
                                    ),
                                    child: CommonText(
                                      string: Utils.formatCurrency("$index"),
                                      fontSize: 14.sp,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Padding(
          padding: EdgeInsets.all(16.w),

          child: Obx(
            () => Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppString.next.tr,
                    onTap: () async {
                      // ratingDoneDialog();
                      if (userRating == 0.0) {
                        AppDialog.commonDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16.r),
                            ),
                          ),
                          childs: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CommonText(
                                string: AppString.rateYourDriver.tr,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              16.verticalSpace,
                              CommonText(
                                string:
                                    AppString.pleaseRateYourRideExperience.tr,
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),
                              22.verticalSpace,

                              CustomButton(
                                text: AppString.goAhead.tr,
                                buttonColor: AppColors.transparent,
                                borderColor: AppColors.mainPrimaryColor,
                                onTap: () {
                                  Navigation.pop();
                                  Navigation.popupUtil(Routes.dashboardScreen);
                                },
                              ),
                              16.verticalSpace,
                              CustomButton(
                                text: AppString.giveRating.tr,
                                onTap: () {
                                  Navigation.pop();
                                },
                              ),
                            ],
                          ),
                        );

                        return;
                      }

                      final data = await homeController.ratingDriver(
                        bookingId: int.parse(
                          riderBookingModel.value?.data?.booking?.id ?? "0",
                        ),
                        comment: commentController.text.trim(),
                        rating: userRating,
                      );

                      if (data.isNotEmpty) {
                        ratingDoneDialog();
                      }
                    },
                  ),
                ),

                if (isTap.value == 2) 25.horizontalSpace,

                if (isTap.value == 2)
                  Expanded(
                    child: CustomButton(
                      text: AppString.payTip.tr,
                      buttonColor: AppColors.blackColor,
                      textColor: AppColors.whiteColor,
                      onTap: () {
                        Navigation.pushNamed(Routes.reportIssueScreen);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void ratingDoneDialog() {
    AppDialog.commonDialog(
      barrierDismissible: false,
      childs: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImage(image: ImagesAsset.done),
          16.verticalSpace,
          CommonText(
            string: AppString.thankYou.tr,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          12.verticalSpace,
          CommonText(
            string: AppString.weAppreciateYourTrip.tr,
            color: AppColors.textCaptionColor,
            softWrap: true,
            textAlign: TextAlign.center,
          ),
          16.verticalSpace,
          CustomButton(
            text: AppString.backToHome.tr,
            onTap: () {
              Navigation.pop();
              Navigation.popupUtil(Routes.dashboardScreen);
            },
          ),
        ],
      ),
    );
  }
}
