import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatingBarWidget extends StatelessWidget {
  const RatingBarWidget({
    required this.selectedIndex,
    required this.onTap,
    super.key,
  });

  final int selectedIndex;
  final Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return GestureDetector(
            onTap: () {
              onTap(index);
            },
            child: CustomImage(
              image: ImagesAsset.selectedStar,
              ht: 16.w,
              wt: 16.w,
              color: index + 1 <= selectedIndex
                  ? AppColors.mainPrimaryColor
                  : AppColors.textFieldBorderColor,
            ),
          );
        }),
      ],
    );
  }
}
