/// Represents the result of a token refresh attempt.
///
/// Used by `AuthInterceptor` to decide whether to retry queued
/// requests, reject them gracefully, or trigger a full logout.
enum TokenRefreshResult {
  /// Refresh succeeded — new access (and possibly refresh) token stored.
  success,

  /// Backend explicitly confirmed the refresh token is invalid / expired
  /// (HTTP 401 or 403 on the refresh endpoint).
  /// The session MUST be cleared and user navigated to login.
  invalidToken,

  /// A transient error occurred (network drop, timeout, 5xx, parsing).
  /// The session MUST be preserved — the user stays logged in.
  temporaryFailure,

  /// Current user has no refresh token.
  noRefreshToken,

  /// No logged-in user at all.
  noUser,
}
