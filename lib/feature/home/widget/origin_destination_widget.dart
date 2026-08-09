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
    required Color foregroundColor,
    required Color bubbleColor,
    Animation<double>? pulse,
  }) {
    final child = Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bubbleColor,
        border: Border.all(
          color: foregroundColor.withValues(alpha: .18),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: foregroundColor, size: 17.w),
    );

    if (pulse == null) return child;

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, widget) {
        final value = pulse.value;
        return Transform.scale(
          scale: .95 + (value * .08),
          child: Opacity(opacity: .72 + (value * .28), child: widget),
        );
      },
      child: child,
    );
  }

  Widget _locationCard({
    required Color backgroundColor,
    required Color foregroundColor,
    required Color labelColor,
    required Color bubbleColor,
    required IconData icon,
    required String label,
    required Widget child,
    Animation<double>? pulse,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: backgroundColor == AppColors.mainPrimaryColor
              ? AppColors.brandNavy.withValues(alpha: .08)
              : AppColors.brandNavy.withValues(alpha: .12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandNavy.withValues(alpha: .08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _iconBubble(
            icon: icon,
            foregroundColor: foregroundColor,
            bubbleColor: bubbleColor,
            pulse: pulse,
          ),
          9.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  string: label,
                  color: labelColor,
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
          backgroundColor: AppColors.brandNavy,
          foregroundColor: AppColors.mainPrimaryColor,
          labelColor: AppColors.whiteColor.withValues(alpha: .72),
          bubbleColor: AppColors.whiteColor.withValues(alpha: .10),
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
            padding: EdgeInsets.only(left: 26.w),
            child: SizedBox(
              height: 12.h,
              child: DottedLine(
                direction: Axis.vertical,
                lineLength: 12.h,
                lineThickness: 2,
                dashLength: 4,
                dashColor: AppColors.mainPrimaryColor.withValues(alpha: .72),
              ),
            ),
          ),
        ] else
          5.verticalSpace,
        _locationCard(
          backgroundColor: AppColors.mainPrimaryColor,
          foregroundColor: AppColors.brandNavy,
          labelColor: AppColors.brandNavy.withValues(alpha: .68),
          bubbleColor: AppColors.whiteColor.withValues(alpha: .46),
          icon: Icons.location_on_rounded,
          label: destinationLabel,
          pulse: showTextField ? destinationPulse : null,
          child: showTextField
              ? TextField(
                  controller: controller,
                  textAlign: TextAlign.start,
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: AppColors.brandNavy,
                  style: TextStyle(
                    color: AppColors.brandNavy,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        destinationHint ??
                        VTaxiLocalizationService.text(
                          'vtaxi.destination.enter_address',
                          'Írd be a címet',
                        ),
                    hintStyle: TextStyle(
                      color: AppColors.brandNavy.withValues(alpha: .66),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
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
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandNavy,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ],
    );
  }
}
