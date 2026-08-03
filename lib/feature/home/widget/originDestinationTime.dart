import 'package:dotted_line/dotted_line.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../widgets/dotted_widget.dart';

class OriginDestinationTimeWidget extends StatelessWidget {
  const OriginDestinationTimeWidget({
    required this.dsubtitle,
    required this.dtitle,
    required this.osubtitle,
    required this.otitle,
    this.child,

    super.key,
  });

  final String otitle;
  final String osubtitle;
  final String dtitle;
  final String dsubtitle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        listWidget(true, otitle, osubtitle),
        Row(
          children: [
            Container(
              width: 14.w,
              height: 18.h,
              alignment: Alignment.center,
              child: CustomImage(image: ImagesAsset.line, wt: 14.w, ht: 18.h),
            ),
            Expanded(child: DottedWidget()),
            if (child != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.whiteColor,
                ),
                child: child,
              ),
          ],
        ),
        listWidget(false, dtitle, dsubtitle),
      ],
    );
  }

  Widget listWidget(bool origin, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomImage(
          image: origin ? IconAsset.originSvg : IconAsset.destinationSvg,
          ht: 18.w,
          wt: 18.w,
        ),
        8.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                string: title,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              if (subtitle.isNotEmpty)
                CommonText(
                  string: subtitle,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textCaptionColor,
                ).paddingOnly(top: 4.h),
            ],
          ),
        ),
      ],
    );
  }
}

class OriginDestinationWidget extends StatelessWidget {
  const OriginDestinationWidget({
    this.customImage = false,
    required this.destination,
    required this.origin,
    this.showDotLine = true,
    super.key,
  });

  final String origin;
  final bool customImage;
  final String destination;
  final bool showDotLine;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomImage(image: IconAsset.originBw),
            10.horizontalSpace,
            Expanded(
              child: CommonText(
                string: origin,
                fontSize: 14.sp,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        3.verticalSpace,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            9.horizontalSpace,
            Container(
              height: 30,
              width: 2,
              color: AppColors.textFieldBorderColor,
            ),
            10.horizontalSpace,

            Expanded(
              child: SizedBox(
                height: 30,
                child: showDotLine
                    ? Center(
                        child: DottedLine(
                          direction: Axis.horizontal,
                          lineLength: double.infinity,
                          lineThickness: 2,
                          dashLength: 5,
                          dashColor: AppColors.textFieldBorderColor,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
        3.verticalSpace,

        Row(
          children: [
            CustomImage(image: IconAsset.destinationBw),
            10.horizontalSpace,
            Expanded(
              child: CommonText(
                string: destination == "" ? "Destination" : destination,
                fontSize: 14.sp,
                color: destination.isEmpty
                    ? AppColors.hintTextColor
                    : AppColors.titleTextColor,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
