import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/localization/vtaxi_localization_service.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/common_text.dart';

class OriginDestinationWidget extends StatelessWidget {
  const OriginDestinationWidget({
    this.controller,
    this.showTextField = false,
    this.onChange,
    this.customImage = false,
    required this.destination,
    required this.origin,
    this.showDotLine = true,
    this.destinationHint,
    this.destinationPulse,
    super.key,
  });

  final String origin;
  final bool customImage;
  final String destination;
  final bool showDotLine;
  final bool showTextField;
  final Function(String?)? onChange;
  final TextEditingController? controller;
  final String? destinationHint;
  final Animation<double>? destinationPulse;

  Widget _iconBubble({
    required IconData icon,
    required Color color,
    Animation<double>? pulse,
  }) {
    final child = Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.whiteColor.withValues(alpha: .18),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: .30),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.whiteColor, size: 18.w),
    );

    if (pulse == null) return child;

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, widget) {
        final value = pulse.value;
        return Transform.scale(
          scale: .94 + (value * .10),
          child: Opacity(opacity: .60 + (value * .40), child: widget),
        );
      },
      child: child,
    );
  }

  Widget _locationCard({
    required Color color,
    required IconData icon,
    required String label,
    required Widget child,
    Animation<double>? pulse,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(13.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _iconBubble(icon: icon, color: color, pulse: pulse),
          9.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  string: label,
                  color: AppColors.whiteColor.withValues(alpha: .82),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                ),
                2.verticalSpace,
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final originLabel = VTaxiLocalizationService.text(
      'vtaxi.location.origin_label',
      'Indulás',
    );
    final destinationLabel = VTaxiLocalizationService.text(
      'vtaxi.location.destination_label',
      'Érkezés',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _locationCard(
          color: AppColors.errorColor,
          icon: Icons.my_location_rounded,
          label: originLabel,
          child: CommonText(
            string: origin.trim().isEmpty
                ? VTaxiLocalizationService.text(
                    'vtaxi.location.origin_missing',
                    'Indulási hely kiválasztása',
                  )
                : origin,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.whiteColor,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showDotLine) ...[
          Padding(
            padding: EdgeInsets.only(left: 27.w),
            child: SizedBox(
              height: 14.h,
              child: DottedLine(
                direction: Axis.vertical,
                lineLength: 14.h,
                lineThickness: 2,
                dashLength: 4,
                dashColor: AppColors.textFieldBorderColor,
              ),
            ),
          ),
        ] else
          6.verticalSpace,
        _locationCard(
          color: AppColors.routeGreen,
          icon: Icons.location_on_rounded,
          label: destinationLabel,
          pulse: showTextField ? destinationPulse : null,
          child: showTextField
              ? TextField(
                  controller: controller,
                  textAlign: TextAlign.start,
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: AppColors.whiteColor,
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        destinationHint ??
                        VTaxiLocalizationService.text(
                          'vtaxi.destination.enter_address',
                          'Írd be a címet',
                        ),
                    hintStyle: TextStyle(
                      color: AppColors.whiteColor.withValues(alpha: .82),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  onChanged: onChange,
                )
              : CommonText(
                  string: destination.trim().isEmpty
                      ? VTaxiLocalizationService.text(
                          'vtaxi.location.destination_missing',
                          'Úti cél nincs megadva',
                        )
                      : destination,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ],
    );
  }
}
