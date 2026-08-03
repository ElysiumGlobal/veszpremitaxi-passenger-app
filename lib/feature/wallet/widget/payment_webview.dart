import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../utils/api_constants.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String webUrl;

  const PaymentWebViewScreen({required this.webUrl, super.key});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late WebViewController webViewController;

  bool inside = false;

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
          onPageStarted: (String url) {
            if (url.startsWith(
                  "${ApiConstants.domain}/api/payments/razorpay/callback",
                ) &&
                inside == false) {
              inside = true;
              Get.back(result: true);
            } else if (url.startsWith(
                  "${ApiConstants.domain}/api/payments/stripe/success",
                ) &&
                inside == false) {
              inside = true;
              Get.back(result: true);
            }
            print("URL:::$url");
          },
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.webUrl));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(child: WebViewWidget(controller: webViewController)),
    );
  }
}
