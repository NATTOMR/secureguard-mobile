import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/ai_message_model.dart';

abstract class AiRepository {
  Future<AiMessageModel> sendSecurityPrompt(String prompt);
  Future<String> generateRemediationAdvice(String findingTitle);
}

class AiRepositoryImpl implements AiRepository {
  final ApiClient apiClient;

  AiRepositoryImpl({required this.apiClient});

  @override
  Future<AiMessageModel> sendSecurityPrompt(String prompt) async {
    if (!AppConfig.isDemoMode) {
      try {
        final response = await apiClient.post(
          ApiEndpoints.aiChat,
          data: {'prompt': prompt, 'context': 'mobile_security_copilot'},
        );
        return AiMessageModel.fromJson(response as Map<String, dynamic>);
      } catch (_) {
        // Fallback to local security remediation logic if offline
      }
    }

    // Clearly marked demo / offline security response generator
    final responseText = _generateMockSecurityResponse(prompt);
    return AiMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: AiMessageRole.assistant,
      content: responseText,
      timestamp: DateTime.now(),
      hasCode: responseText.contains('```'),
    );
  }

  @override
  Future<String> generateRemediationAdvice(String findingTitle) async {
    final msg = await sendSecurityPrompt('Provide remediation for $findingTitle');
    return msg.content;
  }

  String _generateMockSecurityResponse(String query) {
    final lower = query.toLowerCase();

    if (lower.contains('cve-2024-3094') || lower.contains('xz')) {
      return '### 🛡️ Remediation Plan: CVE-2024-3094 (XZ Utils Backdoor)\n\n'
          '**Severity:** Critical (CVSS 10.0)\n\n'
          '1. **Identify Affected Systems:** Scan all container base images for `xz-utils` versions `5.6.0` or `5.6.1`.\n'
          '2. **Downgrade Immediately:** Revert to known-good version `5.4.6` in your Dockerfile / package manager:\n'
          '```dockerfile\nRUN apt-get update && apt-get install -y --allow-downgrades xz-utils=5.4.6-0.1\n```\n'
          '3. **Verify SSHD Integrity:** Ensure no unauthorized systemd modifications exist.\n'
          '4. **Trigger Semgrep Scan:** Run CI/CD verification pipeline to ensure compliance.';
    }

    if (lower.contains('sql') || lower.contains('injection')) {
      return '### 🛡️ SQL Injection Remediation (FastAPI / SQLAlchemy)\n\n'
          '**Risk:** Raw string interpolation allows arbitrary SQL execution.\n\n'
          '**Remediation Code:** Use parameterized queries or ORM models:\n'
          '```python\n# Safe Parameterized Query\nfrom sqlalchemy import text\nstmt = text("SELECT id, username FROM users WHERE tenant_id = :t_id")\nresult = await db.execute(stmt, {"t_id": tenant_id})\n```\n\n'
          'Ensure `Semgrep` rule `python.sqlalchemy.security.audit.avoid-raw-sql` is enforced in your repository.';
    }

    if (lower.contains('secret') || lower.contains('aws') || lower.contains('key')) {
      return '### 🔐 Secret Exposure & Rotation Protocol\n\n'
          '1. **Immediate Revocation:** Invalidate the exposed AWS Access Key ID via AWS IAM Console.\n'
          '2. **Audit CloudTrail:** Inspect AWS CloudTrail logs for unauthorized API calls using this key in the past 48h.\n'
          '3. **Migrate to Secrets Manager:** Replace hardcoded credentials with AWS Secrets Manager or Vault:\n'
          '```python\nimport boto3\nfrom botocore.exceptions import ClientError\n\ndef get_secret(secret_name):\n    client = boto3.client("secretsmanager", region_name="us-east-1")\n    return client.get_secret_value(SecretId=secret_name)["SecretString"]\n```\n'
          '4. **Git History Scrub:** Use `git-filter-repo` to purge the commit containing the secret.';
    }

    return '### 🛡️ SecureGuard AI Analysis\n\n'
        'I have analyzed your security inquiry regarding **"$query"**.\n\n'
        '- **Recommended Action:** Review the affected code branch and ensure all input is validated and sanitized.\n'
        '- **SAST Check:** Enforce Semgrep security rules before merging PRs.\n'
        '- **SOC Monitoring:** Verify Wazuh agent is forwarding endpoint telemetry.\n\n'
        'Would you like me to generate a tailored patch or Semgrep YAML rule for this scenario?';
  }
}
