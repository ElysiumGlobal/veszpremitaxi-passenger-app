import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

import '../widgets/app_loader.dart';

mixin LoadingMixin {
  void handleLoading(bool isLoading) {
    if (isLoading) {
      _startLoading();
    } else {
      _stopLoading();
    }
  }

  Route? _dialogRoute;

  BuildContext get context => Get.context!;

  Route _buildDialogRoute(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return DialogRoute(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.blackColor.withValues(alpha: 0.6),
      useSafeArea: true,
      settings: const RouteSettings(name: "/loading_dialog"),
      builder: (context) =>
          const PopScope(canPop: false, child: LoadingIndicator()),
    );
  }

  void _startLoading() {
    if (_dialogRoute != null) return;
    _dialogRoute = _buildDialogRoute(context);
    context.navigator.push(_dialogRoute!);
  }

  void _stopLoading() {
    if (_dialogRoute != null) context.navigator.removeRoute(_dialogRoute!);
    _dialogRoute = null;
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  }
}
