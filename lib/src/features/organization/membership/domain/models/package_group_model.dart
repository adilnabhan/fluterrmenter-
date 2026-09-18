import 'package:mentor_mobile_app/src/features/organization/membership/domain/models/list_membership_package_model.dart';

class MembershipPackageGroupModel {
  final int? id;
  final int? organization;
  final String? name;
  final String? description;
  final int order;
  final bool isActive;
  final int plansCount;
  final List<MembershipPackageModel> plans;

  const MembershipPackageGroupModel({
    this.id,
    this.organization,
    this.name,
    this.description,
    this.order = 0,
    this.isActive = true,
    this.plansCount = 0,
    this.plans = const [],
  });

  factory MembershipPackageGroupModel.fromJson(Map<String, dynamic> json) {
    return MembershipPackageGroupModel(
      id: (json['id'] as num?)?.toInt(),
      organization: (json['organization'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      plansCount: (json['plans_count'] as num?)?.toInt() ?? 0,
      plans: (json['plans'] as List<dynamic>?)
              ?.map((e) =>
                  MembershipPackageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (organization != null) 'organization': organization,
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        'order': order,
        'is_active': isActive,
      };

  MembershipPackageGroupModel copyWith({
    int? id,
    int? organization,
    String? name,
    String? description,
    int? order,
    bool? isActive,
    int? plansCount,
    List<MembershipPackageModel>? plans,
  }) {
    return MembershipPackageGroupModel(
      id: id ?? this.id,
      organization: organization ?? this.organization,
      name: name ?? this.name,
      description: description ?? this.description,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      plansCount: plansCount ?? this.plansCount,
      plans: plans ?? this.plans,
    );
  }
}

class GroupedMembershipPackagesModel {
  final List<MembershipPackageGroupModel> groups;
  final List<MembershipPackageModel> ungrouped;

  const GroupedMembershipPackagesModel({
    this.groups = const [],
    this.ungrouped = const [],
  });

  factory GroupedMembershipPackagesModel.fromJson(Map<String, dynamic> json) {
    return GroupedMembershipPackagesModel(
      groups: (json['groups'] as List<dynamic>?)
              ?.map((e) => MembershipPackageGroupModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          const [],
      ungrouped: (json['ungrouped'] as List<dynamic>?)
              ?.map((e) =>
                  MembershipPackageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
