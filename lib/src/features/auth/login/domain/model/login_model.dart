// ignore_for_file: invalid_annotation_target, public_member_api_docs

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'login_model.freezed.dart';
part 'login_model.g.dart';

String loginEntityToJson(LoginEntity data) => json.encode(data.toJson());

@freezed
class LoginEntity with _$LoginEntity {
  const factory LoginEntity({
    @JsonKey(name: 'last_login') DateTime? lastLogin,
    @JsonKey(name: 'username') String? username,
    @JsonKey(name: 'message') String? message,
    @JsonKey(name: 'user') int? user,
    @JsonKey(name: 'vendor') Vendor? vendor,
    @JsonKey(name: 'vendor_id') num? vendorId,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'get_full_name') String? getFullName,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'is_staff') bool? isStaff,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'mobile_no') String? mobileNo,
    @JsonKey(name: 'profile_image') dynamic profileImage,
    @JsonKey(name: 'modules') List<dynamic>? modules,
    @JsonKey(name: 'get_role_display') String? getRoleDisplay,
    @JsonKey(name: 'is_vendor') bool? isVendor,
    @JsonKey(name: 'is_customer') bool? isCustomer,
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'role') int? role,
    @JsonKey(name: 'access') String? accessToken,
    @JsonKey(name: 'refresh') String? refresh,
  }) = _LoginEntity;

  factory LoginEntity.fromJson(Map<String, dynamic> json) => _$LoginEntityFromJson(json);
}

@freezed
class Vendor with _$Vendor {
  const factory Vendor({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'shop_name') String? shopName,
    @JsonKey(name: 'vendor_role') int? vendorRole,
    @JsonKey(name: 'gstn_number') String? gstnNumber,
    @JsonKey(name: 'date_of_establishment') dynamic dateOfEstablishment,
    @JsonKey(name: 'business_logo') dynamic businessLogo,
    @JsonKey(name: 'customer_care_number') dynamic customerCareNumber,
    @JsonKey(name: 'landline_number') dynamic landlineNumber,
    @JsonKey(name: 'manufacturing_items') dynamic manufacturingItems,
    @JsonKey(name: 'proprietor_first_name') dynamic proprietorFirstName,
    @JsonKey(name: 'proprietor_last_name') dynamic proprietorLastName,
    @JsonKey(name: 'bank_details') dynamic bankDetails,
    @JsonKey(name: 'last_step') int? lastStep,
    @JsonKey(name: 'addresses') List<dynamic>? addresses,
    @JsonKey(name: 'is_manufacture') bool? isManufacture,
    @JsonKey(name: 'is_retailer') bool? isRetailer,
    @JsonKey(name: 'is_wholesaler') bool? isWholesaler,
    @JsonKey(name: 'documents') List<dynamic>? documents,
    @JsonKey(name: 'partner_request') dynamic partnerRequest,
    @JsonKey(name: 'latitude') dynamic latitude,
    @JsonKey(name: 'longitude') dynamic longitude,
    @JsonKey(name: 'total_delivery_distance') dynamic totalDeliveryDistance,
    @JsonKey(name: 'free_delivery_distance') dynamic freeDeliveryDistance,
  }) = _Vendor;

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
}
