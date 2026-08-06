import 'dart:async';
import 'dart:convert';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/feature/home/model/chat_model.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:flutter/material.dart';
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

class _ChatUnreadBadgeState extends State<ChatUnreadBadge>
    with WidgetsBindingObserver {
  static const Duration _pollInterval = Duration(seconds: 4);

  Timer? _pollTimer;
  late final String _ownerRoute;
  bool _isForeground = true;
  bool _isPolling = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ownerRoute = Get.currentRoute;
    unawaited(_refreshUnreadCount());
    _pollTimer = Timer.periodic(
      _pollInterval,
      (_) => unawaited(_refreshUnreadCount()),
    );
  }

  @override
  void didUpdateWidget(covariant ChatUnreadBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookingId.trim() != widget.bookingId.trim()) {
      _setUnreadCount(0);
      unawaited(_refreshUnreadCount());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    if (_isForeground) {
      unawaited(_refreshUnreadCount());
    }
  }

  Future<void> _refreshUnreadCount() async {
    final String bookingId = widget.bookingId.trim();
    if (bookingId.isEmpty) {
      _setUnreadCount(0);
      return;
    }
    if (!_isForeground || Get.currentRoute != _ownerRoute || _isPolling) {
      return;
    }

    _isPolling = true;
    try {
      final response = await Api().get(
        '${ApiConstants.getChatHistory}$bookingId',
      );
      if (!mounted || bookingId != widget.bookingId.trim()) return;
      if (response.statusCode != 200) {
        // Átmeneti API-hibánál az utolsó igazolt jelzés maradjon látható.
        return;
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map) return;
      final ChatListModel model = ChatListModel.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      final int count = (model.chats ?? <Chat>[])
          .where((Chat chat) => chat.isFromMe != true && chat.isRead != true)
          .length;
      _setUnreadCount(count);
    } catch (_) {
      // A jelzés hibája nem akadályozhatja a fuvar vagy a chat használatát.
    } finally {
      _isPolling = false;
    }
  }

  void _setUnreadCount(int value) {
    if (!mounted || _unreadCount == value) return;
    setState(() => _unreadCount = value);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
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
            top: -6,
            right: -6,
            child: IgnorePointer(
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                alignment: Alignment.center,
                child: Text(
                  _unreadCount > 3 ? '3+' : '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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
