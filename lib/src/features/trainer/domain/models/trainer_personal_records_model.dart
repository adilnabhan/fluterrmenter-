class MetricStatModel {
  final num value;
  final String formatted;
  final String unit;
  final int? reps;
  final String subtext;
  final String displayText;
  final String date;
  final String rawDate;

  const MetricStatModel({
    required this.value,
    required this.formatted,
    required this.unit,
    this.reps,
    required this.subtext,
    required this.displayText,
    required this.date,
    required this.rawDate,
  });

  factory MetricStatModel.fromJson(Map<String, dynamic> json) {
    return MetricStatModel(
      value: (json['value'] ?? json['weight'] ?? 0) as num,
      formatted: (json['formatted'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      reps: (json['reps'] as num?)?.toInt(),
      subtext: (json['subtext'] ?? '').toString(),
      displayText: (json['display_text'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      rawDate: (json['raw_date'] ?? '').toString(),
    );
  }
}

class TimelinePointModel {
  final String date;
  final String displayDate;
  final String fullDate;
  final num value;
  final String unit;
  final int reps;
  final num totalVolume;
  final bool isPeak;

  const TimelinePointModel({
    required this.date,
    required this.displayDate,
    required this.fullDate,
    required this.value,
    required this.unit,
    required this.reps,
    required this.totalVolume,
    required this.isPeak,
  });

  factory TimelinePointModel.fromJson(Map<String, dynamic> json) {
    return TimelinePointModel(
      date: (json['date'] ?? '').toString(),
      displayDate: (json['display_date'] ?? '').toString(),
      fullDate: (json['full_date'] ?? '').toString(),
      value: (json['value'] ?? 0) as num,
      unit: (json['unit'] ?? '').toString(),
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      totalVolume: (json['total_volume'] ?? 0) as num,
      isPeak: (json['is_peak'] as bool?) ?? false,
    );
  }
}

class ChartMetaModel {
  final num minValue;
  final num maxValue;
  final num peakValue;
  final String peakFormatted;

  const ChartMetaModel({
    required this.minValue,
    required this.maxValue,
    required this.peakValue,
    required this.peakFormatted,
  });

  factory ChartMetaModel.fromJson(Map<String, dynamic> json) {
    return ChartMetaModel(
      minValue: (json['min_value'] ?? 0) as num,
      maxValue: (json['max_value'] ?? 100) as num,
      peakValue: (json['peak_value'] ?? 0) as num,
      peakFormatted: (json['peak_formatted'] ?? '').toString(),
    );
  }
}

class ProgressOverTimeModel {
  final String metric;
  final List<TimelinePointModel> timeline;
  final ChartMetaModel chartMeta;

  const ProgressOverTimeModel({
    required this.metric,
    required this.timeline,
    required this.chartMeta,
  });

  factory ProgressOverTimeModel.fromJson(Map<String, dynamic> json) {
    final timelineList = (json['timeline'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(TimelinePointModel.fromJson)
        .toList();

    return ProgressOverTimeModel(
      metric: (json['metric'] ?? 'max_weight').toString(),
      timeline: timelineList,
      chartMeta: json['chart_meta'] is Map
          ? ChartMetaModel.fromJson(
              Map<String, dynamic>.from(json['chart_meta'] as Map),
            )
          : const ChartMetaModel(
              minValue: 0,
              maxValue: 100,
              peakValue: 0,
              peakFormatted: '',
            ),
    );
  }
}

class AllTimeBestModel {
  final String key;
  final String title;
  final String description;
  final String displayValue;
  final String date;

  const AllTimeBestModel({
    required this.key,
    required this.title,
    required this.description,
    required this.displayValue,
    required this.date,
  });

  factory AllTimeBestModel.fromJson(Map<String, dynamic> json) {
    return AllTimeBestModel(
      key: (json['key'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      displayValue: (json['display_value'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
    );
  }
}

class PrHistoryItemModel {
  final String date;
  final String formattedDate;
  final double weightKg;
  final String formattedWeight;
  final int reps;
  final double delta;
  final String? deltaFormatted;
  final String type;

  const PrHistoryItemModel({
    required this.date,
    required this.formattedDate,
    required this.weightKg,
    required this.formattedWeight,
    required this.reps,
    required this.delta,
    this.deltaFormatted,
    required this.type,
  });

  factory PrHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return PrHistoryItemModel(
      date: (json['date'] ?? '').toString(),
      formattedDate: (json['formatted_date'] ?? '').toString(),
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      formattedWeight: (json['formatted_weight'] ?? '').toString(),
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      delta: (json['delta'] as num?)?.toDouble() ?? 0.0,
      deltaFormatted: json['delta_formatted']?.toString(),
      type: (json['type'] ?? '').toString(),
    );
  }
}

class ExercisePrRecordModel {
  final int workoutId;
  final int exerciseId;
  final String name;
  final String category;
  final String majorMuscle;
  final String? thumbnail;
  final String? videoUrl;
  final String? instructions;
  final MetricStatModel? maxWeight;
  final MetricStatModel? bestReps;
  final MetricStatModel? totalVolume;
  final ProgressOverTimeModel? progressOverTime;
  final List<AllTimeBestModel> allTimeBests;
  final List<PrHistoryItemModel> prHistory;
  final String? insights;

  const ExercisePrRecordModel({
    required this.workoutId,
    required this.exerciseId,
    required this.name,
    required this.category,
    required this.majorMuscle,
    this.thumbnail,
    this.videoUrl,
    this.instructions,
    this.maxWeight,
    this.bestReps,
    this.totalVolume,
    this.progressOverTime,
    this.allTimeBests = const [],
    this.prHistory = const [],
    this.insights,
  });

  factory ExercisePrRecordModel.fromJson(Map<String, dynamic> json) {
    final allTimeBestsList = (json['all_time_bests'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(AllTimeBestModel.fromJson)
        .toList();

    final prHistoryList = (json['pr_history'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PrHistoryItemModel.fromJson)
        .toList();

    return ExercisePrRecordModel(
      workoutId: (json['workout_id'] as num?)?.toInt() ?? 0,
      exerciseId: (json['exercise_id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      majorMuscle: (json['major_muscle'] ?? '').toString(),
      thumbnail: json['thumbnail']?.toString(),
      videoUrl: json['video_url']?.toString(),
      instructions: json['instructions']?.toString(),
      maxWeight: json['max_weight'] is Map
          ? MetricStatModel.fromJson(
              Map<String, dynamic>.from(json['max_weight'] as Map),
            )
          : null,
      bestReps: json['best_reps'] is Map
          ? MetricStatModel.fromJson(
              Map<String, dynamic>.from(json['best_reps'] as Map),
            )
          : null,
      totalVolume: json['total_volume'] is Map
          ? MetricStatModel.fromJson(
              Map<String, dynamic>.from(json['total_volume'] as Map),
            )
          : null,
      progressOverTime: json['progress_over_time'] is Map
          ? ProgressOverTimeModel.fromJson(
              Map<String, dynamic>.from(json['progress_over_time'] as Map),
            )
          : null,
      allTimeBests: allTimeBestsList,
      prHistory: prHistoryList,
      insights: json['insights']?.toString(),
    );
  }
}

class TrainerPersonalRecordsResponseModel {
  final int customerId;
  final int userId;
  final String userName;
  final int totalPrsCount;
  final List<String> categories;
  final Map<String, int> categoryCounts;
  final String activeCategory;
  final List<ExercisePrRecordModel> records;

  const TrainerPersonalRecordsResponseModel({
    required this.customerId,
    required this.userId,
    required this.userName,
    required this.totalPrsCount,
    required this.categories,
    required this.categoryCounts,
    required this.activeCategory,
    required this.records,
  });

  factory TrainerPersonalRecordsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final Map<String, int> counts = {};
    if (json['category_counts'] is Map) {
      (json['category_counts'] as Map).forEach((k, v) {
        counts[k.toString()] = (v as num?)?.toInt() ?? 0;
      });
    }

    final categoriesList = (json['categories'] as List? ?? [])
        .map((e) => e.toString())
        .toList();

    final recordsList = (json['records'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ExercisePrRecordModel.fromJson)
        .toList();

    return TrainerPersonalRecordsResponseModel(
      customerId: (json['customer_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      userName: (json['user_name'] ?? '').toString(),
      totalPrsCount: (json['total_prs_count'] as num?)?.toInt() ?? 0,
      categories: categoriesList.isNotEmpty ? categoriesList : ['All'],
      categoryCounts: counts,
      activeCategory: (json['active_category'] ?? 'All').toString(),
      records: recordsList,
    );
  }
}
