import 'package:flutter/material.dart';

extension $BuildContextExtension on BuildContext {
  NavigatorState get navigator => Navigator.of(this);
}
