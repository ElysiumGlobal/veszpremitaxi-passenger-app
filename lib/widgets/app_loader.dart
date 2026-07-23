import 'dart:math' as math;

import 'package:e_taxi/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const double _kGapAngle = math.pi / 12;
const double _kMinAngle = math.pi / 36;

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    const Color color = AppColors.red;
    final double size = 50.h;
    final double ringWidth = size * 0.08;

    final CurvedAnimation firstRotationInterval = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    );

    final CurvedAnimation firstArchinterval = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
    );

    final CurvedAnimation secondRotationInterval = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    );

    final CurvedAnimation secondArchinterval = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeInOut),
    );

    return Center(
      child: Container(
        padding: EdgeInsets.all(size * 0.04),
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (_, __) {
            return _animationController.value <= 0.5
                ? Transform.rotate(
                    angle: Tween<double>(
                      begin: 0,
                      end: 4 * math.pi / 3,
                    ).animate(firstRotationInterval).value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        _Arc.draw(
                          color: color,
                          size: size,
                          strokeWidth: ringWidth,
                          startAngle: 7 * math.pi / 6,
                          endAngle: Tween<double>(
                            begin: 2 * math.pi / 3 - _kGapAngle,
                            end: _kMinAngle,
                          ).animate(firstArchinterval).value,
                        ),
                        _Arc.draw(
                          color: color,
                          size: size,
                          strokeWidth: ringWidth,
                          startAngle: math.pi / 2,
                          endAngle: Tween<double>(
                            begin: 2 * math.pi / 3 - _kGapAngle,
                            end: _kMinAngle,
                          ).animate(firstArchinterval).value,
                        ),
                        _Arc.draw(
                          color: color,
                          size: size,
                          strokeWidth: ringWidth,
                          startAngle: -math.pi / 6,
                          endAngle: Tween<double>(
                            begin: 2 * math.pi / 3 - _kGapAngle,
                            end: _kMinAngle,
                          ).animate(firstArchinterval).value,
                        ),
                      ],
                    ),
                  )
                : Transform.rotate(
                    angle: Tween<double>(
                      begin: 4 * math.pi / 3,
                      end: (4 * math.pi / 3) + (2 * math.pi / 3),
                    ).animate(secondRotationInterval).value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        _Arc.draw(
                          color: color,
                          size: size,
                          strokeWidth: ringWidth,
                          startAngle: 7 * math.pi / 6,
                          endAngle: Tween<double>(
                            begin: _kMinAngle,
                            end: 2 * math.pi / 3 - _kGapAngle,
                          ).animate(secondArchinterval).value,
                        ),
                        _Arc.draw(
                          color: color,
                          size: size,
                          strokeWidth: ringWidth,
                          startAngle: math.pi / 2,
                          endAngle: Tween<double>(
                            begin: _kMinAngle,
                            end: 2 * math.pi / 3 - _kGapAngle,
                          ).animate(secondArchinterval).value,
                        ),
                        _Arc.draw(
                          color: color,
                          size: size,
                          strokeWidth: ringWidth,
                          startAngle: -math.pi / 6,
                          endAngle: Tween<double>(
                            begin: _kMinAngle,
                            end: 2 * math.pi / 3 - _kGapAngle,
                          ).animate(secondArchinterval).value,
                        ),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class _Arc extends CustomPainter {
  final Color _color;
  final double _strokeWidth;
  final double _sweepAngle;
  final double _startAngle;

  _Arc._(this._color, this._strokeWidth, this._startAngle, this._sweepAngle);

  static Widget draw({
    required Color color,
    required double size,
    required double strokeWidth,
    required double startAngle,
    required double endAngle,
  }) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: _Arc._(color, strokeWidth, startAngle, endAngle),
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.height / 2,
    );

    const bool useCenter = false;
    final Paint paint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _strokeWidth;

    canvas.drawArc(rect, _startAngle, _sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
