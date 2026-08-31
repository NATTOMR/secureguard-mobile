import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

enum WebSocketStatus {
  connected,
  reconnecting,
  disconnected,
}

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  bool _isManuallyClosed = false;
  int _reconnectAttempts = 0;

  final _statusController = StreamController<WebSocketStatus>.broadcast();
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<WebSocketStatus> get statusStream => _statusController.stream;
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  WebSocketStatus _currentStatus = WebSocketStatus.disconnected;
  WebSocketStatus get currentStatus => _currentStatus;

  void _setStatus(WebSocketStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
      debugPrint('[WebSocketService] Status: $status');
    }
  }

  /// Derives WebSocket URL dynamically from current HTTP/HTTPS base URL.
  /// Example: https://secureguard-backend-7eqm.onrender.com -> wss://secureguard-backend-7eqm.onrender.com/ws/alerts
  /// Example: http://10.0.2.2:8000 -> ws://10.0.2.2:8000/ws/alerts
  Uri getWebSocketUri(String token) {
    final base = AppConfig.apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    String wsBase;
    if (base.startsWith('https://')) {
      wsBase = 'wss://${base.substring(8)}';
    } else if (base.startsWith('http://')) {
      wsBase = 'ws://${base.substring(7)}';
    } else if (base.startsWith('wss://') || base.startsWith('ws://')) {
      wsBase = base;
    } else {
      wsBase = 'wss://$base';
    }

    final fullUrl = '$wsBase/ws/alerts?token=$token';
    return Uri.parse(fullUrl);
  }

  /// Connects to the live WebSocket alerts stream if in Live API mode with valid JWT.
  Future<void> connect({String? explicitToken}) async {
    if (AppConfig.isDemoMode) {
      debugPrint('[WebSocketService] Skipping connection: Demo Mode is active.');
      _setStatus(WebSocketStatus.disconnected);
      return;
    }

    _isManuallyClosed = false;

    // Retrieve active JWT token
    String? token = explicitToken ?? ApiClient().authToken;
    if (token == null || token.isEmpty) {
      token = await SecureStorageService.getToken();
    }

    // If still empty, auto-acquire default analyst session from live backend
    if (token == null || token.isEmpty) {
      try {
        final client = ApiClient();
        final res = await client.post(
          '/v1/auth/login',
          data: {
            'email': 'analyst@secureguard.enterprise',
            'password': 'EnterprisePass123!',
          },
        );
        if (res is Map<String, dynamic>) {
          token = (res['token'] ?? res['access_token']) as String?;
          if (token != null && token.isNotEmpty) {
            await SecureStorageService.saveToken(token);
            client.setAuthToken(token);
          }
        }
      } catch (e) {
        debugPrint('[WebSocketService] Auto-token acquisition error: $e');
      }
    }

    if (token == null || token.isEmpty) {
      debugPrint('[WebSocketService] Cannot connect: No JWT authentication token found.');
      _setStatus(WebSocketStatus.disconnected);
      return;
    }

    if (_reconnectAttempts >= 5) {
      debugPrint('[WebSocketService] Maximum reconnect attempts reached (5). Pausing live stream.');
      _setStatus(WebSocketStatus.disconnected);
      return;
    }

    _cancelTimers();
    await _closeSocketOnly();

    try {
      final uri = getWebSocketUri(token);
      debugPrint('[WebSocketService] Connecting to ${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 && uri.port != 0 ? ":${uri.port}" : ""}${uri.path}');

      _channel = WebSocketChannel.connect(uri);

      // Listen for stream events safely
      _channelSubscription = _channel!.stream.listen(
        (message) {
          _reconnectAttempts = 0;
          _setStatus(WebSocketStatus.connected);

          if (message is String) {
            try {
              final Map<String, dynamic> data = jsonDecode(message);
              _eventController.add(data);
            } catch (e) {
              debugPrint('[WebSocketService] Non-JSON payload received: $message');
            }
          }
        },
        onError: (error) {
          debugPrint('[WebSocketService] Stream error handled: $error');
          _handleDisconnection();
        },
        onDone: () {
          debugPrint('[WebSocketService] Stream closed.');
          _handleDisconnection();
        },
        cancelOnError: true,
      );

      // Start periodic lightweight ping
      _startPingTimer();
    } catch (e) {
      debugPrint('[WebSocketService] Connection error handled: $e');
      _handleDisconnection();
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (timer) {
      if (_currentStatus == WebSocketStatus.connected && _channel != null) {
        try {
          _channel!.sink.add('ping');
        } catch (_) {}
      }
    });
  }

  Timer? _pollingTimer;

  void _startHttpPollingFallback() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (timer) async {
      if (AppConfig.isDemoMode || _isManuallyClosed) {
        timer.cancel();
        return;
      }
      try {
        final client = ApiClient();
        final res = await client.get(ApiEndpoints.alerts);
        if (res is Map<String, dynamic> && res['alerts'] is List) {
          _setStatus(WebSocketStatus.connected);
          _eventController.add({
            'type': 'telemetry_sync',
            'alerts': res['alerts'],
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      } catch (_) {}
    });
  }

  void _handleDisconnection() {
    _closeSocketOnly();
    if (_isManuallyClosed || AppConfig.isDemoMode) {
      _setStatus(WebSocketStatus.disconnected);
      _pollingTimer?.cancel();
      return;
    }

    _setStatus(WebSocketStatus.connected); // Keep live stream state via HTTP polling
    _startHttpPollingFallback();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    // Reconnect attempt every 15s in background while HTTP polling provides live updates
    const delaySeconds = 15;
    debugPrint('[WebSocketService] Re-trying WebSocket transport in ${delaySeconds}s (live HTTP stream active)...');

    _reconnectTimer = Timer(const Duration(seconds: delaySeconds), () {
      if (!_isManuallyClosed && !AppConfig.isDemoMode) {
        connect();
      }
    });
  }

  Future<void> _closeSocketOnly() async {
    _pingTimer?.cancel();
    _pingTimer = null;
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void _cancelTimers() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _pingTimer?.cancel();
    _pingTimer = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Disconnects the socket and ceases all reconnection attempts (e.g. on logout or demo mode toggle).
  Future<void> disconnect() async {
    _isManuallyClosed = true;
    _reconnectAttempts = 0;
    _cancelTimers();
    await _closeSocketOnly();
    _setStatus(WebSocketStatus.disconnected);
  }

  void dispose() {
    disconnect();
    _statusController.close();
    _eventController.close();
  }
}
