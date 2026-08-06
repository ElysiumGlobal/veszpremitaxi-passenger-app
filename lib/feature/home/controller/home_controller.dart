import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:e_taxi/core/debug/passenger_flow_debug.dart';
import 'package:e_taxi/core/location_utils.dart';
import 'package:e_taxi/feature/home/model/offer_model.dart';
import 'package:e_taxi/feature/home/page/payment_screen.dart';
import 'package:e_taxi/feature/home/service/home_service.dart';
import 'package:e_taxi/feature/trip/controller/trip_controller.dart';
import 'package:e_taxi/feature/wallet/controller/wallet_controller.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:e_taxi/utils/common_api_caller.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../core/socket_channel.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_preferences.dart';
import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/log_utils.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custome_img.dart';
import '../model/address_model.dart';
import '../model/banner_model.dart' as banner;
import '../model/create_booking_model.dart';
import '../model/get_socket_model.dart';
import '../model/origin_destination_model.dart';
import '../model/place_adress_model.dart';
import '../model/user_account_list_model.dart';
import '../widget/dialog.dart';
import '../model/ride_type_list_model.dart' as rideType;

Rxn<NewRideModel> riderBookingModel =
    Rxn<NewRideModel>(); // clear when new ride confirm create

String _firstNonEmptyAmount(Iterable<String?> values) {
  for (final value in values) {
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '0';
}

void saveBookingFare(String? bookingId, String? fare) {
  if (bookingId == null ||
      bookingId.isEmpty ||
      fare == null ||
      fare.trim().isEmpty) {
    return;
  }
  AppPreference.setString(
    AppPreference.bookingFare,
    jsonEncode({'bookingId': bookingId, 'fare': fare.trim()}),
  );
}

String? getSavedBookingFare(String? bookingId) {
  if (bookingId == null || bookingId.isEmpty) {
    return null;
  }
  final raw = AppPreference.getString(AppPreference.bookingFare);
  if (raw.isEmpty) {
    return null;
  }
  try {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    if ('${map['bookingId']}' == bookingId) {
      return map['fare']?.toString();
    }
  } catch (_) {}
  return null;
}

void clearSavedBookingFare() {
  AppPreference.removeKey(AppPreference.bookingFare);
}

String resolveRideAmount([SocketDataModel? data]) {
  data ??= riderBookingModel.value?.data;
  final bookingCreateFare = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
            .bookingCreateModel
            .value
            ?.data
            ?.fareBreakdown
            ?.total
      : null;

  return _firstNonEmptyAmount([
    data?.tripDetails?.fare,
    data?.fare?.totalAmount,
    data?.booking?.finalFare,
    data?.booking?.totalAmount,
    data?.booking?.estimatedFare,
    data?.invoice?.fareBreakdown?.totalAmount,
    getSavedBookingFare(data?.booking?.id),
    bookingCreateFare,
  ]);
}

String resolveTotalAmount([SocketDataModel? data]) {
  data ??= riderBookingModel.value?.data;
  final booking = data?.booking;
  final finalFare = booking?.finalFare?.trim() ?? '';
  if (finalFare.isNotEmpty) {
    return finalFare;
  }

  final rideAmount = resolveRideAmount(data);
  final discount = booking?.discountAmount?.trim() ?? '';
  if (discount.isEmpty || discount == '0' || discount == '0.0') {
    return rideAmount;
  }

  try {
    final total =
        double.parse(rideAmount.replaceAll(',', '')) -
        double.parse(discount.replaceAll(',', ''));
    return total.toString();
  } catch (_) {
    return rideAmount;
  }
}

void persistBookingFareFromModel(SocketDataModel? data) {
  saveBookingFare(data?.booking?.id, resolveRideAmount(data));
}

class HomeController extends GetxController with LoadingMixin, LoadingApiMixin {
  final RxBool awaitingRidePayment = false.obs;
  final RxString awaitingRidePaymentBookingId = ''.obs;
  final Set<String> _finalizedCompletedBookingIds = <String>{};
  String _paymentSelectionShownForBooking = '';
  String _passengerCancellationInProgressBookingId = '';
  String _driverCancellationHandlingBookingId = '';

  bool _isPaymentSettled(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    return const <String>{
      'paid',
      'completed',
      'complete',
      'success',
      'successful',
      'settled',
      '1',
      'true',
    }.contains(normalized);
  }

  String _currentPaymentStatus() {
    return (riderBookingModel.value?.data?.booking?.paymentStatus ?? '')
        .trim()
        .toLowerCase();
  }

  String? placeApi = Platform.isAndroid
      ? dotenv.env['GOOGLE_MAPS_API_KEY_Android']
      : dotenv.env['GOOGLE_MAPS_API_KEY_Ios'];
  Timer? debounce;
  Timer? _bannerLocationDebounce;
  LatLng? _lastBannerLatLng;
  final SocketChannelService _socketService = SocketChannelService();

  void _scheduleBannerForLocation(LatLng latLng) {
    if (latLng.latitude == 0 && latLng.longitude == 0) return;

    if (_lastBannerLatLng != null) {
      final distance = Geolocator.distanceBetween(
        _lastBannerLatLng!.latitude,
        _lastBannerLatLng!.longitude,
        latLng.latitude,
        latLng.longitude,
      );
      if (distance < 500) return;
    }

    _bannerLocationDebounce?.cancel();
    _bannerLocationDebounce = Timer(const Duration(milliseconds: 500), () {
      _lastBannerLatLng = latLng;
      getBanner(lat: latLng.latitude, lng: latLng.longitude);
    });
  }

  @override
  void onInit() {
    LogUtils.printAction("ON INIT CALLED");
    // TODO: implement onInit
    super.onInit();

    final currentLocation = LocationService().currentUserLatLg.value;
    if (currentLocation != null) {
      _scheduleBannerForLocation(currentLocation);
    }
    ever(LocationService().currentUserLatLg, (LatLng? latLng) {
      if (latLng != null) {
        _scheduleBannerForLocation(latLng);
      }
    });

    getAddress();
    getUserNameList();
    getRideTypeList();
    _initializeSocket();
    _listenToSocket();
    _listenToConnection();
  }

  // Observable connection state
  final RxBool isConnected = false.obs;

  @override
  void onClose() {
    _socketService.disconnect();
    _socketSubscription?.cancel();
    _bannerLocationDebounce?.cancel();
    super.onClose();
  }

  /// Initialize WebSocket connection
  void _initializeSocket() {
    _socketService.initSocket(
      url: "wss://ws-ap2.pusher.com/app/bd173a4219b16bb73593",
      subscriptionData: {"channel": "user.all"},
      reconnectInterval: const Duration(seconds: 5),
      maxReconnectAttempts: -1, // Infinite reconnection attempts
    );
  }

  StreamSubscription? _socketSubscription;

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
      PassengerFlowDebug.runtimeError('home_socket_decode', error, stack);
    }
    return null;
  }

  /// Listen to socket data stream
  void _listenToSocket() {
    _socketSubscription?.cancel();
    _socketSubscription = _socketService.onSocketDataListen.listen((event) {
      try {
        final Map<String, dynamic>? data = _decodeSocketMap(event);
        if (data == null) {
          PassengerFlowDebug.send(
            'socket_outer_payload_invalid',
            data: <String, dynamic>{
              'runtime_type': event.runtimeType.toString(),
            },
          );
          return;
        }

        final String eventName = '${data['event'] ?? ''}'.trim();
        final Map<String, dynamic>? eventData = _decodeSocketMap(data['data']);
        final dynamic bookingRaw = eventData?['booking'];
        final Map<String, dynamic>? booking = _decodeSocketMap(bookingRaw);
        final String explicitBookingId =
            '${booking?['id'] ?? eventData?['booking_id'] ?? ''}'.trim();
        final String bookingId = explicitBookingId.isNotEmpty
            ? explicitBookingId
            : AppConstant().bookingId.trim();
        final String incomingStatus =
            '${booking?['status'] ?? eventData?['status'] ?? ''}'
                .trim()
                .toLowerCase();

        PassengerFlowDebug.send(
          'socket_event_received',
          bookingId: bookingId,
          data: <String, dynamic>{
            'event_name': eventName,
            'outer_keys': data.keys.toList(),
            'payload_keys': eventData?.keys.toList() ?? const <String>[],
            'booking_status': booking?['status'] ?? eventData?['status'],
          },
        );

        if (eventName == 'connection_established') {
          final String socketId = '${eventData?['socket_id'] ?? ''}'.trim();
          if (socketId.isNotEmpty) {
            AppConstant().socketId = socketId;
          }
          return;
        }

        final String activeBookingId = AppConstant().bookingId.trim();
        if (incomingStatus == 'cancelled' &&
            explicitBookingId.isNotEmpty &&
            activeBookingId.isNotEmpty &&
            explicitBookingId == activeBookingId) {
          if (!isPassengerCancellationInProgressFor(explicitBookingId)) {
            unawaited(
              handleDriverCancellation(
                bookingId: explicitBookingId,
                source: 'socket_exact_booking_status',
              ),
            );
          }
          return;
        }

        if (eventName == 'new.ride.request') {
          final String socketUserId =
              '${booking?['user'] is Map ? (booking?['user'] as Map)['id'] : booking?['user_id'] ?? ''}'
                  .trim();
          final String currentUserId = AppPreference.getString(
            AppPreference.userId,
          ).trim();
          final String currentBookingId = AppConstant().bookingId.trim();

          final bool userMatches = socketUserId == currentUserId;
          final bool bookingMatches = bookingId == currentBookingId;
          PassengerFlowDebug.send(
            'socket_ride_match_evaluated',
            bookingId: bookingId,
            data: <String, dynamic>{
              'user_matches': userMatches,
              'booking_matches': bookingMatches,
              'has_booking': booking != null,
            },
          );

          if (userMatches && bookingMatches) {
            riderBookingModel.value = NewRideModel.fromJson(data);
            persistBookingFareFromModel(riderBookingModel.value?.data);
            socketData();
          }
          return;
        }

        if (eventName == 'issue.reported') {
          final String issueUserId = '${booking?['user_id'] ?? ''}'.trim();
          final String currentUserId = AppPreference.getString(
            AppPreference.userId,
          ).trim();
          if (issueUserId == currentUserId &&
              bookingId == AppConstant().bookingId.trim()) {
            final Map<String, dynamic>? issue = _decodeSocketMap(
              eventData?['issue_report'],
            );
            AppConstant().reportString.value =
                '${issue?['issue_type_label'] ?? ''}@@${issue?['custom_issue'] ?? ''}';
          }
        }
      } catch (error, stack) {
        PassengerFlowDebug.runtimeError('home_socket_listener', error, stack);
        log('PASSENGER SOCKET LISTENER ERROR: $error, $stack');
      }
    });
  }

  /// Listen to connection state
  void _listenToConnection() {
    _socketService.connectionStream.listen((connected) {
      log("CONNECTION :::::::${connected}");
      isConnected.value = connected;
      PassengerFlowDebug.send(
        'socket_connection_changed',
        bookingId: AppConstant().bookingId,
        data: <String, dynamic>{'connected': connected},
      );
    });
  }

  bool changePolyLine = false;

  Future<void> socketData({bool isFirstTime = false}) async {
    final booking = riderBookingModel.value?.data?.booking;
    final status = (booking?.status ?? '').toLowerCase().trim();
    final bookingId = '${booking?.id ?? AppConstant().bookingId}'.trim();
    final paymentMethod = (booking?.paymentMethod ?? '').trim().toLowerCase();
    final paymentStatus = (booking?.paymentStatus ?? '').trim().toLowerCase();
    final awaitsCashConfirmation =
        status == 'completed' &&
        paymentMethod == 'cash' &&
        !_isPaymentSettled(paymentStatus);
    const activeStatuses = <String>{
      'searching',
      'accepted',
      'arrived',
      'started',
    };
    const terminalStatuses = <String>{'completed', 'cancelled', 'expired'};

    log('PASSENGER STATUS: $status / $bookingId / ${Get.currentRoute}');
    PassengerFlowDebug.send(
      'booking_state_received',
      bookingId: bookingId,
      data: <String, dynamic>{
        'status': status,
        'is_first_time': isFirstTime,
        'route': Get.currentRoute,
        'trip_auth_present': (booking?.otp ?? '').trim().isNotEmpty,
        'trip_auth_length': (booking?.otp ?? '').trim().length,
        'driver_present': riderBookingModel.value?.data?.driver != null,
      },
    );

    if (isFirstTime &&
        (activeStatuses.contains(status) || awaitsCashConfirmation)) {
      final pickupLat =
          double.tryParse(
            riderBookingModel.value?.data?.pickup?.latitude ?? '',
          ) ??
          0;
      final pickupLng =
          double.tryParse(
            riderBookingModel.value?.data?.pickup?.longitude ?? '',
          ) ??
          0;
      final dropoffLat =
          double.tryParse(
            riderBookingModel.value?.data?.dropoff?.latitude ?? '',
          ) ??
          0;
      final dropoffLng =
          double.tryParse(
            riderBookingModel.value?.data?.dropoff?.longitude ?? '',
          ) ??
          0;

      if (pickupLat != 0 &&
          pickupLng != 0 &&
          dropoffLat != 0 &&
          dropoffLng != 0 &&
          Get.currentRoute != Routes.searchDriverScreen) {
        PassengerFlowDebug.send(
          'active_trip_screen_open_requested',
          bookingId: bookingId,
          data: <String, dynamic>{'status': status},
        );
        Navigation.pushNamed(
          Routes.searchDriverScreen,
          arg: <String, LatLng>{
            'origin': LatLng(pickupLat, pickupLng),
            'destination': LatLng(dropoffLat, dropoffLng),
          },
        );
      }
    }

    try {
      if (status == 'accepted') {
        isDriverCome.value = false;
        tripType.value = 1;
        changePolyLine = true;
        AppPreference.removeKey(AppPreference.RideTime);
      } else if (status == 'arrived') {
        changePolyLine = false;
        tripType.value = 1;
        isDriverCome.value = true;
        PassengerFlowDebug.send(
          'trip_auth_display_ready',
          bookingId: bookingId,
          data: <String, dynamic>{
            'trip_auth_present': (booking?.otp ?? '').trim().isNotEmpty,
            'trip_auth_length': (booking?.otp ?? '').trim().length,
          },
        );
        final waitingLimit =
            int.tryParse(booking?.rideType?.waitingTimeLimit ?? '0') ?? 0;
        getRideTimer(waitingLimit);
      } else if (status == 'started') {
        tripType.value = 2;
        AppPreference.removeKey(AppPreference.RideTime);
      } else if (terminalStatuses.contains(status)) {
        PassengerFlowDebug.send(
          'terminal_booking_payment_evaluated',
          bookingId: bookingId,
          data: <String, dynamic>{
            'status': status,
            'payment_method': paymentMethod,
            'payment_status': paymentStatus,
            'payment_settled': _isPaymentSettled(paymentStatus),
            'is_first_time': isFirstTime,
          },
        );

        if (status == 'completed') {
          if (awaitsCashConfirmation) {
            awaitingRidePayment.value = true;
            awaitingRidePaymentBookingId.value = bookingId;
            PassengerFlowDebug.send(
              'completed_cash_waiting_for_driver_confirmation',
              bookingId: bookingId,
              data: <String, dynamic>{
                'payment_method': paymentMethod,
                'payment_status': paymentStatus,
              },
            );
            return;
          }

          AppConstant().reportString.value = '';
          if (Get.isRegistered<TripController>()) {
            unawaited(Get.find<TripController>().getTripHistory());
          }

          await _finalizeCompletedRide(
            bookingId: bookingId,
            paymentMethod: paymentMethod,
            paymentStatus: paymentStatus,
          );
          return;
        }

        _clearCurrentBookingState(
          bookingId: bookingId,
          reason: 'terminal_status_received',
          status: status,
        );

        if (isFirstTime) {
          PassengerFlowDebug.send(
            'terminal_booking_ignored_on_restore',
            bookingId: bookingId,
            data: <String, dynamic>{'status': status},
          );
          if (Get.currentRoute != Routes.dashboardScreen) {
            Navigation.popupUtil(Routes.dashboardScreen);
          }
          return;
        }

        if (status == 'cancelled') {
          AppDialog.commonDialog(
            barrierDismissible: false,
            childs: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomImage(image: ImagesAsset.rideCancel),
                16.verticalSpace,
                CommonText(
                  string: AppString.weAreSadToCancel.tr,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
                12.verticalSpace,
                CommonText(
                  string: AppString.makeYourNextRideHappiest.tr,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textCaptionColor,
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
                16.verticalSpace,
                CustomButton(
                  text: AppString.backToHome.tr,
                  onTap: () {
                    Get.back();
                    Navigation.popupUtil(Routes.dashboardScreen);
                  },
                ),
              ],
            ),
          );
        } else if (status == 'expired') {
          AppDialog.commonBottomSheetWidget(
            isDismiss: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: CommonText(
                    string: AppString.noRideAvailable.tr,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.titleTextColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(height: 1.h, color: AppColors.textFieldBorderColor),
                24.verticalSpace,
                Center(
                  child: CustomImage(
                    image: ImagesAsset.noRide,
                    ht: 160.h,
                    wt: 180.w,
                  ),
                ),
                20.verticalSpace,
                Center(
                  child: CommonText(
                    string: AppString.noRideAvailableRightNow.tr,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.titleTextColor,
                    textAlign: TextAlign.center,
                  ),
                ),
                6.verticalSpace,
                CommonText(
                  string: AppString.pleaseTryAgainAfter.tr,
                  softWrap: true,
                  fontSize: 14.sp,
                  color: AppColors.textCaptionColor,
                  textAlign: TextAlign.center,
                ).paddingSymmetric(horizontal: 42.w),
                32.verticalSpace,
                CustomButton(
                  text: AppString.tryAgain.tr,
                  buttonColor: AppColors.mainPrimaryColor,
                  height: 48.h,
                  width: double.infinity,
                  onTap: () {
                    Get.back();
                    Navigation.popupUtil(Routes.dashboardScreen);
                  },
                ),
                12.verticalSpace,
              ],
            ),
          );
        }
      }
    } catch (error, stack) {
      log('PASSENGER STATUS ERROR: $error, $stack');
      PassengerFlowDebug.send(
        'booking_state_apply_error',
        bookingId: bookingId,
        data: <String, dynamic>{'status': status, 'error': '$error'},
      );
    }
  }

  Future<void> _openCompletedRidePaymentSelection({
    required String bookingId,
    required String paymentMethod,
    required String finalAmount,
  }) async {
    if (bookingId.isEmpty || bookingId == 'null') {
      PassengerFlowDebug.send(
        'completed_payment_screen_blocked',
        data: <String, dynamic>{'reason': 'missing_booking_id'},
      );
      return;
    }
    if (_paymentSelectionShownForBooking == bookingId) return;
    if (Get.currentRoute == Routes.paymentSelectScreen) return;

    _paymentSelectionShownForBooking = bookingId;
    PassengerFlowDebug.send(
      'completed_payment_screen_open_requested',
      bookingId: bookingId,
      data: <String, dynamic>{
        'payment_method': paymentMethod,
        'final_amount': finalAmount,
      },
    );
    await Navigation.pushNamed(
      Routes.paymentSelectScreen,
      arg: <String, dynamic>{
        'method': paymentMethod,
        'finalAmount': finalAmount,
        'bookingId': bookingId,
        'completedRide': true,
      },
    );
  }

  Future<bool> selectCashForCompletedRide({required String bookingId}) async {
    final activeBookingId =
        '${riderBookingModel.value?.data?.booking?.id ?? AppConstant().bookingId}'
            .trim();
    if (bookingId.isEmpty ||
        bookingId == 'null' ||
        activeBookingId.isEmpty ||
        activeBookingId != bookingId) {
      PassengerFlowDebug.send(
        'completed_cash_selection_blocked',
        bookingId: bookingId,
        data: <String, dynamic>{
          'reason': 'booking_mismatch',
          'active_booking_id': activeBookingId,
        },
      );
      AppSnackBar.showErrorSnackBar(
        message: 'A fuvar azonosítása sikertelen. Frissítsd az oldalt.',
        isError: true,
      );
      return false;
    }

    PassengerFlowDebug.send(
      'completed_cash_selection_requested',
      bookingId: bookingId,
    );
    final result = await updatePaymentMode(
      paymentMode: 'cash',
      bookingId: bookingId,
    );
    if (result.isEmpty) {
      PassengerFlowDebug.send(
        'completed_cash_selection_failed',
        bookingId: bookingId,
      );
      return false;
    }

    riderBookingModel.value?.data?.booking?.paymentMethod = 'cash';
    awaitingRidePayment.value = true;
    awaitingRidePaymentBookingId.value = bookingId;
    PassengerFlowDebug.send(
      'completed_cash_selection_saved',
      bookingId: bookingId,
      data: <String, dynamic>{'awaiting_driver_confirmation': true},
    );
    AppSnackBar.showErrorSnackBar(
      message:
          'Készpénzes fizetés kiválasztva. Várjuk a sofőr visszaigazolását.',
    );
    return true;
  }

  Future<void> _finalizeCompletedRide({
    required String bookingId,
    required String paymentMethod,
    required String paymentStatus,
  }) async {
    if (bookingId.isEmpty || bookingId == 'null') return;
    if (_finalizedCompletedBookingIds.contains(bookingId)) return;
    _finalizedCompletedBookingIds.add(bookingId);

    awaitingRidePayment.value = false;
    awaitingRidePaymentBookingId.value = '';
    _paymentSelectionShownForBooking = '';
    AppConstant().bookingId = '';
    clearSavedBookingFare();
    tripType.value = 0;
    isDriverCome.value = false;
    changePolyLine = false;
    AppPreference.removeKey(AppPreference.RideTime);

    PassengerFlowDebug.send(
      'completed_ride_finalized',
      bookingId: bookingId,
      data: <String, dynamic>{
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'route': Get.currentRoute,
      },
    );

    if (Get.currentRoute == Routes.paymentSelectScreen) {
      Get.back();
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }

    AppDialog.commonDialog(
      barrierDismissible: false,
      childs: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomImage(image: ImagesAsset.tripComplete, wt: 200.w, ht: 110.h),
          16.verticalSpace,
          CommonText(
            string: 'Köszönjük, hogy a Veszprémi Taxit választottad!',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          12.verticalSpace,
          CommonText(
            string: 'A fuvar sikeresen lezárult.',
            softWrap: true,
            color: AppColors.textCaptionColor,
            textAlign: TextAlign.center,
          ),
          16.verticalSpace,
          CustomButton(
            text: AppString.done.tr,
            onTap: () {
              Get.back();
              Navigation.popupUtil(Routes.rateDriverScreen);
            },
          ),
        ],
      ),
    );
  }

  void finishCompletedRideUi({String reason = 'rating_flow_finished'}) {
    final bookingId = '${riderBookingModel.value?.data?.booking?.id ?? ''}'
        .trim();
    riderBookingModel.value = null;
    awaitingRidePayment.value = false;
    awaitingRidePaymentBookingId.value = '';
    _paymentSelectionShownForBooking = '';
    PassengerFlowDebug.send(
      'completed_ride_ui_released',
      bookingId: bookingId,
      data: <String, dynamic>{'reason': reason},
    );
  }

  void _clearCurrentBookingState({
    required String bookingId,
    required String reason,
    required String status,
  }) {
    AppConstant().bookingId = '';
    clearSavedBookingFare();
    riderBookingModel.value = null;
    tripType.value = 0;
    isDriverCome.value = false;
    changePolyLine = false;
    awaitingRidePayment.value = false;
    awaitingRidePaymentBookingId.value = '';
    _paymentSelectionShownForBooking = '';
    AppPreference.removeKey(AppPreference.RideTime);

    PassengerFlowDebug.send(
      'local_booking_state_cleared',
      bookingId: bookingId,
      data: <String, dynamic>{'reason': reason, 'status': status},
    );
  }

  void closeDebounce() {
    if (debounce?.isActive ?? false) debounce?.cancel();
  }

  void userSearchPlace(String value) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 300), () {
      searchPlace(value);
    });
  }

  RxList<Prediction> searchList = <Prediction>[].obs;
  RxList<Prediction> recentSearchList = <Prediction>[].obs;

  RxBool searchLoading = false.obs;

  OriginDestinationModel selectedLocationModel = OriginDestinationModel();

  Future<void> searchPlace(String value, {bool forDestination = false}) async {
    if (value.trim().isEmpty) {
      searchList.clear();
      return;
    }

    final apiKey = placeApi?.trim() ?? '';
    if (apiKey.isEmpty) {
      LogUtils.printError('Google Maps API key is missing');
      searchList.clear();
      return;
    }

    try {
      searchLoading(true);

      final countryCode = LocationService().country.trim().isEmpty
          ? 'HU'
          : LocationService().country.trim().toUpperCase();

      final body = <String, dynamic>{
        'input': value.trim(),
        'languageCode': 'hu',
        'regionCode': 'HU',
        'includedRegionCodes': [countryCode.toLowerCase()],
      };

      final currentLocation = LocationService().currentUserLatLg.value;
      if (currentLocation != null) {
        body['locationBias'] = {
          'circle': {
            'center': {
              'latitude': currentLocation.latitude,
              'longitude': currentLocation.longitude,
            },
            'radius': 25000.0,
          },
        };
      }

      if (forDestination) {
        log(
          '[DESTINATION_API] Typing destination → Places API (New) Autocomplete',
        );
      }

      final Stopwatch placesStopwatch = Stopwatch()..start();
      PassengerFlowDebug.send(
        'places_autocomplete_request',
        bookingId: AppConstant().bookingId,
        data: <String, dynamic>{
          'input_length': value.trim().length,
          'for_destination': forDestination,
          'has_location_bias': currentLocation != null,
        },
      );
      final response = await http.post(
        Uri.parse('https://places.googleapis.com/v1/places:autocomplete'),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask':
              'suggestions.placePrediction.placeId,'
              'suggestions.placePrediction.text.text,'
              'suggestions.placePrediction.structuredFormat.mainText.text,'
              'suggestions.placePrediction.structuredFormat.secondaryText.text,'
              'suggestions.placePrediction.types',
        },
        body: jsonEncode(body),
      );

      placesStopwatch.stop();
      PassengerFlowDebug.send(
        'places_autocomplete_response',
        bookingId: AppConstant().bookingId,
        data: <String, dynamic>{
          'status_code': response.statusCode,
          'duration_ms': placesStopwatch.elapsedMilliseconds,
          'for_destination': forDestination,
        },
      );

      if (forDestination) {
        log(
          '[DESTINATION_API] Autocomplete response status: '
          '${response.statusCode}',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Places autocomplete failed (${response.statusCode}): '
          '${response.body}',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final suggestions = decoded['suggestions'] as List<dynamic>? ?? const [];

      searchList.value = suggestions
          .map((item) {
            final suggestion = item as Map<String, dynamic>;
            final prediction =
                suggestion['placePrediction'] as Map<String, dynamic>?;
            if (prediction == null) return null;

            final text = prediction['text'] as Map<String, dynamic>?;
            final structured =
                prediction['structuredFormat'] as Map<String, dynamic>?;
            final mainText = structured?['mainText'] as Map<String, dynamic>?;
            final secondaryText =
                structured?['secondaryText'] as Map<String, dynamic>?;

            return Prediction(
              description: text?['text']?.toString() ?? '',
              placeId: prediction['placeId']?.toString(),
              structuredFormatting: StructuredFormatting(
                mainText: mainText?['text']?.toString() ?? '',
                secondaryText: secondaryText?['text']?.toString() ?? '',
              ),
              types: (prediction['types'] as List<dynamic>?)
                  ?.map((type) => type.toString())
                  .toList(),
            );
          })
          .whereType<Prediction>()
          .toList();

      PassengerFlowDebug.send(
        'places_autocomplete_parsed',
        bookingId: AppConstant().bookingId,
        data: <String, dynamic>{
          'suggestion_count': searchList.length,
          'for_destination': forDestination,
        },
      );
      if (forDestination) {
        log('[DESTINATION_API] Autocomplete suggestions: ${searchList.length}');
      }
    } catch (e, st) {
      searchList.clear();
      PassengerFlowDebug.runtimeError('places_autocomplete', e, st);
      PassengerFlowDebug.send(
        'places_autocomplete_error',
        bookingId: AppConstant().bookingId,
        data: <String, dynamic>{
          'for_destination': forDestination,
          'error_type': e.runtimeType.toString(),
          'error': e.toString(),
        },
      );
      LogUtils.printError('Places autocomplete error: $e, $st');
      if (forDestination) {
        log('[DESTINATION_API] Autocomplete error: $e');
      }
    } finally {
      searchLoading(false);
    }
  }

  String inPlace = "";
  Map originAddress = {};
  Map destinationAddress = {};

  RxBool getLatLngLoading = false.obs;

  Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
    getLatLngLoading(true);
    try {
      final apiKey = placeApi?.trim() ?? '';
      if (apiKey.isEmpty) {
        throw Exception('Google Maps API key is missing');
      }

      final Stopwatch detailsStopwatch = Stopwatch()..start();
      PassengerFlowDebug.send(
        'place_details_request',
        bookingId: AppConstant().bookingId,
        data: <String, dynamic>{
          'place_id_present': placeId.trim().isNotEmpty,
          'place_id_length': placeId.trim().length,
        },
      );
      final response = await http.get(
        Uri.parse(
          'https://places.googleapis.com/v1/places/'
          '${Uri.encodeComponent(placeId)}?languageCode=hu&regionCode=HU',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': 'id,displayName,formattedAddress,location',
        },
      );

      detailsStopwatch.stop();
      PassengerFlowDebug.send(
        'place_details_response',
        bookingId: AppConstant().bookingId,
        data: <String, dynamic>{
          'status_code': response.statusCode,
          'duration_ms': detailsStopwatch.elapsedMilliseconds,
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Place details failed (${response.statusCode}): ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final location = data['location'] as Map<String, dynamic>?;
      if (location == null ||
          location['latitude'] == null ||
          location['longitude'] == null) {
        throw Exception('Place details response does not contain coordinates');
      }

      final displayName = data['displayName'] as Map<String, dynamic>?;
      return {
        'formatted_address': data['formattedAddress']?.toString() ?? '',
        'name': displayName?['text']?.toString() ?? '',
        'geometry': {
          'location': {
            'lat': (location['latitude'] as num).toDouble(),
            'lng': (location['longitude'] as num).toDouble(),
          },
        },
      };
    } catch (e, st) {
      PassengerFlowDebug.runtimeError('place_details', e, st);
      PassengerFlowDebug.send(
        'place_details_error',
        bookingId: AppConstant().bookingId,
        data: <String, dynamic>{
          'error_type': e.runtimeType.toString(),
          'error': e.toString(),
        },
      );
      LogUtils.printError('Get place details error: $e, $st');
      rethrow;
    } finally {
      getLatLngLoading(false);
    }
  }

  Future<void> searchOrigin(String placeId, String name, String add) async {
    try {
      originAddress = {};
      getLatLngLoading(true);

      originAddress = (await _getPlaceDetails(placeId)) ?? {};

      setSelectedLocation(
        isOrigin: true,
        address: add.isNotEmpty ? add : originAddress['formatted_address'],
        latLng: LatLng(
          originAddress['geometry']['location']['lat'],
          originAddress['geometry']['location']['lng'],
        ),
        name: name,
      );

      if (originAddress.isNotEmpty) {
        Navigation.pushNamed(Routes.searchSecoundScreen);
      }
    } catch (e) {
      LogUtils.printAction("search origin :::$e");
    }
  }

  Future<void> searchDestination(
    String placeId,
    int id,
    String name,
    String address,
  ) async {
    if (getLatLngLoading.value == true) {
      return;
    }
    try {
      destinationAddress = {};
      getLatLngLoading(true);

      log('[DESTINATION_API] Destination selected → $name ($address)');
      log('[DESTINATION_API] placeId: $placeId');
      log(
        '[DESTINATION_API] Places API (New) Place Details → '
        'https://places.googleapis.com/v1/places/$placeId',
      );

      destinationAddress = (await _getPlaceDetails(placeId)) ?? {};

      setSelectedLocation(
        isOrigin: false,
        address: address.isNotEmpty
            ? address
            : destinationAddress['formatted_address'],
        latLng: LatLng(
          destinationAddress['geometry']['location']['lat'],
          destinationAddress['geometry']['location']['lng'],
        ),
        name: name,
      );

      LogUtils.printAction("TAP ADSADSD>$destinationAddress>");
      if (destinationAddress.isNotEmpty) {
        log('[DESTINATION_API] Place Details success');
        log(
          '[DESTINATION_API] destination lat/lng: '
          '${destinationAddress['geometry']?['location']?['lat']}, '
          '${destinationAddress['geometry']?['location']?['lng']}',
        );
        log(
          '[DESTINATION_API] No backend API on destination screen — '
          'navigating to BookVehicleScreen',
        );
        log(
          '[DESTINATION_API] Next backend API: POST ${ApiConstants.baseUrl}${ApiConstants.bookingEstimate}',
        );
        LogUtils.printAction(
          "origin:${selectedLocationModel.oAddress}, ${selectedLocationModel.dAddress}, ${selectedLocationModel.oLatLng}, ${selectedLocationModel.dLatLng}",
        );

        Navigation.pushNamed(
          Routes.bookVehicleScreen,
          arg: OriginDestinationModel(
            oAddress: selectedLocationModel.oAddress,
            oLatLng: selectedLocationModel.oLatLng,
            dAddress: selectedLocationModel.dAddress,
            dLatLng: selectedLocationModel.dLatLng,
            userNameId: id,
            dName: selectedLocationModel.dName,
            oName: selectedLocationModel.oName,
          ),
        );
      }
    } catch (e) {
      LogUtils.printAction("search des errro :$e");
    } finally {
      getLatLngLoading(false);
    }
  }

  void setSelectedLocation({
    bool isOrigin = true,
    required String name,
    required String address,
    required LatLng latLng,
  }) {
    if (isOrigin) {
      selectedLocationModel = selectedLocationModel.copyWith(
        oName: name,
        oAddress: address,
        oLatLng: latLng,
      );
    } else {
      selectedLocationModel = selectedLocationModel.copyWith(
        dName: name,
        dAddress: address,
        dLatLng: latLng,
      );
    }
  }

  // get user Addresss

  RxList<AddressModel> userAddressList = <AddressModel>[].obs;

  Future<bool> addAddress(String placeId, String name) async {
    bool succes = false;

    await processApi(
      () async {
        Map res = (await _getPlaceDetails(placeId)) ?? {};

        if (res.isNotEmpty) {
          return await HomeService.addAddress(
            name: name,
            address: res['formatted_address'],
            latLng: LatLng(
              res['geometry']['location']['lat'],
              res['geometry']['location']['lng'],
            ),
          );
        } else {
          throw "Try Again";
        }
      },
      result: (data) {
        succes = true;

        LogUtils.printAction("SUCCESS");
        LogUtils.printAction("LENGTH::${userAddressList.length}");

        try {
          userAddressList.add(
            AddressModel(
              id: data['data']['id'],
              name: data['data']['name'],
              address: data['data']['address'],
              latitude: data['data']['latitude'],
              longitude: data['data']['longitude'],
              type: data['data']['type'],
              isDefault: data['data']['is_default'],
            ),
          );
          LogUtils.printAction("LENGTH:1212:${userAddressList.length}");
          userAddressList.refresh();
        } catch (e, st) {
          LogUtils.printAction("ERROR:::$e\n$st");
        }
      },
      loading: handleLoading,
      error: (error, stack) {
        succes = false;
      },
    );

    getLatLngLoading(false);
    return succes;
  }

  Future<bool> addAddressFromPickUpScreen({
    required String name,
    required String address,
    required LatLng latLng,
  }) async {
    bool succes = false;

    LogUtils.printAction(":::$name::$address::$latLng");

    await processApi(
      () async {
        return await HomeService.addAddress(
          name: name,
          address: address,
          latLng: latLng,
        );
      },
      result: (data) {
        succes = true;

        LogUtils.printAction("SUCCESS");
        try {
          userAddressList.add(
            AddressModel(
              id: data['data']['id'],
              name: data['data']['name'],
              address: data['data']['address'],
              latitude: data['data']['latitude'],
              longitude: data['data']['longitude'],
              type: data['data']['type'],
              isDefault: data['data']['is_default'],
            ),
          );
          LogUtils.printAction("LENGTH:1212:${userAddressList.length}");
          userAddressList.refresh();
        } catch (e, st) {
          LogUtils.printAction("ERROR:::$e\n$st");
        }
      },
      loading: handleLoading,
      error: (error, stack) {
        handleLoading(false);
        succes = false;
      },
    );

    getLatLngLoading(false);
    return succes;
  }

  Future<void> getAddress() async {
    processApi(
      () => HomeService.getAddress(),
      result: (data) {
        userAddressList.value = data.data ?? [];
      },
    );
  }

  RxBool bookRideLoading = false.obs;
  Rxn<BookingCreateModel> bookingCreateModel = Rxn<BookingCreateModel>();

  RxBool finalizingBooking = false.obs;

  Future<String> estimateBooking({
    required LatLng originLatLng,
    required LatLng destinationLatLng,
  }) async {
    String errorMessage = "";
    PassengerFlowDebug.send(
      'booking_estimate_requested',
      data: <String, dynamic>{
        'pickup_latitude': PassengerFlowDebug.coordinate(originLatLng.latitude),
        'pickup_longitude': PassengerFlowDebug.coordinate(
          originLatLng.longitude,
        ),
        'dropoff_latitude': PassengerFlowDebug.coordinate(
          destinationLatLng.latitude,
        ),
        'dropoff_longitude': PassengerFlowDebug.coordinate(
          destinationLatLng.longitude,
        ),
      },
    );
    bookingCreateModel.value = null;
    AppConstant().bookingId = "";
    isDriverCome.value = false;
    bookRideLoading(true);

    await processApi(
      () => HomeService.bookingEstimate(
        originLatLng: originLatLng,
        destinationLatLng: destinationLatLng,
      ),
      result: (data) {
        bookingCreateModel.value = data;
        riderBookingModel.value = null;
        isDriverCome.value = false;
        tripType.value = 0;

        PassengerFlowDebug.send(
          'booking_estimate_success',
          data: <String, dynamic>{
            'ride_option_count': (data.data?.rideOptions ?? []).length,
            'estimated_distance':
                data.data?.booking?.distance ??
                data.data?.rideTypeEstimate?.distance ??
                '',
            'estimated_duration':
                data.data?.booking?.duration ??
                data.data?.rideTypeEstimate?.duration ??
                '',
          },
        );
        if ((data.data?.rideOptions ?? []).isEmpty) {
          errorMessage = "Ehhez a felvételi ponthoz nincs elérhető járműtípus.";
        }
      },
      error: (error, stack) {
        handleLoading(false);
        errorMessage = error.toString();
        PassengerFlowDebug.send(
          'booking_estimate_error',
          data: <String, dynamic>{'error': '$error'},
        );
        LogUtils.printError("BOOKING ESTIMATE FAILED ==> $error, $stack");
      },
    );

    bookRideLoading(false);
    return errorMessage;
  }

  Future<bool> finalizePassengerBooking({
    required String origin,
    required String destination,
    required LatLng originLatLng,
    required LatLng destinationLatLng,
    required int bookingContactId,
    required String rideTypeId,
    required String paymentMethod,
  }) async {
    if (finalizingBooking.value) {
      return false;
    }

    finalizingBooking(true);
    PassengerFlowDebug.send(
      'finalize_booking_requested',
      data: <String, dynamic>{
        'ride_type_id': rideTypeId,
        'payment_method': paymentMethod,
        'booking_contact_id': bookingContactId,
      },
    );
    try {
      final bookingResponse = await HomeService.bookingCreate(
        originAddress: origin,
        destinationAddress: destination,
        originLatLng: originLatLng,
        destinationLatLng: destinationLatLng,
        bookingContactId: bookingContactId,
        rideTypeId: rideTypeId,
        paymentMethod: paymentMethod,
      );

      final bookingId = bookingResponse.data?.booking?.id ?? "";
      if (bookingId.isEmpty) {
        throw Exception("A szerver nem adott vissza booking azonosítót.");
      }

      bookingCreateModel.value = bookingResponse;
      AppConstant().bookingId = bookingId;
      PassengerFlowDebug.send(
        'booking_create_success',
        bookingId: bookingId,
        data: <String, dynamic>{
          'status': bookingResponse.data?.booking?.status ?? '',
          'ride_type_id': rideTypeId,
        },
      );
      saveBookingFare(
        bookingId,
        bookingResponse.data?.booking?.estimatedFare ??
            bookingResponse.data?.rideTypeEstimate?.fareBreakdown?.total,
      );

      final confirmation = await HomeService.confirmRide(bookingId);
      final status = confirmation['data']?['status']?.toString() ?? "";
      PassengerFlowDebug.send(
        'booking_confirm_response',
        bookingId: bookingId,
        data: <String, dynamic>{'status': status},
      );
      if (status.isNotEmpty) {
        bookingCreateModel.value?.data?.booking?.status = status;
        bookingCreateModel.refresh();
      }

      if (status != "searching") {
        throw Exception(
          "A rendelés nem searching állapotban jött létre (állapot: $status).",
        );
      }

      PassengerFlowDebug.send(
        'search_driver_screen_open_requested',
        bookingId: bookingId,
        data: <String, dynamic>{'status': status},
      );
      Navigation.pushNamed(
        Routes.searchDriverScreen,
        arg: {"origin": originLatLng, "destination": destinationLatLng},
      );
      return true;
    } catch (error, stack) {
      PassengerFlowDebug.send(
        'finalize_booking_error',
        bookingId: AppConstant().bookingId,
        data: <String, dynamic>{'error': '$error'},
      );
      LogUtils.printError("FINALIZE BOOKING FAILED ==> $error, $stack");
      AppSnackBar.showErrorSnackBar(
        message: error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
      return false;
    } finally {
      finalizingBooking(false);
    }
  }

  Future<bool> bookVehicle({
    required String bookingId,
    required String vehicleId,
    required LatLng latLng,
    required String paymentType,
  }) async {
    bool res = false;
    await processApi(
      () => HomeService.vehicleBook(
        bookingId: bookingId,
        vehicleId: vehicleId,
        paymentType: paymentType,
      ),
      result: (data) {
        res = true;
        log("SUCCESS _vehicle Book -- $data");
        LogUtils.printSuccess("DATA::::$data");

        AppConstant().bookingId = bookingId;
        bookingCreateModel.value?.data?.booking?.rideTypeId =
            data['data']['booking']['ride_type_id'];

        bookingCreateModel.value?.data?.fareBreakdown = FareBreakdown.fromJson(
          data['data']['fare_breakdown'],
        );

        saveBookingFare(
          bookingId,
          bookingCreateModel.value?.data?.fareBreakdown?.total,
        );

        bookingCreateModel.refresh();
        Navigation.pushNamed(
          Routes.pickupScreen,
          arg: {"pickUpLatLng": latLng},
        );
      },
      loading: handleLoading,
      error: (error, stack) {
        handleLoading(false);
      },
    );
    return res;
  }

  Future<void> updatePickUpLocation({
    required String bookingId,
    required String address,
    required LatLng latLng,
  }) async {
    processApi(
      () async {
        final response = await HomeService.updatePickUpLocation(
          bookingId: bookingId,
          address: address,
          latLng: latLng,
        );

        BookingModel booking = BookingModel.fromJson(
          response['data']['booking'],
        );
        bookingCreateModel.value?.data?.booking = booking;
        bookingCreateModel.value?.data?.fareBreakdown = FareBreakdown.fromJson(
          response['data']['fare_breakdown'],
        );
        return await HomeService.confirmRide(bookingId);
      },
      result: (data) {
        AppConstant().bookingId = bookingId;

        try {
          Navigation.pushNamed(
            Routes.searchDriverScreen,
            arg: {
              "origin": latLng,
              "destination": LatLng(
                double.parse(
                  bookingCreateModel.value?.data?.booking?.dropoffLatitude ??
                      "0",
                ),
                double.parse(
                  bookingCreateModel.value?.data?.booking?.dropoffLongitude ??
                      "0",
                ),
              ),
            },
          );
        } catch (e, st) {
          LogUtils.printAction("ERROR:::$e \n $st");
        }
      },
      loading: handleLoading,
      error: (error, stack) {
        handleLoading(false);
      },
    );
  }

  Future<void> confirmRide({
    required String bookingId,
    required LatLng latLng,
  }) async {
    processApi(
      () => HomeService.confirmRide(bookingId),
      result: (data) {
        AppConstant().bookingId = bookingId;

        LogUtils.printSuccess("DATA::::$data");

        if (data['data']['status'] != "expired") {
          LogUtils.printSuccess("Booking confirm");
          Navigation.pushNamed(
            Routes.searchDriverScreen,
            arg: {
              "origin": latLng,
              "destination": LatLng(
                double.parse(
                  bookingCreateModel.value?.data?.booking?.dropoffLatitude ??
                      "0",
                ),
                double.parse(
                  bookingCreateModel.value?.data?.booking?.dropoffLongitude ??
                      "0",
                ),
              ),
            },
          );
        }
      },
      loading: handleLoading,
    );
  }

  bool dialogOpen = false;

  void _clearCancelledRideLocalState(String bookingId) {
    timer?.cancel();
    AppConstant().bookingId = '';
    clearSavedBookingFare();
    riderBookingModel.value = null;
    bookingCreateModel.value = null;
    tripType.value = 0;
    isDriverCome.value = false;
    changePolyLine = false;
    awaitingRidePayment.value = false;
    awaitingRidePaymentBookingId.value = '';
    _paymentSelectionShownForBooking = '';
    dialogOpen = false;
    AppPreference.removeKey(AppPreference.RideTime);
    PassengerFlowDebug.send(
      'passenger_cancel_local_state_cleared',
      bookingId: bookingId,
    );
  }

  bool isPassengerCancellationInProgressFor(String bookingId) {
    final normalizedBookingId = bookingId.trim();
    return normalizedBookingId.isNotEmpty &&
        _passengerCancellationInProgressBookingId == normalizedBookingId;
  }

  Future<void> handleDriverCancellation({
    required String bookingId,
    required String source,
  }) async {
    final normalizedBookingId = bookingId.trim();
    final activeBookingId = AppConstant().bookingId.trim();

    if (normalizedBookingId.isEmpty ||
        activeBookingId.isEmpty ||
        normalizedBookingId != activeBookingId ||
        isPassengerCancellationInProgressFor(normalizedBookingId) ||
        _driverCancellationHandlingBookingId == normalizedBookingId) {
      PassengerFlowDebug.send(
        'driver_cancel_ignored',
        bookingId: normalizedBookingId,
        data: <String, dynamic>{
          'source': source,
          'active_booking_id': activeBookingId,
          'passenger_cancel_in_progress':
              isPassengerCancellationInProgressFor(normalizedBookingId),
        },
      );
      return;
    }

    _driverCancellationHandlingBookingId = normalizedBookingId;
    try {
      PassengerFlowDebug.send(
        'driver_cancel_confirmed',
        bookingId: normalizedBookingId,
        data: <String, dynamic>{'source': source},
      );

      _clearCancelledRideLocalState(normalizedBookingId);
      Navigation.replaceAll(Routes.dashboardScreen);
      await Future<void>.delayed(const Duration(milliseconds: 250));
      AppSnackBar.showErrorSnackBar(
        message: 'A sofőr lemondta a fuvart.',
        isError: true,
      );
    } finally {
      if (_driverCancellationHandlingBookingId == normalizedBookingId) {
        _driverCancellationHandlingBookingId = '';
      }
    }
  }

  Future<void> cancelRide({
    required String bookingId,
    required String reason,
  }) async {
    final normalizedBookingId = bookingId.trim();
    _passengerCancellationInProgressBookingId = normalizedBookingId;
    try {
      await processApi(
        () => HomeService.cancelRide(normalizedBookingId, reason),
        result: (data) {
          _clearCancelledRideLocalState(normalizedBookingId);
          Navigation.replaceAll(Routes.dashboardScreen);
        },
        error: (error, stack) {
          PassengerFlowDebug.send(
            'passenger_cancel_failed',
            bookingId: normalizedBookingId,
            data: <String, dynamic>{'error': error.toString()},
          );
        },
        loading: handleLoading,
      );
    } finally {
      if (_passengerCancellationInProgressBookingId == normalizedBookingId) {
        _passengerCancellationInProgressBookingId = '';
      }
    }
  }

  // 0 - search driver / 1- driver get // trip destination
  // trip
  RxInt tripType = 0.obs;

  RxBool isDriverCome = false.obs;

  RxInt freeWaintingTime = 0.obs;
  Timer? timer;

  void getRideTimer(int time) {
    String lastTime = AppPreference.getString(AppPreference.RideTime);
    int diffSeconds = 0;

    if (lastTime.isNotEmpty) {
      Map getData = jsonDecode(lastTime);
      if (getData['bookingId'] ==
          "${riderBookingModel.value?.data?.booking?.id}") {
        DateTime lastshowTime = DateTime.fromMillisecondsSinceEpoch(
          getData['time'],
        );
        ;
        DateTime now = DateTime.now();
        diffSeconds = now.difference(lastshowTime).inSeconds;
        log(
          "TIME::::::${getData['time']}>>>${lastshowTime}::::$now:::::::$diffSeconds:::::${time * 60}:::::::${(time * 60) - diffSeconds}",
        );
      }
    }

    if (diffSeconds > time * 60) {
      freeWaintingTime.value = 0;
    } else {
      freeWaintingTime.value = (time * 60) - diffSeconds;
      if (lastTime.isEmpty) {
        AppPreference.setString(
          AppPreference.RideTime,
          jsonEncode({
            'bookingId': "${riderBookingModel.value?.data?.booking?.id}",
            'time': DateTime.now().millisecondsSinceEpoch,
          }),
        );
      }
    }

    // freeWaintingTime.value=time*60;
    if (timer?.isActive ?? false) timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (freeWaintingTime.value > 0) {
        freeWaintingTime.value--;
      } else {
        timer.cancel();
        this.timer?.cancel();
        AppPreference.removeKey(AppPreference.RideTime);
      }
    });
  }

  int pageNo = 1;
  bool isMoreOfferList = true;
  RxList<Offer> offerList = <Offer>[].obs;
  RxBool offerLoading = false.obs;
  RxBool offerPaginationLoading = false.obs;

  Future<void> getOfferList({
    bool isFirst = true,
    required String rideType,
  }) async {
    if (isFirst) {
      pageNo = 1;
      isMoreOfferList = true;
      if (offerList.isEmpty) {
        offerLoading(true);
      }
    }

    await processApi(
      () => HomeService.getOfferList(
        pageNo: pageNo,
        bookingID: bookingCreateModel.value?.data?.booking?.id ?? "",
        rideType: rideType,
      ),
      result: (data) {
        LogUtils.printAction("DATA:::${data.toJson()}");
        if (isFirst) {
          offerList.value = data.data?.offers ?? [];
        } else {
          offerList.addAll(data.data?.offers ?? []);
        }

        if ((data.data?.offers ?? []).length != 10) {
          isMoreOfferList = false;
        }
        pageNo++;
      },
      error: (error, stack) {
        log("OFFER ERROR :$error, $stack");
      },
    );

    offerPaginationLoading(false);
    offerLoading(false);
  }

  Future<Map> applyCouponCode({
    required String code,
    required String bookingId,
    required String rideTypeId,
  }) async {
    Map res = {};
    await processApi(
      () => HomeService.applyCode(
        code: code,
        bookingId: int.parse(bookingId),
        rideTypeId: rideTypeId,
      ),
      result: (data) {
        res = data;
        LogUtils.printAction("data:::$data");
      },
      loading: handleLoading,
    );

    return res;
  }

  Future<List<String>> _getCityNames(double lat, double lng) async {
    final cityNames = <String>[];

    void addName(String? value) {
      final normalized = value?.trim() ?? "";
      if (normalized.isEmpty) return;
      if (RegExp(r'^\d+$').hasMatch(normalized)) return;
      if (cityNames.any((c) => c.toLowerCase() == normalized.toLowerCase())) {
        return;
      }
      cityNames.add(normalized);
    }

    if ((placeApi ?? "").isNotEmpty) {
      try {
        final Stopwatch geocodeStopwatch = Stopwatch()..start();
        PassengerFlowDebug.send(
          'reverse_geocode_request',
          bookingId: AppConstant().bookingId,
          data: <String, dynamic>{
            'latitude': PassengerFlowDebug.coordinate(lat),
            'longitude': PassengerFlowDebug.coordinate(lng),
          },
        );
        final response = await http.get(
          Uri.parse(
            "https://maps.googleapis.com/maps/api/geocode/json"
            "?latlng=$lat,$lng&key=$placeApi",
          ),
        );
        geocodeStopwatch.stop();
        PassengerFlowDebug.send(
          'reverse_geocode_response',
          bookingId: AppConstant().bookingId,
          data: <String, dynamic>{
            'status_code': response.statusCode,
            'duration_ms': geocodeStopwatch.elapsedMilliseconds,
          },
        );
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final results = decoded['results'] as List<dynamic>? ?? [];
          for (final result in results) {
            final components =
                result['address_components'] as List<dynamic>? ?? [];
            for (final component in components) {
              final types = List<String>.from(component['types'] ?? []);
              if (types.contains('locality')) {
                addName(component['long_name'] as String?);
              }
            }
          }

          if (cityNames.isEmpty) {
            for (final result in results) {
              final components =
                  result['address_components'] as List<dynamic>? ?? [];
              for (final component in components) {
                final types = List<String>.from(component['types'] ?? []);
                if (types.contains('administrative_area_level_2') ||
                    types.contains('administrative_area_level_3')) {
                  addName(component['long_name'] as String?);
                }
              }
            }
          }
        }
      } catch (e, st) {
        PassengerFlowDebug.runtimeError('reverse_geocode', e, st);
        LogUtils.printAction("Google geocode error: $e");
      }
    }

    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        addName(place.locality);
        addName(place.subAdministrativeArea);
      }
    } catch (e) {
      LogUtils.printAction("Device geocode error: $e");
    }

    return cityNames;
  }

  bool _bannerHasCity(banner.Row element) {
    final name = element.city?.name?.trim() ?? "";
    final fullName = element.city?.fullName?.trim() ?? "";
    return name.isNotEmpty || fullName.isNotEmpty || element.city?.id != null;
  }

  bool _bannerMatchesCity(banner.Row element, List<String> cityNames) {
    if (cityNames.isEmpty) return !_bannerHasCity(element);

    if (!_bannerHasCity(element)) return false;

    final bannerCityNames = <String>{};

    void addBannerName(String? value) {
      final normalized = value?.trim() ?? "";
      if (normalized.isEmpty) return;
      bannerCityNames.add(normalized);
      for (final part in normalized.split(',')) {
        final piece = part.trim();
        if (piece.isNotEmpty) bannerCityNames.add(piece);
      }
    }

    addBannerName(element.city?.name);
    addBannerName(element.city?.fullName);

    for (final bannerCity in bannerCityNames) {
      final bannerLower = bannerCity.toLowerCase();
      for (final userCity in cityNames) {
        if (bannerLower == userCity.toLowerCase().trim()) {
          return true;
        }
      }
    }
    return false;
  }

  void _applyBannerFilter(banner.BannerModel data, List<String> cityNames) {
    if (cityNames.isEmpty) {
      final firstRow = (data.data?.firstRow ?? [])
          .where((element) => !_bannerHasCity(element))
          .toList();
      final secondRow = (data.data?.secondRow ?? [])
          .where((element) => !_bannerHasCity(element))
          .toList();

      LogUtils.printAction(
        "Banner filter (no city resolved): first=${firstRow.length}, second=${secondRow.length}",
      );

      data.data?.firstRow = firstRow;
      data.data?.secondRow = secondRow;
      bannerModel.value = data;
      bannerModel.refresh();
      return;
    }

    final firstRow = (data.data?.firstRow ?? [])
        .where((element) => _bannerMatchesCity(element, cityNames))
        .toList();
    final secondRow = (data.data?.secondRow ?? [])
        .where((element) => _bannerMatchesCity(element, cityNames))
        .toList();

    LogUtils.printAction(
      "Banner filter $cityNames: first=${firstRow.length}, second=${secondRow.length}",
    );

    data.data?.firstRow = firstRow;
    data.data?.secondRow = secondRow;
    bannerModel.value = data;
    bannerModel.refresh();
  }

  int _bannerRequestId = 0;

  RxBool bannerLoading = false.obs;
  Rxn<banner.BannerModel> bannerModel = Rxn<banner.BannerModel>();

  Future<void> getBanner({double? lat, double? lng}) async {
    final latLong = AppPreference.getString(AppPreference.location);

    final resolvedLat =
        lat ??
        LocationService().currentUserLatLg.value?.latitude ??
        (latLong.isNotEmpty
            ? double.tryParse(latLong.split("@").first) ?? 0
            : 0);
    final resolvedLng =
        lng ??
        LocationService().currentUserLatLg.value?.longitude ??
        (latLong.isNotEmpty
            ? double.tryParse(latLong.split("@").last) ?? 0
            : 0);

    if (resolvedLat == 0 && resolvedLng == 0) {
      LogUtils.printAction("getBanner skipped: location not available");
      return;
    }

    LogUtils.printAction("getBanner: lat=$resolvedLat, lng=$resolvedLng");

    final requestId = ++_bannerRequestId;
    bannerLoading(true);
    await processApi(
      () => HomeService.getBannerList(
        latitude: resolvedLat,
        longitude: resolvedLng,
      ),
      result: (data) async {
        if (requestId != _bannerRequestId) return;

        final cityNames = await _getCityNames(resolvedLat, resolvedLng);

        LogUtils.printAction("Banner city names: $cityNames");

        _applyBannerFilter(data, cityNames);
      },
    );
    if (requestId == _bannerRequestId) {
      bannerLoading(false);
    }
  }

  Future<Map> removePromoCode(int bookingId) async {
    Map res = {};
    await processApi(
      () => HomeService.removePromoCode(bookingId),
      result: (data) {
        res = data;
      },
      loading: handleLoading,
    );
    return res;
  }

  Future<Map> ratingDriver({
    required int bookingId,
    required double rating,
    required String comment,
  }) async {
    Map res = {};
    await processApi(
      () => HomeService.driverRating(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      ),
      result: (data) {
        res = data;
      },
      loading: handleLoading,
    );
    return res;
  }

  String transactionId = "";

  Future paymentInt({
    required String bookingId,
    required double amount,
    required String method,
    required bool isSplit,
    required String tip,
  }) async {
    if (method.trim().toLowerCase() == 'cash') {
      PassengerFlowDebug.send(
        'cash_payment_init_transaction_prevented',
        bookingId: bookingId,
        data: <String, dynamic>{'amount': amount},
      );
      await selectCashForCompletedRide(bookingId: bookingId);
      return;
    }
    transactionId = "";
    await processApi(
      () => HomeService.paymentInt(
        bookingId: bookingId,
        amount: amount,
        method: method,
        isSplit: isSplit,
        tip: tip,
      ),
      result: (data) async {
        transactionId = data['data']['transaction_id'];
        LogUtils.printAction("ID:::::::$transactionId");

        if (method == "cash" || method == "wallet") {
          Navigation.pushNamed(Routes.rateDriverScreen);
          Get.find<WalletController>().getWalletData();
          Get.find<TripController>().getTripHistory();
        } else {
          bool? result = await Get.to(
            () => PaymentWebViewScreen(webUrl: data['data']['payment_link']),
          );
          if (result != null && result) {
            paymentVerify(transactionId);
          }
        }
      },
      loading: handleLoading,
    );
  }

  Future paymentVerify(String transactionId) async {
    await processApi(
      () => HomeService.verifyPayment(transactionID: transactionId),
      result: (data) {
        LogUtils.printAction(">>>>>>$data");

        if (data['data']['status'] == "completed") {
          AppSnackBar.showErrorSnackBar(message: data['message']);
          Navigation.pushNamed(Routes.rateDriverScreen);
          Get.find<TripController>().getTripHistory();
        } else {
          AppSnackBar.showErrorSnackBar(message: data['message']);
        }
      },
      loading: handleLoading,
    );
  }

  Future<Map> updatePaymentMode({
    required String paymentMode,
    required String bookingId,
  }) async {
    Map res = {};

    await processApi(
      () => HomeService.updatePaymentMode(
        bookingId: bookingId,
        paymentMode: paymentMode,
      ),
      result: (data) {
        res = data;
        LogUtils.printAction("reult:::$data");
      },
      loading: handleLoading,
      error: (error, stack) {
        LogUtils.printAction("PAYMENT UPDATEW :ER :$error");
      },
    );
    return res;
  }

  RxList<ContactModel> userNameList = <ContactModel>[].obs;

  Future<void> getUserNameList() async {
    processApi(
      () => HomeService.getUserNameList(),
      result: (data) {
        userNameList.value = data.data?.contacts ?? [];
      },
    );
  }

  Future<void> addUserName({
    required String name,
    required String phone,
    required String imagePath,
  }) async {
    processApi(
      () => HomeService.addUserName(
        name: name,
        phone: phone,
        imagePath: imagePath,
      ),
      result: (data) {
        handleLoading(false);
        Get.back();
        userNameList.add(
          ContactModel(
            id: data['data']['contact']['id'],
            mobileNumber: data['data']['contact']['mobile_number'],
            name: data['data']['contact']['name'],
            profilePic: data['data']['contact']['profile_pic'],
          ),
        );
        userNameList.refresh();
        AppSnackBar.showErrorSnackBar(message: data['message']);
      },
      loading: handleLoading,
    );
  }

  RxList<rideType.RideType> rideTypeList = <rideType.RideType>[].obs;

  Future<void> getRideTypeList() async {
    String dbData = AppPreference.getString(AppPreference.rideType);
    if (dbData.isNotEmpty) {
      rideTypeList.value =
          rideType.RideTypeListModel.fromJson(
            jsonDecode(dbData),
          ).data?.rideTypes ??
          [];
    }

    processApi(
      () => HomeService.getRideTypeList(),
      result: (data) {
        rideTypeList.value = data.data?.rideTypes ?? [];

        AppPreference.setString(
          AppPreference.rideType,
          jsonEncode(data.toJson()),
        );
      },
    );
  }
}
