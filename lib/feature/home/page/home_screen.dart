import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/cachenetworkimage.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import '../../../core/location_utils.dart';
import '../../../core/socket_channel.dart';
import '../../../utils/app_string.dart';
import '../../../utils/log_utils.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  LatLng demoLaeLong = LatLng(0, 0);
  bool _mapHasUserLocation = false;

  bool _isValidLatLng(LatLng location) =>
      location.latitude != 0 || location.longitude != 0;

  LatLng get _mapTarget {
    final live = LocationService().currentUserLatLg.value;
    if (live != null && _isValidLatLng(live)) return live;
    if (_isValidLatLng(demoLaeLong)) return demoLaeLong;
    return const LatLng(21.1702, 72.8311);
  }

  void _refreshMapForLocation(LatLng location) {
    final hasLocation = _isValidLatLng(location);
    if (_mapHasUserLocation == hasLocation || !mounted) return;

    if (hasLocation && !_mapHasUserLocation) {
      _controller = Completer<GoogleMapController>();
      _hasAutoCentered = false;
    }
    setState(() => _mapHasUserLocation = hasLocation);
  }

  void setLocationFromLocal() {
    String latLong = AppPreference.getString(AppPreference.location);

    if (latLong.isNotEmpty) {
      demoLaeLong = LatLng(
        double.parse(latLong.split("@").first),
        double.parse(latLong.split("@").last),
      );
      _mapHasUserLocation = _isValidLatLng(demoLaeLong);
      setState(() {});
    }
  }

  bool _hasAutoCentered = false;

  void _onLocationReady(LatLng location, {bool moveCamera = false}) {
    if (!_isValidLatLng(location)) return;

    demoLaeLong = location;
    currentUser.value = location;
    _refreshMapForLocation(location);
    if (mounted) setState(() {});
    getAddressFromLatLng(location);

    if (moveCamera || !_hasAutoCentered) {
      _hasAutoCentered = true;
      _centerCameraOn(location);
    }
  }

  Future<void> _moveToCurrentLocation() async {
    final location = await LocationService().getCurrentLocation();
    if (location != null) {
      _onLocationReady(location, moveCamera: true);
    }
  }

  bool isFirstTime = false;
  Worker? _locationWorker;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.microtask(() {
      setLocationFromLocal();

      final existingLocation = LocationService().currentUserLatLg.value;
      if (existingLocation != null) {
        _onLocationReady(existingLocation, moveCamera: true);
      }

      _locationWorker = ever(LocationService().currentUserLatLg, (
        LatLng? latLng,
      ) {
        if (latLng != null) {
          _onLocationReady(latLng);
        }
      });

      LocationService().initialize(isopenSetting: true).then((_) async {
        var location = LocationService().currentUserLatLg.value;
        location ??= await LocationService().getCurrentLocation();
        if (location != null) {
          _onLocationReady(location, moveCamera: true);
        }
      });

      LocationService().onLocationChanged.listen((event) {
        currentUser.value = LatLng(event.latitude ?? 0, event.longitude ?? 0);
        if (currentUser.value != LatLng(0, 0) && isFirstTime == false) {
          isFirstTime = true;
          isCameraRedirect = true;
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    LogUtils.printAction("------ $state _______");

    if (state == AppLifecycleState.resumed) {
      LocationService().permissionStreamStart().then((value) {
        final location = LocationService().currentUserLatLg.value;
        if (location != null) {
          _onLocationReady(location, moveCamera: true);
        }
      });
      SocketChannelService().ensureConnected();
    } else if (state == AppLifecycleState.inactive) {
    } else if (state == AppLifecycleState.paused) {
    } else if (state == AppLifecycleState.detached) {}
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    _locationWorker?.dispose();
    super.dispose();
  }

  bool isCameraRedirect = false;

  bool isConnected = false;

  StreamSubscription<LocationData>? _locationSubscription;
  Rxn<LatLng> currentUser = Rxn<LatLng>();

  Future<void> _centerCameraOn(LatLng post) async {
    try {
      final controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: post, zoom: 13),
        ),
      );
    } catch (e) {
      LogUtils.printAction("Camera update error: $e");
    }
  }

  Rx<Set<Marker>> _marker = Rx<Set<Marker>>({});
  RxString currentAddress = "".obs;

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      Placemark place = placemarks[0];
      currentAddress.value =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    } catch (e) {
      LogUtils.printAction("ERROR:::$e");
      currentAddress.value = "Unable to get address";
    }
  }

  final homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: Get.height,
              child: Obx(
                () {
                  final target = _mapTarget;
                  return GoogleMap(
                    key: ValueKey(
                      _mapHasUserLocation ? 'map_located' : 'map_waiting',
                    ),
                    padding: EdgeInsets.only(top: 62.h),
                    initialCameraPosition: CameraPosition(
                      target: target,
                      zoom: 13,
                    ),
                    onMapCreated: (controller) {
                      if (!_controller.isCompleted) {
                        _controller.complete(controller);
                      }
                      final location = LocationService().currentUserLatLg.value;
                      if (location != null && _isValidLatLng(location)) {
                        _onLocationReady(location, moveCamera: true);
                      } else if (_isValidLatLng(demoLaeLong)) {
                        _centerCameraOn(demoLaeLong);
                      }
                    },
                    onCameraMove: (position) {
                      currentUser.value = position.target;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    compassEnabled: true,
                    onCameraIdle: () {
                      if (currentUser.value != null) {
                        getAddressFromLatLng(currentUser.value!);
                      }
                    },
                    zoomControlsEnabled: false,
                    mapType: MapType.normal,
                    gestureRecognizers:
                        <Factory<OneSequenceGestureRecognizer>>{}
                          ..add(
                            Factory<PanGestureRecognizer>(
                              () =>
                                  PanGestureRecognizer()
                                    ..onUpdate = (dragUpdateDetails) {},
                            ),
                          )
                          ..add(
                            Factory<ScaleGestureRecognizer>(
                              () =>
                                  ScaleGestureRecognizer()
                                    ..onStart = (dragUpdateDetails) {},
                            ),
                          )
                          ..add(
                            Factory<TapGestureRecognizer>(
                              () => TapGestureRecognizer(),
                            ),
                          )
                          ..add(
                            Factory<VerticalDragGestureRecognizer>(
                              () =>
                                  VerticalDragGestureRecognizer()
                                    ..onDown = (dragUpdateDetails) {},
                            ),
                          ),
                    markers: _marker.value,
                  );
                },
              ),
            ),
            Positioned(
              right: 16.w,
              bottom: 200.h,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: AppColors.whiteColor,
                onPressed: _moveToCurrentLocation,
                child: CustomImage(
                  image: IconAsset.currentLocation,
                  ht: 22.w,
                  wt: 22.w,
                ),
              ),
            ),
            Positioned(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              child: CustomTextField(
                controller: TextEditingController(),
                hintText: AppString.whereAreYouNow.tr,
                suffixIcon: IconAsset.search,
                enabled: true,
                readOnly: true,
                onTap: () {
                  Navigation.pushNamed(Routes.searchFirstScreen);
                },
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Obx(
        () =>
            ((homeController.bannerModel.value?.data?.secondRow ?? [])
                    .isEmpty &&
                (homeController.bannerModel.value?.data?.firstRow ?? [])
                    .isEmpty)
            ? SizedBox()
            : Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,

                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: RefreshIndicator(
                  onRefresh: () async {
                    homeController.getUserNameList();
                    homeController.getAddress();
                    final location = LocationService().currentUserLatLg.value;
                    await homeController.getBanner(
                      lat: location?.latitude,
                      lng: location?.longitude,
                    );
                  },
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(
                          () =>
                              (homeController
                                          .bannerModel
                                          .value
                                          ?.data
                                          ?.firstRow ??
                                      [])
                                  .isEmpty
                              ? SizedBox.shrink()
                              : SizedBox(
                                  height: 140.h,
                                  child: ListView.separated(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                    ),
                                    separatorBuilder: (context, index) =>
                                        12.horizontalSpace,
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        (homeController
                                                    .bannerModel
                                                    .value
                                                    ?.data
                                                    ?.firstRow ??
                                                [])
                                            .length,

                                    itemBuilder: (context, index) {
                                      final data = homeController
                                          .bannerModel
                                          .value
                                          ?.data
                                          ?.firstRow?[index];

                                      return SizedBox(
                                        width: 156.w,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if ((data?.link?.url ?? "")
                                                    .isNotEmpty) {
                                                  Utils().launchWeb(
                                                    data?.link?.url ?? "",
                                                  );
                                                }
                                              },
                                              child: NetworkImageWidget(
                                                radius: 12.r,
                                                image: data?.imageUrl ?? "",
                                                ht: 90.h,
                                                wt: 156.w,
                                                boxFit: BoxFit.fill,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 50.h,
                                              child: CommonText(
                                                string: data?.description ?? '',
                                                maxLines: 2,
                                                softWrap: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ).paddingOnly(top: 8.h),
                        ),
                        Obx(
                          () =>
                              (homeController
                                          .bannerModel
                                          .value
                                          ?.data
                                          ?.secondRow ??
                                      [])
                                  .isEmpty
                              ? SizedBox.shrink()
                              : SizedBox(
                                  height: 170.h,
                                  child: CarouselSlider(
                                    items:
                                        (homeController
                                                    .bannerModel
                                                    .value
                                                    ?.data
                                                    ?.secondRow ??
                                                [])
                                            .map(
                                              (e) => GestureDetector(
                                                onTap: () {
                                                  if ((e.link?.url ?? "")
                                                      .isNotEmpty) {
                                                    Utils().launchWeb(
                                                      e.link?.url ?? "",
                                                    );
                                                  }
                                                },
                                                child:
                                                    NetworkImageWidget(
                                                      ht: 170.h,
                                                      radius: 12.r,
                                                      image: e.imageUrl ?? "",
                                                      boxFit: BoxFit.fill,
                                                      wt: double.infinity,
                                                    ).paddingSymmetric(
                                                      horizontal: 8.w,
                                                    ),
                                              ),
                                            )
                                            .toList(),
                                    options: CarouselOptions(
                                      padEnds: false,
                                      height: 170.h,
                                      clipBehavior: Clip.antiAlias,
                                      enlargeCenterPage: false,
                                      autoPlay: true,
                                      viewportFraction: 0.93,
                                      autoPlayInterval: Duration(seconds: 3),
                                      autoPlayAnimationDuration: Duration(
                                        milliseconds: 800,
                                      ),
                                    ),
                                  ),
                                ).paddingOnly(bottom: 10.h, top: 8.h),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class TestScreenn extends StatefulWidget {
  const TestScreenn({super.key});

  @override
  State<TestScreenn> createState() => _TestScreennState();
}

class _TestScreennState extends State<TestScreenn> {
  OtpFieldController controller = OtpFieldController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: OTPTextField(
          controller: controller,
          length: 6,
          otpFieldStyle: OtpFieldStyle(
            enabledBorderColor: AppColors.textFieldBorderColor,
            borderColor: AppColors.textFieldBorderColor,
            disabledBorderColor: AppColors.textFieldBorderColor,
            focusBorderColor: AppColors.mainPrimaryColor,
            backgroundColor: AppColors.whiteColor,
          ),
          width: MediaQuery.of(context).size.width,
          textFieldAlignment: MainAxisAlignment.spaceAround,
          fieldWidth: 45,
          fieldStyle: FieldStyle.box,
          outlineBorderRadius: 12.r,
          style: TextStyle(fontSize: 18.sp),
          onChanged: (pin) {
            LogUtils.printAction("Changed: $pin");
          },
          onCompleted: (pin) {
            LogUtils.printAction("Completed: $pin");
          },
        ),
      ),
    );
  }
}
