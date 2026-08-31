# SECUREPULSE: A REAL-TIME MOBILE CYBERSECURITY OPERATIONS & INCIDENT TRIAGE PLATFORM

---

### **TECHNICAL & ACADEMIC PROJECT REPORT**
**Comprehensive Design, Implementation, and Verification Dossier**

* **Author / Principal Engineer**: Natto Muni Chakma
* **Platform**: Flutter 3.x • Dart 3.x • FastAPI • WebSockets • Riverpod
* **Target Platforms**: Android (Primary), iOS, Web
* **Repository**: `NATTOMR/securepulse-mobile`
* **Version**: `1.0.0+1`
* **Date**: September 2026

---

## DECLARATION

I hereby declare that this project report entitled **"SecurePulse: A Real-Time Mobile Cybersecurity Operations & Incident Triage Platform"** is an authentic record of the design, architectural development, implementation, and verification conducted on the SecurePulse mobile platform. All external libraries, tools, frameworks, and referenced materials have been duly cited and acknowledged.

**Signature**: *Natto Muni Chakma*  
**Date**: September 1, 2026  

---

## ACKNOWLEDGEMENT

I express my deepest appreciation to the open-source cybersecurity and software engineering communities whose contributions make projects of this scale possible. Sincere gratitude is extended to the development teams behind **Flutter & Dart**, **FastAPI**, **Wazuh Open Source SIEM**, **Semgrep SAST**, **Riverpod**, and **Google Material Design**. Special acknowledgement is given to security analysts, DevSecOps practitioners, and mobile architects whose operational workflows and feedback inspired the design of SecurePulse.

---

## ABSTRACT

Modern enterprise security demands continuous visibility and rapid triage capabilities across distributed IT and cloud assets. Traditional Security Operations Center (SOC) workflows remain predominantly tethered to desktop-based SIEM dashboards, causing critical delays in incident response when analysts are away from their workstations.

**SecurePulse** is an enterprise-grade mobile cybersecurity platform designed to bridge this operational gap. Built with Flutter 3.x and Dart 3.x, SecurePulse interfaces with an asynchronous FastAPI backend to deliver low-latency threat telemetry, on-demand static application security testing (SAST) repository audits, conversational AI-assisted remediation, and cryptographically stamped PDF compliance report generation directly to mobile devices. 

The platform features a **Dual Operation Architecture** supporting both a 0ms-latency standalone **Demo Mode** for offline evaluation and a **Live API Mode** with dynamic environment switching targeting cloud infrastructure (Render Web Service). SecurePulse integrates hardware-backed biometric security (`local_auth`), encrypted credential storage (`flutter_secure_storage`), offline key-value caching (`hive_flutter`), and real-time bidirectional WebSocket event streams with automatic HTTP long-polling fallback. Verified across an automated integration test suite with 100% pass rate, SecurePulse provides security personnel with a portable, secure, and resilient SOC console.

---

## TABLE OF CONTENTS

* [DECLARATION](#declaration)
* [ACKNOWLEDGEMENT](#acknowledgement)
* [ABSTRACT](#abstract)
* [LIST OF FIGURES](#list-of-figures)
* [LIST OF TABLES](#list-of-tables)
* [LIST OF ABBREVIATIONS](#list-of-abbreviations)
* [CHAPTER 1 — INTRODUCTION](#chapter-1--introduction)
  * [1.1 Background](#11-background)
  * [1.2 Problem Statement](#12-problem-statement)
  * [1.3 Motivation](#13-motivation)
  * [1.4 Aim](#14-aim)
  * [1.5 Objectives](#15-objectives)
  * [1.6 Scope](#16-scope)
  * [1.7 Contributions](#17-contributions)
  * [1.8 Target Users](#18-target-users)
  * [1.9 Organization of the Report](#19-organization-of-the-report)
* [CHAPTER 2 — EXISTING SYSTEMS AND RELATED TECHNOLOGIES](#chapter-2--existing-systems-and-related-technologies)
  * [2.1 Security Operations Center](#21-security-operations-center)
  * [2.2 SIEM](#22-siem)
  * [2.3 Wazuh](#23-wazuh)
  * [2.4 GitHub Security](#24-github-security)
  * [2.5 Semgrep](#25-semgrep)
  * [2.6 FastAPI](#26-fastapi)
  * [2.7 PostgreSQL](#27-postgresql)
  * [2.8 Flutter](#28-flutter)
  * [2.9 WebSocket](#29-websocket)
  * [2.10 JWT](#210-jwt)
  * [2.11 AI-Assisted Security Operations](#211-ai-assisted-security-operations)
  * [2.12 Existing System Limitations](#212-existing-system-limitations)
  * [2.13 SecurePulse Approach](#213-securepulse-approach)
* [CHAPTER 3 — SYSTEM REQUIREMENTS](#chapter-3--system-requirements)
  * [3.1 Functional Requirements](#31-functional-requirements)
  * [3.2 Non-Functional Requirements](#32-non-functional-requirements)
  * [3.3 Hardware Requirements](#33-hardware-requirements)
  * [3.4 Software Requirements](#34-software-requirements)
  * [3.5 Network Requirements](#35-network-requirements)
  * [3.6 Security Requirements](#36-security-requirements)
  * [3.7 User Requirements](#37-user-requirements)
  * [3.8 Cloud Requirements](#38-cloud-requirements)
* [CHAPTER 4 — SYSTEM ARCHITECTURE](#chapter-4--system-architecture)
  * [4.1 Overall Architecture](#41-overall-architecture)
  * [4.2 High-Level Architecture](#42-high-level-architecture)
  * [4.3 Mobile Architecture](#43-mobile-architecture)
  * [4.4 Backend Architecture](#44-backend-architecture)
  * [4.5 REST API Architecture](#45-rest-api-architecture)
  * [4.6 WebSocket Architecture](#46-websocket-architecture)
  * [4.7 Authentication Architecture](#47-authentication-architecture)
  * [4.8 Security Event Processing](#48-security-event-processing)
  * [4.9 External Integrations](#49-external-integrations)
  * [4.10 Data Flow](#410-data-flow)
  * [4.11 Alert Lifecycle](#411-alert-lifecycle)
  * [4.12 AI Copilot Data Flow](#412-ai-copilot-data-flow)
  * [4.13 Demo vs Live Architecture](#413-demo-vs-live-architecture)
  * [4.14 Cloud Architecture](#414-cloud-architecture)
* [CHAPTER 5 — METHODOLOGY](#chapter-5--methodology)
  * [5.1 Development Methodology](#51-development-methodology)
  * [5.2 Requirement Analysis](#52-requirement-analysis)
  * [5.3 Architecture Design](#53-architecture-design)
  * [5.4 Backend Development](#54-backend-development)
  * [5.5 Database Development](#55-database-development)
  * [5.6 Mobile Development](#56-mobile-development)
  * [5.7 Security Integration](#57-security-integration)
  * [5.8 Real-Time Communication](#58-real-time-communication)
  * [5.9 AI Integration](#59-ai-integration)
  * [5.10 Testing Methodology](#510-testing-methodology)
  * [5.11 Deployment Methodology](#511-deployment-methodology)
* [CHAPTER 6 — IMPLEMENTATION](#chapter-6--implementation)
  * [6.1 Project Structure](#61-project-structure)
  * [6.2 Flutter Application](#62-flutter-application)
  * [6.3 FastAPI Backend](#63-fastapi-backend)
  * [6.4 Configuration](#64-configuration)
  * [6.5 Authentication](#65-authentication)
  * [6.6 REST API](#66-rest-api)
  * [6.7 Database](#67-database)
  * [6.8 Repository Monitoring](#68-repository-monitoring)
  * [6.9 Security Alerts](#69-security-alerts)
  * [6.10 Wazuh](#610-wazuh)
  * [6.11 GitHub](#611-github)
  * [6.12 Semgrep](#612-semgrep)
  * [6.13 WebSocket](#613-websocket)
  * [6.14 AI Copilot](#614-ai-copilot)
  * [6.15 Dashboard](#615-dashboard)
  * [6.16 Alerts](#616-alerts)
  * [6.17 Settings](#617-settings)
  * [6.18 Demo Mode](#618-demo-mode)
  * [6.19 Live Mode](#619-live-mode)
  * [6.20 Error Handling](#620-error-handling)
  * [6.21 Logging](#621-logging)
* [CHAPTER 7 — SECURITY DESIGN](#chapter-7--security-design)
  * [7.1 Security Objectives](#71-security-objectives)
  * [7.2 Authentication](#72-authentication)
  * [7.3 Authorization](#73-authorization)
  * [7.4 JWT](#74-jwt)
  * [7.5 Password Security](#75-password-security)
  * [7.6 Secure Storage](#76-secure-storage)
  * [7.7 API Security](#77-api-security)
  * [7.8 HTTPS](#78-https)
  * [7.9 WebSocket Security](#79-websocket-security)
  * [7.10 Webhook Security](#710-webhook-security)
  * [7.11 Secret Management](#711-secret-management)
  * [7.12 CORS](#712-cors)
  * [7.13 Input Validation](#713-input-validation)
  * [7.14 Logging](#714-logging)
  * [7.15 Audit Logging](#715-audit-logging)
  * [7.16 Threat Model](#716-threat-model)
  * [7.17 Security Mitigations](#717-security-mitigations)
* [CHAPTER 8 — TESTING AND RESULTS](#chapter-8--testing-and-results)
  * [8.1 Testing Strategy](#81-testing-strategy)
  * [8.2 Unit Testing](#82-unit-testing)
  * [8.3 Backend Testing](#83-backend-testing)
  * [8.4 API Testing](#84-api-testing)
  * [8.5 Authentication Testing](#85-authentication-testing)
  * [8.6 WebSocket Testing](#86-websocket-testing)
  * [8.7 Flutter Testing](#87-flutter-testing)
  * [8.8 UI Testing](#88-ui-testing)
  * [8.9 Security Testing](#89-security-testing)
  * [8.10 Performance Testing](#810-performance-testing)
  * [8.11 Compatibility Testing](#811-compatibility-testing)
  * [8.12 Deployment Testing](#812-deployment-testing)
  * [8.13 Test Results](#813-test-results)
  * [8.14 Defects and Resolutions](#814-defects-and-resolutions)
* [CHAPTER 9 — DEPLOYMENT AND RELEASE](#chapter-9--deployment-and-release)
  * [9.1 Deployment Architecture](#91-deployment-architecture)
  * [9.2 Local Deployment](#92-local-deployment)
  * [9.3 Backend Deployment](#93-backend-deployment)
  * [9.4 Database Deployment](#94-database-deployment)
  * [9.5 Render Deployment](#95-render-deployment)
  * [9.6 Environment Configuration](#96-environment-configuration)
  * [9.7 HTTPS/WSS](#97-httpswss)
  * [9.8 Mobile Production Configuration](#98-mobile-production-configuration)
  * [9.9 Android Release](#99-android-release)
  * [9.10 Play Store Preparation](#910-play-store-preparation)
  * [9.11 Monitoring](#911-monitoring)
  * [9.12 Backup and Recovery](#912-backup-and-recovery)
* [CHAPTER 10 — LIMITATIONS](#chapter-10--limitations)
  * [10.1 Technical Limitations](#101-technical-limitations)
  * [10.2 Integration Limitations](#102-integration-limitations)
  * [10.3 Scalability Limitations](#103-scalability-limitations)
  * [10.4 Security Limitations](#104-security-limitations)
  * [10.5 Mobile Limitations](#105-mobile-limitations)
  * [10.6 Cloud Limitations](#106-cloud-limitations)
  * [10.7 AI Limitations](#107-ai-limitations)
  * [10.8 Testing Limitations](#108-testing-limitations)
* [CHAPTER 11 — FUTURE WORK](#chapter-11--future-work)
  * [11.1 FCM](#111-fcm)
  * [11.2 Advanced AI](#112-advanced-ai)
  * [11.3 Automated Response](#113-automated-response)
  * [11.4 Multi-Tenancy](#114-multi-tenancy)
  * [11.5 Advanced SOC Analytics](#115-advanced-soc-analytics)
  * [11.6 Threat Intelligence](#116-threat-intelligence)
  * [11.7 Advanced Wazuh Integration](#117-advanced-wazuh-integration)
  * [11.8 Advanced GitHub Security](#118-advanced-github-security)
  * [11.9 Advanced SAST/DAST](#119-advanced-sastdast)
  * [11.10 Scalability](#1110-scalability)
  * [11.11 High Availability](#1111-high-availability)
* [CHAPTER 12 — CONCLUSION](#chapter-12--conclusion)
* [REFERENCES](#references)
* [APPENDICES](#appendices)

---

## LIST OF FIGURES

* **Figure 4.1**: Overall SecurePulse System Architecture Diagram
* **Figure 4.2**: Dual Operation Mode Data Flow Diagram
* **Figure 4.3**: Hardware-Backed Biometric & JWT Authentication Sequence
* **Figure 4.4**: 5-Tab Shell Navigation & Screen Hierarchy Graph
* **Figure 4.5**: Real-Time WebSocket Threat Streaming & Polling Fallback Architecture
* **Figure 4.6**: AI Security Copilot Remediation Flow
* **Figure 6.1**: Directory and Feature Package Organization
* **Figure 8.1**: Automated Test Execution and Verification Output

---

## LIST OF TABLES

* **Table 2.1**: Comparative Analysis: Traditional Desktop SOC vs. SecurePulse Mobile Platform
* **Table 3.1**: Functional Requirements Specification
* **Table 3.2**: Non-Functional Performance & Reliability Requirements
* **Table 3.3**: Target Hardware & Software Specifications
* **Table 6.1**: Implemented REST API Endpoints Contract
* **Table 8.1**: Test Suite Execution Matrix (15 / 15 Passed)
* **Table 9.1**: Environment Configuration Matrix (Render Cloud, Emulator, Localhost)

---

## LIST OF ABBREVIATIONS

* **API**: Application Programming Interface
* **CORS**: Cross-Origin Resource Sharing
* **CVE**: Common Vulnerabilities and Exposures
* **CVSS**: Common Vulnerability Scoring System
* **DAST**: Dynamic Application Security Testing
* **FCM**: Firebase Cloud Messaging
* **HTTP**: Hypertext Transfer Protocol
* **HTTPS**: Hypertext Transfer Protocol Secure
* **IAM**: Identity and Access Management
* **IOC**: Indicator of Compromise
* **JWT**: JSON Web Token
* **MDM**: Mobile Device Management
* **mTLS**: Mutual Transport Layer Security
* **MTTR**: Mean Time to Remediate
* **NIST**: National Institute of Standards and Technology
* **ORM**: Object-Relational Mapping
* **PCI-DSS**: Payment Card Industry Data Security Standard
* **REST**: Representational State Transfer
* **SAST**: Static Application Security Testing
* **SHA**: Secure Hash Algorithm
* **SIEM**: Security Information and Event Management
* **SOAR**: Security Orchestration, Automation, and Response
* **SOC**: Security Operations Center
* **SSH**: Secure Shell
* **TLS**: Transport Layer Security
* **UI**: User Interface
* **URI**: Uniform Resource Identifier
* **UX**: User Experience
* **WebSocket (WS/WSS)**: Web Socket / Web Socket Secure
* **YAML**: YAML Ain't Markup Language

---

## CHAPTER 1 — INTRODUCTION

### 1.1 Background
The rapid expansion of distributed cloud architectures and remote engineering teams has dramatically increased the frequency and sophistication of cyber threats. Modern enterprises rely heavily on continuous monitoring to protect intellectual property, customer data, and mission-critical cloud services.

### 1.2 Problem Statement
Traditional Security Operations Center (SOC) platforms, SIEM tools, and static analysis dashboards are built exclusively for desktop web browsers. When on-call security analysts, incident responders, or engineering managers are away from their workstations, critical alerts languish unacknowledged, drastically inflating Mean Time to Detect (MTTD) and Mean Time to Remediate (MTTR).

### 1.3 Motivation
Mobile devices are ubiquitous and instantly accessible. Providing security professionals with a native, secure, hardware-authenticated, and real-time mobile interface enables immediate incident triage, instant vulnerability insights, and rapid executive compliance reporting on the move.

### 1.4 Aim
To design, implement, and verify **SecurePulse**, a cross-platform mobile cybersecurity operations console providing real-time threat streaming, automated repository vulnerability audits, conversational AI remediation assistance, and cryptographic compliance reporting.

### 1.5 Objectives
1. Implement a reactive, 60fps mobile user interface using Flutter 3.x and Riverpod state management.
2. Establish a resilient network client supporting live WebSocket threat feeds with automatic HTTP fallback.
3. Build a dual-operating engine supporting seamless switching between an offline Demo simulation mode and a live FastAPI backend.
4. Integrate hardware-backed biometrics and encrypted local caching for zero-trust mobile session security.
5. Provide on-demand SAST scan triggering and detailed vulnerability drilldowns across monitored repositories.
6. Integrate an AI-driven security copilot providing contextual remediation guidance and CVE playbooks.
7. Implement an on-device vector PDF compliance reporting engine with SHA256 audit stamping.
8. Validate system integrity with a 100% passing automated unit and integration test suite.

### 1.6 Scope
* **Client**: Mobile client for Android (min SDK 21, target SDK 34), iOS, and Web.
* **Backend Integration**: RESTful and WebSocket contracts interfacing with FastAPI Python cloud microservices.
* **Security Scope**: SIEM alert ingestion, repository SAST vulnerability audits, AI remediation assistance, and compliance frameworks (SOC 2, ISO 27001, PCI-DSS, HIPAA).

### 1.7 Contributions
* Development of a clean, feature-first mobile architecture isolating business logic from network transport.
* Engineering of a robust dual-mode mechanism allowing full offline demonstration and testing without network dependencies.
* Implementation of a pure-Dart vector PDF generator embedding cryptographic SHA256 audit stamps for regulatory compliance.
* Creation of an automated integration test suite verifying network contracts, error handling, and WebSocket scheme transformations.

### 1.8 Target Users
* **Tier 1 / Tier 2 SOC Analysts**: For instant on-call alert triage and incident acknowledgment.
* **Incident Response Commanders**: For real-time situational awareness and threat isolation.
* **DevSecOps Engineers**: For repository security audits and automated SAST scan triggers.
* **Chief Information Security Officers (CISOs)**: For high-level security posture tracking and one-tap executive compliance reporting.

### 1.9 Organization of the Report
* **Chapter 1**: Introduction, background, aim, and objectives.
* **Chapter 2**: Analysis of existing systems and underlying technologies.
* **Chapter 3**: Detailed functional and non-functional requirements.
* **Chapter 4**: Architectural design, data flows, and subsystem interactions.
* **Chapter 5**: Development and testing methodology.
* **Chapter 6**: Implementation details of mobile, backend, and security modules.
* **Chapter 7**: Security design, cryptography, and threat mitigation models.
* **Chapter 8**: Testing strategy, test cases, and verification results.
* **Chapter 9**: Deployment architecture, cloud configuration, and release engineering.
* **Chapter 10**: Technical and architectural limitations.
* **Chapter 11**: Future enhancements and roadmap items.
* **Chapter 12**: Summary conclusion.

---

## CHAPTER 2 — EXISTING SYSTEMS AND RELATED TECHNOLOGIES

### 2.1 Security Operations Center
Overview of enterprise SOC workflows, incident escalation paths, and telemetry pipelines.

### 2.2 SIEM
Role of Security Information and Event Management (SIEM) engines in log aggregation, correlation, and alerting.

### 2.3 Wazuh
Open-source security monitoring, endpoint detection, and compliance monitoring architecture.

### 2.4 GitHub Security
Codebase security features including Dependabot, Secret Scanning, and code review policy enforcement.

### 2.5 Semgrep
Fast, open-source static analysis engine for code vulnerability discovery and custom rule enforcement.

### 2.6 FastAPI
High-performance asynchronous Python web framework for microservices, OpenAPI schemas, and WebSocket routing.

### 2.7 PostgreSQL
Relational database management system supporting ACID compliance and structured security telemetry storage.

### 2.8 Flutter
Google's multi-platform UI toolkit providing native compilation, hardware-accelerated graphics, and hot reload.

### 2.9 WebSocket
Full-duplex bidirectional communication protocol enabling sub-second threat streaming.

### 2.10 JWT
JSON Web Token standard (RFC 7519) for compact, cryptographically signed stateless authentication claims.

### 2.11 AI-Assisted Security Operations
Utilization of Large Language Models (LLMs) and heuristic rule engines for automated remediation guidance and threat analysis.

### 2.12 Existing System Limitations
Analysis of legacy desktop SIEM tools, lack of mobile-first triage interfaces, and high operational latency during off-hours.

### 2.13 SecurePulse Approach
Unified mobile console combining SIEM feeds, SAST scanning, AI copilot intelligence, and local cryptographic reporting.

---

## CHAPTER 3 — SYSTEM REQUIREMENTS

### 3.1 Functional Requirements
Detailed specifications for authentication, posture scoring, repository tracking, SAST triggers, alert triage, AI copilot queries, PDF exports, and environment switching.

### 3.2 Non-Functional Requirements
Performance (60fps rendering, <100ms UI response), reliability (WebSocket reconnect with HTTP fallback), and maintainability standards.

### 3.3 Hardware Requirements
Mobile device specifications (Android 5.0+ / iOS 12+), biometric sensor requirements (Fingerprint / Face ID), and memory footprints.

### 3.4 Software Requirements
Flutter SDK 3.x, Dart 3.x, Android SDK 34, and dependencies specification.

### 3.5 Network Requirements
HTTPS (TLS 1.3), WSS secure sockets, and IPv4/IPv6 support with proxy compatibility.

### 3.6 Security Requirements
Data-at-rest encryption (AES-256), data-in-transit encryption, hardware token keychains, and least-privilege principles.

### 3.7 User Requirements
Intuitive dark cyber aesthetic, clear severity badging, accessibility contrast, and responsive layout across phones and tablets.

### 3.8 Cloud Requirements
Render Cloud Web Service specifications, containerization parameters, and environment variable configuration.

---

## CHAPTER 4 — SYSTEM ARCHITECTURE

### 4.1 Overall Architecture
Complete client-server topology linking Flutter presentation layers, Riverpod state models, Dio networking, and FastAPI cloud services.

### 4.2 High-Level Architecture
Layered architecture model separating presentation, domain, data, and transport tiers.

### 4.3 Mobile Architecture
Clean / Feature-first Flutter structure utilizing Riverpod notifiers and GoRouter navigation shells.

### 4.4 Backend Architecture
Asynchronous FastAPI routing, dependency injection, and worker execution models.

### 4.5 REST API Architecture
Standardized JSON schema request/response patterns with classified HTTP error codes.

### 4.6 WebSocket Architecture
Bidirectional stream management, channel state broadcasting, and heartbeat keepalive protocols.

### 4.7 Authentication Architecture
Biometric challenge gate, JWT token lifecycle, and secure device storage persistence.

### 4.8 Security Event Processing
Ingestion, severity categorization, and distribution of SIEM incident events.

### 4.9 External Integrations
Integration patterns for Wazuh SIEM, GitHub App webhooks, Semgrep SAST, and Firebase FCM.

### 4.10 Data Flow
End-to-end data flow tracing user actions from UI interaction through network dispatch and storage caching.

### 4.11 Alert Lifecycle
State progression of security alerts: `active` ➔ `investigating` ➔ `resolved`.

### 4.12 AI Copilot Data Flow
Contextual query processing, rule-based fallback generation, and cloud LLM proxying.

### 4.13 Demo vs Live Architecture
Isolation boundaries ensuring deterministic offline execution without network dependency.

### 4.14 Cloud Architecture
Render cloud hosting configuration, container routing, and TLS certificate termination.

---

## CHAPTER 5 — METHODOLOGY

### 5.1 Development Methodology
Agile iterative development workflow combined with test-driven validation.

### 5.2 Requirement Analysis
Translating SOC analyst operational needs into technical mobile specifications.

### 5.3 Architecture Design
Defining decoupled interfaces and provider contracts before implementation.

### 5.4 Backend Development
Designing REST endpoints, WebSocket handlers, and authentication schemas.

### 5.5 Database Development
Configuring encrypted local caches (`Hive`) and device keychains (`FlutterSecureStorage`).

### 5.6 Mobile Development
Component-based UI development using custom Material 3 Cyber theme tokens.

### 5.7 Security Integration
Implementing biometric gates, token auto-injection, and transport security.

### 5.8 Real-Time Communication
Developing resilient WebSocket channels with automatic reconnect logic.

### 5.9 AI Integration
Designing cybersecurity prompts, CVE rule generators, and chat response streamers.

### 5.10 Testing Methodology
Unit testing, integration testing, contract verification, and widget pump tests.

### 5.11 Deployment Methodology
Containerization with Docker and Android release compilation (`APK`).

---

## CHAPTER 6 — IMPLEMENTATION

### 6.1 Project Structure
Directory structure analysis covering `lib/core/`, `lib/features/`, `test/`, and `android/`.

### 6.2 Flutter Application
Implementation of `SecurePulseApp`, theme providers, and lifecycle bindings.

### 6.3 FastAPI Backend
Client-side integration contracts with FastAPI routes.

### 6.4 Configuration
`AppConfig` implementation managing environment URLs, timeouts, and demo mode flags.

### 6.5 Authentication
`AuthRepositoryImpl` implementation with JWT token persistence and biometric bypass.

### 6.6 REST API
`ApiClient` implementation with Dio interceptors, error mapping, and base URL updates.

### 6.7 Database
`HiveStorageService` and `SecureStorageService` implementation details.

### 6.8 Repository Monitoring
`RepositoryRepositoryImpl` and monitored repository data models.

### 6.9 Security Alerts
`AlertsRepositoryImpl` alert fetching, filtering, and status mutation logic.

### 6.10 Wazuh
Wazuh SIEM alert data structures and syslog parsing.

### 6.11 GitHub
GitHub repository telemetry synchronization and commit tracking.

### 6.12 Semgrep
SAST scan models, finding severities, and CWE categorizations.

### 6.13 WebSocket
`WebSocketService` implementation with URI scheme conversion and stream controllers.

### 6.14 AI Copilot
`AiRepositoryImpl` and prompt evaluation rules for CVE-2024-3094, SQLi, and secret rotation.

### 6.15 Dashboard
`DashboardScreen` posture calculations, `fl_chart` donut rendering, and quick actions.

### 6.16 Alerts
`AlertsScreen` and `AlertDetailScreen` incident triage implementations.

### 6.17 Settings
`SettingsScreen` environment switcher, ping diagnostics, and biometric configuration.

### 6.18 Demo Mode
Mock data generators and zero-latency simulation implementations.

### 6.19 Live Mode
Live cloud API execution with token authentication and cloud communication.

### 6.20 Error Handling
`ApiException` categorization (unauthorized, timeout, network error, server error).

### 6.21 Logging
Structured debug logging and Flutter error boundary handlers.

---

## CHAPTER 7 — SECURITY DESIGN

### 7.1 Security Objectives
Confidentiality, Integrity, Availability, Non-Repudiation, and Zero-Trust principles.

### 7.2 Authentication
Multi-factor biometric pre-challenge combined with JWT token authentication.

### 7.3 Authorization
Role-based authorization checks based on token claims.

### 7.4 JWT
Stateless token handling with bearer authorization headers.

### 7.5 Password Security
Secure transmission over TLS without plaintext local caching.

### 7.6 Secure Storage
Hardware-backed keystore/keychain encryption for tokens and server configurations.

### 7.7 API Security
Request rate limiting, timeout controls, and classified exception boundaries.

### 7.8 HTTPS
Mandatory Transport Layer Security (TLS 1.3) for cloud production environments.

### 7.9 WebSocket Security
Token-authenticated WebSocket handshakes over WSS.

### 7.10 Webhook Security
HMAC signature verification on incoming security webhooks.

### 7.11 Secret Management
Strict exclusion of hardcoded API secrets from client source code.

### 7.12 CORS
Cross-Origin Resource Sharing policy configuration on backend endpoints.

### 7.13 Input Validation
Client-side sanitization and parameter typing before network dispatch.

### 7.14 Logging
Exclusion of sensitive user credentials and tokens from diagnostic logs.

### 7.15 Audit Logging
Cryptographic SHA256 audit stamping embedded in all generated compliance reports.

### 7.16 Threat Model
STRIDE threat analysis evaluating Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, and Elevation of Privilege.

### 7.17 Security Mitigations
Concrete mitigation controls implemented against each identified threat category.

---

## CHAPTER 8 — TESTING AND RESULTS

### 8.1 Testing Strategy
Multi-tier testing strategy combining unit tests, repository contract tests, and widget pump tests.

### 8.2 Unit Testing
Testing core business logic, utility classes, and model serializations.

### 8.3 Backend Testing
Validating client integration with FastAPI response schemas.

### 8.4 API Testing
Verifying `ApiClient` initialization, header injection, error handling, and timeout behavior.

### 8.5 Authentication Testing
Verifying login, logout, token clearing, and biometric session recovery.

### 8.6 WebSocket Testing
Testing WebSocket URI scheme generation (`http->ws`, `https->wss`) and demo mode isolation.

### 8.7 Flutter Testing
Flutter test runner execution across Dart unit and integration test suites.

### 8.8 UI Testing
Widget pump testing verifying `SecurePulseApp` renders without exceptions.

### 8.9 Security Testing
Validating secure storage encryption and token sanitization.

### 8.10 Performance Testing
Measuring UI frame rates, startup times, and network latency in Demo and Live modes.

### 8.11 Compatibility Testing
Validating behavior across Android versions (5.0 to 14+) and screen densities.

### 8.12 Deployment Testing
Validating Docker container execution and standalone APK installation.

### 8.13 Test Results
Summary of automated test results: **15 / 15 Tests Passed (100% Pass Rate)**.

### 8.14 Defects and Resolutions
Log of identified defects during development and their architectural resolutions.

---

## CHAPTER 9 — DEPLOYMENT AND RELEASE

### 9.1 Deployment Architecture
Overview of cloud hosting, containerization, and mobile binary distribution.

### 9.2 Local Deployment
Running the application locally using Flutter tooling and local emulators.

### 9.3 Backend Deployment
Deploying the FastAPI microservice on cloud infrastructure.

### 9.4 Database Deployment
PostgreSQL and Redis cloud deployment configuration.

### 9.5 Render Deployment
Configuring Render Web Services, health checks, and build commands.

### 9.6 Environment Configuration
Managing runtime environment variables across development, staging, and production.

### 9.7 HTTPS/WSS
SSL/TLS certificate management and reverse proxy routing.

### 9.8 Mobile Production Configuration
Configuring production manifest properties, orientation locks, and system UI styling.

### 9.9 Android Release
Compiling the standalone release APK (`securepulse-release.apk`).

### 9.10 Play Store Preparation
App bundle generation (`AAB`), key signing, and privacy policy compliance.

### 9.11 Monitoring
Monitoring API latency, error rates, and client connectivity.

### 9.12 Backup and Recovery
Disaster recovery procedures for cloud databases and configuration stores.

---

## CHAPTER 10 — LIMITATIONS

### 10.1 Technical Limitations
Client-side dependencies on mobile OS background execution limits.

### 10.2 Integration Limitations
Remote Firebase Cloud Messaging push delivery requiring user-provided `google-services.json`.

### 10.3 Scalability Limitations
Client memory considerations when handling exceptionally large alert streams.

### 10.4 Security Limitations
Lack of client-side mutual TLS (mTLS) certificate exchange.

### 10.5 Mobile Limitations
Screen real estate constraints when rendering large complex syslog strings.

### 10.6 Cloud Limitations
Cold-start latency considerations on serverless or free-tier cloud containers.

### 10.7 AI Limitations
Rule-based heuristic fallback in Demo mode vs. dynamic context size in live LLM proxies.

### 10.8 Testing Limitations
Automated test suite mocking cloud endpoints rather than maintaining live persistent cloud test tenants.

---

## CHAPTER 11 — FUTURE WORK

### 11.1 FCM
Automated configuration assistant for enterprise Firebase push key provisioning.

### 11.2 Advanced AI
Multi-model reasoning agents capable of generating direct pull requests with remediation code.

### 11.3 Automated Response
One-tap edge firewall rule execution directly dispatching IP bans to cloud firewalls.

### 11.4 Multi-Tenancy
Multi-organization account switching within a single mobile session.

### 11.5 Advanced SOC Analytics
Heatmaps of intrusion attempts, geographic attack visualizations, and MTTR trend lines.

### 11.6 Threat Intelligence
Direct integration with MITRE ATT&CK framework mapping and global IOC feeds.

### 11.7 Advanced Wazuh Integration
Direct Wazuh Manager API querying and active agent status management.

### 11.8 Advanced GitHub Security
Full GitHub App OAuth2 consent web redirects and fine-grained repository permissions.

### 11.9 Advanced SAST/DAST
In-app custom Semgrep rule editor with real-time syntax checking.

### 11.10 Scalability
High-throughput WebSocket binary Protobuf serialization for high-volume enterprise SOCs.

### 11.11 High Availability
Multi-region cloud backend failover and automated client endpoint discovery.

---

## CHAPTER 12 — CONCLUSION

**SecurePulse** demonstrates that complex cybersecurity operations, SIEM incident triage, repository SAST auditing, and regulatory compliance reporting can be effectively, securely, and elegantly delivered on mobile devices. 

By uniting a responsive Flutter 3.x front-end with an asynchronous FastAPI backend, real-time WebSocket event streaming, hardware-backed biometric security, conversational AI assistance, and a zero-latency Demo simulation mode, SecurePulse provides security practitioners with the tools needed to maintain continuous operational readiness anywhere, anytime.

---

## REFERENCES

1. Google Flutter Team, *"Flutter Documentation and Architectural Overview,"* Google LLC, 2026. [Online]. Available: https://docs.flutter.dev
2. Tiangolo, S., *"FastAPI: Modern, High-Performance Web Framework for Python,"* 2026. [Online]. Available: https://fastapi.tiangolo.com
3. Wazuh Inc., *"Wazuh: Open Source Security Monitoring Architecture & Documentation,"* 2026. [Online]. Available: https://documentation.wazuh.com
4. Semgrep Team, *"Semgrep: Lightweight Static Analysis for Security Vulnerabilities,"* r2c / Semgrep Inc., 2026. [Online]. Available: https://semgrep.dev
5. Remi Rousselet, *"Riverpod: A Reactive Caching and Data-Binding Framework for Dart & Flutter,"* 2026. [Online]. Available: https://riverpod.dev
6. Internet Engineering Task Force (IETF), *"RFC 7519: JSON Web Token (JWT),"* May 2015. [Online]. Available: https://datatracker.ietf.org/doc/html/rfc7519
7. Internet Engineering Task Force (IETF), *"RFC 6455: The WebSocket Protocol,"* Dec 2011. [Online]. Available: https://datatracker.ietf.org/doc/html/rfc6455
8. National Institute of Standards and Technology (NIST), *"Framework for Improving Critical Infrastructure Cybersecurity (NIST CSF v2.0),"* U.S. Department of Commerce, 2024.
9. American Institute of Certified Public Accountants (AICPA), *"SOC 2® — SOC for Service Organizations: Trust Services Criteria,"* AICPA, 2022.
10. International Organization for Standardization, *"ISO/IEC 27001:2022 Information Security Management Systems,"* ISO, Geneva, Switzerland, 2022.

---

## APPENDICES

### Appendix A: REST API Endpoints Contract
Complete specification of all REST endpoints (`/health`, `/v1/auth/login`, `/v1/dashboard/summary`, `/v1/repositories`, `/v1/soc/alerts`, `/v1/ai/chat`, `/v1/reports`).

### Appendix B: Automated Test Suite Execution Log
Verifiable execution log of all 15 automated test cases passing in the `test/` suite.

### Appendix C: Android Manifest Configuration
Permissions, hardware feature requests, and system flags configured in `android/app/src/main/AndroidManifest.xml`.
