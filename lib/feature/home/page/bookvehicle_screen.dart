import 'dart:async';
import 'dart:ui' as ui;
import 'package:e_taxi/core/debug/passenger_flow_debug.dart';
import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/feature/home/model/create_booking_model.dart';
import 'package:e_taxi/feature/home/widget/select_vehicle.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custome_img.dart';
import '../model/origin_destination_model.dart';

class BookVehicleScreen extends StatefulWidget {
  const BookVehicleScreen({super.key});

  @override
  State<BookVehicleScreen> createState() => _BookVehicleScreenState();
}

class _BookVehicleScreenState extends State<BookVehicleScreen> {
  RxMap codeApply = {}.obs;
  final homeController = Get.find<HomeController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (Get.arguments != null) {
      originDestinationModel = Get.arguments;
      sourceLatLog = originDestinationModel?.oLatLng;
      destinationLatLog = originDestinationModel?.dLatLng;
      setMapMarkerPoliline();
      PassengerFlowDebug.send(
        'book_vehicle_screen_opened',
        data: <String, dynamic>{
          'pickup_ready': sourceLatLog != null,
          'destination_ready': destinationLatLog != null,
        },
      );
      loadEstimate();
      _createCustomMarker();
    }
  }

  Future<void> loadEstimate() async {
    final error = await homeController.estimateBooking(
      originLatLng: originDestinationModel?.oLatLng ?? const LatLng(0, 0),
      destinationLatLng:
          originDestinationModel?.dLatLng ?? const LatLng(0, 0),
    );

    if (error.isNotEmpty && mounted) {
      Get.back();
      AppSnackBar.showErrorSnackBar(
        message: error.split(":").last.trim(),
        isError: true,
      );
    }
  }

  OriginDestinationModel? originDestinationModel;

  Set<Marker> markers = {};
  Set<Polyline> _polyLines = <Polyline>{};

  void setMapMarkerPoliline() async {
    final polylinePoints = PolylinePoints(
      apiKey: homeController.placeApi ?? "",
    );
    final origin = PointLatLng(
      sourceLatLog!.latitude,
      sourceLatLog!.longitude,
    );
    final destination = PointLatLng(
      destinationLatLog!.latitude,
      destinationLatLog!.longitude,
    );

    List<PointLatLng> routePoints = [];

    final result = await polylinePoints.getRouteBetweenCoordinatesV2(
      request: RoutesApiRequest(
        origin: origin,
        destination: destination,
        travelMode: TravelMode.driving,
      ),
    );

    if (result.primaryRoute?.polylinePoints case List<PointLatLng> points) {
      routePoints = points;
    } else {
      final legacyResult = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: origin,
          destination: destination,
          mode: TravelMode.driving,
        ),
      );
      routePoints = legacyResult.points;
    }

    if (routePoints.isNotEmpty) {
      final polylineCoordinates = routePoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      _polyLines
        ..clear()
        ..add(
          Polyline(
            geodesic: false,
            visible: true,
            polylineId: const PolylineId('route_outline'),
            width: 9,
            zIndex: 1,
            color: AppColors.routeOutline,
            points: polylineCoordinates,
            endCap: Cap.roundCap,
            startCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        )
        ..add(
          Polyline(
            geodesic: false,
            visible: true,
            polylineId: const PolylineId('route_main'),
            width: 5,
            zIndex: 2,
            color: AppColors.routeGreen,
            points: polylineCoordinates,
            endCap: Cap.roundCap,
            startCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        );
    }

    setState(() {});
  }

  LatLng? sourceLatLog;
  LatLng? destinationLatLog;

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _googleMapController;

  onMapCreated(GoogleMapController controller) async {
    _googleMapController = controller;
    _controller.complete(controller);
    await Future.delayed(Duration(milliseconds: 50));

    _googleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            sourceLatLog!.latitude <= destinationLatLog!.latitude
                ? sourceLatLog!.latitude
                : destinationLatLog!.latitude,
            sourceLatLog!.longitude <= destinationLatLog!.longitude
                ? sourceLatLog!.longitude
                : destinationLatLog!.longitude,
          ),
          northeast: LatLng(
            sourceLatLog!.latitude <= destinationLatLog!.latitude
                ? destinationLatLog!.latitude
                : sourceLatLog!.latitude,
            sourceLatLog!.longitude <= destinationLatLog!.longitude
                ? destinationLatLog!.longitude
                : sourceLatLog!.longitude,
          ),
        ),
        100,
      ),
    );

    setState(() {});
  }

  RxInt selectedVehicleIndex = 0.obs;
  RxString paymentType = "Cash".obs;

  Future<void> _createCustomMarker() async {
    final Uint8List markerIcon = await _createMarkerImage(
      title: originDestinationModel?.oName ?? "",
      subtitle: '',
      markerImagePath: ImagesAsset.sourceIcon,
    );

    final marker = Marker(
      markerId: const MarkerId('origin'),
      position: sourceLatLog!,
      icon: BitmapDescriptor.bytes(
        markerIcon,
        width: 100,
        height: 70,
      ),
      anchor: const Offset(0.5, 1.0),
    );

    final Uint8List markerIcon1 = await _createMarkerImage(
      title: originDestinationModel?.dName ?? "",
      subtitle: '',
      markerImagePath: ImagesAsset.destinationIcon,
    );
    final marker1 = Marker(
      markerId: const MarkerId('destination'),
      position: destinationLatLog!,
      onTap: () {
        Get.back();
      },
      icon: BitmapDescriptor.bytes(
        markerIcon1,
        width: 100,
        height: 70,
      ),
      anchor: const Offset(0.5, 1.0),
    );

    markers.addAll([marker, marker1]);
  }

  Future<Uint8List> _createMarkerImage({
    required String title,
    required String subtitle,
    required String markerImagePath,
  }) async {
    const double width = 300;
    const double height = 200;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = AppColors.transparent;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

    // --- White label box with blue border ---
    final boxWidth = width - 60;
    double boxHeight = subtitle.isEmpty ? 60 : 90;
    final double boxLeft = (width - boxWidth) / 2;
    const double boxTop = 10;

    final RRect boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxLeft, boxTop, boxWidth, boxHeight),
      const Radius.circular(10),
    );

    final boxPaint = Paint()..color = AppColors.whiteColor;
    final borderPaint = Paint()
      ..color = AppColors.brandNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(boxRect, boxPaint);
    canvas.drawRRect(boxRect, borderPaint);

    // ------- TITLE (One Line) -------
    final titleStyle = ui.ParagraphStyle(
      textAlign: TextAlign.center,
      maxLines: 1,
      ellipsis: "...",
    );

    final titleBuilder = ui.ParagraphBuilder(titleStyle)
      ..pushStyle(
        ui.TextStyle(
          color: AppColors.blackColor,
          fontSize: 28,
          fontWeight: ui.FontWeight.w600,
        ),
      )
      ..addText(title);

    final titleParagraph = titleBuilder.build()
      ..layout(ui.ParagraphConstraints(width: boxWidth - 20));

    final double titleX = boxLeft + (boxWidth - titleParagraph.width) / 2;
    final double titleY = boxTop + 12;
    canvas.drawParagraph(titleParagraph, Offset(titleX, titleY));

    // ------- SUBTITLE (One Line) -------
    if (subtitle.isNotEmpty) {
      final subtitleStyle = ui.ParagraphStyle(
        textAlign: TextAlign.center,
        maxLines: 1,
        ellipsis: "...",
      );

      final subtitleBuilder = ui.ParagraphBuilder(subtitleStyle)
        ..pushStyle(
          ui.TextStyle(
            color: AppColors.blackColor,
            fontSize: 26,
            fontWeight: ui.FontWeight.w700,
          ),
        )
        ..addText("✎");

      final subtitleParagraph = subtitleBuilder.build()
        ..layout(ui.ParagraphConstraints(width: boxWidth - 20));

      final double subtitleX =
          boxLeft + (boxWidth - subtitleParagraph.width) / 2;
      final double subtitleY = titleY + titleParagraph.height + 4;
      canvas.drawParagraph(subtitleParagraph, Offset(subtitleX, subtitleY));
    }

    // --- Load PNG marker image ---
    final ByteData data = await rootBundle.load(markerImagePath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 80,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image markerImage = fi.image;

    final double imageX = (width - markerImage.width) / 2;
    final double imageY = height - markerImage.height;
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(
        imageX,
        imageY,
        markerImage.width.toDouble(),
        markerImage.height.toDouble(),
      ),
      image: markerImage,
      fit: BoxFit.contain,
    );

    // Complete the image
    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: AppColors.whiteColor,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }

          Get.back();
        },
        child: Scaffold(
          backgroundColor: AppColors.whiteColor,
          body: Column(
            children: [
              SizedBox(
                height: 430.h,
                child: Stack(
                  children: [
                    GoogleMap(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                      ),
                      initialCameraPosition: CameraPosition(
                        target: originDestinationModel?.oLatLng ?? LatLng(0, 0),
                        zoom: 14,
                      ),
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      onMapCreated: onMapCreated,
                      markers: markers,
                      polylines: _polyLines,
                      myLocationEnabled: true,
                      onCameraMove: (position) {},
                    ),

                    Positioned(
                      top: 16.h,
                      left: 16.h,
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: SafeArea(
                          child: Container(
                            width: 40.h,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.blackColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: CustomImage(image: IconAsset.arrowLeftIcon),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                    color: AppColors.whiteColor,
                  ),
                  transform: Matrix4.translationValues(0, -10.h, 0),
                  // Moves 10px UP
                  child: Obx(
                    () => homeController.bookRideLoading.value
                        ? Skeletonizer(
                            enabled: true,
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              separatorBuilder: (context, index) =>
                                  8.verticalSpace,

                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return SelectVehicleWidget(
                                  rideOption: null,
                                  newAmount: "",
                                  borderEnable: true,
                                  onTap: () {},
                                );
                              },
                            ),
                          )
                        : homeController.bookingCreateModel.value == null
                        ? Center(child: Text("No Service Available!"))
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            separatorBuilder: (context, index) =>
                                8.verticalSpace,

                            itemCount:
                                (homeController
                                            .bookingCreateModel
                                            .value
                                            ?.data
                                            ?.rideOptions ??
                                        [])
                                    .length,
                            itemBuilder: (context, index) {
                              RideOption? data = homeController
                                  .bookingCreateModel
                                  .value
                                  ?.data
                                  ?.rideOptions?[index];

                              return Obx(
                                () => SelectVehicleWidget(
                                  key: ValueKey(index),
                                  borderEnable:
                                      selectedVehicleIndex.value == index,
                                  rideOption: data,
                                  onTap: () {
                                    if (selectedVehicleIndex.value != index) {
                                      selectedVehicleIndex.value = index;

                                      codeApply.value = {};
                                    }
                                  },
                                  newAmount:
                                      selectedVehicleIndex.value == index &&
                                          codeApply.isNotEmpty
                                      ? "${codeApply['data']['final_amount']}"
                                      : (data?.currentPrice ?? "0"),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            bottom: Utils().checkPlatForm,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withValues(alpha: .4),
                    offset: Offset(0, -1),
                    spreadRadius: 0,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Obx(
                () => Skeletonizer(
                  enabled: homeController.bookRideLoading.value,
                  child: IgnorePointer(
                    ignoring: homeController.bookRideLoading.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () async {
                                    if ((homeController
                                                .bookingCreateModel
                                                .value
                                                ?.data
                                                ?.rideOptions ??
                                            [])
                                        .isEmpty) {
                                      return;
                                    }

                                    String?
                                    getData = await Navigation.pushNamed(
                                      Routes.paymentSelectScreen,
                                      arg: {
                                        'paymentSelection': true,
                                        "amount": codeApply.isNotEmpty
                                            ? "${codeApply['data']['final_amount']}"
                                            : homeController
                                                      .bookingCreateModel
                                                      .value
                                                      ?.data
                                                      ?.rideOptions?[selectedVehicleIndex
                                                          .value]
                                                      .currentPrice ??
                                                  "0",
                                        "method": paymentType.value,
                                        "isRideBook": true,
                                      },
                                    );
                                    if (getData != null) {
                                      paymentType.value = getData;
                                    }
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Obx(
                                          () => CommonText(
                                            string: paymentType.value
                                                .toUpperCase(),
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        16.horizontalSpace,
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                color: AppColors.textFieldBorderColor,
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: CommonText(
                                    string: "Kupon a rendelés után",
                                    fontSize: 12.sp,
                                    color: AppColors.textCaptionColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        16.verticalSpace,
                        CustomButton(
                          text: "Tovább a felvételi ponthoz",
                          onTap: () async {
                            final rideOptions = homeController
                                    .bookingCreateModel.value?.data?.rideOptions ??
                                [];
                            if (rideOptions.isEmpty) {
                              return;
                            }

                            final selectedRide =
                                rideOptions[selectedVehicleIndex.value];
                            final rideTypeId = selectedRide.rideTypeId ?? "";
                            if (rideTypeId.isEmpty ||
                                originDestinationModel == null ||
                                sourceLatLog == null) {
                              AppSnackBar.showErrorSnackBar(
                                message:
                                    "A rendelés adatai hiányosak. Kérjük, válassza ki újra az útvonalat.",
                                isError: true,
                              );
                              return;
                            }

                            Navigation.pushNamed(
                              Routes.pickupScreen,
                              arg: {
                                "pickUpLatLng": sourceLatLog,
                                "originDestination": originDestinationModel,
                                "rideTypeId": rideTypeId,
                                "paymentType": paymentType.value.toLowerCase(),
                              },
                            );
                          },
                        ),
                        12.verticalSpace,
                        Row(
                          children: [
                            6.horizontalSpace,

                            Icon(
                              Icons.info,
                              color: AppColors.mainPrimaryColor,
                              size: 18.sp,
                            ),
                            6.horizontalSpace,
                            Expanded(
                              child: CommonText(
                                string: AppString.rideInfo.tr,
                                softWrap: true,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyCustomInfoWidget extends StatelessWidget {
  final String title;

  const MyCustomInfoWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.blackColor,
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(color: AppColors.whiteColor, fontSize: 14),
      ),
    );
  }
}
