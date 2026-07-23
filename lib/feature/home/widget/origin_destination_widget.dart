import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/assets.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custome_img.dart';

class OriginDestinationWidget extends StatelessWidget {
  const OriginDestinationWidget({
    this.controller,
    this.showTextField = false,
    this.onChange,
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

  final bool showTextField;
  final Function(String?)? onChange;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomImage(
              image: customImage ? IconAsset.originBw : IconAsset.originIcon,
            ),
            10.horizontalSpace,
            Expanded(
              child: CommonText(
                string: origin,
                fontSize: 14.sp,
                softWrap: true,
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
            CustomImage(
              image: customImage
                  ? IconAsset.destinationBw
                  : IconAsset.destinationIcon,
            ),
            10.horizontalSpace,
            Expanded(
              child: showTextField
                  ? SizedBox(
                      height: 30.h,
                      child: TextField(
                        controller: controller,
                        // center vertically
                        textAlign: TextAlign.start,
                        autofocus: true,
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: AppColors.mainPrimaryColor,
                        decoration: InputDecoration(
                          hintText: "Enter Destination",
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 1.w,
                            vertical: 0,
                          ),
                          isDense: true,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        onChanged: onChange,
                      ),
                    )
                  : CommonText(
                      string: destination == "" ? "Destination" : destination,
                      fontSize: 14.sp,
                      color: destination.isEmpty
                          ? AppColors.hintTextColor
                          : AppColors.titleTextColor,
                      softWrap: true,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
