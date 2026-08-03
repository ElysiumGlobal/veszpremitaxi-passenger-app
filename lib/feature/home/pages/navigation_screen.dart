import 'dart:async';
import 'dart:convert';
import 'dart:math' as Math;

import 'package:e_taxi/core/service/location_utils.dart';
import 'package:e_taxi/core/debug/driver_flow_debug.dart';
import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/feature/home/pages/home_screen.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../../core/api/api.dart';
import '../../../core/service/socket_channel.dart';
import '../../../utils/api_constants.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/constants.dart';
import '../../../utils/log_utils.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfeild.dart';
import '../../../widgets/custome_img.dart';
import '../../../widgets/dialog.dart';
import '../../auth/model/ride_type_list_model.dart' as rideType;
import '../widget/icon_widget.dart';
import '../widget/listTileWidget.dart';


class _NoMapAddressRow extends StatelessWidget {
  const _NoMapAddressRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: AppColors.mainPrimaryColor, size: 22.sp),
        12.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CommonText(
                string: label,
                color: AppColors.whiteColor.withValues(alpha: .55),
                fontSize: 11.sp,
              ),
              3.verticalSpace,
              CommonText(
                string: value.isEmpty ? 'Cím betöltése…' : value,
                color: AppColors.whiteColor,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MapNavigationScreen extends StatefulWidget {
  const MapNavigationScreen({super.key});

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen>
    with LoadingMixin {
  RxBool switchToggle = true.obs;

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  Future<void> cameraPositionUpdate(LatLng post) async {
    // A SOFŐRAPP aktív fuvar képernyője térkép nélküli.
    // A GPS-helyzetküldés ettől függetlenül változatlanul működik.
    if (!_controller.isCompleted) return;
    final GoogleMapController controller = await _controller.future;
    final CameraPosition cameraPosition = CameraPosition(target: post, zoom: 13);
    await controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  RxString _estimateDistance = "".obs;
  RxString _estimatedTime = "".obs;

  DateTime _lastApiCall = DateTime.now().subtract(Duration(seconds: 10));

  RxBool showNavigation = false.obs;
  bool _directionsUnavailable = false;
  bool _targetInfoShown = false;

  RxBool inPlace = false.obs;
  StreamSubscription<LatLng?>? _subscription;
  LatLng? prevPos;
  bool _firstLocationLogged = false;

  double getBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * (3.14159265359 / 180.0);
    double lon1 = start.longitude * (3.14159265359 / 180.0);
    double lat2 = end.latitude * (3.14159265359 / 180.0);
    double lon2 = end.longitude * (3.14159265359 / 180.0);

    double dLon = lon2 - lon1;
    double y = Math.sin(dLon) * Math.cos(lat2);
    double x =
        Math.cos(lat1) * Math.sin(lat2) -
            Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);
    double bearing = Math.atan2(y, x);
    bearing = bearing * 180.0 / 3.14159265359;
    bearing = (bearing + 360) % 360;
    return bearing;
  }

  double? _parseCoordinate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }

  String _passengerName() {
    final model = rideDataModel.value;
    final name = (model?.customer?.customerName ?? model?.passenger?.name ?? '')
        .trim();
    return name.isEmpty ? 'Utas' : name;
  }

  LatLng? _activeTarget() {
    final model = rideDataModel.value;
    final status = homeController.rideStatus.value;
    if (status == 2) return null;
    final isPickup = status == 1;
    final latitude = _parseCoordinate(
      isPickup ? model?.pickup?.latitude : model?.dropoff?.latitude,
    );
    final longitude = _parseCoordinate(
      isPickup ? model?.pickup?.longitude : model?.dropoff?.longitude,
    );
    if (latitude == null || longitude == null) return null;
    if (latitude.abs() < 0.000001 && longitude.abs() < 0.000001) return null;
    return LatLng(latitude, longitude);
  }

  double? _coordinateTripDistanceKm() {
    final model = rideDataModel.value;
    final pickupLat = _parseCoordinate(model?.pickup?.latitude);
    final pickupLng = _parseCoordinate(model?.pickup?.longitude);
    final dropoffLat = _parseCoordinate(model?.dropoff?.latitude);
    final dropoffLng = _parseCoordinate(model?.dropoff?.longitude);
    if (pickupLat == null ||
        pickupLng == null ||
        dropoffLat == null ||
        dropoffLng == null) {
      return null;
    }
    final directKm = Geolocator.distanceBetween(
          pickupLat,
          pickupLng,
          dropoffLat,
          dropoffLng,
        ) /
        1000;
    if (!directKm.isFinite || directKm <= 0) return null;
    // Directions-válasz hiányában közúti közelítés. Ez csak kijelzés,
    // a díjszámítás továbbra is a backend feladata.
    return directKm * 1.18;
  }

  String _formatTripDistance() {
    final raw = (rideDataModel.value?.booking?.estimatedDistance ??
            rideDataModel.value?.tripDetails?.distance ??
            '')
        .trim();
    final normalized = raw.toLowerCase().replaceAll(',', '.');
    final numericText = normalized.replaceAll(RegExp(r'[^0-9.\-]'), '');
    double? apiKm = double.tryParse(numericText);

    if (apiKm != null) {
      if (normalized.contains(' m') && !normalized.contains('km')) {
        apiKm /= 1000;
      } else if (apiKm > 500) {
        // A gyári API egyes válaszokban métert küld km mezőnév alatt.
        apiKm /= 1000;
      }
    }

    final coordinateKm = _coordinateTripDistanceKm();
    final bool apiLooksImpossible = apiKm == null ||
        !apiKm.isFinite ||
        apiKm <= 0 ||
        (coordinateKm != null &&
            (apiKm < coordinateKm * 0.45 || apiKm > coordinateKm * 8));
    final resultKm = apiLooksImpossible ? coordinateKm : apiKm;

    if (resultKm == null) return raw;
    final prefix = apiLooksImpossible && coordinateKm != null ? '~' : '';
    return '$prefix${resultKm.toStringAsFixed(1)} km';
  }

  String _driverCommitmentLabel() {
    final int? eta = rideDataModel.value?.driverEtaMinutes ??
        int.tryParse(rideDataModel.value?.booking?.driverEtaMinutes ?? '');
    final String rawExpected =
        (rideDataModel.value?.driverExpectedArrivalAt ??
                rideDataModel.value?.booking?.driverExpectedArrivalAt ??
                '')
            .trim();
    final DateTime? expected = DateTime.tryParse(rawExpected)?.toLocal();
    final String time = expected == null
        ? ''
        : '${expected.hour.toString().padLeft(2, '0')}:'
            '${expected.minute.toString().padLeft(2, '0')}';
    if (eta == null || eta <= 0) return '';
    return time.isEmpty ? 'Vállalt érkezés: $eta perc' : 'Vállalt: $eta perc ($time)';
  }

  String _distanceSummary() {
    final String liveDistance = _estimateDistance.value.isEmpty
        ? 'számítás…'
        : _estimateDistance.value;
    final String liveTime =
        _estimatedTime.value.isEmpty ? 'számítás…' : _estimatedTime.value;
    if (homeController.rideStatus.value == 1) {
      final String tripDistance = _formatTripDistance();
      final String commitment = _driverCommitmentLabel();
      final List<String> parts = <String>[
        'Utasig: $liveDistance / $liveTime',
        if (commitment.isNotEmpty) commitment,
        if (tripDistance.isNotEmpty) 'Fuvar: $tripDistance',
      ];
      return parts.join('  •  ');
    }
    return 'Célig: $liveDistance / $liveTime';
  }

  void _ensureTargetMarker() {
    final target = _activeTarget();
    if (target == null) return;

    final isPickup = homeController.rideStatus.value == 1;
    final icon = isPickup
        ? (Utils().pickupIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen))
        : (Utils().destinationIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange));

    _marker.value.removeWhere(
      (element) => element.markerId.value == 'destination',
    );
    _marker.value.add(
      Marker(
        markerId: const MarkerId('destination'),
        icon: icon,
        position: target,
        anchor: const Offset(0.5, 1.0),
        infoWindow: InfoWindow(
          title: isPickup ? _passengerName() : 'Úti cél',
          snippet: isPickup ? 'Utas felvételi pontja' : 'Fuvar célállomása',
        ),
      ),
    );
    _marker.refresh();
  }

  Future<void> _showTargetInfoWindow() async {
    if (_targetInfoShown || !_controller.isCompleted) return;
    try {
      final controller = await _controller.future;
      await controller.showMarkerInfoWindow(const MarkerId('destination'));
      _targetInfoShown = true;
    } catch (_) {}
  }

  Future<void> _focusInternalNavigation() async {
    if (!_controller.isCompleted) return;
    final controller = await _controller.future;
    final current = LocationService().currentUserLatLg.value;
    final target = _activeTarget();

    if (current != null && target != null) {
      final southWest = LatLng(
        Math.min(current.latitude, target.latitude),
        Math.min(current.longitude, target.longitude),
      );
      final northEast = LatLng(
        Math.max(current.latitude, target.latitude),
        Math.max(current.longitude, target.longitude),
      );
      final samePoint = (southWest.latitude - northEast.latitude).abs() < 0.00001 &&
          (southWest.longitude - northEast.longitude).abs() < 0.00001;
      if (samePoint) {
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: current, zoom: 17),
          ),
        );
      } else {
        await controller.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(southwest: southWest, northeast: northEast),
            90,
          ),
        );
      }
    } else if (current != null) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: current, zoom: 17),
        ),
      );
    } else if (target != null) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 16),
        ),
      );
    }

    showNavigation.value = true;
    DriverFlowDebug.send(
      'internal_navigation_focus',
      bookingId:
          (rideDataModel.value?.bookingId ?? Constants.bookingId).toString(),
      data: <String, dynamic>{
        'ride_status': homeController.rideStatus.value,
        'current_present': current != null,
        'target_present': target != null,
      },
    );
  }

  void _clearInternalRouteForWaiting() {
    if (_polylines.value.isNotEmpty) {
      _polylines.value = <Polyline>{};
      _polylines.refresh();
    }
    _estimateDistance.value = '';
    _estimatedTime.value = '';
    showInstractionStep.value = '';
    steps = <dynamic>[];
    homeController.isDrawPoliLine.value = true;
    _marker.value.removeWhere(
      (element) => element.markerId.value == 'destination',
    );
    _marker.refresh();
  }

  void _setLocalDistanceFallback(String origin, String destination) {
    try {
      final originParts = origin.split(',');
      final destinationParts = destination.split(',');
      if (originParts.length != 2 || destinationParts.length != 2) return;
      final originLat = double.parse(originParts[0]);
      final originLng = double.parse(originParts[1]);
      final destinationLat = double.parse(destinationParts[0]);
      final destinationLng = double.parse(destinationParts[1]);
      final meters = Geolocator.distanceBetween(
        originLat,
        originLng,
        destinationLat,
        destinationLng,
      );
      _estimateDistance.value = '${(meters / 1000).toStringAsFixed(1)} km';
      _estimatedTime.value = '';
      steps = [];
    } catch (_) {}
  }

  Future<void> setDriverMarker(LatLng latLong) async {
    _marker.value.removeWhere((element) => element.markerId.value == "driver");
    _marker.value.add(
      Marker(
        markerId: const MarkerId("driver"),
        icon: Utils().driverIcon ??
            Utils().carIcon ??
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow,
            ),
        position: latLong,
        anchor: const Offset(0.5, 0.5),
        flat: true,
      ),
    );
    _marker.refresh();
  }

  @override
  void initState() {
    super.initState();

    final model = rideDataModel.value;
    DriverFlowDebug.send(
      'navigation_screen_init',
      bookingId: (model?.bookingId ?? Constants.bookingId).toString(),
      data: <String, dynamic>{
        'ride_model_present': model != null,
        'ride_status': homeController.rideStatus.value,
        'pickup_lat': model?.pickup?.latitude ?? '',
        'pickup_lng': model?.pickup?.longitude ?? '',
        'dropoff_lat': model?.dropoff?.latitude ?? '',
        'dropoff_lng': model?.dropoff?.longitude ?? '',
        'current_location_present':
            LocationService().currentUserLatLg.value != null,
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DriverFlowDebug.send(
        'navigation_screen_first_frame',
        bookingId: (rideDataModel.value?.bookingId ?? Constants.bookingId)
            .toString(),
        data: <String, dynamic>{'current_route': Get.currentRoute},
      );
    });

    _ensureTargetMarker();
    socketAuthConnection();
    _subscription = LocationService().currentUserLatLg.listen((data) async {
      if (data != null) {
        LatLng newPos = LatLng(data.latitude, data.longitude);
        if (!_firstLocationLogged) {
          _firstLocationLogged = true;
          DriverFlowDebug.send(
            'navigation_first_location',
            bookingId:
                (rideDataModel.value?.bookingId ?? Constants.bookingId)
                    .toString(),
            data: <String, dynamic>{
              'latitude': DriverFlowDebug.coordinate(data.latitude),
              'longitude': DriverFlowDebug.coordinate(data.longitude),
              'ride_status': homeController.rideStatus.value,
            },
          );
        }

        DateTime now = DateTime.now();
        if (now.difference(_lastApiCall).inSeconds >= 10 && isConnectionDone) {
          locationServerSend(newPos);
          _lastApiCall = now;
        }

        setDriverMarker(newPos);

        prevPos = newPos;
        final riderModel = rideDataModel.value;

        final originLatLng = LatLng(data.latitude, data.longitude);
        final currentRideStatus = homeController.rideStatus.value;
        final LatLng? destinationLatLng = currentRideStatus == 1
            ? LatLng(
                double.parse(riderModel?.pickup?.latitude ?? "0.0"),
                double.parse(riderModel?.pickup?.longitude ?? "0.0"),
              )
            : currentRideStatus == 3
                ? LatLng(
                    double.parse(riderModel?.dropoff?.latitude ?? "0.0"),
                    double.parse(riderModel?.dropoff?.longitude ?? "0.0"),
                  )
                : null;

        if (currentRideStatus == 2) {
          _clearInternalRouteForWaiting();
        } else if (destinationLatLng != null &&
            homeController.isDrawPoliLine.value == false) {
          _marker.value.removeWhere(
            (element) => element.markerId.value == "destination",
          );
          final destinationIcon = homeController.rideStatus.value == 1
              ? (Utils().pickupIcon ??
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ))
              : (Utils().destinationIcon ??
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange,
                  ));
          _marker.value.add(
            Marker(
              markerId: const MarkerId("destination"),
              icon: destinationIcon,
              position: destinationLatLng,
              anchor: const Offset(0.5, 1.0),
              infoWindow: InfoWindow(
                title: homeController.rideStatus.value == 1
                    ? _passengerName()
                    : 'Úti cél',
                snippet: homeController.rideStatus.value == 1
                    ? 'Utas felvételi pontja'
                    : 'Fuvar célállomása',
              ),
            ),
          );
          _marker.refresh();
          unawaited(_showTargetInfoWindow());

          /// fixme: 1 marker and poliline are add....

          PointLatLng origin = PointLatLng(
            originLatLng.latitude,
            originLatLng.longitude,
          );
          PointLatLng destination = PointLatLng(
            destinationLatLng.latitude,
            destinationLatLng.longitude,
          );

          DriverFlowDebug.send(
            'polyline_request_start',
            bookingId:
                (rideDataModel.value?.bookingId ?? Constants.bookingId)
                    .toString(),
            data: <String, dynamic>{
              'origin_lat': DriverFlowDebug.coordinate(originLatLng.latitude),
              'origin_lng': DriverFlowDebug.coordinate(originLatLng.longitude),
              'destination_lat':
                  DriverFlowDebug.coordinate(destinationLatLng.latitude),
              'destination_lng':
                  DriverFlowDebug.coordinate(destinationLatLng.longitude),
              'ride_status': homeController.rideStatus.value,
              'api_key_present': (homeController.placeApi ?? '').isNotEmpty,
            },
          );

          bool routeDrawn = false;
          try {
            final RoutesApiResponse result =
                await PolylinePoints(
                  apiKey: homeController.placeApi ?? "",
                ).getRouteBetweenCoordinatesV2(
                  request: RoutesApiRequest(
                    origin: origin,
                    destination: destination,
                    travelMode: TravelMode.driving,
                    optimizeWaypointOrder: true,
                    routingPreference: RoutingPreference.trafficAware,
                  ),
                );

            final List<PointLatLng>? routePoints =
                result.primaryRoute?.polylinePoints;
            DriverFlowDebug.send(
              'polyline_request_result',
              bookingId:
                  (rideDataModel.value?.bookingId ?? Constants.bookingId)
                      .toString(),
              data: <String, dynamic>{
                'point_count': routePoints?.length ?? 0,
                'has_primary_route': result.primaryRoute != null,
              },
            );

            if (routePoints != null && routePoints.isNotEmpty) {
              _applyRoutePoints(
                routePoints
                    .map((point) => LatLng(point.latitude, point.longitude))
                    .toList(),
              );
              routeDrawn = true;
              await getDistanceAndTime(
                origin: "${originLatLng.latitude},${originLatLng.longitude}",
                destination:
                    "${destinationLatLng.latitude},${destinationLatLng.longitude}",
              );
            }
          } catch (error, stack) {
            DriverFlowDebug.send(
              'navigation_route_build_error',
              bookingId:
                  (rideDataModel.value?.bookingId ?? Constants.bookingId)
                      .toString(),
              data: <String, dynamic>{
                'error': error.toString(),
                'stack': stack.toString(),
              },
            );
            LogUtils.printError('NAVIGATION ROUTE ERROR: $error, $stack');
          }

          if (!routeDrawn) {
            await _buildLegacyDirectionsRoute(
              originLatLng,
              destinationLatLng,
            );
          }
        }

        /// fixme: distance increase
        if (homeController.rideStatus.value == 3) {
          firstLat = secoundLat;
          firstLong = secoundLong;
          secoundLat = data.latitude;
          secoundLong = data.longitude;

          if (firstLat != 0 &&
              firstLong != 0 &&
              firstLat != secoundLat &&
              firstLong != secoundLong) {
            totalDistance += Geolocator.distanceBetween(
              firstLat,
              firstLong,
              secoundLat,
              secoundLong,
            );
            print("TOTAL DISTANCE:::::::${totalDistance}");
          }
        }
        if (homeController.rideStatus.value == 2) {
          firstLat = 0.0;
          firstLong = 0.0;
          secoundLat = 0.0;
          secoundLong = 0.0;
          totalDistance = 0;
        }
        if (steps.isNotEmpty &&
            (homeController.rideStatus.value == 1 ||
                homeController.rideStatus.value == 3)) {
          checkStep(LatLng(data.latitude, data.longitude));
        }
      }
    });
  }

  final SocketChannelService _socketService = SocketChannelService();

  bool isConnectionDone = false;

  Future<void> socketAuthConnection() async {
    try {
      if (Constants.socketId.isEmpty) {
        await Future.delayed(Duration(seconds: 3));
      }

      final response = await Api().post(
        ApiConstants.driverAuthentication,
        bodyData: {
          "socket_id": Constants.socketId,
          "channel_name":
          "private-driver-location.booking.${rideDataModel.value?.bookingId ?? ""}",
        },
      );

      DriverFlowDebug.send(
        'navigation_socket_auth_response',
        bookingId:
            (rideDataModel.value?.bookingId ?? Constants.bookingId).toString(),
        data: <String, dynamic>{
          'http_status': response.statusCode,
          'body_length': response.body.length,
        },
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        _socketService.sendPusherEvent("pusher:subscribe", {
          "channel":
          "private-driver-location.booking.${rideDataModel.value?.bookingId}",
          "auth": "${data['auth']}",
        });
        isConnectionDone = true;
      } else {
        throw "Statuscode :${response.statusCode} ::${response.body}";
      }
    } catch (e, st) {
      DriverFlowDebug.send(
        'navigation_socket_auth_error',
        bookingId:
            (rideDataModel.value?.bookingId ?? Constants.bookingId).toString(),
        data: <String, dynamic>{'error': e.toString(), 'stack': st.toString()},
      );
      LogUtils.printError("SOCKET AUTH ERROR $e, $st");
    } finally {}
  }

  Future<void> locationServerSend(LatLng latLong) async {
    try {
      _socketService.sendPusherEventChanel(
        "client-driver-location-update",
        {
          "booking_id": "${rideDataModel.value?.bookingId ?? ""}",
          "latitude": latLong.latitude,
          "longitude": latLong.longitude,
        },
        channel:
        "private-driver-location.booking.${rideDataModel.value?.bookingId}",
      );
    } catch (e) {}
  }

  double totalDistance = 0.0;
  double firstLat = 0.0;
  double firstLong = 0.0;
  double secoundLat = 0.0;
  double secoundLong = 0.0;


  Rx<Set<Polyline>> _polylines = Rx<Set<Polyline>>({});
  Rx<Set<Marker>> _marker = Rx<Set<Marker>>({});

  void _applyRoutePoints(List<LatLng> points) {
    if (points.isEmpty) return;
    _polylines.value = <Polyline>{
      Polyline(
        geodesic: true,
        visible: true,
        polylineId: const PolylineId('poly'),
        width: 5,
        color: AppColors.mainPrimaryColor,
        points: points,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
      ),
    };
    homeController.isDrawPoliLine.value = true;
  }

  List<LatLng> _decodeGooglePolyline(String encoded) {
    final List<LatLng> points = <LatLng>[];
    int index = 0;
    int latitude = 0;
    int longitude = 0;
    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);
      final int latitudeDelta = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      latitude += latitudeDelta;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);
      final int longitudeDelta =
          (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      longitude += longitudeDelta;
      points.add(LatLng(latitude / 1e5, longitude / 1e5));
    }
    return points;
  }

  Future<bool> _buildLegacyDirectionsRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    final String bookingId =
        (rideDataModel.value?.bookingId ?? Constants.bookingId).toString();
    final String key = (homeController.placeApi ?? '').trim();
    if (key.isEmpty) {
      DriverFlowDebug.send(
        'legacy_directions_skipped',
        bookingId: bookingId,
        data: <String, dynamic>{'reason': 'missing_api_key'},
      );
      return false;
    }

    final Uri url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      <String, String>{
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': 'driving',
        'key': key,
      },
    );
    try {
      final http.Response response =
          await http.get(url).timeout(const Duration(seconds: 10));
      final dynamic payload = jsonDecode(response.body);
      final String googleStatus =
          payload is Map ? (payload['status'] ?? '').toString() : '';
      DriverFlowDebug.send(
        'legacy_directions_result',
        bookingId: bookingId,
        data: <String, dynamic>{
          'http_status': response.statusCode,
          'google_status': googleStatus,
          'error_message': payload is Map
              ? (payload['error_message'] ?? '').toString()
              : '',
        },
      );
      if (response.statusCode != 200 ||
          payload is! Map ||
          googleStatus != 'OK') {
        _setLocalDistanceFallback(
          '${origin.latitude},${origin.longitude}',
          '${destination.latitude},${destination.longitude}',
        );
        return false;
      }

      final dynamic routes = payload['routes'];
      if (routes is! List || routes.isEmpty || routes.first is! Map) {
        return false;
      }
      final Map<dynamic, dynamic> route = routes.first as Map<dynamic, dynamic>;
      final dynamic overviewPolyline = route['overview_polyline'];
      final String encoded = overviewPolyline is Map
          ? (overviewPolyline['points'] ?? '').toString()
          : '';
      final List<LatLng> points =
          encoded.isEmpty ? <LatLng>[] : _decodeGooglePolyline(encoded);
      _applyRoutePoints(points);

      final dynamic legs = route['legs'];
      if (legs is List && legs.isNotEmpty) {
        final int distanceMeters = legs.fold<int>(0, (int sum, dynamic leg) {
          final dynamic distance = leg is Map ? leg['distance'] : null;
          final dynamic value = distance is Map ? distance['value'] : null;
          return sum + (value is num ? value.toInt() : 0);
        });
        final int durationSeconds = legs.fold<int>(0, (int sum, dynamic leg) {
          final dynamic duration = leg is Map ? leg['duration'] : null;
          final dynamic value = duration is Map ? duration['value'] : null;
          return sum + (value is num ? value.toInt() : 0);
        });
        _estimateDistance.value =
            '${(distanceMeters / 1000).toStringAsFixed(1)} km';
        _estimatedTime.value = '${(durationSeconds / 60).round()} perc';
        final dynamic firstSteps =
            legs.first is Map ? (legs.first as Map)['steps'] : null;
        steps = firstSteps is List ? firstSteps : <dynamic>[];
      }
      return points.isNotEmpty;
    } catch (error, stack) {
      DriverFlowDebug.send(
        'legacy_directions_exception',
        bookingId: bookingId,
        data: <String, dynamic>{
          'error': error.toString(),
          'stack': stack.toString(),
        },
      );
      _setLocalDistanceFallback(
        '${origin.latitude},${origin.longitude}',
        '${destination.latitude},${destination.longitude}',
      );
      return false;
    }
  }

  Future<void> getDistanceAndTime({
    required String origin,
    required String destination,
  }) async {
    if (_directionsUnavailable) {
      _setLocalDistanceFallback(origin, destination);
      return;
    }
    DriverFlowDebug.send(
      'directions_http_start',
      bookingId:
          (rideDataModel.value?.bookingId ?? Constants.bookingId).toString(),
      data: <String, dynamic>{
        'origin': origin,
        'destination': destination,
        'api_key_present': (homeController.placeApi ?? '').isNotEmpty,
      },
    );
    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      <String, String>{
        'origin': origin,
        'destination': destination,
        'mode': 'driving',
        'language': 'hu',
        'region': 'hu',
        'key': homeController.placeApi ?? '',
      },
    );
    http.Response response;
    try {
      response = await http.get(url).timeout(const Duration(seconds: 8));
    } catch (error) {
      DriverFlowDebug.send(
        'directions_http_exception',
        bookingId:
            (rideDataModel.value?.bookingId ?? Constants.bookingId).toString(),
        data: <String, dynamic>{'error': error.toString()},
      );
      _setLocalDistanceFallback(origin, destination);
      return;
    }

    if (response.statusCode != 200) {
      DriverFlowDebug.send(
        'directions_http_error_status',
        bookingId:
            (rideDataModel.value?.bookingId ?? Constants.bookingId).toString(),
        data: <String, dynamic>{
          'http_status': response.statusCode,
          'body_length': response.body.length,
        },
      );
      _setLocalDistanceFallback(origin, destination);
      return;
    }

    final jsonData = jsonDecode(response.body);
    DriverFlowDebug.send(
      'directions_http_result',
      bookingId:
          (rideDataModel.value?.bookingId ?? Constants.bookingId).toString(),
      data: <String, dynamic>{
        'http_status': response.statusCode,
        'google_status': jsonData['status']?.toString() ?? '',
        'error_message': jsonData['error_message']?.toString() ?? '',
        'route_count': jsonData['routes'] is List
            ? (jsonData['routes'] as List).length
            : 0,
      },
    );
    final googleStatus = jsonData['status']?.toString() ?? '';
    if (googleStatus == 'REQUEST_DENIED') {
      _directionsUnavailable = true;
    }

    final routes = jsonData['routes'];
    if (routes is! List || routes.isEmpty) {
      _setLocalDistanceFallback(origin, destination);
      return;
    }

    final legs = routes.first['legs'];
    if (legs is! List || legs.isEmpty) {
      _setLocalDistanceFallback(origin, destination);
      return;
    }

    final estimatedDistanceMeters = legs.fold<int>(0, (sum, leg) {
      final distance = leg is Map ? leg['distance'] : null;
      final value = distance is Map ? distance['value'] : null;
      return sum + (value is num ? value.toInt() : 0);
    });
    final estimatedTimeSeconds = legs.fold<int>(0, (sum, leg) {
      final duration = leg is Map ? leg['duration'] : null;
      final value = duration is Map ? duration['value'] : null;
      return sum + (value is num ? value.toInt() : 0);
    });

    _estimateDistance.value =
        "${(estimatedDistanceMeters / 1000).toStringAsFixed(1)} km";
    _estimatedTime.value =
        "${(estimatedTimeSeconds / 60).round()} perc";

    final firstSteps = legs.first['steps'];
    steps = firstSteps is List ? firstSteps : [];
  }

  RxString showInstractionStep = "".obs;
  List<dynamic> steps = [];

  int currentStepIndex = -1;

  void checkStep(LatLng latLng) {
    if (steps.isNotEmpty) {
      showInstractionStep.value = steps.first["html_instructions"];
    }
  }

  @override
  void dispose() {
    DriverFlowDebug.send(
      'navigation_screen_dispose',
      bookingId:
          (rideDataModel.value?.bookingId ?? Constants.bookingId).toString(),
      data: <String, dynamic>{
        'ride_status': homeController.rideStatus.value,
        'polyline_count': _polylines.value.length,
        'marker_count': _marker.value.length,
      },
    );
    _subscription?.cancel();

    super.dispose();
  }

  final homeController = Get.find<HomeController>();

  String _phaseTitle() {
    return switch (homeController.rideStatus.value) {
      1 => 'Úton az utashoz',
      2 => 'Megérkeztél',
      3 => 'Fuvar folyamatban',
      _ => 'Aktív fuvar',
    };
  }

  String _activeAddressLabel() {
    final model = rideDataModel.value;
    final raw = homeController.rideStatus.value == 1
        ? model?.pickup?.address ?? ''
        : model?.dropoff?.address ?? '';
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'A cím betöltése folyamatban…';
    return trimmed;
  }

  Widget _buildNoMapRideBackground() {
    final String pickup = (rideDataModel.value?.pickup?.address ?? '').trim();
    final String dropoff = (rideDataModel.value?.dropoff?.address ?? '').trim();
    final bool gpsActive = LocationService().currentUserLatLg.value != null;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF061126), Color(0xFF102B4D), Color(0xFF071329)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 26.h, 20.w, 250.h),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 96.w,
                    height: 96.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.mainPrimaryColor.withValues(alpha: .14),
                      border: Border.all(color: AppColors.mainPrimaryColor, width: 1.5),
                    ),
                    child: Icon(
                      Icons.local_taxi_rounded,
                      color: AppColors.mainPrimaryColor,
                      size: 52.sp,
                    ),
                  ),
                  18.verticalSpace,
                  CommonText(
                    string: _phaseTitle(),
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 28.sp,
                    textAlign: TextAlign.center,
                  ),
                  8.verticalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: gpsActive
                          ? AppColors.successColor.withValues(alpha: .16)
                          : AppColors.errorColor.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          gpsActive ? Icons.gps_fixed_rounded : Icons.gps_off_rounded,
                          color: gpsActive ? AppColors.successColor : AppColors.errorColor,
                          size: 18.sp,
                        ),
                        7.horizontalSpace,
                        CommonText(
                          string: gpsActive
                              ? 'GPS-helyzetküldés aktív'
                              : 'GPS-pozíció keresése',
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ],
                    ),
                  ),
                  if (homeController.rideStatus.value == 1 &&
                      _driverCommitmentLabel().isNotEmpty) ...<Widget>[
                    12.verticalSpace,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                      decoration: BoxDecoration(
                        color: AppColors.mainPrimaryColor.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(
                          color: AppColors.mainPrimaryColor.withValues(alpha: .55),
                        ),
                      ),
                      child: CommonText(
                        string: _driverCommitmentLabel(),
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                  22.verticalSpace,
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .07),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: Colors.white.withValues(alpha: .12)),
                    ),
                    child: Column(
                      children: <Widget>[
                        _NoMapAddressRow(
                          icon: Icons.trip_origin_rounded,
                          label: 'Felvételi cím',
                          value: pickup,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Divider(color: Colors.white.withValues(alpha: .12)),
                        ),
                        _NoMapAddressRow(
                          icon: Icons.location_on_rounded,
                          label: 'Úti cél',
                          value: dropoff,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingRideCard() {
    final bookingId =
        (rideDataModel.value?.bookingId ?? Constants.bookingId).toString();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Material(
          elevation: 8,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withValues(alpha: 0.97),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.mainPrimaryColor, width: 1.3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mainPrimaryColor,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        _phaseTitle().toUpperCase(),
                        style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    10.horizontalSpace,
                    Expanded(
                      child: Text(
                        _passengerName(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                  ],
                ),
                8.verticalSpace,
                Text(
                  _activeAddressLabel(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.bodyText,
                    height: 1.25,
                  ),
                ),
                8.verticalSpace,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: AppColors.whiteGrey,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    _distanceSummary(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
                10.verticalSpace,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Utils().launchDialer(
                            rideDataModel.value?.passenger?.phone ?? '',
                          );
                        },
                        icon: const Icon(Icons.call_outlined),
                        label: const Text('Hívás'),
                      ),
                    ),
                    8.horizontalSpace,
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: bookingId.isEmpty
                            ? null
                            : () {
                                Navigation.pushNamed(
                                  Routes.chatScreen,
                                  params: <String, String>{
                                    'bookingId': bookingId,
                                  },
                                );
                              },
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Chat'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

  RxBool isPop = false.obs;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bool isTabletLandscape =
        size.width > size.height && size.width >= 900;
    final double tabletPanelWidth =
        (size.width * .36).clamp(420.0, 520.0).toDouble();

    return Scaffold(
      body: Obx(
            () => PopScope(
          canPop: isPop.value,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop == false) {
              final result = await AppDialog.commonDialog(
                barrierDismiss: false,
                childs: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonText(
                      string: "Veszprémi Taxi",
                      fontWeight: FontWeight.w600,
                      fontSize: 26.sp,
                    ),
                    16.verticalSpace,
                    CommonText(
                      string: "Biztosan visszalépsz az aktív fuvarból?",
                      fontSize: 16.sp,
                      softWrap: true,
                    ),
                    24.verticalSpace,
                    CustomButton(
                      text: "Maradok",
                      onTap: () {
                        Get.back(result: false);
                      },
                    ),
                    16.verticalSpace,
                    CustomButton(
                      text: "Visszalépek",
                      buttonColor: AppColors.transparent,
                      borderColor: AppColors.blackColor,
                      onTap: () {
                        Get.back(result: true);
                      },
                    ),
                  ],
                ),
              );
              if (result) {
                isPop.value = true;
                Get.back();
              }
            }
          },
          child: SafeArea(
            bottom: Utils().checkPlatForm,

            child: Obx(
                  () => Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildNoMapRideBackground(),
                  if (!isTabletLandscape)
                    Positioned(
                      top: 12.h,
                      left: 12.w,
                      right: 12.w,
                      child: _buildFloatingRideCard(),
                    ),
                  Positioned(
                    bottom: isTabletLandscape ? 16.h : 0,
                    left: isTabletLandscape ? null : 0,
                    right: isTabletLandscape ? 16.w : 0,
                    width: isTabletLandscape ? tabletPanelWidth : null,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: isTabletLandscape ? 0 : 52.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16.r),
                            ),
                            color: AppColors.whiteGrey,
                          ),
                          child: SingleChildScrollView(
                            child: Obx(
                                  () => showNavigation.value
                                  ? Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showNavigation.value = false;
                                    },
                                    child: Container(
                                      height: 40.h,
                                      width: 40.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.blackColor,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: CustomImage(
                                        image: IconAsset.close,
                                      ),
                                    ),
                                  ),
                                  Obx(
                                        () => Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        CommonText(
                                          string: _estimatedTime.value,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        CommonText(
                                          string: _estimateDistance.value,
                                          color: AppColors.hintTextColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (LocationService()
                                          .currentUserLatLg
                                          .value !=
                                          null) {
                                        cameraPositionUpdate(
                                          LocationService()
                                              .currentUserLatLg
                                              .value!,
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 40.h,
                                      width: 40.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.blackColor,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: CustomImage(
                                        image: IconAsset.frame,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                                  : homeController.rideStatus.value == 1
                                  ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            CommonText(
                                              string:
                                              "${Utils().getString(rideDataModel.value?.pickup?.address ?? "").first}",
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            CommonText(
                                              string:
                                              "${Utils().getString(rideDataModel.value?.dropoff?.address ?? "").first}",
                                              color: AppColors
                                                  .textCaptionColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.successColor.withValues(alpha: .12),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            Icon(
                                              Icons.gps_fixed_rounded,
                                              color: AppColors.successColor,
                                              size: 22.sp,
                                            ),
                                            CommonText(
                                              string: 'GPS aktív',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11.sp,
                                              color: AppColors.successColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  16.verticalSpace,
                                  ListTileWidget(
                                    title:
                                    "${rideDataModel.value?.customer?.customerName ?? ""}",
                                    image:
                                    "${rideDataModel.value?.customer?.customerPhoto ?? ""}",

                                    subtitle: _distanceSummary(),
                                    trailingWidget: Row(
                                      children: [
                                        IconWidgets(
                                          onTap: () {
                                            Utils().launchDialer(
                                              rideDataModel
                                                  .value
                                                  ?.passenger
                                                  ?.phone ??
                                                  "",
                                            );
                                          },
                                          icon: IconAsset.call,
                                          bgColor: AppColors
                                              .textFieldBorderColor,
                                        ),
                                        16.horizontalSpace,
                                        IconWidgets(
                                          onTap: () {
                                            Navigation.pushNamed(
                                              Routes.chatScreen,
                                              params: {
                                                "bookingId":
                                                (rideDataModel
                                                    .value
                                                    ?.bookingId ??
                                                    "")
                                                    .toString(),
                                              },
                                            );
                                          },
                                          icon: IconAsset.message,
                                          bgColor: AppColors
                                              .textFieldBorderColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  24.verticalSpace,

                                  CustomButton(
                                    text: AppString.markReach.tr,
                                    onTap: () async {
                                      final bookingId = (rideDataModel
                                                  .value?.bookingId ??
                                              Constants.bookingId)
                                          .toString();
                                      DriverFlowDebug.send(
                                        'mark_reached_button_tap',
                                        bookingId: bookingId,
                                        data: <String, dynamic>{
                                          'ride_status':
                                              homeController.rideStatus.value,
                                          'current_location_present':
                                              LocationService()
                                                      .currentUserLatLg
                                                      .value !=
                                                  null,
                                        },
                                      );

                                      LatLng? currentPosition =
                                          LocationService()
                                              .currentUserLatLg
                                              .value;
                                      if (currentPosition == null) {
                                        DriverFlowDebug.send(
                                          'mark_reached_location_request',
                                          bookingId: bookingId,
                                        );
                                        currentPosition = await LocationService()
                                            .ensureCurrentLocation()
                                            .timeout(
                                              const Duration(seconds: 10),
                                              onTimeout: () => null,
                                            );
                                      }

                                      if (currentPosition == null) {
                                        DriverFlowDebug.send(
                                          'mark_reached_location_unavailable',
                                          bookingId: bookingId,
                                        );
                                        AppSnackBar.showErrorSnackBar(
                                          message:
                                              'Nem érkezett GPS-pozíció. Próbáld újra.',
                                          isError: true,
                                        );
                                        return;
                                      }

                                      DriverFlowDebug.send(
                                        'mark_reached_status_request',
                                        bookingId: bookingId,
                                        data: <String, dynamic>{
                                          'latitude': DriverFlowDebug.coordinate(
                                            currentPosition.latitude,
                                          ),
                                          'longitude': DriverFlowDebug.coordinate(
                                            currentPosition.longitude,
                                          ),
                                        },
                                      );

                                      final success = await homeController
                                          .updateBookingRideStatus(
                                        bookingId: bookingId,
                                        statusNo: 2,
                                        dropLatLng: currentPosition,
                                        dropAddress: rideDataModel
                                                .value?.pickup?.address ??
                                            '',
                                      );

                                      DriverFlowDebug.send(
                                        'mark_reached_status_result',
                                        bookingId: bookingId,
                                        data: <String, dynamic>{
                                          'success': success,
                                          'ride_status_after':
                                              homeController.rideStatus.value,
                                        },
                                      );
                                    },
                                  ).paddingOnly(bottom: 16.h),

                                  CustomButton(
                                    text: AppString.cancelTrip.tr,
                                    onTap: () {
                                      AppDialog.commonDialog(
                                        barrierDismiss: false,
                                        childs: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CustomImage(
                                              image: IconAsset.infoCircle,
                                              ht: 64.h,
                                              wt: 64.h,
                                            ),
                                            16.verticalSpace,
                                            CommonText(
                                              string: AppString
                                                  .areYouSureCancelTrip
                                                  .tr,
                                              color: AppColors
                                                  .titleTextColor,
                                              softWrap: true,
                                              textAlign: TextAlign.center,
                                            ),
                                            8.verticalSpace,
                                            CommonText(
                                              string: AppString
                                                  .cancelTripAffectYourRate
                                                  .tr,
                                              color: AppColors.bodyText,
                                              softWrap: true,
                                              textAlign: TextAlign.center,
                                            ),
                                            24.verticalSpace,
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomButton(
                                                    text: AppString
                                                        .close
                                                        .tr,
                                                    buttonColor: AppColors
                                                        .transparent,
                                                    borderColor: AppColors
                                                        .blackColor,
                                                    onTap: () {
                                                      Get.back();
                                                    },
                                                  ),
                                                ),
                                                16.horizontalSpace,
                                                Expanded(
                                                  child: CustomButton(
                                                    text: AppString
                                                        .cancel
                                                        .tr,
                                                    buttonColor: AppColors
                                                        .errorColor,
                                                    textColor: AppColors
                                                        .whiteColor,
                                                    onTap: () {
                                                      Navigator.pop(
                                                        context,
                                                      );
                                                      Navigation.pushNamed(
                                                        Routes
                                                            .cancelRequestScreen,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    buttonColor: AppColors.whiteColor,
                                    borderColor: AppColors.titleTextColor,
                                  ).paddingOnly(bottom: 10.h),
                                ],
                              )
                                  : homeController.rideStatus.value == 2
                                  ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      CommonText(
                                        string:
                                        AppString.waitingForRider.tr,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(8.r),
                                          border: Border.all(
                                            color: AppColors.warningColor,
                                          ),
                                          color: AppColors.warningBgColor,
                                        ),
                                        child: Obx(
                                              () => CommonText(
                                            string: timeString(
                                              time: homeController
                                                  .waitingTime
                                                  .value,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: AppColors.textFieldBorderColor,
                                  ),
                                  24.verticalSpace,
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors
                                            .textFieldBorderColor,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        12.r,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              CommonText(
                                                string:
                                                AppString
                                                    .waitingForRider
                                                    .tr +
                                                    "...",
                                              ),
                                              CommonText(
                                                string:
                                                "${rideDataModel.value?.customer?.customerName ?? ""}",
                                                fontWeight:
                                                FontWeight.w500,
                                                fontSize: 16.sp,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconWidgets(
                                          onTap: () {
                                            Utils().launchDialer(
                                              rideDataModel
                                                  .value
                                                  ?.passenger
                                                  ?.phone ??
                                                  "",
                                            );
                                          },
                                          icon: IconAsset.call,
                                          bgColor: AppColors
                                              .textFieldBorderColor,
                                        ),
                                        16.horizontalSpace,
                                        IconWidgets(
                                          onTap: () {
                                            Navigation.pushNamed(
                                              Routes.chatScreen,
                                              params: {
                                                "bookingId":
                                                (rideDataModel
                                                    .value
                                                    ?.bookingId ??
                                                    "")
                                                    .toString(),
                                              },
                                            );
                                          },
                                          icon: IconAsset.message,
                                          bgColor: AppColors
                                              .textFieldBorderColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  16.verticalSpace,
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        12.r,
                                      ),
                                      border: Border.all(
                                        color: AppColors
                                            .textFieldBorderColor,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: CommonText(
                                            string:
                                            "Díjmentes várakozás: ${rideDataModel.value?.booking?.rideType?.waitingTimeLimit ?? "0"} perc. Ezután ${Utils.formatCurrency(rideDataModel.value?.booking?.rideType?.waitingChargePerMinute)}/perc várakozási díj számítható fel.",
                                            softWrap: true,
                                            maxLines: 2,
                                          ),
                                        ),
                                        10.horizontalSpace,
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                  24.verticalSpace,
                                  CustomButton(
                                    text: AppString.startTrip.tr,
                                    onTap: () async {
                                      Navigation.pushNamed(
                                        Routes.customerOtpVerify,
                                        arg: <String, dynamic>{
                                          'booking_id':
                                              (rideDataModel.value?.bookingId ??
                                                      Constants.bookingId)
                                                  .toString(),
                                          'drop_latitude':
                                              rideDataModel.value?.dropoff?.latitude ?? '',
                                          'drop_longitude':
                                              rideDataModel.value?.dropoff?.longitude ?? '',
                                          'drop_address':
                                              rideDataModel.value?.dropoff?.address ?? '',
                                          'customer_name':
                                              rideDataModel.value?.customer?.customerName ?? '',
                                        },
                                      );
                                    },
                                  ),
                                ],
                              )
                                  : Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        8.r,
                                      ),
                                      color: AppColors.sucessContainer,
                                    ),
                                    child: Row(
                                      children: [
                                        16.horizontalSpace,
                                        CustomImage(
                                          image: ImagesAsset.drivingCar,
                                          ht: 16.w,
                                          wt: 16.w,
                                          color: AppColors.successColor,
                                        ),
                                        8.horizontalSpace,

                                        Expanded(
                                          child: CommonText(
                                            string:
                                            "Úton ${(rideDataModel.value?.pickup?.address ?? "").split(",").first} felől ${(rideDataModel.value?.dropoff?.address ?? "").split(",").first} felé",
                                            softWrap: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  8.verticalSpace,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            CommonText(
                                              string: Utils()
                                                  .getString(
                                                rideDataModel
                                                    .value
                                                    ?.dropoff
                                                    ?.address ??
                                                    "",
                                              )
                                                  .first,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16.sp,
                                            ),
                                            CommonText(
                                              string: Utils()
                                                  .getString(
                                                rideDataModel
                                                    .value
                                                    ?.dropoff
                                                    ?.address ??
                                                    "",
                                              )
                                                  .last,
                                              color: AppColors
                                                  .textCaptionColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          IconWidgets(
                                            onTap: () async {
                                              await _focusInternalNavigation();
                                            },
                                            icon: IconAsset.direct,
                                            ht: 40.w,
                                            bgColor: AppColors
                                                .mainPrimaryColor,
                                          ),
                                          CommonText(
                                            string:
                                            AppString.navigation.tr,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16.sp,
                                            color: AppColors
                                                .mainPrimaryColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  24.verticalSpace,
                                  CustomButton(
                                    text: AppString.endTrip.tr,
                                    onTap: () async {
                                      await homeController
                                          .updateBookingRideStatus(
                                        bookingId:
                                        (rideDataModel
                                            .value
                                            ?.bookingId ??
                                            "")
                                            .toString(),
                                        statusNo: 4,
                                        totalDistance: totalDistance,
                                        dropLatLng: LatLng(
                                          double.parse(
                                            rideDataModel
                                                .value
                                                ?.dropoff
                                                ?.latitude ??
                                                "0",
                                          ),
                                          double.parse(
                                            rideDataModel
                                                .value
                                                ?.dropoff
                                                ?.longitude ??
                                                "0",
                                          ),
                                        ),
                                        dropAddress:
                                        rideDataModel
                                            .value
                                            ?.dropoff
                                            ?.address ??
                                            "",
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // A lebegő hibajelző ezen a képernyőn elfedte a
                        // navigációs vezérlőt a Blackview 1280x800-as nézetén.
                        // A hibajegy továbbra is elérhető a Segítség menüből,
                        // ezért az aktív navigációs felületről eltávolítottuk.
                      ],
                    ),
                  ),

                  Positioned(
                    top: 45.h,
                    left: 16.w,
                    right: 16.w,
                    child: Obx(
                          () => showInstractionStep.value.isEmpty
                          ? SizedBox.shrink()
                          : Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          color: AppColors.greenColor,
                        ),
                        child: html.Html(
                          data: showInstractionStep.value,
                          style: {
                            "*": html.Style(
                              color: AppColors.whiteColor,
                              fontSize: html.FontSize(14.sp),
                              fontWeight: FontWeight.w500,
                            ),
                          },
                        ),

                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> reportIssueList = [
    AppString.riderNotShowUp,
    AppString.wrongPickUp,
    AppString.riderIsDelayed,
    AppString.trafficIssue,
    AppString.navigationProblem,
  ];

  reportIssue() {
    RxInt selectedIndex = (-1).obs;
    TextEditingController controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            height: Get.height * (0.6),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              color: AppColors.whiteColor,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 8.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        color: AppColors.textFieldBorderColor,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    24.verticalSpace,

                    Align(
                      alignment: Alignment.topLeft,
                      child: CommonText(
                        string: AppString.reportIssue.tr,
                        fontWeight: FontWeight.w500,
                        fontSize: 18.sp,
                        color: AppColors.titleTextColor,
                      ),
                    ),
                    3.verticalSpace,

                    Divider(color: AppColors.textFieldBorderColor),
                    12.verticalSpace,
                    Obx(
                          () => Wrap(
                        runSpacing: 16.w,
                        spacing: 16.w,
                        children: [
                          GestureDetector(
                            onTap: () {
                              selectedIndex.value = 0;
                            },
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: selectedIndex.value == 0
                                    ? AppColors.primaryContainer
                                    : AppColors.transparentColor,
                                border: Border.all(
                                  color: selectedIndex.value == 0
                                      ? AppColors.mainPrimaryColor
                                      : AppColors.textFieldBorderColor,
                                ),
                              ),
                              child: CommonText(string: reportIssueList[0].tr),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              selectedIndex.value = 1;
                            },
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: selectedIndex.value == 1
                                    ? AppColors.primaryContainer
                                    : AppColors.transparentColor,
                                border: Border.all(
                                  color: selectedIndex.value == 1
                                      ? AppColors.mainPrimaryColor
                                      : AppColors.textFieldBorderColor,
                                ),
                              ),
                              child: CommonText(string: reportIssueList[1].tr),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              selectedIndex.value = 2;
                            },
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: selectedIndex.value == 2
                                    ? AppColors.primaryContainer
                                    : AppColors.transparentColor,
                                border: Border.all(
                                  color: selectedIndex.value == 2
                                      ? AppColors.mainPrimaryColor
                                      : AppColors.textFieldBorderColor,
                                ),
                              ),
                              child: CommonText(string: reportIssueList[2].tr),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              selectedIndex.value = 3;
                            },
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: selectedIndex.value == 3
                                    ? AppColors.primaryContainer
                                    : AppColors.transparentColor,
                                border: Border.all(
                                  color: selectedIndex.value == 3
                                      ? AppColors.mainPrimaryColor
                                      : AppColors.textFieldBorderColor,
                                ),
                              ),
                              child: CommonText(string: reportIssueList[3].tr),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              selectedIndex.value = 4;
                            },
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: selectedIndex.value == 4
                                    ? AppColors.primaryContainer
                                    : AppColors.transparentColor,
                                border: Border.all(
                                  color: selectedIndex.value == 4
                                      ? AppColors.mainPrimaryColor
                                      : AppColors.textFieldBorderColor,
                                ),
                              ),
                              child: CommonText(string: reportIssueList[4].tr),
                            ),
                          ),
                        ],
                      ),
                    ),
                    16.verticalSpace,

                    CustomTextField(
                      controller: controller,
                      hintText: AppString.writeIssue.tr,
                      fillColor: AppColors.dividerColor,
                      hintTextStyle: TextStyle(
                        color: AppColors.textCaptionColor,
                      ),
                    ),
                    24.verticalSpace,
                    CustomButton(
                      text: AppString.submitIssue.tr,
                      onTap: () async {
                        if (selectedIndex.value == -1 &&
                            controller.text.trim().isEmpty) {
                          AppSnackBar.showErrorSnackBar(
                            message: "Írd le a problémát.",
                            isError: true,
                          );
                          return;
                        }

                        final map = await homeController.reportSubmit(
                          bookingId: int.parse(
                            rideDataModel.value?.booking?.id ?? "0",
                          ),
                          selected: selectedIndex.value,
                          description: controller.text.trim(),
                        );

                        if (map.isNotEmpty) {
                          AppSnackBar.showErrorSnackBar(
                            message: map['message'],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
