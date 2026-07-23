import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/cachenetworkimage.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../utils/constants.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/no_data_widget.dart';

class OfferScreen extends StatefulWidget {
  final String vehicleId;
  final String offerCode;

  const OfferScreen({
    required this.offerCode,
    required this.vehicleId,
    super.key,
  });

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  ScrollController offerScrollController = ScrollController();
  final homeController = Get.find<HomeController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.microtask(() {
      vehicleId = widget.vehicleId;
      offerController.text = widget.offerCode;
      homeController.getOfferList(isFirst: true, rideType: vehicleId);
      offerScrollController.addListener(() {
        if (offerScrollController.position.pixels >=
                offerScrollController.position.maxScrollExtent - 300 &&
            homeController.offerPaginationLoading.value == false &&
            homeController.isMoreOfferList) {
          homeController.offerPaginationLoading(true);
          homeController.getOfferList(isFirst: false, rideType: vehicleId);
        }
      });
    });
  }

  String vehicleId = "";

  TextEditingController offerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(centerTitle: false, title: AppString.offers.tr),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.offerCode.isNotEmpty)
              GestureDetector(
                onTap: () async {
                  final data = await homeController.removePromoCode(
                    int.parse(
                      homeController
                              .bookingCreateModel
                              .value
                              ?.data
                              ?.booking
                              ?.id ??
                          AppConstant().bookingId,
                    ),
                  );

                  if (data.isNotEmpty) {
                    Navigation.pop(data: {});
                    AppSnackBar.showErrorSnackBar(message: data['message']);
                  }
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: CommonText(
                    string: "Remove ",
                    color: AppColors.errorColor,
                    fontSize: 16.sp,
                  ).paddingOnly(bottom: 4.h),
                ),
              ),
            CustomTextField(
              controller: offerController,
              fillColor: AppColors.whiteGrey,
              hintText: "Enter the code",
              suffixWidget: GestureDetector(
                onTap: () async {
                  final res = await homeController.applyCouponCode(
                    code: offerController.text.trim(),
                    bookingId:
                        homeController
                            .bookingCreateModel
                            .value
                            ?.data
                            ?.booking
                            ?.id ??
                        "0",
                    rideTypeId: vehicleId,
                  );

                  if (res.isNotEmpty) {
                    Navigation.pop(data: res);
                    AppSnackBar.showErrorSnackBar(message: res['message']);
                  }
                },
                child: Padding(
                  padding: EdgeInsetsGeometry.all(8.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: AppColors.mainPrimaryColor,
                    ),
                    child: CommonText(string: AppString.apply.tr),
                  ),
                ),
              ),
            ),

            22.verticalSpace,
            Obx(
              () => homeController.offerLoading.value
                  ? Expanded(
                      child: ListView.separated(
                        separatorBuilder: (context, index) {
                          return 16.verticalSpace;
                        },
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Skeletonizer(
                            enabled: true,
                            child: Container(
                              height: 172.h,
                              width: double.maxFinite,
                              color: AppColors.whiteColor,
                            ),
                          );
                        },
                      ),
                    )
                  : homeController.offerList.isEmpty
                  ? Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await homeController.getOfferList(
                            isFirst: true,
                            rideType: vehicleId,
                          );
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
                                  child: NoDataWidget(
                                    icon: ImagesAsset.noData,
                                    title: AppString.noDataAvailable.tr,
                                    subTitle: AppString.weNotFindAnything.tr,
                                    onTap: () {},
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await homeController.getOfferList(
                            isFirst: true,
                            rideType: vehicleId,
                          );
                        },
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: homeController.offerList.length,
                          itemBuilder: (context, index) {
                            final data = homeController.offerList[index];
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:
                                  (data.applicableRideTypes ?? []).length,

                              itemBuilder: (context, subindex) {
                                return Container(
                                  height: 175.h,
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.textFieldBorderColor,
                                      width: 1.5.w,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            height: 54.w,
                                            width: 54.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.mainPrimaryColor,
                                            ),
                                            alignment: Alignment.center,
                                            child: NetworkImageWidget(
                                              image:
                                                  data
                                                      .applicableRideTypes?[subindex]
                                                      .icon ??
                                                  "",
                                              ht: 35.w,
                                              wt: 35.w,
                                            ),
                                          ),

                                          GestureDetector(
                                            onTap: () async {
                                              offerController.text =
                                                  data.code ?? "";
                                              final res = await homeController
                                                  .applyCouponCode(
                                                    code: offerController.text
                                                        .trim(),
                                                    bookingId:
                                                        homeController
                                                            .bookingCreateModel
                                                            .value
                                                            ?.data
                                                            ?.booking
                                                            ?.id ??
                                                        "0",
                                                    rideTypeId: vehicleId,
                                                  );

                                              if (res.isNotEmpty) {
                                                Navigation.pop(data: res);
                                                AppSnackBar.showErrorSnackBar(
                                                  message: res['message'],
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12.w,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                color: AppColors.blackColor,
                                              ),
                                              child: CommonText(
                                                string: AppString.apply.tr,
                                                color: AppColors.whiteColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      10.horizontalSpace,

                                      SizedBox(
                                        width: 10.w,

                                        child: DottedLine(
                                          direction: Axis.vertical,
                                          lineLength: double.infinity,
                                          lineThickness: 2,
                                          dashLength: 5,
                                          dashColor:
                                              AppColors.textFieldBorderColor,
                                        ),
                                      ),
                                      6.horizontalSpace,

                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CommonText(
                                              string: data.firstRowText ?? "",
                                              maxLines: 2,
                                              softWrap: true,
                                            ),
                                            AutoSizeText(
                                              "${data.type == "percentage" ? 'Get' : "Flat"} ${Utils.formatCurrency(data.value ?? "")} ${data.type == "percentage" ? '% ' : ""}Off your ride. Minimum fare ${Utils.formatCurrency(data.minOrderAmount ?? "")}",

                                              maxLines: 2,
                                            ),

                                            CommonText(
                                              string:
                                                  'Valid Upto: ${Utils().convertDate(data.createdAt ?? "")} - ${Utils().convertDate(data.expiresAt ?? "")} ',
                                              maxLines: 2,
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),

                                      6.horizontalSpace,
                                      SizedBox(
                                        width: 10.w,
                                        child: DottedLine(
                                          direction: Axis.vertical,
                                          lineLength: double.infinity,
                                          lineThickness: 2,
                                          dashLength: 5,
                                          dashColor:
                                              AppColors.textFieldBorderColor,
                                        ),
                                      ),
                                      6.horizontalSpace,
                                      RotatedBox(
                                        quarterTurns: 1,
                                        child: CommonText(
                                          string: data.code ?? "",
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: CustomButton(text: AppString.continueString.tr),
        ),
      ),
    );
  }
}

class OfferTicketWidget extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String subtitle;
  final VoidCallback? onApply;

  const OfferTicketWidget({
    required this.iconData,
    required this.title,
    required this.subtitle,
    this.onApply,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        height: 96,
        child: Stack(
          children: [
            Positioned.fill(
              child: PhysicalShape(
                color: AppColors.whiteColor,
                elevation: 2,
                shadowColor: AppColors.black12,
                clipper: TicketClipper(),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 10, 6, 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.black12,
                              child: Icon(
                                iconData,
                                color: AppColors.blackColor,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 13 / pixelRatio,
                                  color: AppColors.black87,
                                  height: 1.33,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blackColor,
                                foregroundColor: AppColors.whiteColor,
                                minimumSize: Size(48, 34),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              onPressed: onApply,
                              child: Text(
                                'Apply',
                                style: TextStyle(fontSize: 14 / pixelRatio),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 2,
                      child: CustomPaint(
                        painter: DashLinePainter(),
                        child: SizedBox(height: double.infinity),
                      ),
                    ),
                    Container(
                      width: 56,
                      alignment: Alignment.center,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15 / pixelRatio,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double curveRadius = 10;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - 56, 0)
      ..arcToPoint(
        Offset(size.width - 56, curveRadius),
        radius: Radius.circular(curveRadius),
        clockwise: false,
      )
      ..lineTo(size.width - 56, size.height / 2 - curveRadius)
      // Right tab mid notch
      ..arcToPoint(
        Offset(size.width - 56, size.height / 2 + curveRadius),
        radius: Radius.circular(curveRadius),
        clockwise: true,
      )
      ..lineTo(size.width - 56, size.height - curveRadius)
      // Right tab bottom notch
      ..arcToPoint(
        Offset(size.width - 56 + curveRadius, size.height),
        radius: Radius.circular(curveRadius),
        clockwise: false,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Painter for vertical dashed divider
class DashLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double dashHeight = 6, dashSpace = 4;
    final paint = Paint()
      ..color = AppColors.grey400
      ..strokeWidth = 1;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
