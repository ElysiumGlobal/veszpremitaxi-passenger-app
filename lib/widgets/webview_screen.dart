import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/utils.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({required this.webUrl, super.key});

  final String webUrl;

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  late WebViewController webViewController;

  List<String> urlList = [
    AppConstant().aboutUs,
    AppConstant().termsCondition,
    AppConstant().privacyPolicy,
    AppConstant().contactUs,
  ];

  List<String> name = [
    AppString.aboutUs,
    AppString.termCondition,
    AppString.privacyPolicy,
    AppString.contctUs,
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
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
      ..loadRequest(Uri.parse(widget.webUrl));
  }

  RxBool isLoading = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(
        centerTitle: false,
        automaticallyImplyLeading: true,
        title: name[urlList.indexOf(widget.webUrl)],
      ),

      body: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Obx(
          () => isLoading.value
              ? Center(child: CircularProgressIndicator())
              : WebViewWidget(controller: webViewController),
        ),
      ),
    );
  }
}
