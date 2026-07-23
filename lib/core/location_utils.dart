import 'dart:developer';

import 'package:e_taxi/utils/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:permission_handler/permission_handler.dart'
    hide PermissionStatus;
import 'package:permission_handler/permission_handler.dart' as per;
import 'package:rxdart/rxdart.dart';

import '../feature/home/widget/dialog.dart';
import '../utils/app_colors.dart';
import '../utils/app_string.dart';
import '../utils/assets.dart';
import '../utils/log_utils.dart';
import '../widgets/common_text.dart';
import '../widgets/custom_button.dart';
import '../widgets/custome_img.dart';

class LocationService {
  LocationService._();

  static final LocationService _internal = LocationService._();

  factory LocationService() => _internal;

  Rxn<LatLng> currentUserLatLg = Rxn<LatLng>();
  RxString currentAddressUse = "".obs;
  RxString currentAddress = "".obs;

  Location _locationController = Location();

  var _locationStreamController = BehaviorSubject<LocationData>();
  bool _locationListenerStarted = false;

  Stream<LocationData> get onLocationChanged =>
      _locationStreamController.stream;

  String country = "";

  void _ensureLocationListener() {
    if (_locationListenerStarted) return;
    _locationListenerStarted = true;

    _locationController.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        currentUserLatLg.value = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        if (!_locationStreamController.isClosed) {
          _locationStreamController.add(currentLocation);
        }
      }
    });
  }

  Future<LatLng?> _updateCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationController.requestService();
        if (!serviceEnabled) {
          LogUtils.printAction("Location service disabled");
          return null;
        }
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      currentUserLatLg.value = latLng;

      await AppPreference.setString(
        AppPreference.location,
        "${latLng.latitude}@${latLng.longitude}",
      );

      if (country.isEmpty) {
        await getCountryFromLatLng(latLng.latitude, latLng.longitude);
      }
      await getAddressFromLatLng(latLng);

      _ensureLocationListener();

      if (!_locationStreamController.isClosed) {
        _locationStreamController.add(
          LocationData.fromMap({
            'latitude': latLng.latitude,
            'longitude': latLng.longitude,
          }),
        );
      }

      LogUtils.printAction(
        "Current location updated: ${latLng.latitude}, ${latLng.longitude}",
      );
      return latLng;
    } catch (e) {
      LogUtils.printAction("Location fetch error: $e");
      return null;
    }
  }

  Future<void> getCountryFromLatLng(double lat, double lng) async {
    if (country.isNotEmpty) return;
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        lat,
        lng,
      );

      if (placemarks.isNotEmpty) {
        log("HERE SET:::::${placemarks.first.isoCountryCode}");
        country = placemarks.first.isoCountryCode ?? '';
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> permissionStreamStart() async {
    final locationAlwaysStatus = await per.Permission.location.status;

    if (locationAlwaysStatus.isGranted || locationAlwaysStatus.isLimited) {
      await _updateCurrentLocation();
    }
  }

  Future<void> initialize({
    bool isopenSetting = true,
    bool streamDispose = false,
    bool askPermission = true,
  }) async {
    per.PermissionStatus pers = await per.Permission.location.status;

    if (pers == per.PermissionStatus.permanentlyDenied) {
      if (isopenSetting == false) {
        return;
      }
    }

    if (pers.isDenied && askPermission) {
      pers = await Permission.location.request();
    }

    LogUtils.printAction("LOCATION:::$pers");
    if (pers.isGranted || pers.isLimited) {
      await _updateCurrentLocation();
    } else {
      LogUtils.printAction("❌ Location permission denied");
      if (isopenSetting) {
        openDialog(islocation: true);
      }
    }
  }

  Future<LatLng?> getCurrentLocation() async {
    final permissionStatus = await per.Permission.location.status;
    if (permissionStatus.isDenied) {
      final requested = await per.Permission.location.request();
      if (!requested.isGranted && !requested.isLimited) {
        openDialog(islocation: true);
        return null;
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      openDialog(islocation: true);
      return null;
    }

    return _updateCurrentLocation();
  }

  bool isopenDialog = false;

  openDialog({bool islocation = false}) {
    if (isopenDialog) {
      return;
    }
    isopenDialog = true;
    AppDialog.commonDialog(
      barrierDismissible: false,
      childs: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomImage(image: IconAsset.infoCircle, ht: 40.w, wt: 40.w),
          16.verticalSpace,
          CommonText(
            string: AppString.locationPermissionRequired.tr,
            softWrap: true,
            textAlign: TextAlign.center,
          ),
          24.verticalSpace,
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  buttonColor: AppColors.transparent,
                  borderColor: AppColors.blackColor,
                  text: AppString.deny.tr,
                  onTap: () {
                    isopenDialog = false;

                    Get.back();
                  },
                ),
              ),
              16.horizontalSpace,
              Expanded(
                child: CustomButton(
                  text: AppString.allow.tr,
                  onTap: () {
                    isopenDialog = false;

                    Get.back();
                    if (islocation) {
                      openAppSettings();
                    } else {
                      Geolocator.openAppSettings();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      geo.Placemark place = placemarks[0];

      currentAddressUse.value =
          "${place.street}**${(place.thoroughfare ?? "").isNotEmpty ? "${place.thoroughfare}, " : ""}${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      currentAddress.value =
          "${place.street} ${(place.thoroughfare ?? "").isNotEmpty ? "${place.thoroughfare}, " : ""}${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    } catch (e) {
      LogUtils.printAction("ERROR:::$e");
      currentAddressUse.value = "";
      currentAddress.value = "";
    }
  }
}
