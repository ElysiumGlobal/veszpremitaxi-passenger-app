import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';

class LogUtils {
  static showLogs({String? tag, String? message}) {
    if (!kDebugMode) {
      return;
    }
    if (!kReleaseMode) {
      log(message ?? '', name: tag ?? '');
    }
  }

  static void printError(String text) {
    if (!kDebugMode) {
      return;
    }
    if (Platform.isAndroid) {
      debugPrint('\x1B[91m$text\x1B[0m');
    } else {
      debugPrint(text);
    }
  }

  static void printSuccess(String text) {
    if (!kDebugMode) {
      return;
    }
    if (Platform.isAndroid) {
      debugPrint('\x1B[92m$text\x1B[0m');
    } else {
      debugPrint(text);
    }
  }

  static void printWarning(String text) {
    if (!kDebugMode) {
      return;
    }
    if (Platform.isAndroid) {
      debugPrint('\x1B[93m$text\x1B[0m');
    } else {
      debugPrint(text);
    }
  }

  static void printAction(String text) {
    if (!kDebugMode) {
      return;
    }
    if (Platform.isAndroid) {
      debugPrint('\x1B[94m$text\x1B[0m');
    } else {
      debugPrint(text);
    }
  }

  static void printCancel(String text) {
    if (!kDebugMode) {
      return;
    }
    if (Platform.isAndroid) {
      debugPrint('\x1B[96m$text\x1B[0m');
    } else {
      debugPrint(text);
    }
  }

  static void printWhite(String text) {
    if (!kDebugMode) {
      return;
    }
    if (Platform.isAndroid) {
      debugPrint('\x1B[97m$text\x1B[0m');
    } else {
      debugPrint(text);
    }
  }
}
