import 'dart:async';

import 'package:e_taxi/core/debug/driver_flow_debug.dart';
import 'package:e_taxi/core/service/location_utils.dart';
import 'package:e_taxi/core/service/socket_channel.dart';
import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/feature/home/model/new_ride_model.dart';
import 'package:e_taxi/feature/home/pages/drawer.dart';
import 'package:e_taxi/feature/home/widget/arrival_eta_selector.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Ezeket a navigációs és profil-visszaállítási folyamat több meglévő képernyő
// közvetlenül használja, ezért globálisak maradnak.
Rxn<NewRideModel> rideDataModel = Rxn<NewRideModel>();
NewRideModel rideDataTempModel = NewRideModel();

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AccountController accountController = Get.find<AccountController>();
  final HomeController homeController = Get.find<HomeController>();

  StreamSubscription<LatLng?>? _locationSubscription;
  Timer? _heartbeatTimer;
  LatLng? _currentLocation;
  bool _dutyActionInProgress = false;
  DateTime? _lastLocationUploadAt;

  bool get _shouldBeOnline =>
      homeController.isOnline.value ||
      AppPreference.getBoolean(AppPreference.driverOnline);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    homeController.isOnline.value =
        AppPreference.getBoolean(AppPreference.driverOnline);
    unawaited(_initializeDriverSession());
  }

  Future<void> _initializeDriverSession() async {
    DriverFlowDebug.send(
      'driver_dashboard_initializing',
      data: <String, dynamic>{
        'stored_online': AppPreference.getBoolean(AppPreference.driverOnline),
        'orientation': 'adaptive',
      },
    );

    try {
      await LocationService().initialize(isopenSetting: true, contiCheck: true);
      _currentLocation = LocationService().currentUserLatLg.value;
    } catch (error, stack) {
      DriverFlowDebug.runtimeError('driver_location_init', error, stack);
    }

    _locationSubscription = LocationService().currentUserLatLg.listen(
      (LatLng? location) {
        if (location == null) return;
        _currentLocation = location;
        if (mounted) setState(() {});
        unawaited(_uploadLocationIfNeeded(location));
      },
    );

    // A profilhiba nem akadályozhatja az ajánlatfigyelést. A lokálisan mentett
    // szolgálati állapot azonnal érvényes, a szerver-helyreállítás külön fut.
    unawaited(_loadProfileSafely());

    if (_shouldBeOnline) {
      await homeController.ensureOnlineHeartbeat(
        reason: 'dashboard_start',
        force: true,
      );
      homeController.forceRideOfferRefresh(reason: 'dashboard_start');
    }

    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!_shouldBeOnline) return;
      unawaited(
        homeController.ensureOnlineHeartbeat(reason: 'dashboard_periodic'),
      );
      final LatLng? location = _currentLocation;
      if (location != null) unawaited(_uploadLocationIfNeeded(location));
    });
  }

  Future<void> _loadProfileSafely() async {
    try {
      await accountController.getUserData(
        checkDocument: true,
        rideRedirect: true,
      );
    } catch (error, stack) {
      // A profil válasza kiegészítő adat. Egy ideiglenes 500-as hiba nem
      // állíthatja le az online heartbeatet és a fuvarajánlatok figyelését.
      DriverFlowDebug.runtimeError('driver_profile_bootstrap', error, stack);
    }
  }

  Future<void> _uploadLocationIfNeeded(LatLng location) async {
    if (!_shouldBeOnline) return;
    final DateTime now = DateTime.now();
    if (_lastLocationUploadAt != null &&
        now.difference(_lastLocationUploadAt!).inSeconds < 15) {
      return;
    }
    _lastLocationUploadAt = now;
    try {
      await homeController.updateDriverLocation(location);
    } catch (error, stack) {
      DriverFlowDebug.runtimeError('driver_location_heartbeat', error, stack);
    }
  }

  Future<LatLng?> _resolveLocation() async {
    LatLng? location = _currentLocation ??
        LocationService().currentUserLatLg.value;
    if (location != null) return location;

    final String stored = AppPreference.getString(AppPreference.location);
    if (stored.contains('@')) {
      final List<String> parts = stored.split('@');
      if (parts.length == 2) {
        final double? lat = double.tryParse(parts.first);
        final double? lng = double.tryParse(parts.last);
        if (lat != null && lng != null) {
          location = LatLng(lat, lng);
        }
      }
    }
    location ??= await LocationService().ensureCurrentLocation();
    _currentLocation = location;
    return location;
  }

  Future<void> _setDuty(bool online) async {
    if (_dutyActionInProgress || homeController.dutyStatusLoading.value) return;
    setState(() => _dutyActionInProgress = true);
    try {
      final LatLng? location = await _resolveLocation();
      if (location == null) return;
      final bool success = await homeController.userOnlineOffline(
        location,
        onlineOffline: online ? 1 : 0,
      );
      if (!success) return;
      homeController.isOnline.value = online;
      await AppPreference.setBoolean(
        AppPreference.driverOnline,
        value: online,
      );
      if (online) {
        await _uploadLocationIfNeeded(location);
        homeController.forceRideOfferRefresh(reason: 'manual_duty_start');
      }
      if (mounted) setState(() {});
    } finally {
      if (mounted) setState(() => _dutyActionInProgress = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    DriverFlowDebug.send(
      'driver_dashboard_lifecycle',
      data: <String, dynamic>{
        'state': state.name,
        'stored_online': AppPreference.getBoolean(AppPreference.driverOnline),
      },
    );
    if (state != AppLifecycleState.resumed) return;

    SocketChannelService().ensureConnected();
    unawaited(LocationService().initialize(contiCheck: true));
    if (_shouldBeOnline) {
      unawaited(
        homeController.ensureOnlineHeartbeat(
          reason: 'dashboard_resumed',
          force: true,
        ),
      );
    }
    homeController.onResumed();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    _heartbeatTimer?.cancel();
    // A singleton GPS-szolgáltatást itt nem állítjuk le: egy route-váltás vagy
    // háttérbe helyezés nem kapcsolhatja ki a szolgálatban lévő sofőrt.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerScreen(),
      backgroundColor: const Color(0xFF061225),
      body: SafeArea(
        child: Obx(() {
          final bool online = _shouldBeOnline;
          return Stack(
            children: <Widget>[
              Positioned.fill(child: _buildDashboard(online)),
              _buildTopBar(online),
              if (homeController.isRideAvailable.value == 1)
                _buildOfferOverlay(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTopBar(bool online) {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Row(
        children: <Widget>[
          IconButton.filledTonal(
            tooltip: 'Menü',
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu_rounded),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: online
                  ? const Color(0xFF123B2D)
                  : const Color(0xFF3A2630),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: online
                    ? const Color(0xFF55D69A)
                    : const Color(0xFFFF9AAE),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  online ? Icons.circle : Icons.circle_outlined,
                  size: 12,
                  color: online
                      ? const Color(0xFF55D69A)
                      : const Color(0xFFFF9AAE),
                ),
                const SizedBox(width: 8),
                Text(
                  online ? 'SZOLGÁLATBAN' : 'NINCS SZOLGÁLATBAN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(bool online) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= 760;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFF061225),
                Color(0xFF102A4B),
                Color(0xFF040A14),
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              wide ? 36 : 20,
              84,
              wide ? 36 : 20,
              28,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(flex: 5, child: _buildPrimaryCard(online)),
                          const SizedBox(width: 24),
                          Expanded(flex: 4, child: _buildStatusCard(online)),
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          _buildPrimaryCard(online),
                          const SizedBox(height: 18),
                          _buildStatusCard(online),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrimaryCard(bool online) {
    return _glassCard(
      child: Column(
        children: <Widget>[
          Container(
            width: 112,
            height: 112,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .08),
              border: Border.all(
                color: AppColors.mainPrimaryColor.withValues(alpha: .7),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/vap_driver_logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            online ? 'Fuvarra vársz' : 'Készen állsz a műszakra?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            online
                ? 'Az ajánlatfigyelés aktív. Az alkalmazás háttérből visszatérve is helyreállítja a szolgálati állapotot.'
                : 'Kapcsold be az elérhetőséged. A rendszer ezután figyeli a beérkező fuvarokat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .72),
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _dutyActionInProgress
                  ? null
                  : () => _setDuty(!online),
              style: FilledButton.styleFrom(
                backgroundColor: online
                    ? const Color(0xFF812F3D)
                    : AppColors.mainPrimaryColor,
                foregroundColor: online ? Colors.white : const Color(0xFF061225),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: _dutyActionInProgress
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(online ? Icons.stop_circle : Icons.local_taxi),
              label: Text(
                online ? 'Műszak befejezése' : 'Munkába állok',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool online) {
    final LatLng? location = _currentLocation;
    final String locationLabel = location == null
        ? 'GPS-pozíció keresése…'
        : '${location.latitude.toStringAsFixed(5)}, '
            '${location.longitude.toStringAsFixed(5)}';
    final String driverName =
        (accountController.userModel.value?.name ?? 'Veszprémi Taxi sofőr')
            .trim();

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            driverName.isEmpty ? 'Veszprémi Taxi sofőr' : driverName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          _statusRow(
            icon: Icons.gps_fixed_rounded,
            title: 'GPS-helyzet',
            value: locationLabel,
            healthy: location != null,
          ),
          const SizedBox(height: 12),
          _statusRow(
            icon: Icons.notifications_active_rounded,
            title: 'Ajánlatfigyelés',
            value: online ? 'Aktív, 3 másodperces tartalék lekéréssel' : 'Kikapcsolva',
            healthy: online,
          ),
          const SizedBox(height: 12),
          _statusRow(
            icon: Icons.sync_rounded,
            title: 'Háttér-helyreállítás',
            value: online ? 'Automatikus' : 'Szolgálat indításakor aktiválódik',
            healthy: online,
          ),
          if (online) ...<Widget>[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await homeController.ensureOnlineHeartbeat(
                    reason: 'manual_refresh',
                    force: true,
                  );
                  homeController.forceRideOfferRefresh(
                    reason: 'manual_refresh',
                  );
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Kapcsolat és ajánlatok frissítése',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusRow({
    required IconData icon,
    required String title,
    required String value,
    required bool healthy,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: healthy ? const Color(0xFF55D69A) : Colors.white54,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .68),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            healthy ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: healthy ? const Color(0xFF55D69A) : Colors.white38,
          ),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .075),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .13)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: .2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildOfferOverlay() {
    final NewRideModel data = rideDataTempModel;
    final String bookingId = (data.bookingId ?? '').toString().trim();
    if (bookingId.isEmpty) return const SizedBox.shrink();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.markOfferUiRendered(bookingId);
    });

    final String pickup = (data.pickup?.address ?? '').trim();
    final String dropoff = (data.dropoff?.address ?? '').trim();
    final String distance = Utils.formatDistance(data.tripDetails?.distance);
    final String duration = Utils.formatDuration(data.tripDetails?.duration);
    final String distanceToPickup = _distanceToPickupLabel(data);

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: .76),
        child: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 760;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: wide ? 760 : 560),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 30,
                            offset: Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.mainPrimaryColor
                                      .withValues(alpha: .18),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.local_taxi_rounded,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Új fuvarajánlat',
                                      style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text('Válassz érkezési időt, majd fogadd el.'),
                                  ],
                                ),
                              ),
                              Obx(
                                () => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE38A),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${homeController.rideTimerSec.value} mp',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _addressBlock(
                            icon: Icons.my_location_rounded,
                            title: 'Felvételi cím',
                            address: pickup,
                            color: const Color(0xFF1E8C63),
                          ),
                          const SizedBox(height: 12),
                          _addressBlock(
                            icon: Icons.flag_rounded,
                            title: 'Célállomás',
                            address: dropoff,
                            color: const Color(0xFF294D88),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: <Widget>[
                              _offerMetric(Icons.near_me_rounded, distanceToPickup),
                              _offerMetric(Icons.route_rounded, distance),
                              _offerMetric(Icons.schedule_rounded, duration),
                              _offerMetric(
                                Icons.star_rounded,
                                '${data.customer?.customerRating ?? '0'}',
                              ),
                            ],
                          ),
                          ArrivalEtaSelector(
                            selectedMinutes:
                                homeController.selectedArrivalEtaMinutes,
                            compact: wide,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      homeController.dismissVisibleRideOffer(
                                    bookingId: bookingId,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(54),
                                  ),
                                  child: const Text(
                                    'Most nem',
                                    style: TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Listener(
                                  behavior: HitTestBehavior.opaque,
                                  onPointerDown: (_) => homeController
                                      .markOfferPointerDown(bookingId),
                                  child: FilledButton.icon(
                                    onPressed: homeController.offerAcceptInFlight
                                        ? null
                                        : () => homeController
                                            .acceptVisibleRideOffer(data),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(54),
                                      backgroundColor:
                                          AppColors.mainPrimaryColor,
                                      foregroundColor: const Color(0xFF061225),
                                    ),
                                    icon: const Icon(Icons.check_circle_rounded),
                                    label: Text(
                                      homeController.offerAcceptInFlight
                                          ? 'Elfogadás…'
                                          : 'Fuvar elfogadása',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _addressBlock({
    required IconData icon,
    required String title,
    required String address,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: .24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  address.isEmpty ? 'Cím betöltése…' : address,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _offerMetric(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 17, color: const Color(0xFF294D88)),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  String _distanceToPickupLabel(NewRideModel data) {
    final LatLng? current = _currentLocation;
    final double? pickupLat = double.tryParse(data.pickup?.latitude ?? '');
    final double? pickupLng = double.tryParse(data.pickup?.longitude ?? '');
    if (current == null || pickupLat == null || pickupLng == null) {
      return 'Távolság számítása…';
    }
    final double distanceKm = Geolocator.distanceBetween(
          current.latitude,
          current.longitude,
          pickupLat,
          pickupLng,
        ) /
        1000;
    final int etaMinutes =
        ((distanceKm / 28) * 60).ceil().clamp(1, 999).toInt();
    return '${distanceKm.toStringAsFixed(1)} km · kb. $etaMinutes perc';
  }
}
