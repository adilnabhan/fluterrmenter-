class BulkWorkoutVerificationResponse {
  final String message;
  final int successCount;
  final int failureCount;
  final int totalCount;
  final List<Map<String, dynamic>> verifiedSessions;
  final List<Map<String, dynamic>> failedSessions;

  const BulkWorkoutVerificationResponse({
    required this.message,
    required this.successCount,
    required this.failureCount,
    required this.totalCount,
    this.verifiedSessions = const [],
    this.failedSessions = const [],
  });

  factory BulkWorkoutVerificationResponse.fromJson(Map<String, dynamic> json) {
    return BulkWorkoutVerificationResponse(
      message: json['message']?.toString() ?? '',
      successCount: json['success_count'] as int? ?? 0,
      failureCount: json['failure_count'] as int? ?? 0,
      totalCount: json['total_count'] as int? ?? 0,
      verifiedSessions: (json['verified_sessions'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
      failedSessions: (json['failed_sessions'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
    );
  }
}
