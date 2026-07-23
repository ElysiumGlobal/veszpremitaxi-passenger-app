import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class DottedWidget extends StatelessWidget {
  const DottedWidget({this.direction, super.key});

  final Axis? direction;

  @override
  Widget build(BuildContext context) {
    return DottedLine(
      direction: direction ?? Axis.horizontal,
      lineLength: double.infinity,
      lineThickness: 2,
      dashLength: 5,
      dashColor: AppColors.textFieldBorderColor,
    );
  }
}
