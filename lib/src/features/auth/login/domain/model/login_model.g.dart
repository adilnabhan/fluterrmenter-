// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginEntityImpl _$$LoginEntityImplFromJson(Map<String, dynamic> json) =>
    _$LoginEntityImpl(
      lastLogin: json['last_login'] == null
          ? null
          : DateTime.parse(json['last_login'] as String),
      username: json['username'] as String?,
      message: json['message'] as String?,
      user: (json['user'] as num?)?.toInt(),
      vendor: json['vendor'] == null
          ? null
          : Vendor.fromJson(json['vendor'] as Map<String, dynamic>),
      vendorId: json['vendor_id'] as num?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      getFullName: json['get_full_name'] as String?,
      email: json['email'] as String?,
      isStaff: json['is_staff'] as bool?,
      isActive: json['is_active'] as bool?,
      mobileNo: json['mobile_no'] as String?,
      profileImage: json['profile_image'],
      modules: json['modules'] as List<dynamic>?,
      getRoleDisplay: json['get_role_display'] as String?,
      isVendor: json['is_vendor'] as bool?,
      isCustomer: json['is_customer'] as bool?,
      id: (json['id'] as num?)?.toInt(),
      role: (json['role'] as num?)?.toInt(),
      accessToken: json['access'] as String?,
      refresh: json['refresh'] as String?,
    );

Map<String, dynamic> _$$LoginEntityImplToJson(_$LoginEntityImpl instance) =>
    <String, dynamic>{
      'last_login': instance.lastLogin?.toIso8601String(),
      'username': instance.username,
      'message': instance.message,
      'user': instance.user,
      'vendor': instance.vendor,
      'vendor_id': instance.vendorId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'get_full_name': instance.getFullName,
      'email': instance.email,
      'is_staff': instance.isStaff,
      'is_active': instance.isActive,
      'mobile_no': instance.mobileNo,
      'profile_image': instance.profileImage,
      'modules': instance.modules,
      'get_role_display': instance.getRoleDisplay,
      'is_vendor': instance.isVendor,
      'is_customer': instance.isCustomer,
      'id': instance.id,
      'role': instance.role,
      'access': instance.accessToken,
      'refresh': instance.refresh,
    };

_$VendorImpl _$$VendorImplFromJson(Map<String, dynamic> json) => _$VendorImpl(
      id: (json['id'] as num?)?.toInt(),
      shopName: json['shop_name'] as String?,
      vendorRole: (json['vendor_role'] as num?)?.toInt(),
      gstnNumber: json['gstn_number'] as String?,
      dateOfEstablishment: json['date_of_establishment'],
      businessLogo: json['business_logo'],
      customerCareNumber: json['customer_care_number'],
      landlineNumber: json['landline_number'],
      manufacturingItems: json['manufacturing_items'],
      proprietorFirstName: json['proprietor_first_name'],
      proprietorLastName: json['proprietor_last_name'],
      bankDetails: json['bank_details'],
      lastStep: (json['last_step'] as num?)?.toInt(),
      addresses: json['addresses'] as List<dynamic>?,
      isManufacture: json['is_manufacture'] as bool?,
      isRetailer: json['is_retailer'] as bool?,
      isWholesaler: json['is_wholesaler'] as bool?,
      documents: json['documents'] as List<dynamic>?,
      partnerRequest: json['partner_request'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      totalDeliveryDistance: json['total_delivery_distance'],
      freeDeliveryDistance: json['free_delivery_distance'],
    );

Map<String, dynamic> _$$VendorImplToJson(_$VendorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_name': instance.shopName,
      'vendor_role': instance.vendorRole,
      'gstn_number': instance.gstnNumber,
      'date_of_establishment': instance.dateOfEstablishment,
      'business_logo': instance.businessLogo,
      'customer_care_number': instance.customerCareNumber,
      'landline_number': instance.landlineNumber,
      'manufacturing_items': instance.manufacturingItems,
      'proprietor_first_name': instance.proprietorFirstName,
      'proprietor_last_name': instance.proprietorLastName,
      'bank_details': instance.bankDetails,
      'last_step': instance.lastStep,
      'addresses': instance.addresses,
      'is_manufacture': instance.isManufacture,
      'is_retailer': instance.isRetailer,
      'is_wholesaler': instance.isWholesaler,
      'documents': instance.documents,
      'partner_request': instance.partnerRequest,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'total_delivery_distance': instance.totalDeliveryDistance,
      'free_delivery_distance': instance.freeDeliveryDistance,
    };
