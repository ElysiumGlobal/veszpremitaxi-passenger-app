import 'dart:io';
import 'dart:ui' as ui;

import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_string.dart';
import 'assets.dart';

class Utils with LoadingMixin {
  static void hideKeyboardInApp(BuildContext context) {
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  Utils._();

  static Utils _internal = Utils._();

  factory Utils() => _internal;

  static const double mapVehicleIconLogicalSize = 35;

  BitmapDescriptor? customIcon;
  BitmapDescriptor? carIcon;
  BitmapDescriptor? driverIcon;
  BitmapDescriptor? pickupIcon;
  BitmapDescriptor? destinationIcon;

  double _devicePixelRatio() {
    final context = Get.context;
    if (context != null) {
      return MediaQuery.devicePixelRatioOf(context);
    }
    return WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  }

  Future<void> setCurrentMarker() async {
    pickupIcon = await getMarkerIcon(
      IconAsset.pickupMarker,
      logicalSize: 42,
    );
    destinationIcon = await getMarkerIcon(
      IconAsset.destinationMarker,
      logicalSize: 42,
    );
    customIcon = pickupIcon;
  }

  Future<void> setCarMarker() async {
    driverIcon = await getMarkerIcon(
      IconAsset.driverMarker,
      logicalSize: 46,
    );
    carIcon = driverIcon;
  }

  Future<BitmapDescriptor> getMarkerIcon(
    String path, {
    double logicalSize = mapVehicleIconLogicalSize,
  }) async {
    final double dpr = _devicePixelRatio();
    final int physicalSize = (logicalSize * dpr).round();

    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: physicalSize,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List bytes = (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    return BitmapDescriptor.bytes(
      bytes,
      width: logicalSize,
      height: logicalSize,
    );
  }

  Future<XFile?> getImage({ImageSource source = ImageSource.gallery}) async {
    return await ImagePicker().pickImage(source: source, imageQuality: 40);
  }

  Future<BitmapDescriptor?> _getMarkerIconFromUrl(String path) async {
    const double logicalSize = mapVehicleIconLogicalSize;
    final double dpr = _devicePixelRatio();

    final response = await http.get(Uri.parse(path));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image from $path');
    }
    final Uint8List bytes = response.bodyBytes;

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: (logicalSize * dpr).round(),
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image image = fi.image;

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List resizedBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(
      resizedBytes,
      width: logicalSize,
      height: logicalSize,
    );
  }

  Future<BitmapDescriptor?> _svgNetworkToBitmapDescriptor(
    String svgUrl, {
    double logicalSize = mapVehicleIconLogicalSize,
  }) async {
    try {
      final response = await http.get(Uri.parse(svgUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load SVG from $svgUrl');
      }
      final String svgString = response.body;

      final PictureInfo pictureInfo = await vg.loadPicture(
        SvgStringLoader(svgString),
        null,
      );

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(recorder);

      final double dpr = _devicePixelRatio();

      canvas.scale(
        logicalSize * dpr / pictureInfo.size.width,
        logicalSize * dpr / pictureInfo.size.height,
      );

      canvas.drawPicture(pictureInfo.picture);

      final ui.Picture scaledPicture = recorder.endRecording();

      final ui.Image image = await scaledPicture.toImage(
        (logicalSize * dpr).round(),
        (logicalSize * dpr).round(),
      );

      final ByteData? bytes = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return BitmapDescriptor.bytes(
        bytes!.buffer.asUint8List(),
        width: logicalSize,
        height: logicalSize,
      );
    } catch (e) {
      return null;
    }
  }

  Future<BitmapDescriptor?> markerUrlToSet(String url) async {
    if (url.contains(".svg")) {
      return _svgNetworkToBitmapDescriptor(url);
    } else {
      return _getMarkerIconFromUrl(url);
    }
  }

  Future selectDate({DateTime? firstDate, DateTime? lastDate}) async {
    return await showDatePicker(
      context: Get.context!,
      firstDate: DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      currentDate: firstDate ?? DateTime.now(),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String dateSendServer(String date) {
    print("DATE::$date");
    final parsedDate = DateFormat("dd/MM/yyyy").parse(date);
    print(">>>$parsedDate:::${date}");
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  String dateSendServer1(String dates) {
    final date = DateTime.parse(dates);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String serverToShow(String date) {
    if (date.isEmpty) return "";
    final parsedDate = DateFormat("yyyy-MM-dd").parse(date);
    print(">>>$parsedDate:::${date}");
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  DateTime? stringToDateTime(String date) {
    if (date.isEmpty) return null;
    return DateFormat("dd/MM/yyyy").parse(date);
  }

  DateTime? calenderDate(String date) {
    if (date.isEmpty) return null;
    return DateTime.parse(date);
  }

  String convertFullTime(String dateStr) {
    if (dateStr.isEmpty) {
      return "";
    }
    try {
      DateTime dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat("yyyy.MM.dd. HH:mm").format(dateTime);
    } catch (e) {
      return dateStr;
    }
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

  String serverDesDate(DateTime time) {
    return DateFormat("yyyy-MM-dd").format(time);
  }

  Future<void> launchDialer(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch dialer for $phoneNumber';
    }
  }

  String dateMonth(DateTime date) {
    return DateFormat("d MMM").format(date);
  }

  bool checkPlatForm = Platform.isAndroid;

  String dateMonthWeek(int a) {
    DateTime now = DateTime.now().subtract(Duration(days: 7 * a));

    DateTime from = now.subtract(Duration(days: now.weekday - 1));
    DateTime to = now.add(Duration(days: DateTime.daysPerWeek - now.weekday));
    return "${Utils().dateMonth(from)} - ${Utils().dateMonth(to)}";
  }

  Map<String, String> getWeekRange(int week) {
    DateTime currentWeekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );

    currentWeekStart = currentWeekStart.subtract(Duration(days: 7 * week));

    DateTime weekStart = currentWeekStart;
    DateTime weekEnd = currentWeekStart.add(const Duration(days: 6));

    return {"start": serverDesDate(weekStart), "end": serverDesDate(weekEnd)};
  }

  Future<void> downloadPdf(String url, String fileName) async {
    try {
      handleLoading(true);
      if (Platform.isAndroid) {
        if (await _isAndroid13OrAbove()) {
          print("Android 13+ → No storage permission required");
        } else {
          var status = await Permission.storage.request();
          if (!status.isGranted) {
            print('❌ Storage permission not granted');
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
        print("❌ Couldn't get storage directory");
        return;
      }

      final filePath = '${dir.path}/$fileName.pdf';
      print("📁 Saving to: $filePath:::$url");

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print('✅ PDF saved successfully!');
        AppSnackBar.showErrorSnackBar(
          message: AppString.ReceiptSaveSuuccessflly.tr,
        );
        handleLoading(false);
        await OpenFilex.open(filePath);
      } else {
        print('❌ Failed to download. Status: ${response.statusCode}');
        AppSnackBar.showErrorSnackBar(
          message: AppString.tryAgain.tr,
          isError: true,
        );
      }
    } catch (e) {
      print('⚠️ Error: $e');
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

  String stringToTime(String time) {
    if (time.isEmpty) return "";

    return DateFormat('HH:mm').format(DateTime.parse(time));
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

    print("now:::${now}::input::$getTime");
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds} másodperce';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} perce';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} órája';
    } else if (duration.inDays < 7) {
      return '${duration.inDays} napja';
    } else {
      final int weeks = (duration.inDays / 7).floor();
      if (weeks < 52) {
        return '$weeks hete';
      }
      final int years = (weeks / 52).floor();
      return '$years éve';
    }
  }


  static String tripStatusLabel(String? value) {
    final status = (value ?? '').trim().toLowerCase();
    return switch (status) {
      'searching' => 'Sofőr keresése',
      'pending' => 'Függőben',
      'offered' => 'Kiküldve',
      'accepted' => 'Elfogadva',
      'arrived' => 'Sofőr megérkezett',
      'started' => 'Folyamatban',
      'completed' => 'Teljesítve',
      'cancelled' || 'canceled' => 'Lemondva',
      'cancelled by rider' => 'Utas által lemondva',
      'cancelled by driver' => 'Sofőr által lemondva',
      'expired' => 'Lejárt',
      '' => 'Ismeretlen',
      _ => value ?? 'Ismeretlen',
    };
  }

  static String paymentMethodLabel(String? value) {
    final method = (value ?? '').trim().toLowerCase();
    return switch (method) {
      'cash' => 'Készpénz',
      'wallet' => 'Tárca',
      'card' || 'online' || 'stripe' || 'razorpay' => 'Bankkártya / online',
      '' => 'Nincs megadva',
      _ => value ?? 'Nincs megadva',
    };
  }

  static String cancellationReasonLabel(String? value) {
    final reason = (value ?? '').trim();
    final normalized = reason.toLowerCase();
    return switch (normalized) {
      'passenger didn’t show up' ||
      "passenger didn't show up" ||
      'passenger not show up' => 'Az utas nem jelent meg',
      'wrong pickup location' => 'Hibás felvételi pont',
      'road closure/traffic issue' ||
      'road closure / traffic issue' => 'Útlezárás vagy forgalmi probléma',
      'passenger tacking to long' ||
      'passenger taking too long' => 'Az utas túl sokat késik',
      'safety concern' => 'Biztonsági ok',
      'other' => 'Egyéb',
      '' => 'Nincs megadva',
      _ => reason,
    };
  }

  static String formatDistance(dynamic value) {
    if (value == null) return '0 km';
    final raw = value.toString().trim();
    if (raw.isEmpty) return '0 km';
    if (raw.toLowerCase().contains('km')) return raw;
    final parsed = double.tryParse(raw.replaceAll(',', '.'));
    if (parsed == null) return '$raw km';
    final digits = parsed == parsed.roundToDouble() ? 0 : 1;
    return '${parsed.toStringAsFixed(digits)} km';
  }

  static String formatDuration(dynamic value) {
    if (value == null) return '0 perc';
    final raw = value.toString().trim();
    if (raw.isEmpty) return '0 perc';
    if (raw.toLowerCase().contains('perc')) return raw;
    final parsed = double.tryParse(raw.replaceAll(',', '.'));
    if (parsed == null) return '$raw perc';
    return '${parsed.round()} perc';
  }

  static String formatCurrency(String? amount) {
    try {
      if (amount == null || amount.isEmpty) {
        amount = "0.0";
      }

      num finalAmount = num.parse(amount.replaceAll(",", ""));

      final format = NumberFormat.currency(
        locale: Constants().local,
        symbol: NumberFormat.simpleCurrency(
          name: Constants().currency,
        ).currencySymbol,
      );
      return format.format(finalAmount);
    } catch (e, st) {
      print("EEEEE::::$e,$st");
      return "0.0";
    }
  }

  static final List _languageList = [
    {"languageName": "Magyar", "local": const ui.Locale('hu', 'HU')},
  ];

  static updateLanguage(index) {
    Get.updateLocale(_languageList[index]['local']);

    return _languageList[index]['local'];
  }

  String time12Hr(String time24) {
    if (time24.isEmpty) {
      return "";
    }
    DateTime dt = DateFormat("HH:mm:ss").parse(time24);

    return DateFormat("HH:mm").format(dt);
  }

  String time(String timeString) {
    if (timeString.isEmpty) {
      return "";
    }
    DateTime dt = DateTime.parse(timeString).toLocal();

    return DateFormat('HH:mm').format(dt);
  }
}
