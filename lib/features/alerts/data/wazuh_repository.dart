import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/wazuh_models.dart';

abstract class WazuhRepository {
  Future<List<WazuhAgentModel>> getAgents();
  Future<List<WazuhDaemonModel>> getDaemons();
  Future<bool> restartAgent(String agentId);
  Future<bool> restartDaemon(String daemonName);
}

class WazuhRepositoryImpl implements WazuhRepository {
  final ApiClient apiClient;

  WazuhRepositoryImpl({required this.apiClient});

  @override
  Future<List<WazuhAgentModel>> getAgents() async {
    if (AppConfig.isDemoMode) {
      return _getMockAgents();
    }

    try {
      final response = await apiClient.get(ApiEndpoints.wazuhAgents);
      if (response is List) {
        return response.map((e) => WazuhAgentModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (response is Map<String, dynamic> && response['agents'] is List) {
        return (response['agents'] as List)
            .map((e) => WazuhAgentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return _getMockAgents();
    } catch (_) {
      return _getMockAgents();
    }
  }

  @override
  Future<List<WazuhDaemonModel>> getDaemons() async {
    if (AppConfig.isDemoMode) {
      return _getMockDaemons();
    }

    try {
      final response = await apiClient.get(ApiEndpoints.wazuhDaemons);
      if (response is List) {
        return response.map((e) => WazuhDaemonModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (response is Map<String, dynamic> && response['daemons'] is List) {
        return (response['daemons'] as List)
            .map((e) => WazuhDaemonModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return _getMockDaemons();
    } catch (_) {
      return _getMockDaemons();
    }
  }

  @override
  Future<bool> restartAgent(String agentId) async {
    if (AppConfig.isDemoMode) {
      return true;
    }

    try {
      final response = await apiClient.post('${ApiEndpoints.wazuhAgents}/$agentId/restart');
      return response is Map<String, dynamic> && response['success'] == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> restartDaemon(String daemonName) async {
    if (AppConfig.isDemoMode) {
      return true;
    }

    try {
      final response = await apiClient.post('${ApiEndpoints.wazuhDaemons}/$daemonName/restart');
      return response is Map<String, dynamic> && response['success'] == true;
    } catch (_) {
      return false;
    }
  }

  List<WazuhAgentModel> _getMockAgents() {
    return [
      WazuhAgentModel(
        id: '001',
        name: 'prod-api-gateway-01',
        ip: '10.0.1.15',
        status: WazuhAgentStatus.active,
        osName: 'Ubuntu',
        osVersion: '22.04 LTS',
        version: 'Wazuh v4.7.2',
        group: 'production-dmz',
        lastKeepAlive: DateTime.now().subtract(const Duration(seconds: 42)),
      ),
      WazuhAgentModel(
        id: '002',
        name: 'db-cluster-primary',
        ip: '10.0.2.20',
        status: WazuhAgentStatus.active,
        osName: 'RHEL',
        osVersion: '9.3',
        version: 'Wazuh v4.7.2',
        group: 'database-tier',
        lastKeepAlive: DateTime.now().subtract(const Duration(minutes: 1, seconds: 12)),
      ),
      WazuhAgentModel(
        id: '003',
        name: 'k8s-worker-node-04',
        ip: '10.0.3.44',
        status: WazuhAgentStatus.active,
        osName: 'Debian',
        osVersion: '12 (Bookworm)',
        version: 'Wazuh v4.7.2',
        group: 'kubernetes-cluster',
        lastKeepAlive: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      WazuhAgentModel(
        id: '004',
        name: 'corp-ad-domain-controller',
        ip: '192.168.10.2',
        status: WazuhAgentStatus.active,
        osName: 'Windows Server',
        osVersion: '2022 Datacenter',
        version: 'Wazuh v4.7.1',
        group: 'active-directory',
        lastKeepAlive: DateTime.now().subtract(const Duration(seconds: 15)),
      ),
    ];
  }

  List<WazuhDaemonModel> _getMockDaemons() {
    return const [
      WazuhDaemonModel(
        daemonName: 'wazuh-analysisd',
        description: 'Log analysis and alert evaluation engine',
        isRunning: true,
        pid: 14201,
        uptime: '99.98%',
      ),
      WazuhDaemonModel(
        daemonName: 'wazuh-remoted',
        description: 'Agent connection listener & secure channel',
        isRunning: true,
        pid: 14204,
        uptime: '99.99%',
      ),
      WazuhDaemonModel(
        daemonName: 'wazuh-modulesd',
        description: 'Vulnerability detection & CIS benchmark scanner',
        isRunning: true,
        pid: 14208,
        uptime: '99.95%',
      ),
      WazuhDaemonModel(
        daemonName: 'wazuh-authd',
        description: 'Agent enrollment & registration daemon',
        isRunning: true,
        pid: 14212,
        uptime: '100.0%',
      ),
      WazuhDaemonModel(
        daemonName: 'wazuh-db',
        description: 'Internal state & agent database storage',
        isRunning: true,
        pid: 14216,
        uptime: '99.99%',
      ),
    ];
  }
}
