import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import '../network/api_client.dart';
import '../storage/hive_storage_service.dart';

enum MutationType {
  updateAlertStatus,
  triggerScan,
  restartAgent,
  restartDaemon,
  genericAction,
}

class OfflineMutation extends Equatable {
  final String id;
  final MutationType type;
  final String endpoint;
  final String method;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;

  const OfflineMutation({
    required this.id,
    required this.type,
    required this.endpoint,
    required this.method,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
  });

  OfflineMutation copyWith({
    String? id,
    MutationType? type,
    String? endpoint,
    String? method,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int? retryCount,
  }) {
    return OfflineMutation(
      id: id ?? this.id,
      type: type ?? this.type,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  factory OfflineMutation.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String? ?? 'genericAction';
    final type = MutationType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => MutationType.genericAction,
    );

    return OfflineMutation(
      id: json['id'] as String? ?? 'mut_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      endpoint: json['endpoint'] as String? ?? '',
      method: json['method'] as String? ?? 'POST',
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : {},
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      retryCount: json['retry_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'endpoint': endpoint,
    'method': method,
    'payload': payload,
    'created_at': createdAt.toIso8601String(),
    'retry_count': retryCount,
  };

  @override
  List<Object?> get props => [id, type, endpoint, method, payload, createdAt, retryCount];
}

class OfflineQueueService {
  static final OfflineQueueService instance = OfflineQueueService._internal();
  final HiveStorageService _storage;
  final Connectivity _connectivity;

  static const String queueStorageKey = 'sg_offline_mutations_queue';
  final List<OfflineMutation> _queue = [];
  final StreamController<List<OfflineMutation>> _queueStreamController =
      StreamController<List<OfflineMutation>>.broadcast();

  StreamSubscription<ConnectivityResult>? _connectivitySub;
  ApiClient? _apiClient;

  OfflineQueueService._internal({
    HiveStorageService? storage,
    Connectivity? connectivity,
  })  : _storage = storage ?? HiveStorageService(),
        _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  factory OfflineQueueService({
    HiveStorageService? storage,
    Connectivity? connectivity,
  }) {
    if (storage != null || connectivity != null) {
      return OfflineQueueService._internal(
        storage: storage,
        connectivity: connectivity,
      );
    }
    return instance;
  }

  void attachApiClient(ApiClient client) {
    _apiClient = client;
  }

  Stream<List<OfflineMutation>> get queueStream => _queueStreamController.stream;
  List<OfflineMutation> get pendingMutations => List.unmodifiable(_queue);
  int get pendingCount => _queue.length;

  Future<void> _init() async {
    try {
      final cached = _storage.getCachedData(queueStorageKey);
      if (cached != null) {
        if (cached is List) {
          _queue.clear();
          for (final item in cached) {
            if (item is Map) {
              _queue.add(OfflineMutation.fromJson(Map<String, dynamic>.from(item)));
            } else if (item is String) {
              _queue.add(OfflineMutation.fromJson(jsonDecode(item) as Map<String, dynamic>));
            }
          }
        }
      }
    } catch (_) {}

    _queueStreamController.add(List.unmodifiable(_queue));

    // Listen to network status changes and auto-flush on reconnection
    _connectivitySub?.cancel();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && _queue.isNotEmpty && _apiClient != null) {
        flushQueue(_apiClient!);
      }
    });
  }

  Future<void> enqueue(OfflineMutation mutation) async {
    _queue.add(mutation);
    await _persist();
    _queueStreamController.add(List.unmodifiable(_queue));
  }

  Future<void> remove(String mutationId) async {
    _queue.removeWhere((m) => m.id == mutationId);
    await _persist();
    _queueStreamController.add(List.unmodifiable(_queue));
  }

  Future<void> clear() async {
    _queue.clear();
    await _persist();
    _queueStreamController.add(List.unmodifiable(_queue));
  }

  Future<int> flushQueue(ApiClient client) async {
    if (_queue.isEmpty) return 0;

    final itemsToProcess = List<OfflineMutation>.from(_queue);
    int successCount = 0;

    for (final mutation in itemsToProcess) {
      try {
        if (mutation.method.toUpperCase() == 'PUT') {
          await client.put(mutation.endpoint, data: mutation.payload);
        } else if (mutation.method.toUpperCase() == 'POST') {
          await client.post(mutation.endpoint, data: mutation.payload);
        } else if (mutation.method.toUpperCase() == 'DELETE') {
          await client.delete(mutation.endpoint);
        }
        _queue.removeWhere((m) => m.id == mutation.id);
        successCount++;
      } catch (_) {
        // Increment retry count
        final idx = _queue.indexWhere((m) => m.id == mutation.id);
        if (idx != -1) {
          final updated = _queue[idx].copyWith(retryCount: _queue[idx].retryCount + 1);
          if (updated.retryCount >= 5) {
            // Drop after 5 failed attempts
            _queue.removeAt(idx);
          } else {
            _queue[idx] = updated;
          }
        }
      }
    }

    await _persist();
    _queueStreamController.add(List.unmodifiable(_queue));
    return successCount;
  }

  Future<void> _persist() async {
    try {
      final serialized = _queue.map((m) => m.toJson()).toList();
      await _storage.cacheData(queueStorageKey, serialized);
    } catch (_) {}
  }

  void dispose() {
    _connectivitySub?.cancel();
    _queueStreamController.close();
  }
}
