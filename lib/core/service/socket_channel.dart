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
  bool _isSubscribed = false;

  int _reconnectAttempts = 0;

  String? _url;
  Duration _reconnectInterval = const Duration(seconds: 3);
  int _maxReconnectAttempts = -1;

  Map<String, dynamic>? _initialEvents;
  Map<String, dynamic>? _subscriptionData;

  final BehaviorSubject<dynamic> _socketController =
      BehaviorSubject<dynamic>();
  final BehaviorSubject<bool> _connectionController =
      BehaviorSubject<bool>.seeded(false);

  Stream<dynamic> get onSocketDataListen => _socketController.stream;
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
    if (_url == null || _isDisposed || _isConnecting || _isConnected) return;

    _isConnecting = true;
    _isSubscribed = false;
    _connectionController.add(false);

    try {
      final channel = IOWebSocketChannel.connect(Uri.parse(_url!));
      _channel = channel;
      await channel.ready;

      _subscription = channel.stream.listen(
        _handleMessage,
        onDone: _handleDisconnection,
        onError: (Object error) {
          debugPrint('Pusher socket error: $error');
          _handleDisconnection();
        },
        cancelOnError: true,
      );
    } catch (error) {
      debugPrint('Pusher socket connect failed: $error');
      _handleDisconnection();
    } finally {
      _isConnecting = false;
    }
  }

  void _handleMessage(dynamic rawEvent) {
    try {
      final dynamic decoded = rawEvent is String
          ? jsonDecode(rawEvent)
          : rawEvent;
      final String eventName = decoded is Map
          ? decoded['event']?.toString() ?? ''
          : '';

      if (eventName == 'pusher:connection_established') {
        _isConnected = true;
        _reconnectAttempts = 0;
        _connectionController.add(true);
        _subscribeAfterHandshake();
      } else if (eventName == 'pusher:ping') {
        sendMessage(<String, dynamic>{
          'event': 'pusher:pong',
          'data': <String, dynamic>{},
        });
      } else if (eventName == 'pusher:error') {
        debugPrint('Pusher protocol error: $rawEvent');
      }

      if (!_socketController.isClosed) {
        _socketController.add(rawEvent);
      }
    } catch (error) {
      debugPrint('Pusher message parse error: $error');
      if (!_socketController.isClosed) {
        _socketController.add(rawEvent);
      }
    }
  }

  void _subscribeAfterHandshake() {
    if (!_isConnected || _isSubscribed || _channel == null) return;

    if (_subscriptionData != null) {
      sendMessage(<String, dynamic>{
        'event': 'pusher:subscribe',
        'data': _subscriptionData,
      });
    }

    if (_initialEvents != null) {
      sendMessage(_initialEvents!);
    }

    _isSubscribed = true;
  }

  void sendMessage(dynamic message) {
    if (!_isConnected || _channel == null) return;

    try {
      _channel!.sink.add(
        message is String ? message : jsonEncode(message),
      );
    } catch (error) {
      debugPrint('Pusher socket send error: $error');
      _handleDisconnection();
    }
  }

  void sendPusherEvent(String event, Map<String, dynamic> data) {
    sendMessage(<String, dynamic>{'event': event, 'data': data});
  }

  void sendPusherEventChanel(
    String event,
    Map<String, dynamic> data, {
    required String channel,
  }) {
    sendMessage(<String, dynamic>{
      'event': event,
      'data': data,
      'channel': channel,
    });
  }

  void ensureConnected() {
    if (!_isConnected && !_isConnecting && !_isDisposed) {
      _connect();
    }
  }

  void _handleDisconnection() {
    if (_isDisposed) return;

    _cleanup();
    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }

    if (_maxReconnectAttempts == -1 ||
        _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectAttempts++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectInterval, ensureConnected);
  }

  void _cleanup() {
    _subscription?.cancel();
    _subscription = null;

    try {
      _channel?.sink.close();
    } catch (_) {}

    _channel = null;
    _isConnected = false;
    _isSubscribed = false;
  }

  void disconnect({bool dispose = false}) {
    _isDisposed = dispose;
    _reconnectTimer?.cancel();
    _cleanup();
    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }
  }

  void dispose() {
    disconnect(dispose: true);
    _socketController.close();
    _connectionController.close();
  }
}
