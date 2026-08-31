# SecurePulse Mobile — Documentation Evidence Index 📋

This document serves as the master evidence checklist and tracking register for **SecurePulse Mobile**. It indexes all visual figures, code extracts, terminal logs, API payloads, architectural diagrams, and video walkthroughs referenced across [`docs/PROJECT_REPORT.md`](file:///e:/SOC%20projects/securepulse-mobile/docs/PROJECT_REPORT.md) and [`docs/WALKTHROUGH.md`](file:///e:/SOC%20projects/securepulse-mobile/docs/WALKTHROUGH.md).

---

## 📊 Summary of Evidence Artifacts

| Category | Total Items | Screenshot | Code Snippet | Video | Log / API Response | Diagram |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **1. Architecture** | 4 | 1 | 0 | 0 | 0 | 3 |
| **2. Backend** | 3 | 1 | 1 | 0 | 1 | 0 |
| **3. Database** | 2 | 0 | 1 | 0 | 1 | 0 |
| **4. Authentication** | 4 | 2 | 2 | 0 | 0 | 0 |
| **5. Dashboard** | 3 | 2 | 0 | 1 | 0 | 0 |
| **6. Repositories** | 3 | 2 | 1 | 0 | 0 | 0 |
| **7. Alerts** | 4 | 2 | 1 | 1 | 0 | 0 |
| **8. AI Copilot** | 3 | 2 | 0 | 1 | 0 | 0 |
| **9. WebSocket** | 3 | 0 | 1 | 1 | 1 | 0 |
| **10. Wazuh** | 2 | 1 | 0 | 0 | 1 | 0 |
| **11. GitHub** | 2 | 1 | 0 | 0 | 1 | 0 |
| **12. Semgrep** | 3 | 2 | 1 | 0 | 0 | 0 |
| **13. Cloud Deployment** | 4 | 2 | 1 | 1 | 0 | 0 |
| **14. Android Application** | 4 | 3 | 0 | 1 | 0 | 0 |
| **15. Testing** | 4 | 2 | 0 | 0 | 2 | 0 |
| **16. Security** | 4 | 2 | 2 | 0 | 0 | 0 |
| **TOTAL** | **48** | **23** | **10** | **6** | **6** | **3** |

---

## 📑 Master Evidence Register

### 1. Architecture
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-001** | Chapter 4 (4.1) | `DIAGRAM` | Overall SecurePulse End-to-End System Topology | `fig_4_1_overall_architecture.png` | `PENDING` |
| **E-002** | Chapter 4 (4.2) | `DIAGRAM` | Mobile Clean Architecture & Riverpod 2.6.1 State Tier | `fig_4_2_mobile_clean_architecture.png` | `PENDING` |
| **E-003** | Chapter 4 (4.3) | `DIAGRAM` | FastAPI Backend Asynchronous Component Pipeline | `fig_4_3_backend_architecture.png` | `PENDING` |
| **E-004** | Chapter 4 (4.9) | `SCREENSHOT` | High-Level Architecture Poster / Visual Overview | `fig_4_4_architecture_overview_poster.png` | `PENDING` |

---

### 2. Backend
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-005** | Chapter 6 (6.3) | `CODE SNIPPET` | Centralized REST & WebSocket Endpoint Contracts | `lib/core/network/api_endpoints.dart` | `PENDING` |
| **E-006** | Walkthrough (Sec 9) | `API RESPONSE` | Live `/health` Uptime Check JSON Response | `fig_w_01_api_health_probe.png` | `PENDING` |
| **E-007** | Chapter 9 (9.3) | `SCREENSHOT` | FastAPI OpenAPI Swagger Interactive Documentation | `fig_9_1_api_swagger_docs.png` | `PENDING` |

---

### 3. Database
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-008** | Chapter 6 (6.7) | `CODE SNIPPET` | Hive Encrypted Offline Key-Value Box Initialization | `lib/core/storage/hive_storage_service.dart` | `PENDING` |
| **E-009** | Chapter 9 (9.4) | `LOG` | Cloud PostgreSQL Connection Pool SSL Handshake Log | `log_db_ssl_connection_pool.txt` | `PENDING` |

---

### 4. Authentication
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-010** | Chapter 6 (6.2) | `SCREENSHOT` | Splash Shimmer Screen & Startup Sequence | `fig_6_1_splash_screen_startup.png` | `PENDING` |
| **E-011** | Chapter 7 (7.2) | `SCREENSHOT` | Native Android / iOS Biometric Challenge Modal | `fig_7_1_biometric_auth_prompt.png` | `PENDING` |
| **E-012** | Chapter 6 (6.5) | `CODE SNIPPET` | Biometric Session Recovery & JWT Bearer Setting | `lib/features/auth/data/auth_repository.dart` | `PENDING` |
| **E-013** | Chapter 7 (7.6) | `CODE SNIPPET` | Hardware Keystore Write / Read / Delete Routines | `lib/core/storage/secure_storage_service.dart` | `PENDING` |

---

### 5. Dashboard
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-014** | Chapter 6 (6.15) | `SCREENSHOT` | Executive Dashboard with Posture Gauge & Service Badges | `fig_6_5_executive_dashboard_screen.png` | `PENDING` |
| **E-015** | Walkthrough (Sec 14) | `SCREENSHOT` | Interactive `fl_chart` Donut Vulnerability Breakdown | `fig_w_03_executive_dashboard_ops.png` | `PENDING` |
| **E-016** | Chapter 6 (6.22) | `VIDEO` | Application Launch, Biometric Auth & Dashboard Demo | `media/videos/demo_01_launch_dashboard.mp4` | `PENDING` |

---

### 6. Repositories
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-017** | Chapter 6 (6.8) | `SCREENSHOT` | Monitored Codebases Inventory & Health Badges (A–F) | `fig_6_2_repository_list_screen.png` | `PENDING` |
| **E-018** | Walkthrough (Sec 15) | `SCREENSHOT` | Repository Detail Screen with Branch Tracking | `fig_w_04_repository_sast_findings.png` | `PENDING` |
| **E-019** | Chapter 5 (5.7) | `CODE SNIPPET` | On-Demand SAST Scan Trigger Dispatch Implementation | `lib/features/repositories/data/repository_repository.dart` | `PENDING` |

---

### 7. Alerts
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-020** | Chapter 6 (6.16) | `SCREENSHOT` | SOC Alert Feed with Severity Filter Pills (Crit/High/Med) | `fig_6_6_soc_alerts_screen.png` | `PENDING` |
| **E-021** | Chapter 6 (6.9) | `SCREENSHOT` | Incident Triage Modal with Attacker IP & Quarantine Action | `fig_6_3_alert_detail_screen.png` | `PENDING` |
| **E-022** | Chapter 5 (5.4) | `CODE SNIPPET` | Alert Status Mutation & Resolution Dispatch Logic | `lib/features/alerts/data/alerts_repository.dart` | `PENDING` |
| **E-023** | Chapter 6 (6.22) | `VIDEO` | Live Alert Ingestion, Raw Syslog Inspection & Mitigation | `media/videos/demo_02_alert_triage_mitigation.mp4` | `PENDING` |

---

### 8. AI Copilot
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-024** | Chapter 6 (6.14) | `SCREENSHOT` | AI Copilot Chat Interface with Streaming Markdown | `fig_6_4_ai_assistant_screen.png` | `PENDING` |
| **E-025** | Walkthrough (Sec 17) | `SCREENSHOT` | AI Remediation Patch Output for CVE-2024-3094 | `fig_w_06_ai_copilot_remediation.png` | `PENDING` |
| **E-026** | Chapter 6 (6.22) | `VIDEO` | AI Copilot Interactive Querying & Compliance PDF Export | `media/videos/demo_03_ai_copilot_pdf_export.mp4` | `PENDING` |

---

### 9. WebSocket
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-027** | Chapter 6 (6.13) | `CODE SNIPPET` | Dynamic URL Scheme Mapping (`http->ws`, `https->wss`) | `lib/core/network/websocket_service.dart` | `PENDING` |
| **E-028** | Chapter 8 (8.6) | `LOG` | WebSocket Handshake Token Verification & Connection Log | `log_websocket_handshake_session.txt` | `PENDING` |
| **E-029** | Chapter 8 (8.6) | `VIDEO` | Live WSS Threat Injection & Auto-Reconnect Demonstration | `media/videos/demo_04_websocket_resilience.mp4` | `PENDING` |

---

### 10. Wazuh
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-030** | Walkthrough (Sec 22) | `SCREENSHOT` | Parsed Wazuh HIDS Syslog Alarm in Mobile App | `fig_w_10_wazuh_syslog_inspection.png` | `PENDING` |
| **E-031** | Chapter 4 (4.7) | `LOG` | Raw Wazuh Syslog JSON Event Ingestion Payload | `log_wazuh_raw_syslog_payload.json` | `PENDING` |

---

### 11. GitHub
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-032** | Walkthrough (Sec 23) | `SCREENSHOT` | GitHub Monitored Repository Codebase Sync Screen | `fig_w_11_github_repository_sync.png` | `PENDING` |
| **E-033** | Chapter 7 (7.10) | `LOG` | GitHub HMAC-SHA256 Signature Verification Log | `log_github_webhook_hmac_verify.txt` | `PENDING` |

---

### 12. Semgrep
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-034** | Chapter 6 (6.12) | `SCREENSHOT` | Semgrep Static Analysis Finding with CWE-89 Tag | `fig_6_8_semgrep_finding_detail.png` | `PENDING` |
| **E-035** | Walkthrough (Sec 24) | `SCREENSHOT` | Line-Level Vulnerability Code Snippet Highlight | `fig_w_12_semgrep_code_highlight.png` | `PENDING` |
| **E-036** | Chapter 5 (5.7) | `CODE SNIPPET` | Semgrep Finding Deserialization Model | `lib/models/finding_model.dart` | `PENDING` |

---

### 13. Cloud Deployment
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-037** | Chapter 9 (9.5) | `SCREENSHOT` | Render Cloud Dashboard Active Service Status & Metrics | `fig_9_2_render_dashboard_service.png` | `PENDING` |
| **E-038** | Walkthrough (Sec 25) | `SCREENSHOT` | Render Git Auto-Deploy Build Log Output | `fig_w_08_render_cloud_deployment.png` | `PENDING` |
| **E-039** | Chapter 9 (9.8) | `CODE SNIPPET` | Multi-Stage Production Dockerfile (Flutter Web + Nginx) | `Dockerfile` | `PENDING` |
| **E-040** | Chapter 9 (9.14) | `VIDEO` | Cloud Git CI/CD Build & APK Sideload Demonstration | `media/videos/demo_05_deployment_release.mp4` | `PENDING` |

---

### 14. Android Application
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-041** | Chapter 9 (9.9) | `SCREENSHOT` | Android Release APK Compilation Console Output | `fig_9_3_android_release_apk.png` | `PENDING` |
| **E-042** | Chapter 9 (9.11) | `SCREENSHOT` | Google Play Console Data Safety & Release Management | `fig_9_4_play_store_console.png` | `PENDING` |
| **E-043** | Walkthrough (Sec 27) | `SCREENSHOT` | Android Physical Device Sideload Confirmation | `fig_w_09_android_apk_build.png` | `PENDING` |
| **E-044** | Walkthrough (Sec 30) | `VIDEO` | Complete End-to-End Operational Walkthrough | `media/videos/demo_06_master_walkthrough.mp4` | `PENDING` |

---

### 15. Testing
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-045** | Chapter 8 (8.12) | `SCREENSHOT` | Automated Test Suite Terminal Output (15/15 Passed) | `fig_8_2_automated_test_results.png` | `PENDING` |
| **E-046** | Chapter 8 (8.4) | `API RESPONSE` | Interactive API Client Request / Response Interceptor Log | `fig_8_1_api_response_verification.png` | `PENDING` |
| **E-047** | Chapter 8 (8.7) | `LOG` | Static Analysis `flutter analyze` Clean Log Output | `log_flutter_analyze_clean.txt` | `PENDING` |
| **E-048** | Chapter 8 (8.12) | `LOG` | Exhaustive Automated Test Execution Terminal Log | `log_flutter_test_all_passed.txt` | `PENDING` |

---

### 16. Security
| Evidence ID | Referenced Section | Evidence Type | Description | Suggested Filename | Status |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **E-049** | Chapter 7 (7.15) | `SCREENSHOT` | Generated Compliance PDF with SHA256 Audit Stamp | `fig_7_2_pdf_compliance_report_stamp.png` | `PENDING` |
| **E-050** | Walkthrough (Sec 18) | `SCREENSHOT` | Settings Screen with Environment & Biometric Toggles | `fig_w_07_settings_diagnostics.png` | `PENDING` |
| **E-051** | Chapter 7 (7.15) | `CODE SNIPPET` | Pure-Dart SHA256 Audit Digest Generation Routine | `lib/core/services/report_pdf_service.dart` | `PENDING` |
| **E-052** | Chapter 6 (6.6) | `CODE SNIPPET` | `_handleDioError()` Network Error Sanitization | `lib/core/network/api_client.dart` | `PENDING` |

---
