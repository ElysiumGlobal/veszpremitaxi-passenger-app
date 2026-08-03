import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_taxi/feature/help_center/controller/helpCenter_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/cacheNetworkImage.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custome_img.dart';
import '../../../widgets/webview_screen.dart';

class TicketDetalsScreen extends StatefulWidget {
  final String id;

  const TicketDetalsScreen({required this.id, super.key});

  @override
  State<TicketDetalsScreen> createState() => _TicketDetalsScreenState();
}

class _TicketDetalsScreenState extends State<TicketDetalsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      ticketController.getTicketDetails(id: widget.id);
    });
  }

  int currentPage = 0;
  final ticketController = Get.find<HelpCenterController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppString.ticketDetails.tr,
        centerTitle: false,
      ),

      body: Obx(
        () => ticketController.ticketLoading.value
            ? Skeletonizer(
                enabled: true,
                child: Column(
                  children: [
                    Container(
                      height: 150.h,
                      width: double.infinity,
                      color: AppColors.whiteColor,
                    ),
                    16.verticalSpace,
                    Container(
                      height: 150.h,
                      width: double.infinity,
                      color: AppColors.whiteColor,
                    ),
                    16.verticalSpace,
                  ],
                ).paddingAll(16.w),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.w),
                        color: AppColors.whiteColor,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              CommonText(
                                string:
                                    ticketController
                                        .ticketSupportModel
                                        .value
                                        ?.data
                                        ?.ticketNumber ??
                                    "",
                                fontWeight: FontWeight.w500,
                              ),

                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.r),
                                  color: getBgColor(
                                    ticketController
                                            .ticketSupportModel
                                            .value
                                            ?.data
                                            ?.status ??
                                        "",
                                  ),
                                ),
                                child: CommonText(
                                  string:
                                      "${ticketController.ticketSupportModel.value?.data?.status ?? ""}",
                                  color: getTextColor(
                                    ticketController
                                            .ticketSupportModel
                                            .value
                                            ?.data
                                            ?.status ??
                                        "",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CommonText(string: AppString.raisedOn.tr),
                              CommonText(
                                string:
                                    "${Utils().convertFullTime(ticketController.ticketSupportModel.value?.data?.createdAt ?? "")}",
                              ),
                            ],
                          ),
                          if ((ticketController
                                      .ticketSupportModel
                                      .value
                                      ?.data
                                      ?.booking
                                      ?.tripId ??
                                  "")
                              .isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CommonText(string: AppString.tripId.tr),
                                CommonText(
                                  string:
                                      "${ticketController.ticketSupportModel.value?.data?.booking?.tripId ?? ""}",
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    16.verticalSpace,
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.w),
                        color: AppColors.whiteColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            string:
                                "${ticketController.ticketSupportModel.value?.data?.subject ?? ""}",
                            fontWeight: FontWeight.w600,
                          ),
                          16.verticalSpace,
                          if ((ticketController
                                      .ticketSupportModel
                                      .value
                                      ?.data
                                      ?.messages ??
                                  [])
                              .isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.textFieldBorderColor,
                                ),
                              ),
                              child: CommonText(
                                string:
                                    ticketController
                                        .ticketSupportModel
                                        .value
                                        ?.data
                                        ?.messages
                                        ?.first
                                        .message ??
                                    "",
                                softWrap: true,
                              ),
                            ),
                          // CustomTextField(controller: TextEditingController(text: ),title: AppString.description.tr,textfielHeight: 56.h,),
                        ],
                      ),
                    ),
                    16.verticalSpace,
                    if ((ticketController
                                .ticketSupportModel
                                .value
                                ?.data
                                ?.attachments ??
                            [])
                        .isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.w),
                          color: AppColors.whiteColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CommonText(
                                  string: AppString.uploadScreenshot.tr,
                                  fontWeight: FontWeight.w500,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final image = await Utils().getImage();
                                        if (image != null) {
                                          ticketController.supportDocUpdate(
                                            id: widget.id,
                                            index: currentPage,
                                            imagePath: image.path,
                                            idAttechment:
                                                ticketController
                                                    .ticketSupportModel
                                                    .value
                                                    ?.data
                                                    ?.attachments?[currentPage]
                                                    .id ??
                                                0,
                                          );
                                        }
                                      },
                                      child: CustomImage(image: IconAsset.edit),
                                    ),
                                    16.horizontalSpace,
                                    GestureDetector(
                                      onTap: () {
                                        AppDialog.commonDialog(
                                          childs: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CommonText(
                                                string: AppString.deleteDoc.tr,
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              16.verticalSpace,
                                              CommonText(
                                                string: AppString
                                                    .areYouSureDelDoc
                                                    .tr,
                                                softWrap: true,
                                                fontSize: 16.sp,
                                              ),
                                              16.verticalSpace,
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: CustomButton(
                                                      text: AppString.notAt.tr,
                                                      buttonColor:
                                                          AppColors.transparent,
                                                      borderColor:
                                                          AppColors.blackColor,
                                                      onTap: () {
                                                        Get.back();
                                                      },
                                                    ),
                                                  ),
                                                  12.horizontalSpace,
                                                  Expanded(
                                                    child: CustomButton(
                                                      text: AppString.yes.tr,
                                                      onTap: () {
                                                        ticketController.supportDocDelete(
                                                          id: widget.id,
                                                          index: currentPage,
                                                          idAttechment:
                                                              ticketController
                                                                  .ticketSupportModel
                                                                  .value
                                                                  ?.data
                                                                  ?.attachments?[currentPage]
                                                                  .id ??
                                                              0,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: CustomImage(
                                        image: IconAsset.delete,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            12.verticalSpace,

                            CarouselSlider(
                              items:
                                  (ticketController
                                              .ticketSupportModel
                                              .value
                                              ?.data
                                              ?.attachments ??
                                          [])
                                      .map(
                                        (e) => GestureDetector(
                                          onTap: () {
                                            print("${e.imageUrl}");
                                          },
                                          child: NetworkImageWidget(
                                            image: e.imageUrl ?? "",
                                            boxFit: BoxFit.cover,
                                            wt: double.infinity,
                                            radius: 12.r,
                                          ).paddingAll(8.w),
                                        ),
                                      )
                                      .toList(),
                              options: CarouselOptions(
                                onPageChanged: (index, reason) {
                                  currentPage = index;
                                },
                                height: 150.h,
                                clipBehavior: Clip.antiAlias,
                                enlargeCenterPage: true,
                                viewportFraction: 1,
                                autoPlayAnimationDuration: Duration(
                                  milliseconds: 800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ).paddingAll(16.w),
              ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,
        child: CustomButton(
          text: AppString.contactSupport.tr,
          onTap: () {
            // Utils().launchWeb(Constants().contactUs);
            Get.to(() => WebviewScreen(webUrl: Constants().contactUs));
          },
        ).paddingOnly(left: 16.w, right: 16.w, bottom: 16.w),
      ),
    );
  }

  Color getTextColor(String value) {
    switch (value) {
      case "closed":
        return AppColors.successColor;
      case "resolved":
        return AppColors.successColor;
      default:
        return AppColors.warningColor;
    }
  }

  Color getBgColor(String value) {
    switch (value) {
      case "closed":
        return AppColors.sucessContainer;
      case "resolved":
        return AppColors.sucessContainer;
      default:
        return AppColors.warningBgColor;
    }
  }
}
