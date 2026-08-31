# SecurePulse Mobile — Architecture & System Mindmap 🧠

This document visualizes the entire system architecture, component relationships, data flow pipelines, state tree, and security models of **SecurePulse Mobile**.

---

## 🗺️ Master Architecture Mindmap

```mermaid
mindmap
  root((SecurePulse Mobile))
    Presentation Layer
      Screens
        Splash & Auth
        Dashboard & Telemetry
        Repositories & SAST
        AI Security Copilot
        SOC Alerts & Triage
        Reports & PDF Generator
        Scans & Finding Details
        Settings & Diagnostics
      Design System
        Cyber Obsidian Dark Mode
        Light Theme Support
        Inter & Fira Code Fonts
        Custom SVG Badges & Charts
        Micro-animations
    State Management
      Riverpod 2.x
        Auth State Provider
        Dashboard Telemetry Stream
        Alert Stream & Filter Providers
        Repository & Scan Notifiers
        Theme & Settings Providers
        AI Chat Message State
    Domain & Business Logic
      Entities
        User & Token
        Vulnerability Finding
        SAST Scan Record
        SOC Alert Incident
        Audit Compliance Report
      Services
        Biometric Local Auth
        PDF Compiler Engine
        Notification Manager
        Device Info & Telemetry
    Network & Transport
      Dio HTTP Client
        JWT Auto-Bearer Interceptor
        Environment URL Switcher
        Timeout & Error Interceptor
      WebSocket Engine
        Live Incident Streaming
        Reconnection Protocol
        HTTP Polling Fallback
      Dual Mode Switcher
        Live Cloud API Mode
        Demo / Simulation Mode
    Local Storage & Security
      Flutter Secure Storage
        JWT Tokens
        Custom Endpoint Cache
      Hive Offline DB
        Encrypted Local Cache
        Recent Scans & Telemetry
      Hardware Biometrics
        Fingerprint & FaceID Gate
    External Integrations
      FastAPI Backend
      Render Cloud
      Wazuh SIEM
      GitHub SAST Semgrep
      Google Firebase FCM
```

---

## 🔄 Dual Operating Mode Data Flow

```mermaid
graph TD
    A[User Action / UI Request] --> B{Is Demo Mode Active?}
    
    %% Demo Branch
    B -- YES (Demo Mode) --> C[Mock Repository Layer]
    C --> D1[Realistic SIEM Wazuh Incidents]
    C --> D2[Precomputed Posture Metrics 94% Grade A]
    C --> D3[Sample Monitored Codebases]
    C --> D4[Local Rule-Based AI Responses]
    D1 & D2 & D3 & D4 --> E[Instant UI State Update with Zero Latency]

    %% Live Branch
    B -- NO (Live API Mode) --> F[ApiClient / WebSocketService]
    F --> G[FastAPI Cloud on Render / Localhost]
    G --> H1[PostgreSQL / Redis Threat Database]
    G --> H2[GitHub API & Semgrep SAST Engine]
    G --> H3[Live WebSocket Alert Broadcast]
    G --> H4[Multi-Model AI Knowledge Engine]
    H1 & H2 & H3 & H4 --> I[Encrypted Hive Cache & Reactive UI Updates]
```

---

## 🛡️ Security & Authentication Pipeline

```mermaid
sequenceDiagram
    autonumber
    actor Analyst as Security Analyst
    participant App as SecurePulse Mobile
    participant Bio as Hardware Biometrics
    participant SecStore as Flutter Secure Storage
    participant API as FastAPI Backend (Render)

    Analyst->>App: Launch Application
    App->>Bio: Query Biometric Availability
    Bio-->>App: Biometrics Supported (Face/Fingerprint)
    App->>Analyst: Prompt Biometric Challenge
    Analyst->>Bio: Biometric Confirmation
    Bio-->>App: Success Verified
    App->>SecStore: Read Encrypted JWT Token
    
    alt Token Exists & Valid
        SecStore-->>App: Access Token Retrieved
        App->>API: GET /v1/auth/me (Bearer Token)
        API-->>App: User Profile & Permissions OK
        App->>Analyst: Transition to Executive Dashboard
    else Token Missing or Expired
        App->>Analyst: Present Login Screen
        Analyst->>App: Enter Credentials (or Demo Mode)
        App->>API: POST /v1/auth/login
        API-->>App: 200 OK + JWT Token
        App->>SecStore: Persist Encrypted Token
        App->>Analyst: Navigate to Executive Dashboard
    end
```

---

## 📱 Navigation Graph & Screen Hierarchy

```mermaid
graph LR
    subgraph Root Entry
        Splash[Splash Screen] --> Login[Login Screen]
        Login --> Shell[5-Tab Shell Route]
    end

    subgraph Primary Bottom Tabs
        Shell --> Tab1[1. Dashboard Screen]
        Shell --> Tab2[2. Repositories Screen]
        Shell --> Tab3[3. AI Assistant Screen]
        Shell --> Tab4[4. SOC Alerts Screen]
        Shell --> Tab5[5. Settings Screen]
    end

    subgraph Deep Detail Routes
        Tab1 --> Scans[Scans Screen]
        Tab1 --> Reports[Reports Screen]
        Tab2 --> RepoDetail[Repository Detail Screen]
        Tab2 --> Findings[Findings Screen]
        Findings --> FindingDetail[Finding Detail Screen]
        Scans --> ScanDetail[Scan Detail Screen]
        Tab4 --> AlertDetail[Alert Detail Screen]
        Tab5 --> Profile[Analyst Profile Screen]
    end
```
