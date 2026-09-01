import 'dart:async';
import 'dart:math';
import 'package:app_links/app_links.dart';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../error/api_exception.dart';

class GithubOAuthService {
  static final GithubOAuthService instance = GithubOAuthService._internal();
  final AppLinks _appLinks;

  GithubOAuthService._internal({AppLinks? appLinks})
      : _appLinks = appLinks ?? AppLinks();

  factory GithubOAuthService({AppLinks? appLinks}) {
    if (appLinks != null) {
      return GithubOAuthService._internal(appLinks: appLinks);
    }
    return instance;
  }

  /// Generates a cryptographically strong random state string for CSRF mitigation
  String generateState() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return sha256.convert(values).toString().substring(0, 32);
  }

  /// Builds the complete GitHub OAuth authorization URI
  Uri buildAuthorizationUri({
    required String state,
    String? clientId,
    String? redirectUri,
    String? scopes,
  }) {
    final cId = clientId ?? AppConfig.githubClientId;
    final rUri = redirectUri ?? AppConfig.githubCallbackUrl;
    final sc = scopes ?? AppConfig.githubOAuthScopes;

    return Uri.parse(AppConfig.githubAuthorizeUrl).replace(
      queryParameters: {
        'client_id': cId,
        'redirect_uri': rUri,
        'scope': sc,
        'state': state,
        'allow_signup': 'true',
      },
    );
  }

  /// Extracts the authorization code from an incoming deep link URI
  String? extractCodeFromUri(Uri uri, String expectedState) {
    if (uri.scheme != AppConfig.githubCallbackScheme ||
        uri.host != AppConfig.githubCallbackHost ||
        !uri.path.startsWith(AppConfig.githubCallbackPath)) {
      return null;
    }

    final queryParams = uri.queryParameters;
    final state = queryParams['state'];
    final code = queryParams['code'];
    final error = queryParams['error'];
    final errorDescription = queryParams['error_description'];

    if (error != null) {
      throw ApiException(
        message: errorDescription ?? 'GitHub OAuth authorization rejected: $error',
      );
    }

    if (state != expectedState) {
      throw const ApiException(
        message: 'Security validation failed: OAuth state mismatch (possible CSRF attack).',
      );
    }

    return code;
  }

  /// Initiates the full GitHub OAuth2 flow:
  /// 1. Prepares state token
  /// 2. Sets up AppLinks listener for deep link callback
  /// 3. Launches external system browser
  /// 4. Captures callback, validates state, and returns authorization code
  Future<String> startOAuthFlow({
    Duration timeout = const Duration(minutes: 3),
  }) async {
    final state = generateState();
    final authUri = buildAuthorizationUri(state: state);

    final completer = Completer<String>();
    StreamSubscription<Uri>? linkSub;
    Timer? timeoutTimer;

    void cleanup() {
      linkSub?.cancel();
      timeoutTimer?.cancel();
    }

    timeoutTimer = Timer(timeout, () {
      cleanup();
      if (!completer.isCompleted) {
        completer.completeError(
          const ApiException(message: 'GitHub OAuth sign-in timed out. Please try again.'),
        );
      }
    });

    try {
      // Listen to incoming app links (while app is in background or foreground)
      linkSub = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          try {
            final code = extractCodeFromUri(uri, state);
            if (code != null && !completer.isCompleted) {
              cleanup();
              completer.complete(code);
            }
          } catch (e) {
            cleanup();
            if (!completer.isCompleted) {
              completer.completeError(e);
            }
          }
        },
        onError: (err) {
          cleanup();
          if (!completer.isCompleted) {
            completer.completeError(
              ApiException(message: 'Failed to listen to deep link: $err'),
            );
          }
        },
      );

      // Launch the authorization URL in external browser
      final launched = await launchUrl(
        authUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        cleanup();
        throw const ApiException(message: 'Could not open system browser for GitHub sign in.');
      }

      return await completer.future;
    } catch (e) {
      cleanup();
      if (e is ApiException) rethrow;
      throw ApiException(message: 'GitHub OAuth initialization failed: $e');
    }
  }
}
