import '../models/models.dart';

class FindingRepository {
  Future<List<FindingModel>> getFindings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    return [
      FindingModel(
        id: 'fnd_001',
        cveId: 'CVE-2024-3094',
        title: 'XZ Utils Backdoor Vulnerability in SSHD Pipeline',
        description: 'Malicious code introduced in XZ Utils versions 5.6.0 and 5.6.1 allows unauthorized SSH access.',
        severity: SeverityLevel.critical,
        cvssScore: 10.0,
        repositoryName: 'auth-gateway-service',
        filePath: 'infra/docker/base-image.Dockerfile',
        lineNumber: 14,
        remediationGuide: 'Upgrade xz-utils package to version >= 5.6.2 immediately. Downgrade container base OS to Debian Bookworm stable.',
        isResolved: false,
        detectedAt: now.subtract(const Duration(hours: 3)),
      ),
      FindingModel(
        id: 'fnd_002',
        cveId: 'CVE-2023-4863',
        title: 'Heap Buffer Overflow in libwebp Graphics Library',
        description: 'Buffer overflow in WebP encoding engine allows remote code execution via crafted WebP image files.',
        severity: SeverityLevel.high,
        cvssScore: 8.8,
        repositoryName: 'payment-processor-vault',
        filePath: 'src/media/image_processor.ts',
        lineNumber: 88,
        remediationGuide: 'Update libwebp dependency to version >= 1.3.2. Sanitize incoming binary stream prior to memory allocation.',
        isResolved: false,
        detectedAt: now.subtract(const Duration(hours: 8)),
      ),
      FindingModel(
        id: 'fnd_003',
        cveId: 'CWE-89',
        title: 'SQL Injection in User Search Filter',
        description: 'Unsanitized query string passed directly to raw Postgres DB connection inside user filter route.',
        severity: SeverityLevel.high,
        cvssScore: 8.1,
        repositoryName: 'secureguard-backend-api',
        filePath: 'services/user_service.py',
        lineNumber: 142,
        remediationGuide: 'Replace raw string interpolation with parameterized SQL query using SQLAlchemy ORM expressions.',
        isResolved: true,
        detectedAt: now.subtract(const Duration(days: 2)),
      ),
      FindingModel(
        id: 'fnd_004',
        cveId: 'CWE-798',
        title: 'Hardcoded AWS Access Secret in Test Suite',
        description: 'Plaintext AWS access key string discovered in integration unit test environment setup file.',
        severity: SeverityLevel.medium,
        cvssScore: 6.5,
        repositoryName: 'secureguard-mobile',
        filePath: 'test/mocks/aws_credentials.dart',
        lineNumber: 9,
        remediationGuide: 'Revoke AWS Access Key ID AKIA... in AWS IAM Console. Inject key via environment secrets manager at build time.',
        isResolved: false,
        detectedAt: now.subtract(const Duration(hours: 18)),
      ),
    ];
  }
}
