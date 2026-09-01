import 'package:equatable/equatable.dart';

enum WazuhAgentStatus {
  active,
  disconnected,
  pending,
  neverConnected,
}

class WazuhAgentModel extends Equatable {
  final String id;
  final String name;
  final String ip;
  final WazuhAgentStatus status;
  final String osName;
  final String osVersion;
  final String version;
  final String group;
  final DateTime lastKeepAlive;

  const WazuhAgentModel({
    required this.id,
    required this.name,
    required this.ip,
    required this.status,
    required this.osName,
    required this.osVersion,
    required this.version,
    required this.group,
    required this.lastKeepAlive,
  });

  factory WazuhAgentModel.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] as String? ?? 'active').toLowerCase();
    WazuhAgentStatus status = WazuhAgentStatus.active;
    if (statusStr == 'disconnected') status = WazuhAgentStatus.disconnected;
    if (statusStr == 'pending') status = WazuhAgentStatus.pending;
    if (statusStr == 'never_connected') status = WazuhAgentStatus.neverConnected;

    final osMap = json['os'] is Map<String, dynamic> ? json['os'] as Map<String, dynamic> : null;

    return WazuhAgentModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Agent',
      ip: json['ip'] as String? ?? '0.0.0.0',
      status: status,
      osName: osMap?['name'] as String? ?? json['os_name'] as String? ?? 'Linux',
      osVersion: osMap?['version'] as String? ?? json['os_version'] as String? ?? 'Ubuntu 22.04',
      version: json['version'] as String? ?? 'Wazuh v4.7.2',
      group: json['group'] as String? ?? 'default',
      lastKeepAlive: DateTime.tryParse(json['lastKeepAlive'] as String? ?? json['last_keep_alive'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ip': ip,
    'status': status.name,
    'os_name': osName,
    'os_version': osVersion,
    'version': version,
    'group': group,
    'last_keep_alive': lastKeepAlive.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, name, ip, status, osName, osVersion, version, group, lastKeepAlive];
}

class WazuhDaemonModel extends Equatable {
  final String daemonName;
  final String description;
  final bool isRunning;
  final int pid;
  final String uptime;

  const WazuhDaemonModel({
    required this.daemonName,
    required this.description,
    required this.isRunning,
    required this.pid,
    required this.uptime,
  });

  factory WazuhDaemonModel.fromJson(Map<String, dynamic> json) {
    return WazuhDaemonModel(
      daemonName: json['daemon_name'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? 'Wazuh System Daemon',
      isRunning: json['is_running'] as bool? ?? json['status'] == 'running' || json['status'] == true,
      pid: json['pid'] as int? ?? 0,
      uptime: json['uptime'] as String? ?? '99.9%',
    );
  }

  Map<String, dynamic> toJson() => {
    'daemon_name': daemonName,
    'description': description,
    'is_running': isRunning,
    'pid': pid,
    'uptime': uptime,
  };

  @override
  List<Object?> get props => [daemonName, description, isRunning, pid, uptime];
}
