import 'dart:io';
import 'dart:ui' as ui;
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_snackbar.dart';
import 'api_constants.dart';
import 'app_string.dart';
import 'constants.dart';
import 'loading_mixin.dart';

import 'package:flutter_svg/svg.dart';

class Utils with LoadingMixin {
  Utils._();

  static final Utils _internal = Utils._();

  factory Utils() => _internal;

  static void hideKeyboardInApp(BuildContext context) {
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  BitmapDescriptor? customIcon;
  BitmapDescriptor? sourceMarkerIcon;
  BitmapDescriptor? destinationMarkerIcon;
  BitmapDescriptor? carIcon;

  static const double vehicleMarkerSize = 48;
  static const int vehicleMarkerAssetTargetWidth = 84;

  static String resolveNetworkImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final path = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    if (path.startsWith('storage/')) {
      return '${ApiConstants.domain}/$path';
    }
    return '${ApiConstants.domain}/storage/$path';
  }

  Future<void> setCurrentMarker() async {
    customIcon = await getMarkerIcon(IconAsset.userLocation, 60);
  }

  Future<void> setRouteMarkers() async {
    sourceMarkerIcon = await getMarkerIcon(
      IconAsset.pickupMarker,
      128,
      displaySize: 52,
    );
    destinationMarkerIcon = await getMarkerIcon(
      IconAsset.destinationMarker,
      128,
      displaySize: 52,
    );
  }

  Future<void> setCarMarker() async {
    carIcon = await getMarkerIcon(
      IconAsset.driverMarker,
      128,
      displaySize: 54,
    );
  }

  Future<BitmapDescriptor> getMarkerIcon(
    String path,
    int targetWidth, {
    double displaySize = 35,
  }) async {
    final ByteData data = await rootBundle.load(path);

    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: targetWidth,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List bytes = (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    return BitmapDescriptor.bytes(
      bytes,
      height: displaySize,
      width: displaySize,
    );
  }

  Future<BitmapDescriptor?> _getMarkerIconFromUrl(String path) async {
    try {
      final resolvedUrl = resolveNetworkImageUrl(path);
      const logicalSize = vehicleMarkerSize;

      final response = await http.get(Uri.parse(resolvedUrl));
      if (response.statusCode != 200) {
        LogUtils.printAction(
          'Failed to load marker from $resolvedUrl (${response.statusCode})',
        );
        return null;
      }

      final ui.Codec codec = await ui.instantiateImageCodec(
        response.bodyBytes,
        targetWidth: logicalSize.round(),
      );
      final ui.FrameInfo fi = await codec.getNextFrame();
      final byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      return BitmapDescriptor.bytes(
        byteData.buffer.asUint8List(),
        width: logicalSize,
        height: logicalSize,
      );
    } catch (e) {
      LogUtils.printAction('marker URL error: $e');
      return null;
    }
  }

  Future<BitmapDescriptor?> _svgNetworkToBitmapDescriptor(
    String svgUrl, {
    double width = vehicleMarkerSize,
    double height = vehicleMarkerSize,
  }) async {
    try {
      final resolvedUrl = resolveNetworkImageUrl(svgUrl);
      final response = await http.get(Uri.parse(resolvedUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load SVG from $resolvedUrl');
      }

      final pictureInfo = await vg.loadPicture(
        SvgStringLoader(response.body),
        null,
      );

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.scale(
        width / pictureInfo.size.width,
        height / pictureInfo.size.height,
      );
      canvas.drawPicture(pictureInfo.picture);

      final image = await recorder.endRecording().toImage(
        width.round(),
        height.round(),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return null;

      return BitmapDescriptor.bytes(
        bytes.buffer.asUint8List(),
        width: width.toDouble(),
        height: height.toDouble(),
      );
    } catch (e) {
      LogUtils.printAction('SVG marker error: $e');
      return null;
    }
  }

  Future<BitmapDescriptor> ensureCarIcon() async {
    if (carIcon != null) return carIcon!;
    await setCarMarker();
    return carIcon ?? BitmapDescriptor.defaultMarker;
  }

  Future<BitmapDescriptor?> markerUrlToSet(String url) async {
    try {
      if (url.toLowerCase().contains('.svg')) {
        return _svgNetworkToBitmapDescriptor(url);
      }
      return _getMarkerIconFromUrl(url);
    } catch (e) {
      LogUtils.printAction('markerUrlToSet error: $e');
      return null;
    }
  }

  String convertFullTime(String dateStr) {
    if (dateStr.isEmpty) {
      return "";
    }
    DateTime dateTime = DateTime.parse(dateStr).toLocal();

    return DateFormat("yyyy. MM. dd. HH:mm").format(dateTime);
  }

  String convertDate(String dateStr) {
    if (dateStr.isEmpty) {
      return "";
    }
    DateTime dateTime = DateTime.parse(dateStr).toLocal();

    return DateFormat("yyyy. MM. dd.").format(dateTime);
  }

  List<String> getString(String address) {
    List<String> data = ['', ''];

    if (address.isNotEmpty) {
      int commaIndex = address.indexOf(',');
      if (commaIndex != -1) {
        data[0] = address.substring(0, commaIndex).trim();
        data[1] = address.substring(commaIndex + 1).trim();
      } else {
        data[0] = address.trim();
        data[1] = "";
      }
    }

    return data;
  }

  Future<void> launchDialer(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch dialer for $phoneNumber';
    }
  }

  Future<void> launchWeb(String url) async {
    try {
      Uri uri = Uri.parse(url);
      await launchUrl(uri);
    } catch (e) {
      LogUtils.printAction("e:$e");
    }
  }

  static final List _languageList = [
    {
      "languageName": "Magyar",
      "local": const ui.Locale('hu', 'HU'),
    },
  ];

  static updateLanguage(index) {
    const locale = ui.Locale('hu', 'HU');
    Get.updateLocale(locale);
    return locale;
  }

  String getdateTimeDateWise({required String date}) {
    if (date.isEmpty) {
      return "";
    }

    DateTime getTime = DateTime.parse(date);
    DateTime nowUtc = DateTime.now().toUtc();
    DateTime now = DateTime(
      nowUtc.year,
      nowUtc.month,
      nowUtc.day,
      nowUtc.hour,
      nowUtc.minute,
      nowUtc.second,
      nowUtc.millisecond,
    );

    Duration duration = now.difference(getTime).abs();

    if (duration.inSeconds < 60) {
      return '${duration.inSeconds} másodperc';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} perc';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} óra';
    } else if (duration.inDays < 7) {
      return '${duration.inDays} nap';
    } else {
      final weeks = (duration.inDays / 7).floor();
      if (weeks < 52) {
        return '$weeks hét';
      } else {
        final years = (weeks / 52).floor();
        return '$years év';
      }
    }
  }

  static String formatCurrency(String? amount) {
    final rawAmount = (amount == null || amount.trim().isEmpty)
        ? "0"
        : amount.trim();
    final normalizedAmount = rawAmount
        .replaceAll(RegExp(r'[^0-9,.-]'), '')
        .replaceAll(',', '');

    final finalAmount = double.tryParse(normalizedAmount) ?? 0;

    final format = NumberFormat.currency(
      locale: 'hu_HU',
      symbol: 'Ft',
      decimalDigits: 0,
    );

    return format.format(finalAmount);
  }

  String time(String timeString) {
    if (timeString.isEmpty) {
      return "";
    }
    DateTime dt = DateTime.parse(timeString).toLocal();

    return DateFormat('HH:mm').format(dt);
  }

  Future<void> downloadPdf(String url, String fileName) async {
    try {
      handleLoading(true);

      if (Platform.isAndroid) {
        if (await _isAndroid13OrAbove()) {
        } else {
          var status = await Permission.storage.request();
          if (!status.isGranted) {
            return;
          }
        }
      }

      Directory? dir;

      if (Platform.isAndroid) {
        if (await _isAndroid13OrAbove()) {
          dir = await getDownloadsDirectory();
          dir ??= await getExternalStorageDirectory();
        } else {
          dir = Directory('/storage/emulated/0/Download');
          if (!await dir.exists()) {
            dir = await getExternalStorageDirectory();
          }
        }
      } else if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      }

      if (dir == null) {
        return;
      }

      final filePath = '${dir.path}/$fileName.pdf';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        AppSnackBar.showErrorSnackBar(
          message: AppString.receiptSaveSuuccessflly.tr,
        );
        handleLoading(false);
        await OpenFilex.open(filePath);
      } else {
        AppSnackBar.showErrorSnackBar(
          message: AppString.tryAgain.tr,
          isError: true,
        );
      }
    } catch (e) {
      AppSnackBar.showErrorSnackBar(
        message: AppString.tryAgain.tr,
        isError: true,
      );
    } finally {
      handleLoading(false);
    }
  }

  Future<bool> _isAndroid13OrAbove() async {
    if (!Platform.isAndroid) return false;
    final version = await _getAndroidSdkInt();
    return version >= 33;
  }

  Future<int> _getAndroidSdkInt() async {
    try {
      final sdk = await File('/system/build.prop')
          .readAsLines()
          .then(
            (lines) => lines.firstWhere(
              (l) => l.startsWith('ro.build.version.sdk'),
          orElse: () => '',
        ),
      )
          .then((line) => int.tryParse(line.split('=').last.trim()) ?? 0);
      return sdk;
    } catch (_) {
      return 33;
    }
  }

  bool checkPlatForm = Platform.isAndroid;
}
