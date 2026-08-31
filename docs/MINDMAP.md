# SecurePulse Mobile — Master System Architecture Mindmap 🧠

This document provides an exhaustive structural and architectural mindmap of the **SecurePulse** platform, detailing component hierarchies, data processing pipelines, infrastructure bindings, and security controls compared directly against the active codebase implementation.

---

## 🗺️ Master Architectural Mindmap

```mermaid
mindmap
  root((SECUREPULSE))
    Mobile Client
      Dashboard
        Posture Gauge 88-94%
        Vulnerability Donut Chart
        Service Latency Health Badges
        Quick Action Dock
      Repositories
        Monitored Codebases
        Branch & Commit SHA Tracking
        Health Grades A to F
        On-Demand Scan Triggering
      Alerts
        Severity Filtering All/Crit/High/Med/Low
        Raw Syslog Payload Inspection
        Attacker IP & Port Tracking
        One-Tap Quarantine IP Status Triage
      AI Copilot
        Streaming Markdown Chat
        Offline CVE Heuristics (CVE-2024-3094, SQLi)
        Live Cloud LLM Bridge
        Copyable Code Patches
      Settings
        Environment Switcher (Cloud/Emulator/Local)
        Live Latency Ping Tool
        Biometric App-Lock Toggle
        Theme Switcher (Dark Obsidian / Light)
    Cloud Backend
      FastAPI Microservice
        Python 3.11 ASGI Engine
        Pydantic Request/Response Schemas
        CORS Whitelist Middleware
        12s Timeout Gates
      REST API Endpoints
        /health (Uptime Monitoring)
        /v1/auth/login & /me
        /v1/dashboard/summary
        /v1/repositories & /scan
        /v1/soc/alerts & /status
        /v1/ai/chat
        /v1/reports
      WebSocket Engine
        /ws/alerts (Real-Time Threat Stream)
        Dynamic Scheme Conversion (http->ws, https->wss)
        Query Token Authentication Handshake
        Exponential Backoff Reconnect Loop
      Authentication Tier
        Stateless JWT HS256 Tokens
        Password bcrypt Hashing
        Role-Based Claims (Analyst/Responder/Auditor)
      Database Persistence
        Cloud PostgreSQL 16 (SSL Enforced)
        Connection Pooling
        Hive Local Key-Value Box (securepulse_cache)
    Security Sources
      Wazuh SIEM
        Host Intrusion Detection (HIDS)
        SSH Brute-Force Syslog Ingestion
        Rootkit & FIM Event Parsing
        Wazuh Manager REST API [PLANNED]
      GitHub Integration
        Enterprise Codebase Sync
        Branch Metadata & Commit Hashes
        Direct Session Bearer Auth
        Interactive OAuth2 Deep-Linking [PLANNED]
      Semgrep Engine
        Static Application Security Testing (SAST)
        Line-Level Vulnerability Pinpointing
        CWE-89 & CWE-798 Rule Mapping
        Custom In-App Rule Editor [PLANNED]
    Processing Pipeline
      Security Events
        Syslog Stream Normalization
        WebSocket Event Deserialization
        Event Queue In-Memory Buffering
      Findings
        Severity Mapping (Critical/High/Med/Low)
        Source Code File & Line Attribution
        Remediation Guidance Formatting
      Alerts
        Lifecycle State Machine (Active->In Progress->Resolved)
        Status Mutation Ingestion
        Mitigation Action Triggering
      Scans
        On-Demand Scan Job Scheduling
        Scan Progress Polling
        Historical Scan Archive
      Risk & Posture
        Composite Posture Score Calculation
        Vulnerability Count Aggregation
        MTTD & MTTR Metrics [PLANNED]
    Artificial Intelligence
      Security Copilot
        Offline Regex Heuristic Matcher
        CVE Remediation Playbooks
        Cloud LLM Proxy (Live Mode)
        Autonomous PR Patch Creator [PLANNED]
        On-Device Quantized SLM Gemma-2B [PLANNED]
    Infrastructure
      Render Cloud
        Dockerized ASGI Web Service
        Automated Git CI/CD Deployments
        30s Health Check Probes
      PostgreSQL
        Managed Cloud Relational Database
        Continuous WAL Archiving & PITR
        SSL Mode Require Enforced
      HTTPS / WSS Transport
        Let's Encrypt TLS 1.3 Termination
        Port 443 Encrypted WebSocket Framing
        Local Loopback Cleartext Isolation
    Security & Cryptography
      JWT Security
        RFC 7519 Standard Stateless Tokens
        Header Bearer Injection
        Instant Keystore Token Purge on Logout
      Secret Management
        Zero Hardcoded Secrets in Client Code
        Cloud Runtime Environment Variables
        Encrypted Render Key Vault
      Authorization & RBAC
        Role-Based Endpoint Protection
        Token Claim Verification
        Multi-Tenant Scoped Tokens [PLANNED]
      Webhook Validation
        HMAC-SHA256 Payload Signatures
        Constant-Time Hash Comparison
        GitHub X-Hub-Signature-256 Check
      Audit Logging
        Pure-Dart On-Device SHA256 Hash Digest
        Cryptographic Stamp on Compliance PDFs
        Tamper-Evident Report Verification
```

---

## 🏛️ Comprehensive Component Hierarchy Diagram

```mermaid
graph TD
    subgraph "PRESENTATION TIER (Flutter 3.x Mobile)"
        DASH["Executive Dashboard<br>• Posture Gauge (88-94%)<br>• fl_chart Donut Graph<br>• Service Ping Badges"]
        REPOS["Monitored Repositories<br>• Health Grades A-F<br>• Branch Tracking<br>• Trigger SAST Scan"]
        ALERTS["SOC Alert Triage<br>• Severity Filtering<br>• Syslog Inspection<br>• Quarantine IP Action"]
        AI["AI Security Copilot<br>• Streaming Chat UI<br>• CVE-2024-3094 Patches<br>• SQLi / Secret Rotation"]
        REPORTS["Compliance PDF Engine<br>• SOC 2 / ISO 27001<br>• SHA256 Audit Stamp<br>• Pure-Dart Vector PDF"]
        SETT["Settings & Diagnostics<br>• Environment Switcher<br>• Server Ping Tester<br>• Biometric Lock Toggle"]
    end

    subgraph "STATE & DOMAIN TIER (Riverpod 2.6.1)"
        AUTH_P["AuthStateNotifier<br>• JWT Bearer Token<br>• Biometric Session Gate"]
        DASH_P["DashboardStreamProvider<br>• Telemetry Polling<br>• Cached State Hydration"]
        ALERT_P["WebSocketAlertProvider<br>• Full-Duplex Threat Stream<br>• Event Filtering State"]
        REPO_P["RepositoryScanProvider<br>• Scan Job Status<br>• Findings Aggregator"]
    end

    subgraph "DATA & TRANSPORT TIER"
        API_C["ApiClient (Dio 5.4.1)<br>• 12s Timeout Gates<br>• ApiException Mapping<br>• Dynamic Base URL"]
        WS_C["WebSocketService<br>• http->ws / https->wss<br>• Token Handshake<br>• Exponential Backoff"]
        SEC_S["SecureStorageService<br>• Android Keystore (AES-256)<br>• Apple Keychain"]
        HIVE_S["HiveStorageService<br>• securepulse_cache Box<br>• Zero-Latency Offline Read"]
    end

    subgraph "CLOUD BACKEND TIER (Render Cloud)"
        FASTAPI["FastAPI ASGI Server (Python 3.11)<br>• Pydantic Schemas<br>• CORS Whitelisting<br>• /health Uptime Probe"]
        POSTGRES[("Cloud PostgreSQL 16<br>• SSL Mode Require<br>• Connection Pooling")]
        LLM_PROXY["Cloud LLM Gateway<br>• Live AI Prompt Proxy"]
    end

    subgraph "EXTERNAL SECURITY SOURCES"
        WAZUH["Wazuh SIEM Connector<br>• HIDS Syslog Stream<br>• Brute-Force Alarms"]
        GITHUB["GitHub Telemetry API<br>• Codebase Metadata<br>• HMAC-SHA256 Webhooks"]
        SEMGREP["Semgrep SAST Engine<br>• CWE Code Findings<br>• Vulnerability Rules"]
    end

    %% Bindings
    DASH & REPOS & ALERTS & AI & REPORTS & SETT --> AUTH_P & DASH_P & ALERT_P & REPO_P
    AUTH_P & DASH_P & ALERT_P & REPO_P --> API_C & WS_C & SEC_S & HIVE_S
    API_C <-->|HTTPS / REST| FASTAPI
    WS_C <-->|WSS / WebSockets| FASTAPI
    FASTAPI --> POSTGRES
    FASTAPI --> LLM_PROXY
    FASTAPI <--> WAZUH & GITHUB & SEMGREP
```

---

## 🔬 Implementation Verification Matrix

The following table correlates every mindmap branch with the verified status in the codebase:

| Mindmap Branch | Specific Component | Codebase Implementation Reference | Status |
| :--- | :--- | :--- | :---: |
| **Mobile** | Executive Dashboard | `lib/features/dashboard/presentation/dashboard_screen.dart` | ✅ IMPLEMENTED |
| **Mobile** | Monitored Repositories | `lib/features/repositories/presentation/repositories_screen.dart` | ✅ IMPLEMENTED |
| **Mobile** | SOC Alert Triage | `lib/features/alerts/presentation/alerts_screen.dart` | ✅ IMPLEMENTED |
| **Mobile** | AI Security Copilot | `lib/features/ai/presentation/ai_assistant_screen.dart` | ✅ IMPLEMENTED |
| **Mobile** | Compliance PDF Generator | `lib/core/services/report_pdf_service.dart` | ✅ IMPLEMENTED |
| **Mobile** | Settings & Diagnostics | `lib/features/settings/presentation/settings_screen.dart` | ✅ IMPLEMENTED |
| **Cloud** | FastAPI Asynchronous Server | Cloud Microservice (`secureguard-backend-7eqm.onrender.com`) | ✅ IMPLEMENTED |
| **Cloud** | REST Endpoints Contract | `lib/core/network/api_endpoints.dart` | ✅ IMPLEMENTED |
| **Cloud** | WebSocket Threat Engine | `lib/core/network/websocket_service.dart` | ✅ IMPLEMENTED |
| **Cloud** | Database Persistence | Cloud PostgreSQL + `lib/core/storage/hive_storage_service.dart` | ✅ IMPLEMENTED |
| **Sources** | Wazuh Syslog Ingestion | `lib/features/alerts/data/alerts_repository.dart` | ✅ IMPLEMENTED |
| **Sources** | Wazuh Manager REST API | Direct remote daemon control | 🔵 PLANNED |
| **Sources** | GitHub Telemetry & Webhooks | `lib/features/repositories/data/repository_repository.dart` | ✅ IMPLEMENTED |
| **Sources** | GitHub OAuth2 Deep-Links | Interactive in-app OAuth2 callback redirect | 🔵 PLANNED |
| **Sources** | Semgrep SAST Scanning | `lib/repositories/scan_repository.dart` | ✅ IMPLEMENTED |
| **Sources** | Custom In-App Rule Editor | Mobile YAML rule authoring editor | 🔵 PLANNED |
| **Processing** | Syslog Event Normalization | `lib/features/alerts/models/alert_model.dart` | ✅ IMPLEMENTED |
| **Processing** | Alert Lifecycle State Machine | `updateAlertStatus()` in `AlertsRepository` | ✅ IMPLEMENTED |
| **AI** | Heuristic CVE Remediation | `AiRepositoryImpl._generateMockResponse()` | ✅ IMPLEMENTED |
| **AI** | Cloud LLM Chat Bridge | `POST /v1/ai/chat` client dispatch | ✅ IMPLEMENTED |
| **AI** | Autonomous PR Remediation | One-tap GitHub Pull Request patch generation | 🔵 PLANNED |
| **AI** | On-Device Quantized SLM | Gemma-2B / Llama-3-1B via ONNX Runtime | 🔵 PLANNED |
| **Security** | Hardware Biometric Gate | `lib/core/services/biometric_service.dart` (`local_auth`) | ✅ IMPLEMENTED |
| **Security** | Hardware Keystore Encryption | `lib/core/storage/secure_storage_service.dart` (AES-256) | ✅ IMPLEMENTED |
| **Security** | SHA256 PDF Audit Stamping | `ReportPdfService._generateAuditSignature()` | ✅ IMPLEMENTED |
| **Security** | Multi-Tenancy per Org | Dynamic organization switching & scoped tokens | 🔵 PLANNED |
| **Security** | Per-Device Mutual TLS (mTLS)| Client X.509 certificate enrollment | 🔵 PLANNED |

---
