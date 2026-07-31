class AttendanceSession {
  final int? id;
  final String checkIn;
  final String checkOut;

  AttendanceSession({
    this.id,
    required this.checkIn,
    required this.checkOut,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'] as int?,
      checkIn: (json['check_in'] ?? '').toString(),
      checkOut: (json['check_out'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'check_in': checkIn,
      'check_out': checkOut,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}

class TrainerAttendanceDay {
  final int? attendanceId;
  final int trainerId;
  final String trainerName;
  final String? profileImage;
  final String designation;
  final String status;
  final String workingHours;
  final List<AttendanceSession> sessions;

  TrainerAttendanceDay({
    this.attendanceId,
    required this.trainerId,
    required this.trainerName,
    this.profileImage,
    required this.designation,
    required this.status,
    required this.workingHours,
    required this.sessions,
  });

  factory TrainerAttendanceDay.fromJson(Map<String, dynamic> json) {
    var rawSessions = json['sessions'] as List<dynamic>? ?? [];
    var mappedSessions = rawSessions
        .map((e) => AttendanceSession.fromJson(e as Map<String, dynamic>))
        .toList();

    return TrainerAttendanceDay(
      attendanceId: json['attendance_id'] as int?,
      trainerId: json['trainer_id'] as int? ?? 0,
      trainerName: (json['trainer_name'] ?? '').toString(),
      profileImage: json['profile_image'] as String?,
      designation: (json['designation'] ?? 'Trainer').toString(),
      status: (json['status'] ?? 'not_marked').toString(),
      workingHours: (json['working_hours'] ?? '00:00').toString(),
      sessions: mappedSessions,
    );
  }

  TrainerAttendanceDay copyWith({
    int? attendanceId,
    int? trainerId,
    String? trainerName,
    String? profileImage,
    String? designation,
    String? status,
    String? workingHours,
    List<AttendanceSession>? sessions,
  }) {
    return TrainerAttendanceDay(
      attendanceId: attendanceId ?? this.attendanceId,
      trainerId: trainerId ?? this.trainerId,
      trainerName: trainerName ?? this.trainerName,
      profileImage: profileImage ?? this.profileImage,
      designation: designation ?? this.designation,
      status: status ?? this.status,
      workingHours: workingHours ?? this.workingHours,
      sessions: sessions ?? this.sessions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trainer_id': trainerId,
      'status': status,
      'sessions': sessions.map((e) => e.toJson()).toList(),
    };
  }
}

class TrainerAttendanceReportSummary {
  final int totalTrainers;
  final int fullDay;
  final int halfDay;
  final int leave;
  final int holiday;
  final int notMarked;

  TrainerAttendanceReportSummary({
    required this.totalTrainers,
    required this.fullDay,
    required this.halfDay,
    required this.leave,
    required this.holiday,
    required this.notMarked,
  });

  factory TrainerAttendanceReportSummary.fromJson(Map<String, dynamic> json) {
    return TrainerAttendanceReportSummary(
      totalTrainers: json['total_trainers'] as int? ?? 0,
      fullDay: json['full_day'] as int? ?? 0,
      halfDay: json['half_day'] as int? ?? 0,
      leave: json['leave'] as int? ?? 0,
      holiday: json['holiday'] as int? ?? 0,
      notMarked: json['not_marked'] as int? ?? 0,
    );
  }
}

class TrainerAttendanceReportItem {
  final int trainerId;
  final String trainerName;
  final String? profileImage;
  final String designation;
  final int fullDays;
  final int halfDays;
  final int leaveDays;
  final int holidayDays;
  final int notMarkedDays;
  final String totalWorkingHours;
  final String averageWorkingHours;
  final double attendancePercentage;

  TrainerAttendanceReportItem({
    required this.trainerId,
    required this.trainerName,
    this.profileImage,
    required this.designation,
    required this.fullDays,
    required this.halfDays,
    required this.leaveDays,
    required this.holidayDays,
    required this.notMarkedDays,
    required this.totalWorkingHours,
    required this.averageWorkingHours,
    required this.attendancePercentage,
  });

  factory TrainerAttendanceReportItem.fromJson(Map<String, dynamic> json) {
    return TrainerAttendanceReportItem(
      trainerId: json['trainer_id'] as int? ?? 0,
      trainerName: (json['trainer_name'] ?? '').toString(),
      profileImage: json['profile_image'] as String?,
      designation: (json['designation'] ?? 'Trainer').toString(),
      fullDays: json['full_days'] as int? ?? 0,
      halfDays: json['half_days'] as int? ?? 0,
      leaveDays: json['leave_days'] as int? ?? 0,
      holidayDays: json['holiday_days'] as int? ?? 0,
      notMarkedDays: json['not_marked_days'] as int? ?? 0,
      totalWorkingHours: (json['total_working_hours'] ?? '00:00').toString(),
      averageWorkingHours: (json['average_working_hours'] ?? '00:00').toString(),
      attendancePercentage: double.tryParse((json['attendance_percentage'] ?? '0').toString()) ?? 0.0,
    );
  }
}

class TrainerAttendanceReport {
  final String startDate;
  final String endDate;
  final int organizationId;
  final TrainerAttendanceReportSummary summary;
  final List<TrainerAttendanceReportItem> trainers;

  TrainerAttendanceReport({
    required this.startDate,
    required this.endDate,
    required this.organizationId,
    required this.summary,
    required this.trainers,
  });

  factory TrainerAttendanceReport.fromJson(Map<String, dynamic> json) {
    var rawSummary = json['summary'] as Map<String, dynamic>? ?? {};
    var rawTrainers = json['trainers'] as List<dynamic>? ?? [];

    return TrainerAttendanceReport(
      startDate: (json['start_date'] ?? '').toString(),
      endDate: (json['end_date'] ?? '').toString(),
      organizationId: json['organization_id'] as int? ?? 0,
      summary: TrainerAttendanceReportSummary.fromJson(rawSummary),
      trainers: rawTrainers
          .map((e) => TrainerAttendanceReportItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
