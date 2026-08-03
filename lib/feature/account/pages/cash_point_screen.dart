import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart';

import '../../../utils/app_string.dart';
import '../../../widgets/no_data_widget.dart';

class CashCollectionPointScreen extends StatefulWidget {
  const CashCollectionPointScreen({super.key});

  @override
  State<CashCollectionPointScreen> createState() =>
      _CashCollectionPointScreenState();
}

class _CashCollectionPointScreenState extends State<CashCollectionPointScreen> {
  final accountController = Get.find<AccountController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      accountController.getCashPoint();
    });
  }

  RxInt selectedIndex = (-1).obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppString.cashCollect.tr, centerTitle: false),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: Obx(
          () => accountController.cashPointLoading.value
              ? Center(child: CircularProgressIndicator())
              : (accountController
                            .cashPoint
                            .value
                            ?.data
                            ?.cashCollectionPoints ??
                        [])
                    .isEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    await accountController.getCashPoint(isRefresh: true);
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: NoDataWidget(
                                    icon: ImagesAsset.noData,
                                    title: AppString.noDataAvailable.tr,
                                    subTitle: AppString.weNotFindAnything.tr,
                                    onTap: () {
                                      accountController.getCashPoint(
                                        isRefresh: true,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await accountController.getCashPoint(isRefresh: true);
                  },
                  child: ListView.separated(
                    physics: AlwaysScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => 16.verticalSpace,
                    itemCount:
                        (accountController
                                    .cashPoint
                                    .value
                                    ?.data
                                    ?.cashCollectionPoints ??
                                [])
                            .length,
                    itemBuilder: (context, index) {
                      final data = accountController
                          .cashPoint
                          .value
                          ?.data
                          ?.cashCollectionPoints?[index];

                      return Theme(
                        data: ThemeData().copyWith(
                          dividerColor: AppColors.transparent,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: AppColors.whiteColor,
                          ),
                          child: ExpansionTile(
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            title: CommonText(
                              string:
                                  "${AppString.branch} : ${data?.name ?? ""}",
                              fontWeight: FontWeight.w500,
                              softWrap: true,
                              fontSize: 14.sp,
                            ),
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            commonRow(
                                              title: "${AppString.address.tr}",
                                              subtitle: data?.address ?? "",
                                            ),
                                            commonRow(
                                              title: "${AppString.name.tr}",
                                              subtitle:
                                                  data?.contactPerson ?? "",
                                            ),
                                            commonRow(
                                              title:
                                                  "${AppString.phoneNumber.tr}",
                                              subtitle:
                                                  data?.contactPhone ?? "",
                                            ),
                                            commonRow(
                                              title: "${AppString.email.tr}",
                                              subtitle:
                                                  data?.contactEmail ?? "",
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(5.w),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                AppColors.textFieldBorderColor,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: GestureDetector(
                                          onTap: () async {
                                            final latLong = LatLng(
                                              double.parse(
                                                data?.latitude ?? "0",
                                              ),
                                              double.parse(
                                                data?.longitude ?? "0",
                                              ),
                                            );
                                            final availableMaps =
                                                await MapLauncher.installedMaps;
                                            await availableMaps.first
                                                .showDirections(
                                                  destination: Coords(
                                                    latLong.latitude,
                                                    latLong.longitude,
                                                  ),
                                                );
                                          },
                                          child: CustomImage(
                                            image: IconAsset.mapIcon,
                                            wt: 30.w,
                                            ht: 30.w,
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ).paddingSymmetric(horizontal: 16.w),
                              8.verticalSpace,
                              ...List.generate(
                                (data?.operatingHours ?? []).length,
                                (index) {
                                  final day = data?.operatingHours?[index];
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: CommonText(
                                          string: "${day?.day ?? ""}",
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      Row(
                                        children: [
                                          Container(
                                            height: 10.w,
                                            width: 10.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: day?.isClosed == true
                                                  ? AppColors.redColor
                                                  : AppColors.greenColor,
                                            ),
                                          ),
                                          8.horizontalSpace,
                                          CommonText(
                                            string:
                                                "${Utils().time12Hr(day?.openTime ?? "")} - ${Utils().time12Hr(day?.closeTime ?? "")}",
                                          ),
                                        ],
                                      ),
                                    ],
                                  ).paddingOnly(
                                    left: 16.w,
                                    right: 16.w,
                                    bottom: 8.w,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ).paddingAll(16.w),
    );
  }

  Widget commonRow({required String title, required String subtitle}) {
    return Row(
      children: [
        CommonText(string: "${title} : ", fontWeight: FontWeight.w500),
        Expanded(child: CommonText(string: subtitle, softWrap: true)),
      ],
    );
  }
}
