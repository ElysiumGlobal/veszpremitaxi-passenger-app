import 'dart:async';

import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:e_taxi/widgets/dialog.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart'
    hide PermissionStatus;
import 'package:permission_handler/permission_handler.dart' as per;
import 'package:rxdart/rxdart.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_string.dart';

class LocationService {
  LocationService._();

  static LocationService _internal = LocationService._();

  factory LocationService() => _internal;

  Rxn<LatLng> currentUserLatLg = Rxn<LatLng>();
  Location _locationController = Location();

  BehaviorSubject<LocationData> _locationStreamController =
      BehaviorSubject<LocationData>();

  Stream<LocationData> get onLocationChanged =>
      _locationStreamController.stream;

  bool isDialogOpen = false;
  StreamSubscription<LocationData>? _nativeLocationSubscription;

  String country = "";

  Future<void> getCountryFromLatLng(double lat, double lng) async {
    if (country.isNotEmpty) return;
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        lat,
        lng,
      );

      if (placemarks.isNotEmpty) {
        country = placemarks.first.isoCountryCode ?? '';
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  Future<void> initialize({
    bool isopenSetting = true,
    bool contiCheck = false,
  }) async {
    per.PermissionStatus pers = await per.Permission.location.status;

    if (pers.isDenied) {
      pers = await per.Permission.location.request();
    }

    if (pers == per.PermissionStatus.denied) {
      pers = await per.Permission.location.request();
    }

    if (pers == per.PermissionStatus.granted ||
        pers == per.PermissionStatus.limited) {
      final locationAlwaysStatus =
          await per.Permission.locationAlways.status;
      await _getLocationPermission(
        locationAlwaysStatus.isGranted,
        contiCheck,
      );
    } else if (pers.isPermanentlyDenied) {
      if (isopenSetting) {
        openDialog(islocation: true);
      }
    } else {
      if (isopenSetting) {
        openDialog(islocation: true);
      }
    }
  }

  Future<void> _getLocationPermission(bool check, bool streamDispose) async {
    try {
      var value = await Location().getLocation();
      currentUserLatLg.value = LatLng(value.latitude!, value.longitude!);
      if (country.isEmpty) {
        getCountryFromLatLng(
          currentUserLatLg.value?.latitude ?? 0,
          currentUserLatLg.value?.longitude ?? 0,
        );
      }
      AppPreference.setString(
        AppPreference.location,
        "${value.latitude ?? 0}@${value.longitude ?? 0}",
      );

      await _nativeLocationSubscription?.cancel();

      _locationStreamController.close();
      _locationStreamController = BehaviorSubject<LocationData>();

      _nativeLocationSubscription = _locationController.onLocationChanged
          .listen((LocationData currentLocation) {
            if (currentLocation.latitude != null ||
                currentLocation.longitude != null) {
              currentUserLatLg.value = LatLng(
                currentLocation.latitude!,
                currentLocation.longitude!,
              );
              _locationStreamController.add(currentLocation);
            }
          });
      if (check) {
        await Location().enableBackgroundMode(enable: true);
      }
    } catch (e) {}
  }

  Future<void> dispose() async {
    await _nativeLocationSubscription?.cancel();
    await _locationStreamController.close();
  }

  Future<bool> checkBackGroundPermission() async {
    var pers = await per.Permission.location.status;

    if (pers.isDenied) {
      pers = await per.Permission.location.request();
    }

    if (pers == per.PermissionStatus.denied) {
      pers = await per.Permission.location.request();
    }

    if (pers == per.PermissionStatus.granted ||
        pers == per.PermissionStatus.limited) {
      var locationAlwaysStatus = await per.Permission.locationAlways.status;

      if (locationAlwaysStatus != per.PermissionStatus.granted) {
        locationAlwaysStatus = await per.Permission.locationAlways.request();
      }

      if (locationAlwaysStatus.isGranted) {
        await _getLocationPermission(true, true);
        return true;
      } else {
        openDialog(islocation: true);
        return false;
      }
    } else {
      openDialog(islocation: true);

      return false;
    }
  }

  openDialog({bool islocation = false}) {
    if (isDialogOpen) {
      return;
    }
    isDialogOpen = true;
    AppDialog.commonDialog(
      barrierDismiss: false,
      childs: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomImage(image: IconAsset.infoCircle, ht: 64.w, wt: 6.w),
          16.verticalSpace,
          CommonText(
            string: AppString.locationPermissionRequired.tr,
            softWrap: true,
          ),
          24.verticalSpace,
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  buttonColor: AppColors.transparentColor,
                  borderColor: AppColors.blackColor,
                  text: AppString.deny.tr,
                  onTap: () {
                    isDialogOpen = false;

                    Get.back();
                  },
                ),
              ),
              16.horizontalSpace,
              Expanded(
                child: CustomButton(
                  text: AppString.allow.tr,
                  onTap: () {
                    isDialogOpen = false;
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

  Future<LatLng?> ensureCurrentLocation() async {
    try {
      bool serviceEnabled = await _locationController.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationController.requestService();
      }

      if (!serviceEnabled) {
        AppSnackBar.showErrorSnackBar(
          message: 'Kapcsold be a helymeghatározást a munkába álláshoz.',
          isError: true,
        );
        return null;
      }

      PermissionStatus permissionStatus =
          await _locationController.hasPermission();

      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _locationController.requestPermission();
      }

      if (permissionStatus == PermissionStatus.denied ||
          permissionStatus == PermissionStatus.deniedForever) {
        AppSnackBar.showErrorSnackBar(
          message: 'Engedélyezd a helyhozzáférést a munkába álláshoz.',
          isError: true,
        );
        openDialog(islocation: true);
        return null;
      }

      final value = await _locationController
          .getLocation()
          .timeout(const Duration(seconds: 15));
      final latitude = value.latitude;
      final longitude = value.longitude;

      if (latitude == null || longitude == null) {
        AppSnackBar.showErrorSnackBar(
          message: 'A telefon nem adott használható GPS-pozíciót.',
          isError: true,
        );
        return null;
      }

      final latLng = LatLng(latitude, longitude);
      currentUserLatLg.value = latLng;
      AppPreference.setString(
        AppPreference.location,
        '$latitude@$longitude',
      );
      await getAddressFromLatLng(latLng);
      return latLng;
    } catch (error, stack) {
      LogUtils.printError('CURRENT LOCATION ERROR: $error, $stack');
      AppSnackBar.showErrorSnackBar(
        message: 'Nem sikerült lekérni a helyzetedet. Próbáld újra.',
        isError: true,
      );
      return null;
    }
  }

  Future<void> getCurrentLocation() async {
    await ensureCurrentLocation();
  }

  Map locationSelect = {};

  Future<void> getAddressFromLatLng(LatLng? latLng) async {
    if (latLng == null) {
      return;
    }
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      geo.Placemark place = placemarks[0];

      locationSelect['name'] = (place.subLocality ?? "").isNotEmpty
          ? place.subLocality
          : place.locality;
    } catch (e) {
      LogUtils.printAction("ERROR:::$e");
    }
  }
}
