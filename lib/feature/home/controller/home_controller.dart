import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart'as http;
import 'package:e_taxi/core/service/socket_channel.dart';
import 'package:e_taxi/core/debug/driver_flow_debug.dart';
import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/feature/home/service/home_service.dart';
import 'package:e_taxi/utils/common_api_caller.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/service/firebase_notification_new.dart';
import '../../../core/service/location_utils.dart';
import '../../../utils/api_constants.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_preferences.dart';
import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../utils/constants.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custome_img.dart';
import '../../../widgets/dialog.dart';
import '../../../widgets/app_snackbar.dart';
import '../../auth/model/ride_type_list_model.dart' as rideType;
import '../model/new_ride_model.dart';
import '../model/ride_complete_model.dart' hide RideType;
import '../pages/home_screen.dart';
import '../widget/arrival_eta_selector.dart';
import '../widget/icon_widget.dart';
import '../widget/listTileWidget.dart';
import '../widget/originDestinationTime.dart';

class HomeController extends GetxController with LoadingApiMixin, LoadingMixin {
  Rx<BuildContext?> sheetContext = Rx<BuildContext?>(null);

  void close() {
    if (sheetContext.value != null && isRideAvailable.value == -1) {
      Navigator.of(sheetContext.value!).pop();
      sheetContext.value = null;
    }
    if (rideTimerSec.value <= 0) {
      isRideAvailable.value = -1;
      update();
    }
  }

  StreamSubscription<Map<String, dynamic>>? _notificationStream;

  Future<void> notificationRedirect() async {
    FireBaseNotification().notificationPermission();
    _notificationStream?.cancel();
    _notificationStream = FireBaseNotification.selectNotificationSubject.listen(
      (Map<String, dynamic> value) async {
        try {
          final String eventType =
              (value['event_type'] ?? value['event'] ?? '').toString();
          DriverFlowDebug.send(
            'push_event_received',
            bookingId: (value['booking_id'] ?? '').toString(),
            data: <String, dynamic>{
              'event_type': eventType,
              'has_data': value['data'] != null,
              'route': Get.currentRoute,
            },
          );

          if (eventType == 'new_ride_request') {
            final bool driverIsOnline =
                isOnline.value ||
                AppPreference.getBoolean(AppPreference.driverOnline) ||
                (accountController.userModel.value?.isOnline ?? '0') == '1';
            if (!driverIsOnline) {
              DriverFlowDebug.send(
                'push_offer_ignored_driver_offline',
                bookingId: (value['booking_id'] ?? '').toString(),
              );
              return;
            }

            final dynamic rawData = value['data'];
            dynamic decoded = rawData;
            if (rawData is String && rawData.trim().isNotEmpty) {
              decoded = jsonDecode(rawData);
            }
            if (decoded is Map &&
                !decoded.containsKey('booking_id') &&
                decoded['data'] is Map) {
              decoded = decoded['data'];
            }
            if (decoded is! Map) {
              DriverFlowDebug.send(
                'push_offer_payload_invalid',
                data: <String, dynamic>{'payload_type': decoded.runtimeType.toString()},
              );
              return;
            }

            _presentRideOffer(
              Map<String, dynamic>.from(decoded),
              source: 'push',
            );
            return;
          }

          if (value.containsKey('chat_id')) {
            final String bookingId = (value['booking_id'] ?? '').toString();
            if (bookingId.trim().isEmpty) {
              DriverFlowDebug.send('push_chat_missing_booking_id');
              return;
            }
            Navigation.pushNamed(
              Routes.chatScreen,
              params: <String, String>{'bookingId': bookingId},
            );
          }
        } catch (error, stack) {
          DriverFlowDebug.runtimeError('driver_push_listener', error, stack);
          log('DRIVER PUSH ERROR: $error, $stack');
        }
      },
    );
  }

  void onResumed() {
    close();
    unawaited(ensureOnlineHeartbeat(reason: 'app_resumed', force: true));
    forceRideOfferRefresh(reason: 'app_resumed');
  }

  RxInt isRideAvailable = (-1).obs;
  static const List<int> allowedArrivalEtaMinutes = <int>[10, 12, 15, 20, 25, 30];
  final RxInt selectedArrivalEtaMinutes = 0.obs;

  void resetArrivalEta() {
    selectedArrivalEtaMinutes.value = 0;
  }

  RxInt rideTimerSec = 0.obs;
  Timer? timer;
  final SocketChannelService _socketService = SocketChannelService();

  void getRideTimer(int time, {bool closeBottomSheet = false}) {
    rideTimerSec.value = time;
    if (timer?.isActive ?? false) timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (rideTimerSec.value > 0) {
        rideTimerSec.value--;
      } else {
        this.timer?.cancel();
        timer.cancel();
        final String expiredOfferId = _lastPresentedOfferId;
        if (expiredOfferId.isNotEmpty) {
          dismissVisibleRideOffer(
            bookingId: expiredOfferId,
            reason: 'acceptance_timeout',
          );
        } else {
          isRideAvailable.value = -1;
          update();
          close();
        }
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    isOnline.value = AppPreference.getBoolean(AppPreference.driverOnline);
    debugPrint("HOME INIT ");
    notificationRedirect();
    getRideTypeList();
    _initializeSocket();
    _listenToSocket();
    _listenToConnection();
    _startRideOfferPolling();
    unawaited(ensureOnlineHeartbeat(reason: 'home_controller_init', force: true));
    getSetting();
  }

  final RxBool isConnected = false.obs;

  @override
  void onClose() {
    _socketService.disconnect();
    _socketSubscription?.cancel();
    _notificationStream?.cancel();
    _rideOfferPollingTimer?.cancel();
    FireBaseNotification().removeListen();
    super.onClose();
  }

  Timer? _rideOfferPollingTimer;
  bool _rideOfferPollInProgress = false;
  String _lastPresentedOfferId = '';
  DateTime? _lastPresentedOfferAt;
  DateTime? _nextRideOfferPollAt;
  int _rideOfferPollFailureCount = 0;
  String _lastPollSkipReason = '';
  DateTime? _lastPollSkipLoggedAt;
  DateTime? _lastActiveRideCheckAt;
  bool _activeRideCheckInProgress = false;
  String _lastAlertedOfferId = '';
  String _offerUiRenderedId = '';
  DateTime? _offerUiRenderedAt;
  String _offerPointerDownId = '';
  DateTime? _offerPointerDownAt;
  bool _offerAcceptInFlight = false;

  String get visibleOfferBookingId => _lastPresentedOfferId;
  bool get offerAcceptInFlight => _offerAcceptInFlight;

  void markOfferUiRendered(String bookingId) {
    final String normalized = bookingId.trim();
    if (normalized.isEmpty ||
        normalized != _lastPresentedOfferId ||
        isRideAvailable.value != 1) {
      DriverFlowDebug.send(
        'offer_ui_render_ignored',
        bookingId: normalized,
        data: <String, dynamic>{
          'last_offer_id': _lastPresentedOfferId,
          'ride_available': isRideAvailable.value,
        },
      );
      return;
    }
    if (_offerUiRenderedId == normalized) return;
    _offerUiRenderedId = normalized;
    _offerUiRenderedAt = DateTime.now();
    DriverFlowDebug.send(
      'offer_ui_rendered',
      bookingId: normalized,
      data: <String, dynamic>{
        'route': Get.currentRoute,
        'timer_seconds': rideTimerSec.value,
      },
    );
  }

  void markOfferPointerDown(String bookingId) {
    final String normalized = bookingId.trim();
    _offerPointerDownId = normalized;
    _offerPointerDownAt = DateTime.now();
    DriverFlowDebug.send(
      'offer_accept_pointer_down',
      bookingId: normalized,
      data: <String, dynamic>{
        'ui_rendered': _offerUiRenderedId == normalized,
        'ride_available': isRideAvailable.value,
      },
    );
  }

  void dismissVisibleRideOffer({
    required String bookingId,
    String reason = 'driver_dismissed',
  }) {
    final String normalized = bookingId.trim();
    if (normalized.isEmpty || normalized != _lastPresentedOfferId) {
      DriverFlowDebug.send(
        'offer_dismiss_ignored',
        bookingId: normalized,
        data: <String, dynamic>{
          'last_offer_id': _lastPresentedOfferId,
          'reason': reason,
        },
      );
      return;
    }
    timer?.cancel();
    isRideAvailable.value = -1;
    _lastPresentedOfferId = '';
    _lastPresentedOfferAt = null;
    _offerUiRenderedId = '';
    _offerUiRenderedAt = null;
    _offerPointerDownId = '';
    _offerPointerDownAt = null;
    resetArrivalEta();
    DriverFlowDebug.send(
      'offer_dismissed',
      bookingId: normalized,
      data: <String, dynamic>{'reason': reason},
    );
    update();
    Future<void>.delayed(
      const Duration(milliseconds: 600),
      () => forceRideOfferRefresh(reason: 'after_offer_dismiss'),
    );
  }

  Future<bool> acceptVisibleRideOffer(NewRideModel offer) async {
    final String bookingId = (offer.bookingId ?? '').toString().trim();
    final DateTime now = DateTime.now();
    final bool uiIsCurrent =
        bookingId.isNotEmpty &&
        bookingId == _lastPresentedOfferId &&
        bookingId == _offerUiRenderedId &&
        isRideAvailable.value == 1;
    final bool recentRealPointer =
        bookingId == _offerPointerDownId &&
        _offerPointerDownAt != null &&
        now.difference(_offerPointerDownAt!).inMilliseconds <= 2500;
    final bool renderedRecently =
        _offerUiRenderedAt != null &&
        now.difference(_offerUiRenderedAt!).inMinutes < 3;
    final int etaMinutes = selectedArrivalEtaMinutes.value;

    DriverFlowDebug.send(
      'offer_accept_guard_checked',
      bookingId: bookingId,
      data: <String, dynamic>{
        'ui_is_current': uiIsCurrent,
        'recent_real_pointer': recentRealPointer,
        'rendered_recently': renderedRecently,
        'accept_in_flight': _offerAcceptInFlight,
        'eta_minutes': etaMinutes,
        'last_offer_id': _lastPresentedOfferId,
      },
    );

    if (_offerAcceptInFlight) return false;
    if (!uiIsCurrent || !recentRealPointer || !renderedRecently) {
      AppSnackBar.showErrorSnackBar(
        message: 'A fuvarajánlat már nem aktív. Frissítjük a listát.',
        isError: true,
      );
      forceRideOfferRefresh(reason: 'accept_guard_rejected');
      return false;
    }
    if (!allowedArrivalEtaMinutes.contains(etaMinutes)) {
      AppSnackBar.showErrorSnackBar(
        message: 'Válaszd ki a vállalt érkezési időt.',
        isError: true,
      );
      return false;
    }

    final double? dropLat = double.tryParse(offer.dropoff?.latitude ?? '');
    final double? dropLng = double.tryParse(offer.dropoff?.longitude ?? '');
    if (dropLat == null || dropLng == null) {
      DriverFlowDebug.send(
        'offer_accept_invalid_dropoff',
        bookingId: bookingId,
      );
      AppSnackBar.showErrorSnackBar(
        message: 'A cél koordinátája hiányzik. A fuvar nem fogadható el.',
        isError: true,
      );
      return false;
    }

    _offerAcceptInFlight = true;
    _offerPointerDownId = '';
    _offerPointerDownAt = null;
    DriverFlowDebug.send(
      'offer_accept_user_confirmed',
      bookingId: bookingId,
      data: <String, dynamic>{'eta_minutes': etaMinutes},
    );
    try {
      final bool accepted = await updateBookingRideStatus(
        bookingId: bookingId,
        statusNo: 1,
        dropLatLng: LatLng(dropLat, dropLng),
        dropAddress: offer.dropoff?.address ?? '',
        rideModel: offer,
        etaMinutes: etaMinutes,
      );
      if (accepted) {
        isRideAvailable.value = -1;
        _offerUiRenderedId = '';
        _offerUiRenderedAt = null;
        update();
      } else {
        _lastPresentedOfferId = '';
        _lastPresentedOfferAt = null;
      }
      return accepted;
    } finally {
      _offerAcceptInFlight = false;
    }
  }

  void _startRideOfferPolling() {
    _rideOfferPollingTimer?.cancel();
    unawaited(_pollPendingRideOffer(force: true));
    _rideOfferPollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => unawaited(_pollPendingRideOffer()),
    );
  }

  void forceRideOfferRefresh({String reason = 'manual'}) {
    _nextRideOfferPollAt = null;
    DriverFlowDebug.send(
      'pending_offer_force_refresh',
      data: <String, dynamic>{'reason': reason, 'route': Get.currentRoute},
    );
    unawaited(_pollPendingRideOffer(force: true));
  }

  String _currentLocalRideBookingId() {
    final String rideModelId =
        (rideDataModel.value?.booking?.id ?? rideDataModel.value?.bookingId ?? '')
            .toString()
            .trim();
    if (rideModelId.isNotEmpty) return rideModelId;
    final String constantId = Constants.bookingId.trim();
    if (constantId.isNotEmpty) return constantId;
    return (accountController.userModel.value?.currentBookingId ?? '').trim();
  }

  void clearTerminalRideState({
    String reason = 'terminal_status',
    String bookingId = '',
    bool refreshOffers = true,
  }) {
    final String incomingId = bookingId.trim();
    final String activeId = _currentLocalRideBookingId();
    final String serverCurrentId =
        (accountController.userModel.value?.currentBookingId ?? '').trim();

    final bool mismatchesActive =
        incomingId.isNotEmpty &&
        activeId.isNotEmpty &&
        incomingId != activeId;
    final bool mismatchesVisibleOffer =
        incomingId.isNotEmpty &&
        activeId.isEmpty &&
        _lastPresentedOfferId.isNotEmpty &&
        incomingId != _lastPresentedOfferId;
    final bool emptyIdWouldClearServerActive =
        incomingId.isEmpty && activeId.isNotEmpty && serverCurrentId.isNotEmpty;

    if (mismatchesActive ||
        mismatchesVisibleOffer ||
        emptyIdWouldClearServerActive) {
      DriverFlowDebug.send(
        'stale_terminal_clear_ignored',
        bookingId: incomingId,
        data: <String, dynamic>{
          'reason': reason,
          'active_booking_id': activeId,
          'server_current_booking_id': serverCurrentId,
          'visible_offer_id': _lastPresentedOfferId,
          'route': Get.currentRoute,
        },
      );
      return;
    }

    timer?.cancel();
    timer1?.cancel();
    rideDataModel.value = null;
    rideDataModel.refresh();
    isRideAvailable.value = -1;
    rideStatus.value = 1;
    isDrawPoliLine.value = false;
    Constants.bookingId = '';
    AppPreference.removeKey(AppPreference.driverRideTime);
    accountController.userModel.update((value) {
      value?.currentBookingId = '';
    });
    accountController.userModel.refresh();
    _lastPresentedOfferId = '';
    _lastPresentedOfferAt = null;
    _lastAlertedOfferId = '';
    _offerUiRenderedId = '';
    _offerUiRenderedAt = null;
    _offerPointerDownId = '';
    _offerPointerDownAt = null;
    _offerAcceptInFlight = false;
    _nextRideOfferPollAt = null;
    DriverFlowDebug.send(
      'active_ride_state_cleared',
      bookingId: incomingId.isNotEmpty ? incomingId : activeId,
      data: <String, dynamic>{'reason': reason, 'route': Get.currentRoute},
    );
    update();
    if (refreshOffers) {
      Future.delayed(
        const Duration(milliseconds: 800),
        () => forceRideOfferRefresh(reason: 'after_$reason'),
      );
    }
  }

  void _logPollSkip(String reason, Map<String, dynamic> data) {
    final now = DateTime.now();
    final shouldLog = reason != _lastPollSkipReason ||
        _lastPollSkipLoggedAt == null ||
        now.difference(_lastPollSkipLoggedAt!).inSeconds >= 15;
    if (!shouldLog) return;
    _lastPollSkipReason = reason;
    _lastPollSkipLoggedAt = now;
    DriverFlowDebug.send(
      'pending_offer_poll_skipped',
      data: <String, dynamic>{'reason': reason, ...data},
    );
  }

  void _presentRideOffer(
    Map<String, dynamic> payload, {
    required String source,
  }) {
    final String bookingId = payload['booking_id']?.toString().trim() ?? '';
    if (bookingId.isEmpty) {
      DriverFlowDebug.send(
        'offer_state_rejected_missing_booking_id',
        data: <String, dynamic>{'source': source},
      );
      return;
    }

    final String activeId = _currentLocalRideBookingId();
    if (activeId.isNotEmpty && activeId != bookingId) {
      DriverFlowDebug.send(
        'offer_state_rejected_active_ride',
        bookingId: bookingId,
        data: <String, dynamic>{
          'active_booking_id': activeId,
          'source': source,
          'route': Get.currentRoute,
        },
      );
      return;
    }

    if (bookingId == _lastPresentedOfferId && isRideAvailable.value == 1) {
      DriverFlowDebug.send(
        'offer_duplicate_signal_ignored',
        bookingId: bookingId,
        data: <String, dynamic>{'source': source},
      );
      return;
    }

    _lastPresentedOfferId = bookingId;
    _lastPresentedOfferAt = DateTime.now();
    _offerUiRenderedId = '';
    _offerUiRenderedAt = null;
    _offerPointerDownId = '';
    _offerPointerDownAt = null;
    _offerAcceptInFlight = false;
    resetArrivalEta();
    rideDataTempModel = NewRideModel.fromJson(payload);
    getRideTimer(rideDataTempModel.acceptanceTimer ?? 30);
    isRideAvailable.value = 1;
    isRideAvailable.refresh();

    final String routeBeforeRedirect = Get.currentRoute;
    if (routeBeforeRedirect != Routes.homeScreen &&
        routeBeforeRedirect != Routes.mapNavigationScreen) {
      Navigation.replaceAll(Routes.homeScreen);
    }
    update();

    if (_lastAlertedOfferId != bookingId) {
      _lastAlertedOfferId = bookingId;
      unawaited(SystemSound.play(SystemSoundType.alert));
      unawaited(HapticFeedback.heavyImpact());
      unawaited(
        FireBaseNotification().showIncomingRideAlert(bookingId: bookingId),
      );
      DriverFlowDebug.send(
        'incoming_ride_alert_triggered',
        bookingId: bookingId,
        data: <String, dynamic>{'source': source},
      );
    }

    DriverFlowDebug.send(
      'pending_offer_state_ready',
      bookingId: bookingId,
      data: <String, dynamic>{
        'source': source,
        'route_before_redirect': routeBeforeRedirect,
        'route_after_redirect': Get.currentRoute,
        'pickup_present':
            (rideDataTempModel.pickup?.address ?? '').trim().isNotEmpty,
        'dropoff_present':
            (rideDataTempModel.dropoff?.address ?? '').trim().isNotEmpty,
        'acceptance_timer': rideDataTempModel.acceptanceTimer ?? 30,
      },
    );
  }

  Future<void> _reconcileActiveRideFromProfile() async {
    final DateTime now = DateTime.now();
    if (_activeRideCheckInProgress ||
        (_lastActiveRideCheckAt != null &&
            now.difference(_lastActiveRideCheckAt!).inSeconds < 5)) {
      return;
    }
    _activeRideCheckInProgress = true;
    _lastActiveRideCheckAt = now;
    final String previousBookingId = _currentLocalRideBookingId();
    try {
      await accountController.getUserData();
      final String serverStatus =
          accountController.lastServerRideStatus.value.toLowerCase().trim();
      final String serverBookingId =
          accountController.lastServerRideBookingId.value.trim();
      final String serverCurrentBookingId =
          (accountController.userModel.value?.currentBookingId ?? '').trim();
      final String serverPaymentStatus =
          accountController.lastServerRidePaymentStatus.value
              .toLowerCase()
              .trim();
      final bool paymentSettled = const <String>{
        'paid',
        'completed',
        'complete',
        'success',
        'successful',
        'settled',
        '1',
        'true',
      }.contains(serverPaymentStatus);
      final bool completedAwaitingPayment =
          serverStatus == 'completed' && !paymentSettled;
      final bool terminal = const <String>{
        'cancelled',
        'completed',
        'expired',
      }.contains(serverStatus);

      if (completedAwaitingPayment) {
        DriverFlowDebug.send(
          'completed_ride_preserved_until_payment',
          bookingId: serverBookingId,
          data: <String, dynamic>{
            'payment_status': serverPaymentStatus,
            'previous_booking_id': previousBookingId,
            'route': Get.currentRoute,
          },
        );
        if (serverBookingId.isNotEmpty &&
            previousBookingId == serverBookingId &&
            Get.currentRoute != Routes.cashCollectScreen) {
          Navigation.replaceAll(Routes.cashCollectScreen);
        }
        return;
      }

      if (!terminal) {
        DriverFlowDebug.send(
          'active_ride_reconcile_non_terminal',
          bookingId: serverBookingId,
          data: <String, dynamic>{
            'server_status': serverStatus,
            'previous_booking_id': previousBookingId,
            'server_current_booking_id': serverCurrentBookingId,
            'server_payment_status': serverPaymentStatus,
          },
        );
        return;
      }

      if (previousBookingId.isEmpty ||
          serverBookingId.isEmpty ||
          serverBookingId != previousBookingId) {
        DriverFlowDebug.send(
          'stale_terminal_profile_result_ignored',
          bookingId: serverBookingId,
          data: <String, dynamic>{
            'server_status': serverStatus,
            'previous_booking_id': previousBookingId,
            'server_current_booking_id': serverCurrentBookingId,
            'route': Get.currentRoute,
          },
        );
        return;
      }

      DriverFlowDebug.send(
        'active_ride_reconciled_terminal',
        bookingId: serverBookingId,
        data: <String, dynamic>{
          'server_status': serverStatus,
          'route': Get.currentRoute,
        },
      );
      clearTerminalRideState(
        reason: serverStatus == 'cancelled'
            ? 'passenger_cancelled_profile_poll'
            : 'terminal_profile_poll',
        bookingId: serverBookingId,
      );
      if (const <String>{
        Routes.mapNavigationScreen,
        Routes.customerOtpVerify,
        Routes.cashCollectScreen,
      }.contains(Get.currentRoute)) {
        Navigation.replaceAll(Routes.homeScreen);
        AppSnackBar.showErrorSnackBar(
          message: serverStatus == 'cancelled'
              ? 'Az utas lemondta az utazást.'
              : 'Az aktív utazás lezárult.',
          isError: serverStatus == 'cancelled',
        );
      }
    } catch (error, stack) {
      DriverFlowDebug.send(
        'active_ride_reconcile_error',
        bookingId: previousBookingId,
        data: <String, dynamic>{
          'error': error.toString(),
          'stack': stack.toString(),
        },
      );
    } finally {
      _activeRideCheckInProgress = false;
    }
  }

  Future<void> _pollPendingRideOffer({bool force = false}) async {
    final bool driverIsOnline =
        isOnline.value ||
        AppPreference.getBoolean(AppPreference.driverOnline) ||
        (accountController.userModel.value?.isOnline ?? '0') == '1';

    final String currentRideStatus =
        rideDataModel.value?.booking?.status?.toLowerCase().trim() ?? '';
    final bool localRideLooksActive = const {'accepted', 'arrived', 'started'}
        .contains(currentRideStatus);
    final String serverCurrentBookingId =
        (accountController.userModel.value?.currentBookingId ?? '').trim();
    final bool activeRideScreen = const <String>{
      Routes.mapNavigationScreen,
      Routes.customerOtpVerify,
      Routes.cashCollectScreen,
    }.contains(Get.currentRoute);

    // A korábban lemondott/befejezett fuvar helyi modellje nem állíthatja le
    // örökre az új ajánlatok lekérését.
    if (localRideLooksActive &&
        serverCurrentBookingId.isEmpty &&
        !activeRideScreen) {
      rideDataModel.value = null;
      rideDataModel.refresh();
      rideStatus.value = 1;
      isDrawPoliLine.value = false;
      DriverFlowDebug.send(
        'stale_local_ride_removed_before_poll',
        data: <String, dynamic>{
          'local_status': currentRideStatus,
          'route': Get.currentRoute,
        },
      );
    }

    // A profilban önmagában beragadt current_booking_id nem állíthatja le
    // örökre a pending-offer végpontot. Valódi aktív fuvarnak csak a helyi
    // aktív állapotot vagy a megnyitott navigációt tekintjük; a backend ettől
    // még biztonságosan visszaadhat üres ajánlatot.
    final bool hasActiveRide = activeRideScreen ||
        (localRideLooksActive && serverCurrentBookingId.isNotEmpty);
    final DateTime now = DateTime.now();

    if (!driverIsOnline) {
      _logPollSkip('driver_offline', <String, dynamic>{
        'local_online': isOnline.value,
        'stored_online': AppPreference.getBoolean(AppPreference.driverOnline),
        'profile_online': accountController.userModel.value?.isOnline ?? '',
      });
      return;
    }
    if (_rideOfferPollInProgress) {
      _logPollSkip('poll_in_progress', <String, dynamic>{});
      return;
    }
    if (isRideAvailable.value == 1) {
      _logPollSkip('offer_already_visible', <String, dynamic>{
        'booking_id': _lastPresentedOfferId,
      });
      return;
    }
    if (hasActiveRide) {
      _logPollSkip('active_ride', <String, dynamic>{
        'server_booking_id': serverCurrentBookingId,
        'local_status': currentRideStatus,
        'route': Get.currentRoute,
      });
      unawaited(_reconcileActiveRideFromProfile());
      return;
    }
    if (!force &&
        _nextRideOfferPollAt != null &&
        now.isBefore(_nextRideOfferPollAt!)) {
      _logPollSkip('backoff', <String, dynamic>{
        'retry_at': _nextRideOfferPollAt!.toIso8601String(),
      });
      return;
    }

    _rideOfferPollInProgress = true;
    DriverFlowDebug.send(
      'pending_offer_poll_started',
      data: <String, dynamic>{
        'force': force,
        'route': Get.currentRoute,
        'last_offer_id': _lastPresentedOfferId,
      },
    );

    try {
      final dynamic response = await HomeServices.pendingRideOffer(
        onlineHeartbeat: driverIsOnline,
        currentLocation: LocationService().currentUserLatLg.value,
      );
      _rideOfferPollFailureCount = 0;
      _nextRideOfferPollAt = null;

      dynamic rawPayload = response is Map ? response['data'] : null;
      if (rawPayload is Map &&
          !rawPayload.containsKey('booking_id') &&
          rawPayload['data'] is Map) {
        rawPayload = rawPayload['data'];
      }

      if (rawPayload is! Map) {
        final String responseMessage = response is Map
            ? response['message']?.toString() ?? ''
            : '';
        DriverFlowDebug.send(
          'pending_offer_none',
          data: <String, dynamic>{
            'reason_code': response is Map
                ? response['reason_code']?.toString() ?? ''
                : '',
            'message': responseMessage,
          },
        );
        if (driverIsOnline &&
            responseMessage.toLowerCase().contains('offline')) {
          unawaited(
            ensureOnlineHeartbeat(
              reason: 'pending_offer_server_offline',
              force: true,
            ),
          );
        }
        return;
      }

      final payload = Map<String, dynamic>.from(rawPayload);
      final bookingId = payload['booking_id']?.toString().trim() ?? '';
      if (bookingId.isEmpty) {
        DriverFlowDebug.send('pending_offer_missing_booking_id');
        return;
      }

      final bool sameOfferRecentlyShown = bookingId == _lastPresentedOfferId &&
          _lastPresentedOfferAt != null &&
          now.difference(_lastPresentedOfferAt!).inSeconds < 12;
      if (sameOfferRecentlyShown) return;

      final targetDriverId =
          payload['driver_auth_token']?.toString().trim() ?? '';
      final currentDriverId =
          AppPreference.getString(AppPreference.userId).trim();

      if (targetDriverId.isNotEmpty &&
          currentDriverId.isNotEmpty &&
          targetDriverId != currentDriverId) {
        DriverFlowDebug.send(
          'pending_offer_wrong_driver',
          bookingId: bookingId,
          data: <String, dynamic>{
            'target_driver_id': targetDriverId,
            'current_driver_id': currentDriverId,
          },
        );
        return;
      }

      _presentRideOffer(payload, source: 'polling');
    } catch (error, stack) {
      if (_rideOfferPollFailureCount < 5) {
        _rideOfferPollFailureCount++;
      }
      final int retrySeconds = switch (_rideOfferPollFailureCount) {
        1 => 4,
        2 => 8,
        3 => 15,
        _ => 25,
      };
      _nextRideOfferPollAt = DateTime.now().add(Duration(seconds: retrySeconds));
      DriverFlowDebug.send(
        'pending_offer_poll_error',
        data: <String, dynamic>{
          'error': error.toString(),
          'retry_seconds': retrySeconds,
        },
      );
      LogUtils.printError('RIDE OFFER POLLING ERROR: $error, $stack');
    } finally {
      _rideOfferPollInProgress = false;
    }
  }

  void _initializeSocket() {
    _socketService.initSocket(
      url: "wss://ws-ap2.pusher.com/app/bd173a4219b16bb73593?protocol=7&client=flutter&version=1.0&flash=false",
      subscriptionData: {"channel": "drivers.all"},
      reconnectInterval: const Duration(seconds: 5),
      maxReconnectAttempts: -1,
    );
  }

  StreamSubscription? _socketSubscription;

  void _listenToSocket() {
    _socketSubscription?.cancel();
    _socketSubscription = _socketService.onSocketDataListen.listen((event) {
      try {
        if (event != null) {
          final data = jsonDecode(event);

          if (data['event'] == "pusher:connection_established") {
            Constants.socketId = jsonDecode(data['data'])['socket_id'];
          }
          final dynamic decodedPayload = data['data'] is String
              ? jsonDecode(data['data'])
              : data['data'];
          final Map<String, dynamic> payload = decodedPayload is Map
              ? Map<String, dynamic>.from(decodedPayload)
              : <String, dynamic>{};
          final String currentDriverId =
              AppPreference.getString(AppPreference.userId).trim();
          final dynamic payloadBooking = payload['booking'];
          final String targetDriverId =
              (payload['driver_auth_token'] ??
                      payload['driver_id'] ??
                      (payloadBooking is Map
                          ? payloadBooking['driver_id']
                          : null) ??
                      '')
                  .toString()
                  .trim();
          final String eventName = (data['event'] ?? '').toString();
          final String eventStatus =
              (payload['status'] ??
                      (payloadBooking is Map ? payloadBooking['status'] : null) ??
                      '')
                  .toString()
                  .toLowerCase()
                  .trim();
          final bool isPassengerCancellation =
              <String>{
                'user_cancle_booking',
                'user_cancel_booking',
                'booking_cancelled',
                'booking.cancelled',
              }.contains(eventName) ||
              (eventName.toLowerCase().contains('bookingstatuschanged') &&
                  eventStatus == 'cancelled');
          final bool isDriverOnline =
              isOnline.value ||
              AppPreference.getBoolean(AppPreference.driverOnline) ||
              (accountController.userModel.value?.isOnline ?? "0") == "1";

          if (data['event'] == "new.ride.request" &&
              targetDriverId.isNotEmpty &&
              currentDriverId.isNotEmpty &&
              targetDriverId == currentDriverId &&
              isDriverOnline) {
            _presentRideOffer(payload, source: 'socket');
          } else if (isPassengerCancellation &&
              (targetDriverId.isEmpty || targetDriverId == currentDriverId)) {
            clearTerminalRideState(
              reason: 'passenger_cancelled',
              bookingId: payload['booking_id']?.toString() ?? '',
            );
            AppDialog.commonDialog(
              barrierDismiss: false,
              childs: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 159.h,
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: CustomImage(
                            image: ImagesAsset.sadShadow,
                            ht: 60.h,
                            wt: 138.w,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: CustomImage(
                            image: ImagesAsset.sadImage,
                            ht: 139.h,
                            wt: 139.w,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.verticalSpace,
                  CommonText(
                    string: AppString.weAreSadYouHadToCancel.tr,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    textAlign: TextAlign.center,
                  ),
                  8.verticalSpace,
                  CommonText(
                    string: AppString.weWorkExtraToNextRideHappiest.tr,
                    softWrap: true,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    textAlign: TextAlign.center,
                    color: AppColors.textCaptionColor,
                  ),
                  16.verticalSpace,
                  CustomButton(
                    text: AppString.backToHome.tr,
                    onTap: () {
                      Get.back();
                      Navigation.popupUtil(Routes.homeScreen);
                    },
                  ),
                ],
              ),
            );
          } else if (data['event'] == "payment_success" &&
              (jsonDecode(data['data']))['driver_auth_token']?.toString() ==
                  AppPreference.getString(AppPreference.userId)) {
            Constants.transactionId.value = (jsonDecode(
              data['data'],
            ))['transaction_id'];
            Constants.paymentMode.value = (jsonDecode(
              data['data'],
            ))['payment_method'];

            AppDialog.commonDialog(
              barrierDismiss: false,
              childs: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,

                children: [
                  CustomImage(
                    image: IconAsset.checkMarkDone,
                    ht: 154.h,
                    wt: 154.w,
                    fit: BoxFit.cover,
                  ),
                  20.verticalSpace,
                  CommonText(
                    string:
                        "Az utas fizetése sikeresen megtörtént (${Utils.paymentMethodLabel((jsonDecode(data['data']))['payment_method']?.toString())}).",
                    softWrap: true,
                  ),
                  20.verticalSpace,
                  CustomButton(
                    text: AppString.done.tr,
                    onTap: () {
                      if ((jsonDecode(data['data']))['payment_method'] ==
                          "cash") {
                        driverConfirmCashPayment(
                          transactionId: Constants.transactionId.value,
                          status: "completed",
                        );
                      } else {
                        Get.back();
                        Navigation.pushNamed(Routes.reviewScreen);
                        Constants.transactionId.value = "";
                      }
                    },
                  ),
                ],
              ),
            );
          }
        }
      } catch (e, st) {
        debugPrint("SOCKET ERROR ::$e, $st");
      }
    });
  }

  void _listenToConnection() {
    _socketService.connectionStream.listen((connected) {
      isConnected.value = connected;
    });
  }

  @override
  void dispose() {
    _socketService.disconnect();
    FireBaseNotification().removeListner();
    super.dispose();
  }

  RxBool isOnline = false.obs;
  RxBool dutyStatusLoading = false.obs;
  DateTime? _lastDutyHeartbeatAt;
  bool _dutyHeartbeatInProgress = false;

  final accountController = Get.put(AccountController());

  Future<bool> ensureOnlineHeartbeat({
    String reason = 'periodic',
    bool force = false,
  }) async {
    final bool shouldBeOnline = isOnline.value ||
        AppPreference.getBoolean(AppPreference.driverOnline) ||
        (accountController.userModel.value?.isOnline ?? '0') == '1';
    if (!shouldBeOnline || _dutyHeartbeatInProgress) return false;

    final DateTime now = DateTime.now();
    if (!force &&
        _lastDutyHeartbeatAt != null &&
        now.difference(_lastDutyHeartbeatAt!).inSeconds < 25) {
      return true;
    }

    _dutyHeartbeatInProgress = true;
    try {
      LatLng? location = LocationService().currentUserLatLg.value;
      if (location == null) {
        final String stored = AppPreference.getString(AppPreference.location);
        if (stored.contains('@')) {
          final List<String> parts = stored.split('@');
          if (parts.length == 2) {
            final double? lat = double.tryParse(parts.first);
            final double? lng = double.tryParse(parts.last);
            if (lat != null && lng != null) location = LatLng(lat, lng);
          }
        }
      }
      location ??= await LocationService().ensureCurrentLocation();
      if (location == null) {
        DriverFlowDebug.send(
          'driver_online_heartbeat_skipped',
          data: <String, dynamic>{'reason': reason, 'cause': 'no_location'},
        );
        return false;
      }

      final bool success = await userOnlineOffline(
        location,
        onlineOffline: 1,
        silent: true,
        refreshOffers: false,
      );
      if (success) {
        _lastDutyHeartbeatAt = DateTime.now();
        try {
          await updateDriverLocation(location);
        } catch (_) {}
      }
      DriverFlowDebug.send(
        'driver_online_heartbeat',
        data: <String, dynamic>{
          'reason': reason,
          'success': success,
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
      );
      return success;
    } catch (error, stack) {
      DriverFlowDebug.send(
        'driver_online_heartbeat_error',
        data: <String, dynamic>{
          'reason': reason,
          'error': error.toString(),
          'stack': stack.toString(),
        },
      );
      return false;
    } finally {
      _dutyHeartbeatInProgress = false;
    }
  }

  Future<bool> userOnlineOffline(
    LatLng latLng, {
    bool screenRedirect = false,
    required int onlineOffline,
    bool silent = false,
    bool refreshOffers = true,
  }) async {
    if (dutyStatusLoading.value) return false;

    dutyStatusLoading.value = true;
    try {
      final data = await HomeServices.userOnlineOffline(latLng, onlineOffline);
      final dynamic responseData = data is Map ? data['data'] : null;
      final dynamic rawOnline = responseData is Map
          ? responseData['is_online']
          : (data is Map ? data['is_online'] : null);
      final String normalizedOnline = rawOnline?.toString().toLowerCase() ?? '';
      final bool serverSaysOnline = rawOnline == null
          ? onlineOffline == 1
          : rawOnline == true ||
              rawOnline == 1 ||
              normalizedOnline == '1' ||
              normalizedOnline == 'true' ||
              normalizedOnline == 'online';
      final String onlineValue = serverSaysOnline ? '1' : '0';

      isOnline.value = serverSaysOnline;
      await AppPreference.setBoolean(
        AppPreference.driverOnline,
        value: serverSaysOnline,
      );
      accountController.userModel.update((val) {
        val?.isOnline = onlineValue;
      });
      accountController.userModel.refresh();

      // Az online állapotot a sikeres attendance-válasz teszi hitelessé.
      // Nem várunk a /user/profile végpontra, mert annak hibája nem blokkolhatja
      // a munkába állást és a felület állapotváltását.
      update();

      final profile = accountController.userModel.value;
      if (profile != null) {
        AppPreference.setProfileModel(jsonEncode(profile.toJson()));
      }

      if (onlineOffline == 1) {
        if (!silent) {
          AppSnackBar.showErrorSnackBar(
            message: 'Sikeresen munkába álltál.',
          );
        }
        if (refreshOffers) {
          forceRideOfferRefresh(reason: 'went_online');
        }
      } else {
        _lastPresentedOfferId = '';
        _lastPresentedOfferAt = null;
      }

      if (screenRedirect) {
        Navigation.popupUtil(Routes.homeScreen);
      }
      return true;
    } catch (error, stack) {
      LogUtils.printError('ONLINE/OFFLINE ERROR: $error, $stack');
      if (!silent) {
        AppSnackBar.showErrorSnackBar(
          message: onlineOffline == 1
              ? 'Nem sikerült munkába állni. Próbáld újra.'
              : 'Nem sikerült befejezni a műszakot. Próbáld újra.',
          isError: true,
        );
      }
      return false;
    } finally {
      dutyStatusLoading.value = false;
    }
  }

  RxInt rideStatus = 1.obs;
  RxBool isDrawPoliLine = false.obs;

  Future<void> updateDriverLocation(LatLng latLng) async {
    await processApi(
      () => HomeServices.updateDriverLocation(latLng),
      result: (data) {
      },
    );
  }


  Future<bool> updateBookingRideStatus({
    NewRideModel? rideModel,
    required String bookingId,
    required int statusNo,
    String dropAddress = "",
    required LatLng dropLatLng,
    String otp = "",
    String cancelReason = "",
    double totalDistance = 0,
    bool isNotificationTap = false,
    int? etaMinutes,
  }) async {
    DriverFlowDebug.send(
      'status_update_requested',
      bookingId: bookingId,
      data: <String, dynamic>{
        'status_no': statusNo,
        'notification_tap': isNotificationTap,
        'ride_model_present': rideModel != null,
        'ride_status_before': rideStatus.value,
        'current_route': Get.currentRoute,
        'eta_minutes': etaMinutes,
      },
    );

    if (statusNo == 4) {
      rideCompleteModel.value = null;
      Constants.transactionId.value = "";
    }
    bool isdone = false;

    await processApi(
      () => HomeServices.updateBookingRideStatus(
        bookingId: bookingId,
        status: statusNo,
        address: dropAddress,
        latLng: dropLatLng,
        otp: otp,
        cancelReason: cancelReason,
        totalDistance: totalDistance,
        etaMinutes: etaMinutes,
      ),
      result: (data) {
        DriverFlowDebug.send(
          'status_update_success',
          bookingId: bookingId,
          data: <String, dynamic>{
            'status_no': statusNo,
            'response_type': data.runtimeType.toString(),
            'response': data,
          },
        );
        LogUtils.printAction("RIDE STATUS:${statusNo}:${data}");
        isdone = true;

        debugPrint("STATUS :$statusNo:::${data}");
        statusData(
          statusNo: statusNo,
          bookingId: bookingId,
          data: data,
          notificationTap: isNotificationTap,
          newRideModel: rideModel,
          etaMinutes: etaMinutes,
        );
      },
      error: (error, stack) {
        DriverFlowDebug.send(
          'status_update_error',
          bookingId: bookingId,
          data: <String, dynamic>{
            'status_no': statusNo,
            'error': error.toString(),
            'stack': stack.toString(),
          },
        );
        LogUtils.printError("STATUS UPDATE ERROR::$error, $stack");
        if (statusNo == 1) {
          final String text = error.toString().toLowerCase();
          if (text.contains('booking_already_taken') ||
              text.contains('másik sofőr') ||
              text.contains('masik sofor') ||
              text.contains('409')) {
            AppSnackBar.showErrorSnackBar(
              message: 'A címet másik sofőr felvette.',
              isError: true,
              dismisDuration: 4,
            );
            clearTerminalRideState(
              reason: 'offer_taken_by_another_driver',
              bookingId: bookingId,
            );
          }
        }
      },
      loading: handleLoading,
    );

    return isdone;
  }

  void statusData({
    required int statusNo,
    required String bookingId,
    dynamic data,
    bool redirectProfile = false,
    bool notificationTap = false,
    bool profileCome = false,
    NewRideModel? newRideModel,
    int? etaMinutes,
  }) {
    if (profileCome) {
      LocationService().checkBackGroundPermission();
    }
    if (statusNo == 1) {
      if (profileCome == false) {
        rideDataModel.value = newRideModel;
      }
      rideDataModel.value?.booking?.status = 'accepted';
      final int acceptedEta = etaMinutes ?? selectedArrivalEtaMinutes.value;
      if (acceptedEta > 0) {
        rideDataModel.value?.driverEtaMinutes = acceptedEta;
        rideDataModel.value?.driverExpectedArrivalAt =
            DateTime.now().add(Duration(minutes: acceptedEta)).toIso8601String();
        rideDataModel.value?.booking?.driverEtaMinutes = acceptedEta.toString();
        rideDataModel.value?.booking?.driverExpectedArrivalAt =
            rideDataModel.value?.driverExpectedArrivalAt;
      }
      accountController.userModel.update((value) {
        value?.currentBookingId = bookingId;
      });
      accountController.userModel.refresh();
      rideDataModel.refresh();
      AppPreference.removeKey(AppPreference.driverRideTime);
      isRideAvailable.value = -1;

      // The navigation screen must receive the accepted ride state before it
      // is created. This also removes a race where the map could initialize
      // with stale route data.
      rideStatus.value = 1;
      Constants.bookingId = bookingId;
      isDrawPoliLine.value = false;
      update();

      DriverFlowDebug.send(
        'accept_state_prepared',
        bookingId: bookingId,
        data: <String, dynamic>{
          'ride_model_present': rideDataModel.value != null,
          'ride_status': rideStatus.value,
          'notification_tap': notificationTap,
          'pickup_lat': rideDataModel.value?.pickup?.latitude ?? '',
          'pickup_lng': rideDataModel.value?.pickup?.longitude ?? '',
          'dropoff_lat': rideDataModel.value?.dropoff?.latitude ?? '',
          'dropoff_lng': rideDataModel.value?.dropoff?.longitude ?? '',
        },
      );

      if (notificationTap) {
        handleLoading(false);
        Get.back();
      }

      DriverFlowDebug.send(
        'navigation_push_requested',
        bookingId: bookingId,
        data: <String, dynamic>{'target_route': Routes.mapNavigationScreen},
      );
      final Future<dynamic> navigationFuture =
          Navigation.pushNamed(Routes.mapNavigationScreen);
      DriverFlowDebug.send(
        'navigation_push_dispatched',
        bookingId: bookingId,
        data: <String, dynamic>{'current_route': Get.currentRoute},
      );
      unawaited(
        navigationFuture.then((dynamic result) {
          DriverFlowDebug.send(
            'navigation_screen_returned',
            bookingId: bookingId,
            data: <String, dynamic>{'result': result},
          );
        }),
      );
    } else if (statusNo == 2) {
      getRideTimer1(
        int.parse(
          rideDataModel.value?.booking?.rideType?.waitingTimeLimit ?? "1",
        ),
      );
      rideDataModel.value?.booking?.status = 'arrived';
      rideDataModel.refresh();
      rideStatus.value = 2;
      isDrawPoliLine.value = false;
    } else if (statusNo == 3) {
      rideDataModel.value?.booking?.status = 'started';
      rideDataModel.refresh();
      rideStatus.value = 3;
      isDrawPoliLine.value = false;
      AppPreference.removeKey(AppPreference.driverRideTime);
    } else if (statusNo == 4) {
      rideCompleteModel.value = RideCompleteModel.fromJson(data);
      rideDataModel.value?.booking?.status = 'completed';
      rideDataModel.refresh();
      timer?.cancel();
      timer1?.cancel();
      rideStatus.value = 4;
      isDrawPoliLine.value = false;
      isRideAvailable.value = -1;
      Constants.bookingId = bookingId;
      accountController.userModel.update((value) {
        value?.currentBookingId = bookingId;
      });
      accountController.userModel.refresh();
      DriverFlowDebug.send(
        'trip_completed_waiting_for_payment',
        bookingId: bookingId,
        data: <String, dynamic>{
          'payment_status': rideCompleteModel.value?.booking?.paymentStatus ?? '',
          'payment_method': rideCompleteModel.value?.booking?.paymentMethod ?? '',
        },
      );
      update();
      if (Get.currentRoute != Routes.cashCollectScreen) {
        Navigation.pushNamed(Routes.cashCollectScreen);
      }
    } else if (statusNo == 5) {
      clearTerminalRideState(
        reason: 'booking_cancelled',
        bookingId: bookingId,
      );
      Navigation.replaceAll(Routes.homeScreen);
    }
  }

  Rxn<RideCompleteModel> rideCompleteModel = Rxn<RideCompleteModel>();

  String? placeApi = Platform.isAndroid
      ? dotenv.env['GOOGLE_MAPS_API_KEY_Android']
      : dotenv.env['GOOGLE_MAPS_API_KEY_Ios'];

  String _bookingStatusFromResponse(dynamic response) {
    if (response is! Map) return '';
    final dynamic data = response['data'];
    final dynamic booking = response['booking'] ??
        (data is Map ? data['booking'] ?? data : null);
    if (booking is Map) {
      return (booking['status'] ?? '').toString().toLowerCase().trim();
    }
    return (response['status'] ?? '').toString().toLowerCase().trim();
  }

  Future<bool> verifyCustomerOtpAndStartTrip({
    required String bookingId,
    required String otp,
    required LatLng dropLatLng,
    required String dropAddress,
  }) async {
    if (bookingId.trim().isEmpty || otp.trim().length != 6) {
      AppSnackBar.showErrorSnackBar(
        message: 'Adj meg egy érvényes, 6 számjegyű utazási kódot.',
        isError: true,
      );
      return false;
    }

    handleLoading(true);
    try {
      final dynamic verifyResponse = await HomeServices.customerOtpVerify(
        bookingId: bookingId,
        otp: otp.trim(),
      );
      final String verifiedStatus = _bookingStatusFromResponse(verifyResponse);
      DriverFlowDebug.send(
        'otp_verify_success',
        bookingId: bookingId,
        data: <String, dynamic>{
          'booking_status': verifiedStatus,
          'response_type': verifyResponse.runtimeType.toString(),
        },
      );

      if (const <String>{'started', 'in_progress', 'ongoing'}
          .contains(verifiedStatus)) {
        statusData(statusNo: 3, bookingId: bookingId, data: verifyResponse);
        return true;
      }

      final dynamic startResponse = await HomeServices.updateBookingRideStatus(
        bookingId: bookingId,
        status: 3,
        address: dropAddress,
        latLng: dropLatLng,
        // A kódot a match-otp végpont már hitelesítette. A státuszváltásnál
        // ezért nem küldjük újra, így nem fut bele a régi hibás OTP-validációba.
        otp: '',
        cancelReason: '',
        totalDistance: 0,
      );
      statusData(statusNo: 3, bookingId: bookingId, data: startResponse);
      DriverFlowDebug.send(
        'trip_started_after_otp_verify',
        bookingId: bookingId,
        data: <String, dynamic>{
          'response_status': _bookingStatusFromResponse(startResponse),
        },
      );
      return true;
    } catch (error, stack) {
      DriverFlowDebug.send(
        'otp_verify_or_start_failed',
        bookingId: bookingId,
        data: <String, dynamic>{
          'error': error.toString(),
          'stack': stack.toString(),
        },
      );
      AppSnackBar.showErrorSnackBar(
        message: 'A kód nem fogadható el. Ellenőrizd az utasnál látható 6 számjegyet.',
        isError: true,
      );
      return false;
    } finally {
      handleLoading(false);
    }
  }

  Future<bool> driverReviewAdd({
    required int bookingId,
    required double rating,
    required String comment,
  }) async {
    bool success = false;
    await processApi(
      () => HomeServices.driverReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      ),
      result: (data) {
        success = true;
        DriverFlowDebug.send(
          'customer_review_submitted',
          bookingId: bookingId.toString(),
          data: <String, dynamic>{'rating': rating},
        );
        finishPostRideFlow(reason: 'customer_review_submitted');
      },
      error: (error, stack) {
        DriverFlowDebug.send(
          'customer_review_failed',
          bookingId: bookingId.toString(),
          data: <String, dynamic>{
            'error': error.toString(),
            'stack': stack.toString(),
          },
        );
        AppSnackBar.showErrorSnackBar(
          message: 'Az utas értékelése nem menthető. Próbáld újra.',
          isError: true,
        );
      },
      loading: handleLoading,
    );
    return success;
  }

  void finishPostRideFlow({required String reason}) {
    final bookingId = rideCompleteModel.value?.booking?.id ?? '';
    DriverFlowDebug.send(
      'post_ride_flow_finished',
      bookingId: bookingId,
      data: <String, dynamic>{'reason': reason},
    );
    rideCompleteModel.value = null;
    Constants.transactionId.value = '';
    isRideAvailable.value = -1;
    forceRideOfferRefresh(reason: reason);
    Navigation.replaceAll(Routes.homeScreen);
  }

  Future<void> driverPaymentAccept({
    required double amount,
    required int id,
  }) async {
    processApi(
      () => HomeServices.driverAcceptPayment(amount: amount, paymentId: id),
      result: (data) {
        Navigation.pushNamed(Routes.reviewScreen);
      },
      loading: handleLoading,
    );
  }

  RxInt waitingTime = 0.obs;
  Timer? timer1;
  Future<void> getSetting()async{
    try{

      final response =await http.get(Uri.parse(ApiConstants.baseUrl+ApiConstants.setting));
      if(response.statusCode ==200){
        var data = jsonDecode(response.body);
        Constants().iosLink= data['data']['appleShareLink']??"";
        Constants().androidLink= data['data']['androidShareLink']??"";
        Constants().appStoreId= data['data']['appstoreId']??"";
        Constants().currency= data['data']['currency']??"";

      }

    }catch(e){

    }
  }

  void getRideTimer1(int time) {
    String lastTime = AppPreference.getString(AppPreference.driverRideTime);
    int diffSeconds = 0;

    if (lastTime.isNotEmpty) {
      Map getData = jsonDecode(lastTime);
      if (getData['bookingId'] == "${rideDataModel.value?.booking?.id}") {
        DateTime lastshowTime = DateTime.fromMillisecondsSinceEpoch(
          getData['time'],
        );
        ;
        DateTime now = DateTime.now();
        diffSeconds = now.difference(lastshowTime).inSeconds;
      }
    }

    if (diffSeconds > time * 60) {
      waitingTime.value = 0;
    } else {
      waitingTime.value = (time * 60) - diffSeconds;
      if (lastTime.isEmpty) {
        AppPreference.setString(
          AppPreference.driverRideTime,
          jsonEncode({
            'bookingId': "${rideDataModel.value?.booking?.id}",
            'time': DateTime.now().millisecondsSinceEpoch,
          }),
        );
      }
    }

    if (timer1?.isActive ?? false) timer1?.cancel();
    timer1 = Timer.periodic(Duration(seconds: 1), (timer) {
      if (waitingTime.value > 0) {
        waitingTime.value--;
      } else {
        timer.cancel();
        this.timer1?.cancel();
        AppPreference.removeKey(AppPreference.driverRideTime);
      }
    });
  }

  Future<Map> reportSubmit({
    required int bookingId,
    required int selected,
    required String description,
  }) async {
    List<String> issueList = [
      "rider_didnt_show_up",
      "wrong_pickup",
      "rider_delayed",
      "traffic_issue",
      "navigation_problem",
      "custom",
    ];

    String issueType = "";
    if (selected == -1) {
      issueType = issueList.last;
    } else {
      issueType = issueList[selected];
    }

    Map res = {};
    await processApi(
      () => HomeServices.reportIssueSubmit(
        bookingId: bookingId,
        description: description,
        issueType: issueType,
      ),
      result: (data) {
        res = data;
      },
      loading: handleLoading,
    );

    return res;
  }

  Future<bool> confirmPaymentCollected({
    required String bookingId,
    required double cashAmount,
    required double tipAmount,
  }) async {
    if (bookingId.trim().isEmpty) {
      AppSnackBar.showErrorSnackBar(
        message: 'A fuvar azonosítója hiányzik.',
        isError: true,
      );
      return false;
    }

    bool success = false;
    await processApi(
      () => HomeServices.confirmCashCollected(
        bookingId: bookingId.trim(),
        cashAmount: cashAmount,
        tipAmount: tipAmount,
      ),
      result: (data) {
        final dynamic payload = data is Map ? data['data'] : null;
        final String paymentStatus = (
          payload is Map
              ? payload['payment_status']
              : data is Map
                  ? data['payment_status']
                  : ''
        )
            .toString()
            .toLowerCase()
            .trim();

        if (paymentStatus != 'paid') {
          AppSnackBar.showErrorSnackBar(
            message:
                'A backend nem állította fizetettre a rendelést. Telepítsd a készpénzes fizetési patchet.',
            isError: true,
          );
          return;
        }

        success = true;
        final booking = rideCompleteModel.value?.booking;
        if (booking != null) {
          booking.paymentStatus = 'paid';
          booking.paymentMethod = 'cash';
          booking.cashAmount = cashAmount.toStringAsFixed(2);
          rideCompleteModel.refresh();
        }
        DriverFlowDebug.send(
          'cash_payment_marked_paid',
          bookingId: bookingId,
          data: <String, dynamic>{
            'cash_amount': cashAmount,
            'tip_amount': tipAmount,
            'payment_status': paymentStatus,
          },
        );
        AppSnackBar.showErrorSnackBar(
          message: 'A készpénzes fizetés rögzítve.',
        );
        clearTerminalRideState(
          reason: 'cash_payment_paid',
          bookingId: bookingId,
          refreshOffers: false,
        );
        Navigation.replaceAll(Routes.reviewScreen);
      },
      error: (error, stack) {
        DriverFlowDebug.send(
          'cash_payment_mark_paid_failed',
          bookingId: bookingId,
          data: <String, dynamic>{
            'error': error.toString(),
            'stack': stack.toString(),
          },
        );
        AppSnackBar.showErrorSnackBar(
          message: 'A készpénzes fizetés nem rögzíthető. Próbáld újra.',
          isError: true,
        );
      },
      loading: handleLoading,
    );
    return success;
  }

  Future<Map> driverConfirmCashPayment({
    required String transactionId,
    required String status,
  }) async {
    Map res = {};
    await processApi(
      () => HomeServices.driverConfirmCashPayment(
        transactionId: transactionId,
        status: status,
      ),
      result: (data) {
        res = data;
        Get.back();
        Navigation.pushNamed(Routes.reviewScreen);
        Constants.transactionId.value = "";
        forceRideOfferRefresh(reason: 'cash_payment_confirmed');
      },
      loading: handleLoading,
    );
    return res;
  }

  RxList<rideType.RideType> rideTypeList = <rideType.RideType>[].obs;

  Future<void> getRideTypeList() async {
    final dbData = AppPreference.getString(AppPreference.driverRideType);
    if (dbData.isNotEmpty) {
      rideTypeList.value =
          rideType.RideTypeListModel.fromJson(
            jsonDecode(dbData),
          ).data?.rideTypes ??
          [];
    }
    processApi(
      () => HomeServices.getRideTypeList(),
      result: (data) {
        rideTypeList.value = data.data?.rideTypes ?? [];
        AppPreference.setString(
          AppPreference.driverRideType,
          jsonEncode(data.toJson()),
        );
      },
    );
  }
}
