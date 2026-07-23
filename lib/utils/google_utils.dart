import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'log_utils.dart';

class GoogleMapUtils {
  static Future<String> latLngToLocation(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      Placemark place = placemarks[0];

      LogUtils.printAction(">>>>>>>lat ::$latLng>>${place.toJson()}");
      return "${place.street}**${(place.thoroughfare ?? "").isNotEmpty ? "${place.thoroughfare}, " : ""}${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    } catch (e) {
      LogUtils.printAction("ERROR:::$e");
      return "";
    }
  }
}
