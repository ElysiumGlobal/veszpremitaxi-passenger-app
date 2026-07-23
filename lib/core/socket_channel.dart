import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/io.dart';

class SocketChannelService {
  static final SocketChannelService _instance =
      SocketChannelService._internal();

  factory SocketChannelService() => _instance;

  SocketChannelService._internal();

  IOWebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;

  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isDisposed = false;

  int _reconnectAttempts = 0;

  String? _url;
  Duration _reconnectInterval = const Duration(seconds: 3);
  int _maxReconnectAttempts = -1;

  Map<String, dynamic>? _initialEvents;
  Map<String, dynamic>? _subscriptionData;

  final BehaviorSubject<dynamic> _socketController = BehaviorSubject<dynamic>();

  Stream<dynamic> get onSocketDataListen => _socketController.stream;

  final BehaviorSubject<bool> _connectionController = BehaviorSubject<bool>();

  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _isConnected;


  Future<void> initSocket({
    required String url,
    Map<String, dynamic>? events,
    Map<String, dynamic>? subscriptionData,
    Duration? reconnectInterval,
    int? maxReconnectAttempts,
  }) async {
    if (_isDisposed) return;

    _url = url;
    _initialEvents = events;
    _subscriptionData = subscriptionData;

    if (reconnectInterval != null) {
      _reconnectInterval = reconnectInterval;
    }

    if (maxReconnectAttempts != null) {
      _maxReconnectAttempts = maxReconnectAttempts;
    }

    ensureConnected();
  }

  Future<void> _connect() async {
    if (_url == null || _isDisposed) return;

    if (_isConnecting) {
      debugPrint('Socket: already connecting');
      return;
    }

    _isConnecting = true;
    _isConnected = false;
    _connectionController.add(false);

    try {
      debugPrint('Socket: connecting to $_url');

      _channel = IOWebSocketChannel.connect(Uri.parse(_url!));
      await _channel!.ready;

      debugPrint('Socket: connected');

      if (_subscriptionData != null) {
        _channel!.sink.add(
          jsonEncode({"event": "pusher:subscribe", "data": _subscriptionData}),
        );
      }

      if (_initialEvents != null) {
        _channel!.sink.add(jsonEncode(_initialEvents));
      }

      _subscription = _channel!.stream.listen(
        (event) {
          _socketController.add(event);

          if (kDebugMode) {
            try {
              debugPrint('Socket data: ${jsonDecode(event)}');
            } catch (_) {
              debugPrint('Socket raw: $event');
            }
          }
        },
        onDone: _handleDisconnection,
        onError: (e) {
          debugPrint('Socket error: $e');
          _handleDisconnection();
        },
        cancelOnError: true,
      );

      _reconnectAttempts = 0;
      _isConnected = true;
      _connectionController.add(true);
    } catch (e) {
      debugPrint('Socket connect failed: $e');
      _handleDisconnection();
    } finally {
      _isConnecting = false;
    }
  }


  void sendMessage(dynamic message) {
    if (!_isConnected || _channel == null) return;

    try {
      if (message is String) {
        _channel!.sink.add(message);
      } else {
        _channel!.sink.add(jsonEncode(message));
      }
    } catch (e) {
      debugPrint('Socket send error: $e');
      _handleDisconnection();
    }
  }

  void sendPusherEvent(String event, Map<String, dynamic> data) {
    sendMessage({"event": event, "data": data});
  }

  void sendPusherEventChanel(
    String event,
    Map<String, dynamic> data, {
    required String channel,
  }) {
    sendMessage({"event": event, "data": data, "channel": channel});
  }

  void ensureConnected() {
    if (!_isConnected && !_isConnecting && !_isDisposed) {
      debugPrint('Socket: ensureConnected()');
      _connect();
    }
  }

  void _handleDisconnection() {
    if (_isDisposed) return;

    _cleanup();
    _connectionController.add(false);

    if (_maxReconnectAttempts == -1 ||
        _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectAttempts++;
    _reconnectTimer?.cancel();

    debugPrint(
      'Socket: reconnect attempt $_reconnectAttempts in ${_reconnectInterval.inSeconds}s',
    );

    _reconnectTimer = Timer(_reconnectInterval, () {
      ensureConnected();
    });
  }

  void _cleanup() {
    _subscription?.cancel();
    _subscription = null;

    try {
      _channel?.sink.close();
    } catch (_) {}

    _channel = null;
    _isConnected = false;
  }


  void disconnect({bool dispose = false}) {
    _isDisposed = dispose;
    _reconnectTimer?.cancel();
    _cleanup();
    _connectionController.add(false);
  }

  void dispose() {
    disconnect(dispose: true);
    _socketController.close();
    _connectionController.close();
  }
}
