class HighestAttendanceInfo {
  final String date;
  final int clientsCount;

  HighestAttendanceInfo({
    required this.date,
    required this.clientsCount,
  });

  factory HighestAttendanceInfo.fromJson(Map<String, dynamic> json) {
    return HighestAttendanceInfo(
      date: (json['date'] ?? '').toString(),
      clientsCount: json['clients_count'] as int? ?? 0,
    );
  }
}

class WorkoutCalendarSummary {
  final int activeClients;
  final int averageDailyAttendance;
  final HighestAttendanceInfo? highestAttendance;

  WorkoutCalendarSummary({
    required this.activeClients,
    required this.averageDailyAttendance,
    this.highestAttendance,
  });

  factory WorkoutCalendarSummary.fromJson(Map<String, dynamic> json) {
    final highestJson = json['highest_attendance'] as Map<String, dynamic>?;
    return WorkoutCalendarSummary(
      activeClients: json['active_clients'] as int? ?? 0,
      averageDailyAttendance: json['average_daily_attendance'] as int? ?? 0,
      highestAttendance: highestJson != null ? HighestAttendanceInfo.fromJson(highestJson) : null,
    );
  }
}

class WorkoutCalendarDay {
  final String date;
  final int clientsCount;
  final int completedSessions;

  WorkoutCalendarDay({
    required this.date,
    required this.clientsCount,
    required this.completedSessions,
  });

  factory WorkoutCalendarDay.fromJson(Map<String, dynamic> json) {
    return WorkoutCalendarDay(
      date: (json['date'] ?? '').toString(),
      clientsCount: json['clients_count'] as int? ?? 0,
      completedSessions: json['completed_sessions'] as int? ?? 0,
    );
  }
}

class WorkoutCalendarMonthResponse {
  final String month;
  final WorkoutCalendarSummary summary;
  final List<WorkoutCalendarDay> calendar;

  WorkoutCalendarMonthResponse({
    required this.month,
    required this.summary,
    required this.calendar,
  });

  factory WorkoutCalendarMonthResponse.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] as Map<String, dynamic>? ?? {};
    final calendarList = json['calendar'] as List<dynamic>? ?? [];

    return WorkoutCalendarMonthResponse(
      month: (json['month'] ?? '').toString(),
      summary: WorkoutCalendarSummary.fromJson(summaryJson),
      calendar: calendarList
          .map((e) => WorkoutCalendarDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WorkoutClientDetail {
  final int id;
  final String name;
  final String trainer;

  WorkoutClientDetail({
    required this.id,
    required this.name,
    required this.trainer,
  });

  factory WorkoutClientDetail.fromJson(Map<String, dynamic> json) {
    return WorkoutClientDetail(
      id: json['id'] as int? ?? 0,
      name: (json['name'] ?? json['client_name'] ?? 'Client').toString(),
      trainer: (json['trainer'] ?? json['trainer_name'] ?? 'Unassigned').toString(),
    );
  }
}

class WorkoutDateDetailResponse {
  final String date;
  final int clientsCount;
  final int completedSessions;
  final String peakHour;
  final List<WorkoutClientDetail> clients;

  WorkoutDateDetailResponse({
    required this.date,
    required this.clientsCount,
    required this.completedSessions,
    required this.peakHour,
    required this.clients,
  });

  factory WorkoutDateDetailResponse.fromJson(Map<String, dynamic> json) {
    final clientsList = json['clients'] as List<dynamic>? ?? [];

    return WorkoutDateDetailResponse(
      date: (json['date'] ?? '').toString(),
      clientsCount: json['clients_count'] as int? ?? 0,
      completedSessions: json['completed_sessions'] as int? ?? 0,
      peakHour: (json['peak_hour'] ?? 'N/A').toString(),
      clients: clientsList
          .map((e) => WorkoutClientDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
