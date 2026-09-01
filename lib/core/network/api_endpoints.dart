class ApiEndpoints {
  ApiEndpoints._();

  // Health / Root Probe
  static const String health = '/health';

  // Authentication
  static const String login = '/v1/auth/login';
  static const String me = '/v1/auth/me';
  static const String githubAuth = '/v1/auth/github';

  // Dashboard & Overview
  static const String dashboard = '/v1/dashboard/summary';

  // Repositories, Scans & Findings
  static const String repositories = '/v1/repositories';
  static const String scans = '/v1/scans';
  static const String findings = '/v1/findings';

  // Alerts & SOC
  static const String alerts = '/v1/soc/alerts';
  static const String wazuhAgents = '/v1/wazuh/agents';
  static const String wazuhDaemons = '/v1/wazuh/daemons';

  // AI Security Assistant & Remediation
  static const String aiRemediate = '/v1/ai/remediate';
  static const String aiChat = '/v1/ai/chat';

  // Executive Reports
  static const String reports = '/v1/reports';
}
