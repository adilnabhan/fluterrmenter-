class LiveActivityModel {
  final String date;
  final int assigned;
  final int verified;
  final int pending;
  final double verifiedRate;

  const LiveActivityModel({
    required this.date,
    required this.assigned,
    required this.verified,
    required this.pending,
    required this.verifiedRate,
  });

  factory LiveActivityModel.fromJson(Map<String, dynamic> json) {
    return LiveActivityModel(
      date: (json['date'] ?? '').toString(),
      assigned: (json['assigned'] as num?)?.toInt() ?? 0,
      verified: (json['verified'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      verifiedRate: (json['verified_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MetricDiffModel {
  final int count;
  final int diff;
  final String diffText;

  const MetricDiffModel({
    required this.count,
    required this.diff,
    required this.diffText,
  });

  factory MetricDiffModel.fromJson(Map<String, dynamic> json) {
    return MetricDiffModel(
      count: (json['count'] as num?)?.toInt() ?? 0,
      diff: (json['diff'] as num?)?.toInt() ?? 0,
      diffText: (json['diff_text'] ?? '').toString(),
    );
  }
}

class RateDiffModel {
  final double rate;
  final double diff;
  final String diffText;

  const RateDiffModel({
    required this.rate,
    required this.diff,
    required this.diffText,
  });

  factory RateDiffModel.fromJson(Map<String, dynamic> json) {
    return RateDiffModel(
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      diff: (json['diff'] as num?)?.toDouble() ?? 0.0,
      diffText: (json['diff_text'] ?? '').toString(),
    );
  }
}

class TopTrainerModel {
  final int id;
  final String name;
  final int totalClients;

  const TopTrainerModel({
    required this.id,
    required this.name,
    required this.totalClients,
  });

  factory TopTrainerModel.fromJson(Map<String, dynamic> json) {
    return TopTrainerModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      totalClients: (json['total_clients'] as num?)?.toInt() ?? 0,
    );
  }
}

class TrainerSummaryModel {
  final int totalTrainers;
  final String selectedMonth;
  final String comparisonMonth;
  final MetricDiffModel workoutAssigned;
  final MetricDiffModel workoutVerified;
  final RateDiffModel avgVerifiedRate;
  final TopTrainerModel? topTrainer;

  const TrainerSummaryModel({
    required this.totalTrainers,
    required this.selectedMonth,
    required this.comparisonMonth,
    required this.workoutAssigned,
    required this.workoutVerified,
    required this.avgVerifiedRate,
    this.topTrainer,
  });

  factory TrainerSummaryModel.fromJson(Map<String, dynamic> json) {
    final topTrainerJson = json['top_trainer'];
    return TrainerSummaryModel(
      totalTrainers: (json['total_trainers'] as num?)?.toInt() ?? 0,
      selectedMonth: (json['selected_month'] ?? '').toString(),
      comparisonMonth: (json['comparison_month'] ?? '').toString(),
      workoutAssigned: json['workout_assigned'] is Map
          ? MetricDiffModel.fromJson(
              Map<String, dynamic>.from(json['workout_assigned'] as Map),
            )
          : const MetricDiffModel(count: 0, diff: 0, diffText: ''),
      workoutVerified: json['workout_verified'] is Map
          ? MetricDiffModel.fromJson(
              Map<String, dynamic>.from(json['workout_verified'] as Map),
            )
          : const MetricDiffModel(count: 0, diff: 0, diffText: ''),
      avgVerifiedRate: json['avg_verified_rate'] is Map
          ? RateDiffModel.fromJson(
              Map<String, dynamic>.from(json['avg_verified_rate'] as Map),
            )
          : const RateDiffModel(rate: 0.0, diff: 0.0, diffText: ''),
      topTrainer: topTrainerJson is Map
          ? TopTrainerModel.fromJson(
              Map<String, dynamic>.from(topTrainerJson),
            )
          : null,
    );
  }
}

class TrainerPerformanceItemModel {
  final int id;
  final String name;
  final String profilePicture;
  final int totalClients;
  final int verifiedClients;
  final double verifiedRate;
  final MetricDiffModel workoutAssigned;
  final MetricDiffModel workoutVerified;
  final RateDiffModel avgVerifiedRate;

  const TrainerPerformanceItemModel({
    required this.id,
    required this.name,
    required this.profilePicture,
    required this.totalClients,
    required this.verifiedClients,
    required this.verifiedRate,
    required this.workoutAssigned,
    required this.workoutVerified,
    required this.avgVerifiedRate,
  });

  factory TrainerPerformanceItemModel.fromJson(Map<String, dynamic> json) {
    return TrainerPerformanceItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      profilePicture: (json['profile_picture'] ?? '').toString(),
      totalClients: (json['total_clients'] as num?)?.toInt() ?? 0,
      verifiedClients: (json['verified_clients'] as num?)?.toInt() ?? 0,
      verifiedRate: (json['verified_rate'] as num?)?.toDouble() ?? 0.0,
      workoutAssigned: json['workout_assigned'] is Map
          ? MetricDiffModel.fromJson(
              Map<String, dynamic>.from(json['workout_assigned'] as Map),
            )
          : const MetricDiffModel(count: 0, diff: 0, diffText: ''),
      workoutVerified: json['workout_verified'] is Map
          ? MetricDiffModel.fromJson(
              Map<String, dynamic>.from(json['workout_verified'] as Map),
            )
          : const MetricDiffModel(count: 0, diff: 0, diffText: ''),
      avgVerifiedRate: json['avg_verified_rate'] is Map
          ? RateDiffModel.fromJson(
              Map<String, dynamic>.from(json['avg_verified_rate'] as Map),
            )
          : const RateDiffModel(rate: 0.0, diff: 0.0, diffText: ''),
    );
  }
}

class TrainerReportsResponseModel {
  final LiveActivityModel liveActivity;
  final TrainerSummaryModel summary;
  final List<TrainerPerformanceItemModel> trainers;

  const TrainerReportsResponseModel({
    required this.liveActivity,
    required this.summary,
    required this.trainers,
  });

  factory TrainerReportsResponseModel.fromJson(Map<String, dynamic> json) {
    final trainersRaw = json['trainers'];
    final List<TrainerPerformanceItemModel> trainersList = [];
    if (trainersRaw is List) {
      for (final item in trainersRaw) {
        if (item is Map) {
          trainersList.add(
            TrainerPerformanceItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return TrainerReportsResponseModel(
      liveActivity: json['live_activity'] is Map
          ? LiveActivityModel.fromJson(
              Map<String, dynamic>.from(json['live_activity'] as Map),
            )
          : const LiveActivityModel(
              date: '',
              assigned: 0,
              verified: 0,
              pending: 0,
              verifiedRate: 0.0,
            ),
      summary: json['summary'] is Map
          ? TrainerSummaryModel.fromJson(
              Map<String, dynamic>.from(json['summary'] as Map),
            )
          : const TrainerSummaryModel(
              totalTrainers: 0,
              selectedMonth: '',
              comparisonMonth: '',
              workoutAssigned: MetricDiffModel(count: 0, diff: 0, diffText: ''),
              workoutVerified: MetricDiffModel(count: 0, diff: 0, diffText: ''),
              avgVerifiedRate: RateDiffModel(rate: 0.0, diff: 0.0, diffText: ''),
            ),
      trainers: trainersList,
    );
  }
}
