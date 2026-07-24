import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dotted_line/dotted_line.dart';
import 'package:e_taxi/core/location_utils.dart';
import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/feature/home/widget/origin_destination_widget.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/socket_channel.dart';
import '../../../utils/constants.dart';
import '../../../utils/log_utils.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custom_button.dart';
import '../widget/driver_details_widget.dart';
import '../widget/trip_modals.dart';

class SearchDriverScreen extends StatefulWidget {
  const SearchDriverScreen({super.key});

  @override
  State<SearchDriverScreen> createState() => _SearchDriverScreenState();
}

class _SearchDriverScreenState extends State<SearchDriverScreen> {
  Rx<Set<Polyline>> _polylines = Rx<Set<Polyline>>({});
  Rx<Set<Marker>> _marker = Rx<Set<Marker>>({});
  BitmapDescriptor? _driverMarkerIcon;

  String _activeBookingId() {
    return "${riderBookingModel.value?.data?.booking?.id ?? riderBookingModel.value?.data?.bookingId ?? homeController.bookingCreateModel.value?.data?.booking?.id ?? AppConstant().bookingId}";
  }

  Future<void> setDriverMarker(LatLng latLong) async {
    try {
      final markers = Set<Marker>.from(_marker.value);
      markers.removeWhere((element) => element.markerId.value == "driver");

      final icon = await _resolveDriverMarkerIcon();

      markers.add(
        Marker(
          markerId: const MarkerId("driver"),
          position: latLong,
          icon: icon,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          zIndexInt: 2,
        ),
      );
      _marker.value = markers;
    } catch (e, st) {
      LogUtils.printAction("setDriverMarker error: $e , $st");
      try {
        final markers = Set<Marker>.from(_marker.value);
        markers.removeWhere((element) => element.markerId.value == "driver");
        markers.add(
          Marker(
            markerId: const MarkerId("driver"),
            position: latLong,
            icon: await Utils().ensureCarIcon(),
            anchor: const Offset(0.5, 0.5),
            flat: true,
            zIndexInt: 2,
          ),
        );
        _marker.value = markers;
      } catch (_) {}
    }
  }

  Future<BitmapDescriptor> _resolveDriverMarkerIcon({
    bool forceReload = false,
  }) async {
    if (!forceReload && _driverMarkerIcon != null) return _driverMarkerIcon!;

    final rideTypeId = homeController.tripType.value == 0
        ? homeController.bookingCreateModel.value?.data?.booking?.rideTypeId
        : riderBookingModel.value?.data?.booking?.rideType?.id ?? "";

    var bookingIcon =
        riderBookingModel.value?.data?.booking?.rideType?.icon ?? "";
    final rideOptions =
        homeController.bookingCreateModel.value?.data?.rideOptions ?? [];

    var optionIcon = "";
    for (final option in rideOptions) {
      if ("${option.rideTypeId}" == "$rideTypeId" &&
          (option.icon ?? "").isNotEmpty) {
        optionIcon = option.icon!;
        break;
      }
    }

    final rideTypes = homeController.rideTypeList
        .where((e) => (e.id ?? "") == (rideTypeId ?? ""))
        .toList();
    final listIcon = rideTypes.isEmpty ? "" : (rideTypes.first.icon ?? "");
    final url = bookingIcon.isNotEmpty
        ? bookingIcon
        : (optionIcon.isNotEmpty ? optionIcon : listIcon);

    BitmapDescriptor icon = await Utils().ensureCarIcon();
    if (url.isNotEmpty) {
      final remote = await Utils().markerUrlToSet(url);
      if (remote != null) icon = remote;
    }

    _driverMarkerIcon = icon;
    return icon;
  }

  Future<void> _showDriverMarkerIfAvailable() async {
    final driver = riderBookingModel.value?.data?.driver;
    if (driver == null) return;

    final current = driver.currentLocation;
    var lat = double.tryParse("${current?.latitude ?? ""}");
    var lng = double.tryParse("${current?.longitude ?? ""}");
    if (lat == null || lng == null || lat == 0 || lng == 0) {
      lat = double.tryParse("${driver.lastLatitude ?? ""}");
      lng = double.tryParse("${driver.lastLongitude ?? ""}");
    }
    if (lat == null || lng == null || lat == 0 || lng == 0) return;

    _driverMarkerIcon = null;
    await setDriverMarker(LatLng(lat, lng));
  }

  Future<void> _preloadDriverMarkerIcon() async {
    await _resolveDriverMarkerIcon();
  }

  StreamSubscription? _sub;
  Worker? _rideModelWorker;

  bool driverReach = true;
  bool routLine = false;
  DateTime _lastApiCall = DateTime.now().subtract(Duration(seconds: 6));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (Get.arguments != null) {
      Map data = Get.arguments;
      userOrigin.value = data['origin'];
      _marker.value.add(
        Marker(
          markerId: MarkerId("Origin"),
          position: data['origin'],
          icon: Utils().customIcon!,
        ),
      );

      _marker.value.add(
        Marker(
          markerId: MarkerId("Destination"),
          position: data['destination'],
          icon: Utils().customIcon!,
        ),
      );
    }

    drawPoliLine();
    _preloadDriverMarkerIcon();

    _rideModelWorker = ever(riderBookingModel, (_) {
      _showDriverMarkerIfAvailable();
    });

    _sub = SocketChannelService().onSocketDataListen.listen((event) async {
      final datas = jsonDecode(event);
      if (datas is Map && datas.containsKey('event')) {
        var eventData = jsonDecode(datas['data']);
        log(
          "driver.location.updated:::A:D::D::::${eventData['booking_id']}::::${_activeBookingId()}",
        );
        if (datas['event'] == "driver.location.updated" &&
            "${eventData['booking_id'] ?? 0}" == _activeBookingId()) {
          try {
            LatLng data = LatLng(
              double.parse("${eventData['latitude'] ?? 0}"),
              double.parse("${eventData['longitude'] ?? "0"}"),
            );

            LatLng newPos = LatLng(data.latitude, data.longitude);

            await setDriverMarker(newPos);

            final riderModel = riderBookingModel.value?.data;

            final originLatLng = homeController.changePolyLine
                ? data
                : LatLng(
              double.parse(riderModel?.pickup?.latitude ?? "0.0"),
              double.parse(riderModel?.pickup?.longitude ?? "0.0"),
            );
            final destinationLatLng = homeController.changePolyLine
                ? LatLng(
              double.parse(riderModel?.pickup?.latitude ?? "0.0"),
              double.parse(riderModel?.pickup?.longitude ?? "0.0"),
            )
                : LatLng(
              double.parse(riderModel?.dropoff?.latitude ?? "0.0"),
              double.parse(riderModel?.dropoff?.longitude ?? "0.0"),
            );

            DateTime now = DateTime.now();
            log(">>>>>difreeent:::${now.difference(_lastApiCall).inSeconds}");

            _marker.value.add(
              Marker(
                markerId: MarkerId("destination"),
                icon: Utils().customIcon ?? BitmapDescriptor.defaultMarker,
                position: destinationLatLng,
              ),
            );

            final polylineCoordinates = await _getRoutePoints(
              originLatLng,
              destinationLatLng,
            );

            if (polylineCoordinates.isNotEmpty) {
              _polylines.value = {
                Polyline(
                  geodesic: false,
                  visible: true,
                  width: 3,
                  polylineId: PolylineId('poly'),
                  color: AppColors.textCaptionColor,
                  points: polylineCoordinates,
                  endCap: Cap.roundCap,
                  startCap: Cap.roundCap,
                ),
              };
              isDrawPoliLine = true;
            }
          } catch (e, st) {
            LogUtils.printAction("MARKER ERROR :$e ,$st ");
          }
        }
      }
    });
  }

  Future<List<LatLng>> _getRoutePoints(
    LatLng originLatLng,
    LatLng destinationLatLng,
  ) async {
    final polylinePoints = PolylinePoints(
      apiKey: homeController.placeApi ?? "",
    );
    final origin = PointLatLng(
      originLatLng.latitude,
      originLatLng.longitude,
    );
    final destination = PointLatLng(
      destinationLatLng.latitude,
      destinationLatLng.longitude,
    );

    final result = await polylinePoints.getRouteBetweenCoordinatesV2(
      request: RoutesApiRequest(
        origin: origin,
        destination: destination,
        travelMode: TravelMode.driving,
      ),
    );

    List<PointLatLng> routePoints = [];
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

    return routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  Future<void> drawPoliLine() async {
    final sourceLatLog = Get.arguments['origin'];
    final destinationLatLog = Get.arguments['destination'];

    final polylineCoordinates = await _getRoutePoints(
      sourceLatLog,
      destinationLatLog,
    );

    if (polylineCoordinates.isNotEmpty) {
      _polylines.value = {
        Polyline(
          geodesic: false,
          visible: true,
          polylineId: PolylineId('poly'),
          width: 3,
          color: AppColors.textCaptionColor,
          points: polylineCoordinates,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
        ),
      };
    }

    setState(() {});
  }

  bool isDrawPoliLine = false;
  StreamSubscription<LatLng?>? _subscription;

  Rxn<LatLng> userOrigin = Rxn<LatLng>();

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  Future<void> cameraPositionUpdate(LatLng post) async {
    GoogleMapController controller = await _controller.future;

    CameraPosition cameraPosition = CameraPosition(target: post, zoom: 13);

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  void getTokensd() {
    final token = AppPreference.getString(AppPreference.userToken);
    LogUtils.printAction(">>$token");
  }

  @override
  void dispose() {
    _rideModelWorker?.dispose();
    _subscription?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        LogUtils.printAction("asdads");
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SafeArea(
          bottom: Utils().checkPlatForm,
          child: Column(
            children: [
              // Map Section (top 2/3)
              SizedBox(
                height: 425.h,
                child: Stack(
                  children: [
                    Obx(
                          () => GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: userOrigin.value != null
                              ? userOrigin.value!
                              : const LatLng(47.0933, 17.9115),
                          // Bhuj coordinates
                          zoom: 14,
                        ),
                        onMapCreated: (controller) {
                          Future.delayed(Duration(milliseconds: 500), () {
                            _controller.complete(controller);
                          });
                        },

                        polylines: _polylines.value,
                        markers: _marker.value,
                        mapType: MapType.normal,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                    ),
                    Positioned(
                      top: 30.h,
                      left: 16.w,
                      right: 16.w,

                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigation.popupUtil(Routes.dashboardScreen);
                            },
                            child: Container(
                              width: 40.w,
                              height: 40.w,
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
                              child: CustomImage(
                                image: IconAsset.arrowLeftIcon,
                              ),
                            ),
                          ),
                          16.horizontalSpace,
                          Expanded(
                            child: Obx(
                                  () => AppConstant().reportString.value.isNotEmpty
                                  ? Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: double.infinity,

                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        12.r,
                                      ),
                                      color: AppColors.successColor,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              CommonText(
                                                string: AppConstant()
                                                    .reportString
                                                    .value
                                                    .split("@@")
                                                    .first,
                                                color:
                                                AppColors.whiteColor,
                                                softWrap: true,
                                                fontWeight:
                                                FontWeight.w500,
                                              ),
                                              CommonText(
                                                string: AppConstant()
                                                    .reportString
                                                    .value
                                                    .split("@@")
                                                    .last,
                                                color:
                                                AppColors.whiteColor,
                                                softWrap: true,
                                                fontSize: 12.sp,
                                              ),
                                            ],
                                          ),
                                        ),
                                        4.horizontalSpace,
                                        GestureDetector(
                                          onTap: () {
                                            AppConstant()
                                                .reportString
                                                .value =
                                            "";
                                          },
                                          behavior:
                                          HitTestBehavior.translucent,
                                          child: Container(
                                            height: 25.w,
                                            width: 25.w,
                                            decoration: BoxDecoration(
                                              color: AppColors.whiteColor,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: CustomImage(
                                              image: IconAsset.close,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                                  : SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      bottom: 15,
                      left: 0,
                      right: 16.w,
                      child: Obx(
                            () => homeController.tripType.value != 0
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                String title =
                                    "Origin : ${riderBookingModel.value?.data?.pickup?.address ?? ""}\nDestination : ${riderBookingModel.value?.data?.dropoff?.address ?? ""}";
                                title +=
                                "\nUser last location : https://www.google.com/maps/search/?api=1&query=${LocationService().currentUserLatLg.value?.latitude},${LocationService().currentUserLatLg.value?.longitude}";
                                title +=
                                "\n\nhttps://www.google.com/maps/dir/?api=1&origin=${LocationService().currentUserLatLg.value?.latitude ?? riderBookingModel.value?.data?.pickup?.latitude},${LocationService().currentUserLatLg.value?.longitude ?? riderBookingModel.value?.data?.pickup?.longitude}&destination=${riderBookingModel.value?.data?.dropoff?.latitude},${riderBookingModel.value?.data?.dropoff?.longitude}&travelmode=driving";

                                final box =
                                context.findRenderObject()
                                as RenderBox?;

                                SharePlus.instance.share(
                                  ShareParams(
                                    text: title,

                                    sharePositionOrigin:
                                    box!.localToGlobal(Offset.zero) &
                                    box.size,
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10.w,
                                  horizontal: 16.w,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    4.r,
                                  ),
                                  color: AppColors.blackColor,
                                ),
                                child: Row(
                                  children: [
                                    CustomImage(
                                      image: IconAsset.share1,
                                      ht: 16.w,
                                      wt: 16.w,
                                      color: AppColors.whiteColor,
                                    ),
                                    10.horizontalSpace,
                                    CommonText(
                                      string: "Share location",
                                      color: AppColors.whiteColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            8.horizontalSpace,

                            GestureDetector(
                              onTap: () {
                                Navigation.pushNamed(Routes.safetyScreen);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10.w,
                                  horizontal: 16.w,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    4.r,
                                  ),
                                  color: AppColors.blackColor,
                                ),
                                child: Row(
                                  children: [
                                    CustomImage(
                                      image: IconAsset.safety,
                                      ht: 16.w,
                                      wt: 16.w,
                                      color: AppColors.whiteColor,
                                    ),
                                    10.horizontalSpace,
                                    CommonText(
                                      string: "Safety",
                                      color: AppColors.whiteColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                            : SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  log(
                    "NEW rideType :::::${homeController.tripType.value}:::${homeController.isDriverCome.value}",
                  );
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blackColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    transform: Matrix4.translationValues(0, -10.h, 0),
                    child: SingleChildScrollView(
                      child: homeController.tripType.value == 0
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title and Description
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                string: AppString.searchingDriver.tr,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.titleTextColor,
                              ),
                              SizedBox(height: 8.h),
                              CommonText(
                                string:
                                AppString.weAreLookingForDriver.tr,
                                softWrap: true,
                                fontSize: 14.sp,
                                color: AppColors.textCaptionColor,
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 24.h,
                                ),
                                child: Center(
                                  child: CustomImage(
                                    image: IconAsset.searchDriver,
                                    ht: 150.w,
                                    wt: 150.w,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Trip Details Button
                          CustomButton(
                            text: "Trip details",
                            buttonColor: AppColors.mainPrimaryColor,
                            textColor: AppColors.whiteColor,
                            height: 56.h,
                            width: double.infinity,
                            onTap: () {
                              _showTripDetailsModal(context);
                            },
                          ),
                        ],
                      )
                          : homeController.tripType.value == 1
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                                () => Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      CommonText(
                                        string:
                                        homeController
                                            .isDriverCome
                                            .value
                                            ? AppString.driverIsHere.tr
                                            : AppString.driverIsComing.tr,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.sp,
                                      ),
                                      CommonText(
                                        string:
                                        "Enjoy ${riderBookingModel.value?.data?.booking?.rideType?.waitingTimeLimit ?? 0} Min of free waiting time.",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp,
                                        color: AppColors.textCaptionColor,
                                      ),
                                    ],
                                  ),
                                ),

                                8.horizontalSpace,
                                homeController.isDriverCome.value
                                    ? Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: 7.h,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(4.r),
                                    border: Border.all(
                                      color: AppColors
                                          .mainPrimaryColor,
                                    ),
                                    color:
                                    AppColors.primaryContainer,
                                  ),
                                  child: CommonText(
                                    string: timeString(
                                      time: homeController
                                          .freeWaintingTime
                                          .value,
                                    ),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Divider(
                              color: AppColors.textFieldBorderColor,
                            ),
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CommonText(
                                  string:
                                  AppString.sharePinWithCaptain.tr,
                                  softWrap: true,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                ),
                              ),

                              ...List.generate(4, (index) {
                                return Container(
                                  margin: EdgeInsets.only(left: 5.w),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.w,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      4.r,
                                    ),
                                    color: AppColors.textFieldBorderColor,
                                  ),
                                  child: CommonText(
                                    string:
                                    "${(riderBookingModel.value?.data?.booking?.otp ?? "0000").split("").toList()[index]}",
                                  ),
                                );
                              }),
                            ],
                          ),
                          16.verticalSpace,
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColors.whiteGrey,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigation.pushNamed(
                                      Routes.driverDetailsScreen,
                                    );
                                  },
                                  child: DriverDetailsWidget(
                                    image:
                                    riderBookingModel
                                        .value
                                        ?.data
                                        ?.driver
                                        ?.profilePhoto ??
                                        "",
                                    firstText:
                                    riderBookingModel
                                        .value
                                        ?.data
                                        ?.driver
                                        ?.vehicle
                                        ?.numberPlate ??
                                        "",
                                    secoundText:
                                    riderBookingModel
                                        .value
                                        ?.data
                                        ?.driver
                                        ?.name ??
                                        "",
                                    thirdText:
                                    riderBookingModel
                                        .value
                                        ?.data
                                        ?.driver
                                        ?.vehicle
                                        ?.model ??
                                        "",
                                    rating:
                                    riderBookingModel
                                        .value
                                        ?.data
                                        ?.driver
                                        ?.rating ??
                                        "0",
                                    radius: 100,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8.h,
                                  ),
                                  child: Divider(
                                    color: AppColors.textFieldBorderColor,
                                  ),
                                ),

                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Utils().launchDialer(
                                          riderBookingModel
                                              .value
                                              ?.data
                                              ?.driver
                                              ?.phone ??
                                              "",
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          right: 8.w,
                                        ),
                                        padding: EdgeInsets.all(8.w),

                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors
                                                .textFieldBorderColor,
                                          ),
                                        ),
                                        child: CustomImage(
                                          image: IconAsset.call,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigation.pushNamed(
                                          Routes.chatScreen,
                                          params: {
                                            'bookingId':
                                            '${riderBookingModel.value?.data?.bookingId}',
                                          },
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          right: 8.w,
                                        ),
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors
                                                .textFieldBorderColor,
                                          ),
                                        ),
                                        child: CustomImage(
                                          image: IconAsset.message,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigation.pushNamed(
                                          Routes.driverDetailsScreen,
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          right: 8.w,
                                        ),
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(8.r),
                                          border: Border.all(
                                            color: AppColors
                                                .textFieldBorderColor,
                                          ),
                                        ),
                                        child: CommonText(
                                          string:
                                          AppString.driverDetails.tr,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: 42,
                            child: Center(
                              child: DottedLine(
                                direction: Axis.horizontal,
                                lineLength: double.infinity,
                                lineThickness: 2,
                                dashLength: 5,
                                dashColor: AppColors.textFieldBorderColor,
                              ),
                            ),
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // tripType.value = 2;
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      CommonText(
                                        string: AppString.pickupFrom.tr,
                                        fontSize: 14.sp,
                                      ),
                                      CommonText(
                                        string: Utils()
                                            .getString(
                                          riderBookingModel
                                              .value
                                              ?.data
                                              ?.pickup
                                              ?.address ??
                                              "",
                                        )
                                            .first,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              16.horizontalSpace,
                              GestureDetector(
                                onTap: () {
                                  Navigation.pushNamed(
                                    Routes.tripDetailsScreen,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.w,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      48.r,
                                    ),
                                    border: Border.all(
                                      color:
                                      AppColors.textFieldBorderColor,
                                    ),
                                  ),
                                  child: CommonText(
                                    string: AppString.tripDetails.tr,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              CommonText(
                                string: AppString.tripToDetination.tr,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              CommonText(
                                string:
                                '${riderBookingModel.value?.data?.booking?.distance ?? ""} Km',
                                fontSize: 14.sp,
                              ),
                            ],
                          ),
                          Divider(color: AppColors.textFieldBorderColor),
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              color: AppColors.whiteGrey,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                // tripType.value=0;
                              },
                              child: DriverDetailsWidget(
                                image:
                                riderBookingModel
                                    .value
                                    ?.data
                                    ?.driver
                                    ?.profilePhoto ??
                                    "",
                                firstText:
                                riderBookingModel
                                    .value
                                    ?.data
                                    ?.driver
                                    ?.vehicle
                                    ?.numberPlate ??
                                    "",
                                thirdText:
                                riderBookingModel
                                    .value
                                    ?.data
                                    ?.driver
                                    ?.vehicle
                                    ?.model ??
                                    "",
                                secoundText:
                                riderBookingModel
                                    .value
                                    ?.data
                                    ?.driver
                                    ?.name ??
                                    "",
                                rating:
                                riderBookingModel
                                    .value
                                    ?.data
                                    ?.driver
                                    ?.rating ??
                                    "",
                                radius: 100,
                              ),
                            ),
                          ),
                          16.verticalSpace,

                          OriginDestinationWidget(
                            destination:
                            "${riderBookingModel.value?.data?.booking?.dropoffAddress}",
                            origin:
                            "${riderBookingModel.value?.data?.booking?.pickupAddress}",
                            customImage: true,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String timeString({required int time}) {
    final minute = (time ~/ 60);
    final second = (time % 60);
    String sec = second.toString();
    if (second < 10) {
      sec = "0$sec";
    }

    return "0$minute:$sec";
  }

  HomeController homeController = Get.find<HomeController>();

  void _showTripDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => TripDetailsModal(
        destination:
        homeController
            .bookingCreateModel
            .value
            ?.data
            ?.booking
            ?.dropoffAddress ??
            riderBookingModel.value?.data?.dropoff?.address ??
            "",
        origin:
        homeController
            .bookingCreateModel
            .value
            ?.data
            ?.booking
            ?.pickupAddress ??
            riderBookingModel.value?.data?.pickup?.address ??
            "",
        price:
        homeController
            .bookingCreateModel
            .value
            ?.data
            ?.fareBreakdown
            ?.total ??
            "",
        onTap: () {
          // tripType.value = 1;

          Navigation.pushNamed(Routes.cancelRequestScreen);
        },
      ),
    );
  }
}
