import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as Math;
import 'package:dotted_line/dotted_line.dart';
import 'package:e_taxi/core/debug/passenger_flow_debug.dart';
import 'package:e_taxi/core/service/google_route_service.dart';
import 'package:e_taxi/core/location_utils.dart';
import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/feature/home/model/get_socket_model.dart';
import 'package:e_taxi/feature/profile/model/user_model.dart';
import 'package:e_taxi/feature/profile/service/profile_service.dart';
import 'package:e_taxi/feature/home/widget/origin_destination_widget.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
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
import '../../../widgets/app_snackbar.dart';
import '../widget/driver_details_widget.dart';
import '../widget/chat_unread_badge.dart';
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
  LatLng? _driverMarkerPosition;
  double _driverMarkerRotation = 0;
  Timer? _driverMarkerAnimationTimer;

  String _displayTripOtp() {
    final raw = riderBookingModel.value?.data?.booking?.otp?.toString() ?? '';
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '000000';
    if (digits.length >= 6) return digits.substring(digits.length - 6);
    return digits.padLeft(6, '0');
  }

  Widget _buildSearchingVisual() {
    return Container(
      width: 184.w,
      height: 128.w,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: AppColors.mainPrimaryColor.withValues(alpha: .45),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 94.w,
            height: 94.w,
            child: CircularProgressIndicator(
              strokeWidth: 5.w,
              color: AppColors.mainPrimaryColor,
              backgroundColor: AppColors.mainPrimaryColor.withValues(
                alpha: .15,
              ),
            ),
          ),
          Container(
            width: 68.w,
            height: 68.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.whiteColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withValues(alpha: .12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.local_taxi_rounded,
              color: AppColors.mainPrimaryColor,
              size: 38.w,
            ),
          ),
          Positioned(
            left: 24.w,
            bottom: 18.w,
            child: Icon(
              Icons.location_on_rounded,
              color: AppColors.successColor,
              size: 26.w,
            ),
          ),
          Positioned(
            right: 24.w,
            top: 18.w,
            child: Icon(
              Icons.my_location_rounded,
              color: AppColors.titleTextColor,
              size: 22.w,
            ),
          ),
        ],
      ),
    );
  }

  double _bearingBetween(LatLng from, LatLng to) {
    final double fromLat = from.latitude * 0.017453292519943295;
    final double fromLng = from.longitude * 0.017453292519943295;
    final double toLat = to.latitude * 0.017453292519943295;
    final double toLng = to.longitude * 0.017453292519943295;
    final double y = Math.sin(toLng - fromLng) * Math.cos(toLat);
    final double x =
        Math.cos(fromLat) * Math.sin(toLat) -
        Math.sin(fromLat) * Math.cos(toLat) * Math.cos(toLng - fromLng);
    return (Math.atan2(y, x) * 57.29577951308232 + 360) % 360;
  }

  void _setDriverMarkerFrame(
    LatLng position,
    BitmapDescriptor icon,
    double rotation,
  ) {
    final markers = Set<Marker>.from(_marker.value);
    markers.removeWhere((element) => element.markerId.value == 'driver');
    markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: position,
        icon: icon,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        rotation: rotation,
        zIndexInt: 3,
      ),
    );
    _marker.value = markers;
  }

  String _activeBookingId() {
    return "${riderBookingModel.value?.data?.booking?.id ?? riderBookingModel.value?.data?.bookingId ?? homeController.bookingCreateModel.value?.data?.booking?.id ?? AppConstant().bookingId}";
  }

  int? _driverCommitmentMinutes() {
    final bookingValue = int.tryParse(
      riderBookingModel.value?.data?.booking?.driverEtaMinutes ?? '',
    );
    return bookingValue ?? riderBookingModel.value?.data?.driverEtaMinutes;
  }

  double? _driverDistanceToPickupKm() {
    final driver = riderBookingModel.value?.data?.driver;
    final pickup = riderBookingModel.value?.data?.pickup;
    final driverLat = double.tryParse(
      driver?.currentLocation?.latitude ?? driver?.lastLatitude ?? '',
    );
    final driverLng = double.tryParse(
      driver?.currentLocation?.longitude ?? driver?.lastLongitude ?? '',
    );
    final pickupLat = double.tryParse(pickup?.latitude ?? '');
    final pickupLng = double.tryParse(pickup?.longitude ?? '');
    if (driverLat == null ||
        driverLng == null ||
        pickupLat == null ||
        pickupLng == null) {
      return null;
    }
    return Geolocator.distanceBetween(
          driverLat,
          driverLng,
          pickupLat,
          pickupLng,
        ) /
        1000;
  }

  int? _gpsArrivalEstimateMinutes() {
    final distanceKm = _driverDistanceToPickupKm();
    if (distanceKm == null) return null;
    // Városi forgalomra konzervatív, folyamatosan frissülő helyi becslés.
    return Math.max(1, (distanceKm / 28 * 60).ceil()).toInt();
  }

  Widget _buildArrivalInfoCard() {
    final commitment = _driverCommitmentMinutes();
    final gpsEstimate = _gpsArrivalEstimateMinutes();
    final distanceKm = _driverDistanceToPickupKm();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.mainPrimaryColor.withValues(alpha: .35),
        ),
      ),
      child: Wrap(
        spacing: 16.w,
        runSpacing: 8.h,
        children: [
          _arrivalMetric(
            Icons.schedule_rounded,
            'Sofőr vállalása',
            commitment == null ? '–' : '$commitment perc',
          ),
          _arrivalMetric(
            Icons.navigation_rounded,
            'GPS-becslés',
            gpsEstimate == null ? '–' : '$gpsEstimate perc',
          ),
          _arrivalMetric(
            Icons.route_rounded,
            'Távolság',
            distanceKm == null ? '–' : '${distanceKm.toStringAsFixed(1)} km',
          ),
        ],
      ),
    );
  }

  Widget _arrivalMetric(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20.w, color: AppColors.mainPrimaryColor),
        6.horizontalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              string: label,
              fontSize: 11.sp,
              color: AppColors.textCaptionColor,
            ),
            CommonText(
              string: value,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> setDriverMarker(LatLng latLong) async {
    try {
      final BitmapDescriptor icon = await _resolveDriverMarkerIcon();
      final LatLng? previous = _driverMarkerPosition;
      _driverMarkerAnimationTimer?.cancel();

      if (previous == null ||
          Geolocator.distanceBetween(
                previous.latitude,
                previous.longitude,
                latLong.latitude,
                latLong.longitude,
              ) >
              1500) {
        _driverMarkerPosition = latLong;
        _setDriverMarkerFrame(latLong, icon, _driverMarkerRotation);
        return;
      }

      final double targetRotation = _bearingBetween(previous, latLong);
      const int steps = 12;
      int step = 0;
      _driverMarkerAnimationTimer = Timer.periodic(
        const Duration(milliseconds: 75),
        (Timer timer) {
          step++;
          final double progress = step / steps;
          final double eased = 1 - Math.pow(1 - progress, 3).toDouble();
          final LatLng frame = LatLng(
            previous.latitude + (latLong.latitude - previous.latitude) * eased,
            previous.longitude +
                (latLong.longitude - previous.longitude) * eased,
          );
          double rotationDelta =
              ((targetRotation - _driverMarkerRotation + 540) % 360) - 180;
          final double frameRotation =
              (_driverMarkerRotation + rotationDelta * eased + 360) % 360;
          _setDriverMarkerFrame(frame, icon, frameRotation);
          if (step >= steps) {
            timer.cancel();
            _driverMarkerPosition = latLong;
            _driverMarkerRotation = targetRotation;
            _setDriverMarkerFrame(latLong, icon, targetRotation);
          }
        },
      );
    } catch (e, st) {
      LogUtils.printAction("setDriverMarker error: $e , $st");
      try {
        final icon = await Utils().ensureCarIcon();
        _driverMarkerPosition = latLong;
        _setDriverMarkerFrame(latLong, icon, _driverMarkerRotation);
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
  Timer? _bookingStatusPollingTimer;
  bool _bookingStatusPollInProgress = false;
  String _lastAppliedBookingState = '';
  int _missingCurrentBookingPolls = 0;
  int _consecutiveExactServerReleasePolls = 0;
  String _exactServerReleaseBookingId = '';

  bool driverReach = true;
  bool routLine = false;
  DateTime _lastApiCall = DateTime.now().subtract(Duration(seconds: 6));

  Map<String, dynamic>? _decodeSocketMap(dynamic raw) {
    try {
      if (raw is Map<String, dynamic>) return raw;
      if (raw is Map) {
        return raw.map<String, dynamic>(
          (dynamic key, dynamic value) =>
              MapEntry<String, dynamic>(key.toString(), value),
        );
      }
      if (raw is String && raw.trim().isNotEmpty) {
        final dynamic decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map<String, dynamic>(
            (dynamic key, dynamic value) =>
                MapEntry<String, dynamic>(key.toString(), value),
          );
        }
      }
    } catch (error, stack) {
      PassengerFlowDebug.runtimeError(
        'search_driver_socket_decode',
        error,
        stack,
      );
    }
    return null;
  }

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
          icon: Utils().sourceMarkerIcon ?? Utils().customIcon!,
        ),
      );

      _marker.value.add(
        Marker(
          markerId: MarkerId("Destination"),
          position: data['destination'],
          icon: Utils().destinationMarkerIcon ?? Utils().customIcon!,
        ),
      );
    }

    PassengerFlowDebug.send(
      'search_driver_screen_opened',
      bookingId: _activeBookingId(),
      data: <String, dynamic>{
        'has_arguments': Get.arguments != null,
        'trip_type': homeController.tripType.value,
      },
    );

    drawPoliLine();
    _preloadDriverMarkerIcon();

    _rideModelWorker = ever(riderBookingModel, (_) {
      _showDriverMarkerIfAvailable();
    });

    _startBookingStatusPolling();

    _sub = SocketChannelService().onSocketDataListen.listen((event) async {
      try {
        final Map<String, dynamic>? datas = _decodeSocketMap(event);
        if (datas == null) {
          PassengerFlowDebug.send(
            'search_driver_socket_outer_invalid',
            bookingId: _activeBookingId(),
            data: <String, dynamic>{
              'runtime_type': event.runtimeType.toString(),
            },
          );
          return;
        }

        final String eventName = '${datas['event'] ?? ''}'.trim();
        final Map<String, dynamic>? eventData = _decodeSocketMap(datas['data']);
        final String eventBookingId = '${eventData?['booking_id'] ?? ''}'
            .trim();

        PassengerFlowDebug.send(
          'search_driver_socket_event',
          bookingId: eventBookingId.isNotEmpty
              ? eventBookingId
              : _activeBookingId(),
          data: <String, dynamic>{
            'event_name': eventName,
            'payload_keys': eventData?.keys.toList() ?? const <String>[],
            'booking_matches':
                eventBookingId.isNotEmpty &&
                eventBookingId == _activeBookingId(),
          },
        );

        if (eventName != 'driver.location.updated' ||
            eventData == null ||
            eventBookingId != _activeBookingId()) {
          return;
        }

        final double? latitude = double.tryParse(
          '${eventData['latitude'] ?? ''}',
        );
        final double? longitude = double.tryParse(
          '${eventData['longitude'] ?? ''}',
        );
        if (latitude == null || longitude == null) {
          PassengerFlowDebug.send(
            'driver_location_socket_invalid_coordinates',
            bookingId: _activeBookingId(),
            data: <String, dynamic>{
              'has_latitude': eventData.containsKey('latitude'),
              'has_longitude': eventData.containsKey('longitude'),
            },
          );
          return;
        }

        final LatLng newPos = LatLng(latitude, longitude);
        await setDriverMarker(newPos);
        PassengerFlowDebug.send(
          'driver_location_socket_received',
          bookingId: _activeBookingId(),
          data: <String, dynamic>{
            'latitude': PassengerFlowDebug.coordinate(newPos.latitude),
            'longitude': PassengerFlowDebug.coordinate(newPos.longitude),
          },
        );

        final riderModel = riderBookingModel.value?.data;
        final LatLng originLatLng = homeController.changePolyLine
            ? newPos
            : LatLng(
                double.tryParse(riderModel?.pickup?.latitude ?? '') ?? 0,
                double.tryParse(riderModel?.pickup?.longitude ?? '') ?? 0,
              );
        final LatLng destinationLatLng = homeController.changePolyLine
            ? LatLng(
                double.tryParse(riderModel?.pickup?.latitude ?? '') ?? 0,
                double.tryParse(riderModel?.pickup?.longitude ?? '') ?? 0,
              )
            : LatLng(
                double.tryParse(riderModel?.dropoff?.latitude ?? '') ?? 0,
                double.tryParse(riderModel?.dropoff?.longitude ?? '') ?? 0,
              );

        final Set<Marker> markers = Set<Marker>.from(_marker.value);
        markers.removeWhere(
          (Marker marker) => marker.markerId.value == 'destination',
        );
        markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            icon:
                Utils().destinationMarkerIcon ??
                Utils().customIcon ??
                BitmapDescriptor.defaultMarker,
            position: destinationLatLng,
          ),
        );
        _marker.value = markers;

        final List<LatLng> polylineCoordinates = await _getRoutePoints(
          originLatLng,
          destinationLatLng,
        );

        PassengerFlowDebug.send(
          'driver_route_points_updated',
          bookingId: _activeBookingId(),
          data: <String, dynamic>{
            'point_count': polylineCoordinates.length,
            'change_polyline': homeController.changePolyLine,
          },
        );

        if (polylineCoordinates.isNotEmpty) {
          _polylines.value = <Polyline>{
            Polyline(
              geodesic: false,
              visible: true,
              width: 9,
              zIndex: 1,
              polylineId: const PolylineId('route_outline'),
              color: AppColors.routeOutline,
              points: polylineCoordinates,
              endCap: Cap.roundCap,
              startCap: Cap.roundCap,
              jointType: JointType.round,
            ),
            Polyline(
              geodesic: false,
              visible: true,
              width: 5,
              zIndex: 2,
              polylineId: const PolylineId('route_main'),
              color: AppColors.routeGreen,
              points: polylineCoordinates,
              endCap: Cap.roundCap,
              startCap: Cap.roundCap,
              jointType: JointType.round,
            ),
          };
          isDrawPoliLine = true;
        }
      } catch (error, stack) {
        PassengerFlowDebug.runtimeError(
          'search_driver_socket_listener',
          error,
          stack,
        );
        LogUtils.printAction('MARKER OR SOCKET ERROR: $error, $stack');
      }
    });
  }

  String _profileCancellationReasonForBooking({
    required UserProfileModel profile,
    required String bookingId,
  }) {
    final String normalizedBookingId = bookingId.trim();
    if (normalizedBookingId.isEmpty) return '';

    final recentBookings = profile.data?.recentBookings;
    if (recentBookings == null) return '';

    for (final booking in recentBookings) {
      final String recentBookingId = (booking.id ?? '').trim();
      final String recentStatus = (booking.status ?? '').toLowerCase().trim();
      if (recentBookingId == normalizedBookingId &&
          recentStatus == 'cancelled') {
        return (booking.cancellationReason ?? '').trim();
      }
    }
    return '';
  }

  void _startBookingStatusPolling() {
    _bookingStatusPollingTimer?.cancel();
    unawaited(_pollBookingStatus());
    _bookingStatusPollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => unawaited(_pollBookingStatus()),
    );
  }

  Future<void> _pollBookingStatus() async {
    if (_bookingStatusPollInProgress || !mounted) return;

    final activeBookingId = _activeBookingId().trim();
    if (activeBookingId.isEmpty || activeBookingId == 'null') return;

    _bookingStatusPollInProgress = true;
    try {
      final profile = await ProfileService.getUserProfileSilent();
      final currentBooking = profile.currentBooking;
      final String serverCurrentBookingId =
          (profile.data?.currentBookingId ?? '').trim();
      final String responseBookingId =
          '${currentBooking?.booking?.id ?? currentBooking?.bookingId ?? ''}'
              .trim();
      // A current_booking objektum a mérvadó. A backend jelenleg
      // előfordul, hogy a data.current_booking_id mezőt üresen küldi vissza
      // egy frissen létrehozott, searching állapotú rendelés mellett.
      // Emiatt csak a segédmező hiánya alapján tilos megszüntetni a rendelést.
      final bool currentBookingMatches =
          currentBooking != null &&
          responseBookingId.isNotEmpty &&
          responseBookingId == activeBookingId;

      if (!currentBookingMatches) {
        _missingCurrentBookingPolls++;
        final localStatus =
            (riderBookingModel.value?.data?.booking?.status ?? '')
                .trim()
                .toLowerCase();
        final bool serverReleasedBooking =
            currentBooking == null &&
            serverCurrentBookingId.isEmpty &&
            responseBookingId.isEmpty;
        if (serverReleasedBooking) {
          if (_exactServerReleaseBookingId != activeBookingId) {
            _exactServerReleaseBookingId = activeBookingId;
            _consecutiveExactServerReleasePolls = 0;
          }
          _consecutiveExactServerReleasePolls++;
        } else {
          _exactServerReleaseBookingId = '';
          _consecutiveExactServerReleasePolls = 0;
        }
        PassengerFlowDebug.send(
          'booking_status_poll_profile_inconsistent',
          bookingId: activeBookingId,
          data: <String, dynamic>{
            'missing_poll_count': _missingCurrentBookingPolls,
            'exact_release_poll_count': _consecutiveExactServerReleasePolls,
            'server_current_booking_id': serverCurrentBookingId,
            'response_booking_id': responseBookingId,
            'current_booking_present': currentBooking != null,
            'local_status': localStatus,
            'server_released_booking': serverReleasedBooking,
          },
        );

        if (currentBooking == null &&
            const <String>{'cancelled', 'expired'}.contains(localStatus)) {
          _bookingStatusPollingTimer?.cancel();
          PassengerFlowDebug.send(
            'booking_status_poll_terminal_without_profile_booking',
            bookingId: activeBookingId,
            data: <String, dynamic>{'status': localStatus},
          );
          await homeController.socketData();
          return;
        }

        // Accepted/arrived állapotban két egymást követő, sikeres és
        // teljesen üres profilválasz a sofőr lemondásának biztonságos
        // fallback bizonyítéka. Az utas saját folyamatban lévő lemondását
        // itt nem szabad sofőrlemondásként kezelni.
        if (serverReleasedBooking &&
            const <String>{'accepted', 'arrived'}.contains(localStatus) &&
            _consecutiveExactServerReleasePolls >= 2 &&
            !homeController.isPassengerCancellationInProgressFor(
              activeBookingId,
            )) {
          _bookingStatusPollingTimer?.cancel();
          PassengerFlowDebug.send(
            'booking_status_poll_driver_cancelled_by_pointer_release',
            bookingId: activeBookingId,
            data: <String, dynamic>{
              'missing_poll_count': _missingCurrentBookingPolls,
              'exact_release_poll_count': _consecutiveExactServerReleasePolls,
              'previous_local_status': localStatus,
            },
          );
          await homeController.handleDriverCancellation(
            bookingId: activeBookingId,
            source: 'profile_poll_exact_release',
            cancellationReason: _profileCancellationReasonForBooking(
              profile: profile,
              bookingId: activeBookingId,
            ),
          );
          return;
        }

        // A current_booking pointer completed fuvarnal megszunhet mar a
        // fizetes rendezese elott is (peldaul Stripe QR session inditasakor).
        // Ezert pointer-release alapjan SOHA nem gyartunk lokalisan paid
        // allapotot. A profile recent_bookings booking rekordja hordozza az
        // autoritativ payment_status/payment_method mezoket.
        if (serverReleasedBooking &&
            const <String>{'started', 'completed'}.contains(localStatus) &&
            _consecutiveExactServerReleasePolls >= 2) {
          RecentBooking? recentBooking;
          for (final item in profile.data?.recentBookings ?? <RecentBooking>[]) {
            if ((item.id ?? '').trim() == activeBookingId) {
              recentBooking = item;
              break;
            }
          }

          final recentStatus = (recentBooking?.status ?? '').trim().toLowerCase();
          final recentPaymentMethod =
              (recentBooking?.paymentMethod ?? '').trim().toLowerCase();
          final recentPaymentStatus =
              (recentBooking?.paymentStatus ?? '').trim().toLowerCase();

          if (recentBooking != null && recentStatus == 'completed') {
            final localData = riderBookingModel.value?.data;
            if (localData?.booking != null) {
              localData!.booking!.status = 'completed';
              if (recentPaymentMethod.isNotEmpty) {
                localData.booking!.paymentMethod = recentPaymentMethod;
              }
              if (recentPaymentStatus.isNotEmpty) {
                localData.booking!.paymentStatus = recentPaymentStatus;
              }
              final recentOnlinePaid =
                  (recentBooking.onlinePaidAmount ?? '').trim();
              if (recentOnlinePaid.isNotEmpty) {
                localData.booking!.onlinePaidAmount = recentOnlinePaid;
              }
            }
            if (localData != null) {
              localData.status = 'completed';
            }

            _lastAppliedBookingState =
                '$activeBookingId:completed:$recentPaymentStatus:$recentPaymentMethod:recent';
            PassengerFlowDebug.send(
              'booking_status_poll_completed_from_recent_booking',
              bookingId: activeBookingId,
              data: <String, dynamic>{
                'missing_poll_count': _missingCurrentBookingPolls,
                'exact_release_poll_count': _consecutiveExactServerReleasePolls,
                'previous_local_status': localStatus,
                'payment_method': recentPaymentMethod,
                'payment_status': recentPaymentStatus,
                'online_paid_amount': recentBooking.onlinePaidAmount ?? '',
              },
            );

            await homeController.socketData();
            if (recentPaymentStatus == 'paid') {
              _bookingStatusPollingTimer?.cancel();
            }
            return;
          }

          PassengerFlowDebug.send(
            'booking_status_poll_release_waiting_for_authoritative_payment',
            bookingId: activeBookingId,
            data: <String, dynamic>{
              'exact_release_poll_count': _consecutiveExactServerReleasePolls,
              'previous_local_status': localStatus,
              'recent_booking_present': recentBooking != null,
              'recent_status': recentStatus,
              'recent_payment_status': recentPaymentStatus,
            },
          );
          return;
        }

        // Egyetlen átmeneti vagy inkonzisztens profilválasz miatt aktív
        // fuvart nem zárunk le.
        return;
      }

      _missingCurrentBookingPolls = 0;
      _exactServerReleaseBookingId = '';
      _consecutiveExactServerReleasePolls = 0;
      final authoritativeBooking = currentBooking!;
      final polledModel = NewRideModel.fromJson({
        'data': jsonEncode(authoritativeBooking.toJson()),
      });
      final polledBookingId =
          '${polledModel.data?.booking?.id ?? polledModel.data?.bookingId ?? ''}'
              .trim();
      if (polledBookingId != activeBookingId) return;

      final status = (polledModel.data?.booking?.status ?? '')
          .toLowerCase()
          .trim();
      if (status.isEmpty) return;

      final paymentStatus = (polledModel.data?.booking?.paymentStatus ?? '')
          .toLowerCase()
          .trim();
      final paymentMethod = (polledModel.data?.booking?.paymentMethod ?? '')
          .toLowerCase()
          .trim();
      final stateKey = '$polledBookingId:$status:$paymentStatus:$paymentMethod';
      if (stateKey == _lastAppliedBookingState) return;
      PassengerFlowDebug.send(
        'booking_status_poll_changed',
        bookingId: polledBookingId,
        data: <String, dynamic>{
          'status': status,
          'previous_state': _lastAppliedBookingState,
        },
      );
      _lastAppliedBookingState = stateKey;

      riderBookingModel.value = polledModel;
      persistBookingFareFromModel(polledModel.data);
      homeController.socketData();
      await _showDriverMarkerIfAvailable();

      final bool awaitsPaymentSettlement =
          status == 'completed' && paymentStatus != 'paid';
      if ((status == 'completed' && !awaitsPaymentSettlement) ||
          status == 'cancelled' ||
          status == 'expired') {
        _bookingStatusPollingTimer?.cancel();
        PassengerFlowDebug.send(
          'booking_status_poll_terminal',
          bookingId: polledBookingId,
          data: <String, dynamic>{'status': status},
        );
      }
    } catch (error, stack) {
      // A háttérpolling nem zavarhatja felugró hibával az utast.
      _exactServerReleaseBookingId = '';
      _consecutiveExactServerReleasePolls = 0;
      PassengerFlowDebug.send(
        'booking_status_poll_error',
        bookingId: activeBookingId,
        data: <String, dynamic>{'error': '$error'},
      );
      LogUtils.printError(
        'PASSENGER BOOKING STATUS POLL ERROR: $error, $stack',
      );
    } finally {
      _bookingStatusPollInProgress = false;
    }
  }

  Future<List<LatLng>> _getRoutePoints(
    LatLng originLatLng,
    LatLng destinationLatLng,
  ) async {
    final String apiKey = homeController.placeApi?.trim() ?? '';
    if (apiKey.isEmpty) return <LatLng>[];
    try {
      final GoogleRouteResult route = await GoogleRouteService.bestDrivingRoute(
        apiKey: apiKey,
        origin: originLatLng,
        destination: destinationLatLng,
      );
      return route.points;
    } catch (error, stack) {
      PassengerFlowDebug.runtimeError('search_driver_route', error, stack);
      return <LatLng>[];
    }
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
          polylineId: const PolylineId('route_outline'),
          width: 9,
          zIndex: 1,
          color: AppColors.routeOutline,
          points: polylineCoordinates,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
          jointType: JointType.round,
        ),
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
    PassengerFlowDebug.send(
      'search_driver_screen_closed',
      bookingId: _activeBookingId(),
      data: <String, dynamic>{
        'last_state': _lastAppliedBookingState,
        'trip_type': homeController.tripType.value,
      },
    );
    _bookingStatusPollingTimer?.cancel();
    _driverMarkerAnimationTimer?.cancel();
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
                                          "Indulási hely: ${riderBookingModel.value?.data?.pickup?.address ?? ""}\nÉrkezési hely: ${riderBookingModel.value?.data?.dropoff?.address ?? ""}";
                                      title +=
                                          "\nAz utas utolsó ismert helye: https://www.google.com/maps/search/?api=1&query=${LocationService().currentUserLatLg.value?.latitude},${LocationService().currentUserLatLg.value?.longitude}";
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
                                        child: _buildSearchingVisual(),
                                      ),
                                    ),
                                  ],
                                ),

                                // Trip Details Button
                                CustomButton(
                                  text: AppString.tripDetails.tr,
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
                                                  homeController
                                                      .isDriverCome
                                                      .value
                                                  ? 'A sofőr megérkezett. A felvételhez add meg neki az alábbi kódot.'
                                                  : 'A sofőr a felvételi ponthoz tart. Kövesd a térképen!',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14.sp,
                                              color: AppColors.textCaptionColor,
                                              softWrap: true,
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
                                _buildArrivalInfoCard(),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CommonText(
                                        string:
                                            homeController.isDriverCome.value
                                            ? 'Utazási kód a sofőrnek'
                                            : 'A fuvar azonosító kódja',
                                        softWrap: true,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp,
                                      ),
                                    ),

                                    ...List.generate(6, (index) {
                                      final otp = _displayTripOtp();
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
                                          string: otp[index],
                                          fontWeight: FontWeight.w700,
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
                                                      _activeBookingId(),
                                                },
                                              );
                                            },
                                            child: ChatUnreadBadge(
                                              bookingId: _activeBookingId(),
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
