import 'package:country_pickers/country.dart' as country;
import 'package:country_pickers/utils/utils.dart';
import 'package:e_taxi/feature/help_center/pages/faq_screen.dart';
import 'package:e_taxi/feature/help_center/pages/ticket_details.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/navigation_utils/navigation.dart';
import 'package:e_taxi/utils/validation_utils.dart';
import 'package:e_taxi/widgets/common_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_country_picker.dart';
import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfeild.dart';
import '../../../widgets/custome_img.dart';
import '../../../widgets/webview_screen.dart';
import '../controller/helpCenter_controller.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  final helpCenterController = Get.put(HelpCenterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBarSize: 120.h,
        title: AppString.helpCenter.tr,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 56.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              border: Border(
                top: BorderSide(color: AppColors.textFieldBorderColor),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: AppColors.mainPrimaryColor,
              labelColor: AppColors.mainPrimaryColor,
              unselectedLabelColor: AppColors.textCaptionColor,
              dividerColor: AppColors.transparent,
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: AppColors.textCaptionColor,
              ),
              labelStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: AppString.support.tr),
                Tab(text: AppString.safety.tr),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: TabBarView(
          controller: _tabController,
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await helpCenterController.getContactSupport();
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Obx(
                  () => helpCenterController.supportLoading.value
                      ? Skeletonizer(
                          enabled: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(string: "Asddas"),
                              16.verticalSpace,
                              Container(
                                padding: EdgeInsets.all(12.w),
                                color: AppColors.whiteColor,
                                child: Column(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: double.infinity,
                                      color: AppColors.whiteColor,
                                    ),
                                    16.verticalSpace,
                                    ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          16.verticalSpace,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: 3,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          height: 50,
                                          width: double.infinity,
                                          color: AppColors.whiteColor,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ).paddingAll(16.w),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              string: AppString.helpCategories.tr,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            8.verticalSpace,
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        20.verticalSpace,
                                    itemCount:
                                        (helpCenterController
                                                    .supportModel
                                                    .value
                                                    ?.data
                                                    ?.categories ??
                                                [])
                                            .length,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final data = helpCenterController
                                          .supportModel
                                          .value
                                          ?.data
                                          ?.categories?[index];
                                      return commonRow(
                                        icon:
                                            _icons[categoryName.indexOf(
                                              data?.title ?? "",
                                            )],
                                        // icon:  _icons[index],
                                        title: data?.title ?? "",
                                        subTitle: data?.description ?? "",
                                        onTap: () {
                                          Get.to(
                                            () => FaqScreen(category: data!),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            CommonText(
                              string: AppString.raisedTicket.tr,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ).paddingSymmetric(vertical: 16.h),
                            ListView.separated(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final data = helpCenterController
                                    .supportModel
                                    .value
                                    ?.data
                                    ?.raisedTickets
                                    ?.tickets?[index];
                                return GestureDetector(
                                  onTap: () {
                                    Get.to(
                                      () => TicketDetalsScreen(
                                        id: data?.id ?? "",
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      color: AppColors.whiteColor,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CommonText(
                                                string:
                                                    data?.ticketNumber ?? "",
                                                fontWeight: FontWeight.w500,
                                              ),
                                              CommonText(
                                                string: data?.subject ?? "",
                                                color: AppColors.bodyText,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        8.horizontalSpace,
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
                                            color: getBgColor(
                                              data?.status ?? "",
                                            ),
                                          ),
                                          child: CommonText(
                                            string: "${data?.status ?? ""}",
                                            color: getTextColor(
                                              data?.status ?? "",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  16.verticalSpace,
                              itemCount:
                                  (helpCenterController
                                              .supportModel
                                              .value
                                              ?.data
                                              ?.raisedTickets
                                              ?.tickets ??
                                          [])
                                      .length,
                            ),
                            16.verticalSpace,
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: AppColors.whiteColor,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonText(
                                    string: AppString.hiThereIam.tr,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  4.verticalSpace,
                                  CommonText(
                                    string:
                                        "I can help you with ride issues, payments, account settings, safety concerns, and more. Type your question or choose from the options below.",
                                    softWrap: true,
                                  ),

                                  8.verticalSpace,
                                  Wrap(
                                    direction: Axis.horizontal,
                                    spacing: 12.w,
                                    runSpacing: 12.w,
                                    children: [
                                      ...List.generate(_icons.length, (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigation.pushNamed(
                                              Routes.raiseTickerScreen,
                                              params: {
                                                "title": _nameList[index],
                                                "subject": subjectName[index],
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(12.w),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              border: Border.all(
                                                color: AppColors
                                                    .textFieldBorderColor,
                                              ),
                                              color: AppColors.whiteGrey,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CustomImage(
                                                  image: _icons[index],
                                                  ht: 16.w,
                                                  wt: 16.w,
                                                  color: AppColors.blackColor,
                                                ),
                                                4.horizontalSpace,
                                                CommonText(
                                                  string: _nameList[index].tr,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12.sp,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            16.verticalSpace,
                            CustomButton(
                              text: AppString.contactSupport.tr,
                              onTap: () {
                                // Utils().launchWeb(Constants().contactUs);
                                Get.to(
                                  () => WebviewScreen(
                                    webUrl: Constants().contactUs,
                                  ),
                                );
                              },
                            ),
                            16.verticalSpace,
                          ],
                        ).paddingAll(16.w),
                ),
              ),
            ),
            RefreshIndicator(
              onRefresh: () async {
                await helpCenterController.getEmergencyContact();
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    CommonText(
                      string:
                          "We’re committed to keeping you protected on every ride. Learn how our safety features — like live tracking, verified drivers, and SOS support — work together for your peace of mind.",
                      softWrap: true,
                    ),

                    24.verticalSpace,

                    MasonryGridView.count(
                      crossAxisSpacing: 16.w,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12.h,
                      itemCount: 4,
                      crossAxisCount: 2,
                      itemBuilder: (context, index) {
                        return CustomImage(image: iconList[index], ht: 131.h);
                      },
                    ),
                    19.verticalSpace,

                    CustomTextField(
                      controller: TextEditingController(),
                      readOnly: true,
                      hintText: AppString.addContact.tr,
                      hintTextStyle: TextStyle(),
                      suffixIcon: IconAsset.arrowRightIcon1,
                      onTap: () {
                        CustomWidget.commonBottomSheetWidget1(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  string: AppString.emergencyContact.tr,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                16.verticalSpace,
                                CommonText(
                                  string: AppString.youSave5Contact.tr,
                                  softWrap: true,
                                ),

                                Obx(
                                  () => ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        16.verticalSpace,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount:
                                        helpCenterController.contactList.length,
                                    itemBuilder: (context, index) {
                                      final data = helpCenterController
                                          .contactList[index];

                                      return Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(
                                                12.r,
                                              ),
                                          border: Border.all(
                                            color:
                                                AppColors.textFieldBorderColor,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 40.h,
                                              width: 40.h,
                                              decoration: BoxDecoration(
                                                color: AppColors
                                                    .textFieldBorderColor,

                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: CommonText(
                                                string:
                                                    (data.name ?? "").isNotEmpty
                                                    ? (data.name ?? "")[0]
                                                          .toUpperCase()
                                                    : "",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15.sp,
                                              ),
                                            ),
                                            18.horizontalSpace,
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CommonText(
                                                    string: data.name ?? "",
                                                    fontSize: 16.sp,
                                                  ),
                                                  4.verticalSpace,
                                                  CommonText(
                                                    string:
                                                        data.mobileNumber ?? "",
                                                    fontSize: 14.sp,
                                                    color: AppColors
                                                        .textCaptionColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            18.horizontalSpace,

                                            GestureDetector(
                                              onTap: () async {
                                                final res =
                                                    await helpCenterController
                                                        .deleteEmergency(
                                                          data.id ?? 0,
                                                          index,
                                                        );
                                                if (res.isNotEmpty) {
                                                  AppSnackBar.showErrorSnackBar(
                                                    message: res['message'],
                                                  );
                                                }
                                              },
                                              child: Container(
                                                height: 40.h,
                                                width: 40.h,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.errorBgColor,
                                                ),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  CupertinoIcons.delete,
                                                  color: AppColors.errorColor,
                                                  size: 20.h,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                24.verticalSpace,

                                Obx(
                                  () => CustomButton(
                                    text:
                                        helpCenterController.contactList.isEmpty
                                        ? AppString.add.tr
                                        : AppString.addMore.tr,
                                    onTap: () {
                                      if (helpCenterController
                                              .contactList
                                              .length ==
                                          5) {
                                        AppSnackBar.showErrorSnackBar(
                                          message:
                                              "Not add more then 5 contacts",
                                          isError: true,
                                        );
                                        return;
                                      }

                                      final Rx<country.Country>
                                      selectedDialogCountry =
                                          CountryPickerUtils.getCountryByPhoneCode(
                                            "91",
                                          ).obs;

                                      String code = "+91";
                                      TextEditingController nameController =
                                          TextEditingController();
                                      TextEditingController phoneController =
                                          TextEditingController();

                                      CustomWidget.commonBottomSheetWidget1(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: CommonText(
                                                string: AppString.addContact.tr,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18.sp,
                                              ),
                                            ),
                                            24.verticalSpace,
                                            CustomTextField(
                                              controller: nameController,
                                              hintText: AppString.fullName.tr,
                                              title: AppString.name.tr,
                                              textInputAction:
                                                  TextInputAction.next,
                                            ),
                                            16.verticalSpace,

                                            CommonText(
                                              string: AppString.mobileNumber.tr,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12.sp,
                                            ),
                                            4.verticalSpace,
                                            Container(
                                              height: 56.h,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(6.r),
                                                ),
                                                border: Border.all(
                                                  color: AppColors
                                                      .textFieldBorderColor,
                                                ),
                                              ),
                                              // padding: EdgeInsets.symmetric(vertical: 12.h),
                                              child: Row(
                                                children: [
                                                  Obx(
                                                    () => CountryPickerWidget1(
                                                      phoneController:
                                                          TextEditingController(),
                                                      country:
                                                          selectedDialogCountry
                                                              .value,
                                                      onTap: (v) {
                                                        code =
                                                            "+${v.phoneCode}";

                                                        selectedDialogCountry
                                                                .value =
                                                            CountryPickerUtils.getCountryByPhoneCode(
                                                              v.phoneCode,
                                                            );
                                                      },
                                                    ).paddingOnly(right: 10.w),
                                                  ),
                                                  Expanded(
                                                    child: TextFormField(
                                                      cursorColor: AppColors
                                                          .mainPrimaryColor,
                                                      controller:
                                                          phoneController,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: AppColors
                                                            .textPrimaryColor,
                                                      ),
                                                      decoration: InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 18.h,
                                                            ),
                                                        hintStyle: TextStyle(
                                                          color: AppColors
                                                              .hintTextColor,
                                                          fontSize: 14.sp,
                                                        ),
                                                        hintText: "9988776655",
                                                        border:
                                                            InputBorder.none,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                      ),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly,
                                                        LengthLimitingTextInputFormatter(
                                                          16,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            24.verticalSpace,
                                            CustomButton(
                                              onTap: () async {
                                                if (nameController.text
                                                        .trim()
                                                        .textDataIsNotValid(
                                                          AppString
                                                              .pleaseEnterFirstName
                                                              .tr,
                                                        ) ||
                                                    !phoneController.text
                                                        .phoneValid(
                                                          phoneController.text
                                                              .trim(),
                                                          code,
                                                        )) {
                                                  return;
                                                }

                                                final res =
                                                    await helpCenterController
                                                        .addEmergencyContact(
                                                          name: nameController
                                                              .text
                                                              .trim(),
                                                          phone:
                                                              "$code ${phoneController.text.trim()}",
                                                        );
                                                if (res.isNotEmpty) {
                                                  Get.back();
                                                  AppSnackBar.showErrorSnackBar(
                                                    message: res['message'],
                                                  );
                                                }
                                              },
                                              text: AppString.add.tr,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ).paddingAll(16.w),
              ),
            ),
          ],
        ),
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

  List<String> _icons = [
    ImagesAsset.drivingCar,
    IconAsset.wallet,
    IconAsset.discount,
    IconAsset.danger,
    IconAsset.information,
  ];
  List<String> _nameList = [
    AppString.rideIssues,
    AppString.paymentAndWallet,
    AppString.offerReward,
    AppString.appRelatedIssue,
    AppString.other,
  ];

  List<String> subjectName = [
    "Ride Issue",
    "Payment & Wallet",
    "Offer & Reward",
    'App Related',
    'Other',
  ];
  List<String> categoryName = [
    AppString.rideIssues,
    AppString.paymentAndWallet,
    AppString.promotionAndOffers,
    AppString.appTroublehooting,
  ];

  Widget commonRow({
    required String icon,
    required String title,
    required String subTitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 40.h,
            width: 40.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: AppColors.whiteGrey,
            ),
            alignment: Alignment.center,
            child: CustomImage(
              image: icon,
              ht: 24.h,
              wt: 24.h,
              color: AppColors.blackColor,
            ),
            // child: NetworkImageWidget(image: icon,ht: 24.h,wt: 24.h, radius: 0,),
          ),
          8.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(string: title, fontWeight: FontWeight.w600),
                CommonText(
                  string: subTitle,
                  color: AppColors.textCaptionColor,
                  softWrap: true,
                ),
              ],
            ),
          ),
          8.horizontalSpace,
          Icon(CupertinoIcons.forward),
        ],
      ),
    );
  }

  List iconList = [
    ImagesAsset.ambulance,
    ImagesAsset.police,
    ImagesAsset.liveLocation,
    ImagesAsset.trustContact,
  ];
}
