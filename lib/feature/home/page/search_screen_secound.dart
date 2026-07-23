import 'dart:async';
import 'dart:io';
import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/feature/home/widget/dialog.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/validation_utils.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/common_widget.dart';
import '../../../widgets/custome_img.dart';
import '../widget/origin_destination_widget.dart';
import '../widget/suggetion_address.dart';

class SearchSecoundScreen extends StatefulWidget {
  const SearchSecoundScreen({super.key});

  @override
  State<SearchSecoundScreen> createState() => _SearchSecoundScreenState();
}

class _SearchSecoundScreenState extends State<SearchSecoundScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  RxString destination = "".obs;

  final homeController = Get.find<HomeController>();

  TextEditingController searchController = TextEditingController();

  RxInt selectedUserNameIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          behavior: HitTestBehavior.translucent,
          child: Container(
            height: 48.h,
            width: 48.h,
            alignment: Alignment.center,
            child: CustomImage(
              image: IconAsset.arrowLeftIcon,
              ht: 24.h,
              wt: 24.h,
            ),
          ),
        ),
        title: AppString.destination.tr,
        centerTitle: false,
        leadingSize: 48.w,
        actions: [
          GestureDetector(
            onTap: () {
              AppDialog.commonBottomSheetWidget(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      8.verticalSpace,

                      CommonText(
                        string: AppString.bookingForRide.tr,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                      Divider(color: AppColors.textFieldBorderColor),
                      20.verticalSpace,

                      Obx(
                        () => ListView.separated(
                          padding: EdgeInsets.zero,
                          separatorBuilder: (context, index) =>
                              16.verticalSpace,
                          itemCount: homeController.userNameList.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Obx(() {
                              final data = homeController.userNameList[index];
                              return GestureDetector(
                                onTap: () {
                                  selectedUserNameIndex.value = index;
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CommonText(string: data.name ?? ""),
                                    Container(
                                      height: 24.w,
                                      width: 24.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.mainPrimaryColor,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child:
                                          index == selectedUserNameIndex.value
                                          ? Container(
                                              height: 16.w,
                                              width: 16.w,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    AppColors.mainPrimaryColor,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              );
                            });
                          },
                        ),
                      ),
                      Divider(color: AppColors.textFieldBorderColor),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          String name = "";
                          String phone = "";
                          Rxn<XFile> image = Rxn<XFile>();

                          AppDialog.commonBottomSheetWidget(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  string: AppString.addContact.tr,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                16.verticalSpace,
                                CustomTextField(
                                  title: AppString.name.tr,
                                  controller: TextEditingController(),
                                  onChanged: (v) {
                                    name = v;
                                  },
                                  hintText: AppString.enterName.tr,
                                ),
                                16.verticalSpace,
                                CustomTextField(
                                  title: AppString.phoneNumber.tr,
                                  controller: TextEditingController(),
                                  onChanged: (v) {
                                    phone = v;
                                  },
                                  hintText: AppString.enterPhone.tr,

                                  keyboardType: TextInputType.phone,
                                  textinputformate: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                                16.verticalSpace,

                                Obx(
                                  () => image.value == null
                                      ? CustomButton(
                                          buttonColor:
                                              AppColors.textFieldBorderColor,
                                          text: AppString.uploadFile.tr,
                                          prefixIconWidget: CustomImage(
                                            image: IconAsset.addCircle,
                                            ht: 20.h,
                                            wt: 20.h,
                                          ).paddingOnly(right: 4.w),
                                          onTap: () async {
                                            final take =
                                                await CustomWidget.takeImage(
                                                  ImageSource.gallery,
                                                );
                                            if (take != null) {
                                              image.value = take;
                                            }
                                          },
                                        )
                                      : SizedBox(
                                          height: 100.h,
                                          width: 100.h,
                                          child: Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              Image.file(
                                                (File(image.value?.path ?? "")),
                                                height: 100.h,
                                                width: 110.w,
                                                fit: BoxFit.cover,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  image.value = null;
                                                },
                                                child: Container(
                                                  height: 24.w,
                                                  width: 24.w,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.whiteColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: CustomImage(
                                                    image: IconAsset.close,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),

                                40.verticalSpace,
                                CustomButton(
                                  onTap: () {
                                    if (name.textDataIsNotValid(
                                      AppString.pleaseEnterName.tr,
                                    )) {
                                      return;
                                    } else if (!phone.phoneValid(
                                      phone,
                                      "+36",
                                    )) {
                                      return;
                                    } else {
                                      homeController.addUserName(
                                        name: name,
                                        phone: "+36$phone",
                                        imagePath: image.value?.path ?? "",
                                      );
                                    }
                                  },
                                  text: AppString.submit.tr,
                                ),
                                16.verticalSpace,
                              ],
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            CustomImage(image: IconAsset.contactPerson),
                            8.horizontalSpace,
                            CommonText(
                              string: AppString.addNewContact.tr,
                              color: AppColors.mainPrimaryColor,
                              fontSize: 16.sp,
                            ),
                          ],
                        ),
                      ),
                      21.verticalSpace,
                      Container(
                        // height: 46.h,
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 14.w,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: AppColors.whiteGrey,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.error_outline),
                            6.horizontalSpace,
                            Expanded(
                              child: CommonText(
                                string:
                                    "Contact name Won’t be shared with captain",
                                fontSize: 14.sp,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      80.verticalSpace,
                      CustomButton(
                        text: AppString.done.tr,
                        onTap: () {
                          Get.back();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              height: 30.h,
              margin: EdgeInsets.only(right: 24.w),
              padding: EdgeInsets.symmetric(horizontal: 11.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textFieldBorderColor),
                borderRadius: BorderRadius.circular(16.r),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Obx(
                    () => CommonText(
                      string: homeController.userNameList.isEmpty
                          ? "For me"
                          : homeController
                                    .userNameList[selectedUserNameIndex.value]
                                    .name ??
                                "",
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.blackColor,
                    size: 24.h,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // selecetion Section
              Container(
                margin: EdgeInsets.all(16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.whiteColor,
                ),
                child: Obx(
                  () => OriginDestinationWidget(
                    destination: destination.value == ""
                        ? "Destination"
                        : destination.value,
                    origin: homeController.selectedLocationModel.oAddress ?? "",
                    showTextField: true,
                    controller: searchController,
                    onChange: (search) {
                      if ((search ?? "").isNotEmpty) {
                        debugPrint(
                          '[DESTINATION_API] destination field typing → will call Google Places Autocomplete',
                        );
                        if (homeController.debounce?.isActive ?? false)
                          homeController.debounce?.cancel();
                        homeController.debounce = Timer(
                          const Duration(milliseconds: 400),
                          () {
                            homeController.searchPlace(
                              search ?? "",
                              forDestination: true,
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),

              Expanded(
                child: Obx(
                  () => homeController.searchList.isEmpty
                      ? SizedBox.shrink()
                      : Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 16.w,
                            horizontal: 16.w,
                          ),
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                string: AppString.popularPlace.tr,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              Divider(color: AppColors.textFieldBorderColor),
                              8.verticalSpace,
                              Expanded(
                                child: Obx(
                                  () => ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                          color: AppColors.textFieldBorderColor,
                                        ),
                                    itemCount: homeController.searchList.length,
                                    itemBuilder: (context, index) {
                                      final data =
                                          homeController.searchList[index];
                                      return SuggestionAddressWidget(
                                        title: (data.terms ?? []).isNotEmpty
                                            ? data.terms?.first.value ?? ""
                                            : "",
                                        subTitle: data.description ?? "",
                                        onTap: () {
                                          debugPrint(
                                            '[DESTINATION_API] destination suggestion tapped → '
                                            '${data.description}',
                                          );
                                          searchController.text =
                                              (data.terms ?? []).isNotEmpty
                                              ? data.terms?.first.value ?? ""
                                              : "";
                                          homeController.searchDestination(
                                            data.placeId ?? "",
                                            homeController.userNameList.isEmpty
                                                ? 0
                                                : homeController
                                                          .userNameList[selectedUserNameIndex
                                                              .value]
                                                          .id ??
                                                      0,
                                            (data.terms ?? []).isNotEmpty
                                                ? data.terms?.first.value ?? ""
                                                : "",
                                            data.description ?? "",
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
          Obx(
            () => homeController.getLatLngLoading.value
                ? Center(child: CircularProgressIndicator())
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
