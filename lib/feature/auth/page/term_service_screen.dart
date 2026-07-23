import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/navigation_utils/routes.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/utils.dart';

class TermServiceScreen extends StatefulWidget {
  const TermServiceScreen({super.key});

  @override
  State<TermServiceScreen> createState() => _TermServiceScreenState();
}

class _TermServiceScreenState extends State<TermServiceScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            isLoading.value = false;
          },
          onHttpError: (HttpResponseError error) {
            isLoading.value = false;
          },
          onWebResourceError: (WebResourceError error) {
            isLoading.value = false;
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(AppConstant().termsCondition));
  }

  RxBool isLoading = true.obs;
  late WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.whiteGrey,
        appBar: CustomAppBar(
          automaticallyImplyLeading: false,

          title: AppString.termOfService.tr,
          centerTitle: false,
          leadingSize: 48.w,
        ),
        body: SafeArea(
          bottom: Utils().checkPlatForm,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Obx(
                    () => isLoading.value
                        ? Center(child: CircularProgressIndicator())
                        : WebViewWidget(controller: webViewController),
                  ),
                ),

                CustomButton(
                  text: AppString.accept.tr,
                  onTap: () {
                    Navigation.replaceAll(Routes.dashboardScreen);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
