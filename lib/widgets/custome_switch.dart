import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({Key? key, required this.value, required this.onChanged})
    : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 50.w,
        height: 30.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: widget.value
              ? AppColors.mainPrimaryColor
              : AppColors.textFieldBorderColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 300),
          alignment: widget.value
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: 27.h,
            height: 27.h,
            decoration: BoxDecoration(
              color: widget.value ? AppColors.blackColor : AppColors.whiteColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
