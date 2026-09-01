# SecurePulse Mobile — Master System Architecture Mindmap 🧠

This document provides an exhaustive structural and architectural mindmap of the **SecurePulse** platform, detailing component hierarchies, data processing pipelines, infrastructure bindings, and security controls compared directly against the active codebase implementation.

---

## 🗺️ Master Architectural Mindmap

```mermaid
flowchart TB

    S["SECUREPULSE"]

    S --> M["📱 MOBILE CLIENT"]
    S --> B["☁️ CLOUD BACKEND"]
    S --> SS["🛡️ SECURITY SOURCES"]
    S --> P["⚙️ PROCESSING PIPELINE"]
    S --> AI["🤖 ARTIFICIAL INTELLIGENCE"]
    S --> I["🌐 INFRASTRUCTURE"]
    S --> SEC["🔐 SECURITY"]

    M --> D["Dashboard"]
    M --> R["Repositories"]
    M --> A["Alerts"]
    M --> C["AI Copilot"]
    M --> ST["Settings"]

    B --> F["FastAPI"]
    B --> API["REST API"]
    B --> WS["WebSocket"]
    B --> DB["PostgreSQL"]

    SS --> W["Wazuh"]
    SS --> G["GitHub"]
    SS --> SEM["Semgrep"]

    W --> EV["Security Events"]
    G --> EV
    SEM --> EV

    EV --> P
    P --> FIND["Findings"]
    P --> ALERT["Alerts"]
    P --> SCAN["Scans"]
    P --> RISK["Risk & Posture"]

    F --> API
    F --> WS
    F --> DB

    WS --> A
    WS --> D

    API --> D
    API --> R
    API --> A
    API --> C

    AI --> C
    AI --> LLM["Cloud LLM"]
    AI --> OFF["Offline Security Analysis"]

    I --> REN["Render Cloud"]
    I --> PG["Managed PostgreSQL"]
    I --> HTTPS["HTTPS / WSS"]

    SEC --> JWT["JWT Authentication"]
    SEC --> RBAC["RBAC Authorization"]
    SEC --> SECRET["Secret Management"]
    SEC --> WEB["Webhook Validation"]
    SEC --> AUDIT["Audit Logging"]

    REN --> F
    PG --> DB
    HTTPS --> WS

    classDef main fill:#0b1220,stroke:#2563eb,color:#ffffff,stroke-width:3px;
    classDef mobile fill:#111827,stroke:#3b82f6,color:#ffffff;
    classDef backend fill:#111827,stroke:#22c55e,color:#ffffff;
    classDef security fill:#111827,stroke:#ef4444,color:#ffffff;
    classDef ai fill:#111827,stroke:#a855f7,color:#ffffff;

    class S main;
    class M,D,R,A,C,ST mobile;
    class B,F,API,WS,DB backend;
    class SEC,JWT,RBAC,SECRET,WEB,AUDIT security;
    class AI,LLM,OFF ai;
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
        REPORTS["Compliance PDF Engine<br>• SOC 2 / ISO 27001<br>• Time-Stamped Audit ID<br>• Pure-Dart Vector PDF"]
        SETT["Settings & Diagnostics<br>• Environment Switcher<br>• Server Ping Tester<br>• Biometric Lock Toggle"]
    end

    subgraph "STATE & DOMAIN TIER (Riverpod 2.5.1)"
        AUTH_P["AuthStateNotifier<br>• JWT Bearer Token<br>• Biometric Session Gate"]
        DASH_P["DashboardStreamProvider<br>• Telemetry Polling<br>• Cached State Hydration"]
        ALERT_P["WebSocketAlertProvider<br>• Full-Duplex Threat Stream<br>• Event Filtering State"]
        REPO_P["RepositoryScanProvider<br>• Scan Job Status<br>• Findings Aggregator"]
    end

    subgraph "DATA & TRANSPORT TIER"
        API_C["ApiClient (Dio 5.4.1)<br>• 12s Timeout Gates<br>• ApiException Mapping<br>• Dynamic Base URL"]
        WS_C["WebSocketService<br>• http->ws / https->wss<br>• Token Handshake<br>• fixed 15-second retry"]
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
