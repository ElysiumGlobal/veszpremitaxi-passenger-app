import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({
    required this.image,
    this.ht,
    this.fit,
    this.wt,
    this.color,
    super.key,
  });

  final String image;
  final double? ht;
  final double? wt;
  final BoxFit? fit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return image.contains(".svg")
        ? SvgPicture.asset(
            image,
            width: wt,
            height: ht,
            fit: fit ?? BoxFit.cover,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
          )
        : Image.asset(
            image,
            height: ht,
            width: wt,
            fit: fit ?? BoxFit.cover,
            color: color,
          );
  }
}
