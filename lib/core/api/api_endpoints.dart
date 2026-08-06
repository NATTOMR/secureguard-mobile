class ApiEndpoints {
  ApiEndpoints._();

  static const String login = '/v1/auth/login';
  static const String me = '/v1/auth/me';
  static const String dashboard = '/v1/dashboard/summary';
  static const String repositories = '/v1/repositories';
  static const String scans = '/v1/scans';
  static const String findings = '/v1/findings';
  static const String socAlerts = '/v1/soc/alerts';
  static const String aiRemediate = '/v1/ai/remediate';
  static const String reports = '/v1/reports';
}
