import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../utils/assets.dart';

class NetworkImageWidget extends StatelessWidget {
  const NetworkImageWidget({
    this.errorImage,
    this.boxFit = BoxFit.cover,
    this.ht,
    this.wt,
    required this.image,
    required this.radius,
    super.key,
  });

  final String image;
  final double? ht;
  final double? wt;
  final BoxFit boxFit;
  final String? errorImage;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: image.contains(".svg")
          ? SvgPicture.network(
              image,
              height: ht,
              width: wt,
              fit: boxFit,

              errorBuilder: (context, url, error) => errorImage != null
                  ? CustomImage(
                      image: errorImage!,
                      ht: ht,
                      wt: wt,
                      fit: BoxFit.cover,
                    )
                  : CustomImage(image: IconAsset.placeHolder, ht: ht, wt: wt),
              placeholderBuilder: (context) => Skeletonizer(
                enabled: true,
                child: Container(
                  height: ht,
                  width: wt,
                  color: AppColors.whiteColor,
                ),
              ),
            )
          : CachedNetworkImage(
              imageUrl: image,
              height: ht,
              width: wt,
              fit: boxFit,
              errorWidget: (context, url, error) => errorImage != null
                  ? CustomImage(
                      image: errorImage!,
                      ht: ht,
                      wt: wt,
                      fit: BoxFit.cover,
                    )
                  : CustomImage(image: IconAsset.placeHolder, ht: ht, wt: wt),
              placeholder: (context, url) => Skeletonizer(
                enabled: true,
                child: Container(
                  height: ht,
                  width: wt,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
    );
  }
}
