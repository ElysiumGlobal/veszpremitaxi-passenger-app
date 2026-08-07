import 'dart:async';
import 'dart:convert';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/feature/home/model/chat_model.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ChatUnreadBadge extends StatefulWidget {
  const ChatUnreadBadge({
    required this.bookingId,
    required this.child,
    super.key,
  });

  final String bookingId;
  final Widget child;

  @override
  State<ChatUnreadBadge> createState() => _ChatUnreadBadgeState();
}

class _ChatUnreadBadgeState extends State<ChatUnreadBadge> {
  final Object _subscriptionToken = Object();

  _SharedChatUnreadPoller? _poller;
  String _ownerRoute = '';
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _ownerRoute = Get.currentRoute;
    _attachToBooking(widget.bookingId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = (ModalRoute.of(context)?.settings.name ?? '').trim();
    final routeName = modalRoute.isNotEmpty
        ? modalRoute
        : Get.currentRoute.trim();
    if (routeName.isEmpty || routeName == _ownerRoute) return;

    _ownerRoute = routeName;
    _poller?.updateSubscriberRoute(_subscriptionToken, _ownerRoute);
  }

  @override
  void didUpdateWidget(covariant ChatUnreadBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookingId.trim() != widget.bookingId.trim()) {
      _detachFromBooking();
      _attachToBooking(widget.bookingId);
    }
  }

  void _attachToBooking(String rawBookingId) {
    final bookingId = rawBookingId.trim();
    if (bookingId.isEmpty) {
      _unreadCount = 0;
      return;
    }

    final poller = _SharedChatUnreadPoller.acquire(bookingId);
    _poller = poller;
    _unreadCount = poller.unreadCount;
    poller.addListener(_handleUnreadCountChanged);
    poller.registerSubscriber(_subscriptionToken, _ownerRoute);
  }

  void _detachFromBooking() {
    final poller = _poller;
    if (poller == null) return;

    poller.removeListener(_handleUnreadCountChanged);
    poller.unregisterSubscriber(_subscriptionToken);
    _poller = null;
  }

  void _handleUnreadCountChanged() {
    final nextValue = _poller?.unreadCount ?? 0;
    if (!mounted || nextValue == _unreadCount) return;
    setState(() => _unreadCount = nextValue);
  }

  @override
  void dispose() {
    _detachFromBooking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        widget.child,
        if (_unreadCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: IgnorePointer(
              child: Container(
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                alignment: Alignment.center,
                child: Text(
                  _unreadCount > 3 ? '3+' : '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SharedChatUnreadPoller extends ChangeNotifier
    with WidgetsBindingObserver {
  _SharedChatUnreadPoller._(this.bookingId) {
    WidgetsBinding.instance.addObserver(this);
    _pollTimer = Timer.periodic(
      _pollInterval,
      (_) => unawaited(_refreshUnreadCount()),
    );
  }

  static const Duration _pollInterval = Duration(seconds: 4);
  static final Map<String, _SharedChatUnreadPoller> _instances =
      <String, _SharedChatUnreadPoller>{};

  static _SharedChatUnreadPoller acquire(String bookingId) {
    return _instances.putIfAbsent(
      bookingId,
      () => _SharedChatUnreadPoller._(bookingId),
    );
  }

  final String bookingId;
  final Map<Object, String> _subscriberRoutes = <Object, String>{};

  Timer? _pollTimer;
  bool _isForeground = true;
  bool _isPolling = false;
  bool _isDisposed = false;
  bool _hasLoadedInitialCount = false;
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  void registerSubscriber(Object token, String ownerRoute) {
    if (_isDisposed) return;
    _subscriberRoutes[token] = ownerRoute;
    unawaited(_refreshUnreadCount());
  }

  void updateSubscriberRoute(Object token, String ownerRoute) {
    if (_isDisposed || !_subscriberRoutes.containsKey(token)) return;
    _subscriberRoutes[token] = ownerRoute;
    unawaited(_refreshUnreadCount());
  }

  void unregisterSubscriber(Object token) {
    if (_isDisposed) return;
    _subscriberRoutes.remove(token);
    if (_subscriberRoutes.isEmpty) {
      _disposePoller();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    if (_isForeground) {
      unawaited(_refreshUnreadCount());
    }
  }

  bool get _hasVisibleSubscriber {
    final currentRoute = Get.currentRoute.trim();
    if (currentRoute.isEmpty) return false;
    return _subscriberRoutes.values.contains(currentRoute);
  }

  Future<void> _refreshUnreadCount() async {
    if (_isDisposed ||
        bookingId.isEmpty ||
        !_isForeground ||
        !_hasVisibleSubscriber ||
        _isPolling) {
      return;
    }

    _isPolling = true;
    try {
      final response = await Api().get(
        '${ApiConstants.getChatHistory}$bookingId',
      );
      if (_isDisposed || response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return;
      final model = ChatListModel.fromJson(Map<String, dynamic>.from(decoded));
      final count = (model.chats ?? <Chat>[])
          .where((chat) => chat.isFromMe != true && chat.isRead != true)
          .length;
      _setUnreadCount(count);
    } catch (_) {
      // A jelzés hibája nem akadályozhatja a fuvar vagy a chat használatát.
    } finally {
      if (!_isDisposed) _isPolling = false;
    }
  }

  void _setUnreadCount(int value) {
    if (_isDisposed) return;
    final shouldAlert = _hasLoadedInitialCount && value > _unreadCount;
    _hasLoadedInitialCount = true;
    if (_unreadCount == value) return;

    _unreadCount = value;
    notifyListeners();
    if (shouldAlert) {
      unawaited(SystemSound.play(SystemSoundType.alert));
      unawaited(HapticFeedback.mediumImpact());
    }
  }

  void _disposePoller() {
    if (_isDisposed) return;
    _isDisposed = true;
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (identical(_instances[bookingId], this)) {
      _instances.remove(bookingId);
    }
    super.dispose();
  }
}
