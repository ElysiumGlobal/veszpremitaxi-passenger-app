import 'dart:convert';

OfferModel offerModelFromJson(String str) =>
    OfferModel.fromJson(json.decode(str));

String offerModelToJson(OfferModel data) => json.encode(data.toJson());

class OfferModel {
  bool? success;
  String? message;
  Data? data;

  OfferModel({this.success, this.message, this.data});

  OfferModel copyWith({bool? success, String? message, Data? data}) =>
      OfferModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory OfferModel.fromJson(Map<String, dynamic> json) => OfferModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  List<Offer>? offers;
  Pagination? pagination;

  Data({this.offers, this.pagination});

  Data copyWith({List<Offer>? offers, Pagination? pagination}) => Data(
    offers: offers ?? this.offers,
    pagination: pagination ?? this.pagination,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    offers: json["offers"] == null
        ? []
        : List<Offer>.from(json["offers"]!.map((x) => Offer.fromJson(x))),
    pagination: json["pagination"] == null
        ? null
        : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "offers": offers == null
        ? []
        : List<dynamic>.from(offers!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Offer {
  int? id;
  String? code;
  String? description;
  String? type;
  String? value;
  String? minOrderAmount;
  String? maxDiscountAmount;
  int? maxUsesPerUser;
  dynamic maxUsesTotal;
  bool? isFirstRideOnly;
  bool? isReferralCode;
  String? status;
  String? startsAt;
  String? expiresAt;
  bool? isExpired;
  bool? isActive;
  bool? isAvailable;
  int? usageCount;
  dynamic remainingUses;
  dynamic usagePercentage;
  List<dynamic>? cityIds;
  List<ApplicableRideType>? applicableRideTypes;
  String? firstRowText;
  String? secondRowText;
  String? thirdRowText;
  String? createdAt;
  String? updatedAt;

  Offer({
    this.id,
    this.code,
    this.description,
    this.type,
    this.value,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.maxUsesPerUser,
    this.maxUsesTotal,
    this.isFirstRideOnly,
    this.isReferralCode,
    this.status,
    this.startsAt,
    this.expiresAt,
    this.isExpired,
    this.isActive,
    this.isAvailable,
    this.usageCount,
    this.remainingUses,
    this.usagePercentage,
    this.cityIds,
    this.applicableRideTypes,
    this.firstRowText,
    this.secondRowText,
    this.thirdRowText,
    this.createdAt,
    this.updatedAt,
  });

  Offer copyWith({
    int? id,
    String? code,
    String? description,
    String? type,
    String? value,
    String? minOrderAmount,
    String? maxDiscountAmount,
    int? maxUsesPerUser,
    dynamic maxUsesTotal,
    bool? isFirstRideOnly,
    bool? isReferralCode,
    String? status,
    String? startsAt,
    String? expiresAt,
    bool? isExpired,
    bool? isActive,
    bool? isAvailable,
    int? usageCount,
    dynamic remainingUses,
    dynamic usagePercentage,
    List<dynamic>? cityIds,
    List<ApplicableRideType>? applicableRideTypes,
    String? firstRowText,
    String? secondRowText,
    String? thirdRowText,
    String? createdAt,
    String? updatedAt,
  }) => Offer(
    id: id ?? this.id,
    code: code ?? this.code,
    description: description ?? this.description,
    type: type ?? this.type,
    value: value ?? this.value,
    minOrderAmount: minOrderAmount ?? this.minOrderAmount,
    maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
    maxUsesPerUser: maxUsesPerUser ?? this.maxUsesPerUser,
    maxUsesTotal: maxUsesTotal ?? this.maxUsesTotal,
    isFirstRideOnly: isFirstRideOnly ?? this.isFirstRideOnly,
    isReferralCode: isReferralCode ?? this.isReferralCode,
    status: status ?? this.status,
    startsAt: startsAt ?? this.startsAt,
    expiresAt: expiresAt ?? this.expiresAt,
    isExpired: isExpired ?? this.isExpired,
    isActive: isActive ?? this.isActive,
    isAvailable: isAvailable ?? this.isAvailable,
    usageCount: usageCount ?? this.usageCount,
    remainingUses: remainingUses ?? this.remainingUses,
    usagePercentage: usagePercentage ?? this.usagePercentage,
    cityIds: cityIds ?? this.cityIds,
    applicableRideTypes: applicableRideTypes ?? this.applicableRideTypes,
    firstRowText: firstRowText ?? this.firstRowText,
    secondRowText: secondRowText ?? this.secondRowText,
    thirdRowText: thirdRowText ?? this.thirdRowText,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
    id: json["id"],
    code: json["code"],
    description: json["description"],
    type: json["type"],
    value: json["value"],
    minOrderAmount: json["min_order_amount"],
    maxDiscountAmount: json["max_discount_amount"],
    maxUsesPerUser: json["max_uses_per_user"],
    maxUsesTotal: json["max_uses_total"],
    isFirstRideOnly: json["is_first_ride_only"],
    isReferralCode: json["is_referral_code"],
    status: json["status"],
    startsAt: json["starts_at"],
    expiresAt: json["expires_at"],
    isExpired: json["is_expired"],
    isActive: json["is_active"],
    isAvailable: json["is_available"],
    usageCount: json["usage_count"],
    remainingUses: json["remaining_uses"],
    usagePercentage: json["usage_percentage"],
    cityIds: json["city_ids"] == null
        ? []
        : List<dynamic>.from(json["city_ids"]!.map((x) => x)),
    applicableRideTypes: json["applicable_ride_types"] == null
        ? []
        : List<ApplicableRideType>.from(
            json["applicable_ride_types"]!.map(
              (x) => ApplicableRideType.fromJson(x),
            ),
          ),
    firstRowText: json["first_row_text"],
    secondRowText: json["second_row_text"],
    thirdRowText: json["third_row_text"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "description": description,
    "type": type,
    "value": value,
    "min_order_amount": minOrderAmount,
    "max_discount_amount": maxDiscountAmount,
    "max_uses_per_user": maxUsesPerUser,
    "max_uses_total": maxUsesTotal,
    "is_first_ride_only": isFirstRideOnly,
    "is_referral_code": isReferralCode,
    "status": status,
    "starts_at": startsAt,
    "expires_at": expiresAt,
    "is_expired": isExpired,
    "is_active": isActive,
    "is_available": isAvailable,
    "usage_count": usageCount,
    "remaining_uses": remainingUses,
    "usage_percentage": usagePercentage,
    "city_ids": cityIds == null
        ? []
        : List<dynamic>.from(cityIds!.map((x) => x)),
    "applicable_ride_types": applicableRideTypes == null
        ? []
        : List<dynamic>.from(applicableRideTypes!.map((x) => x.toJson())),
    "first_row_text": firstRowText,
    "second_row_text": secondRowText,
    "third_row_text": thirdRowText,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class ApplicableRideType {
  String? name;
  String? icon;

  ApplicableRideType({this.name, this.icon});

  ApplicableRideType copyWith({String? name, String? icon}) =>
      ApplicableRideType(name: name ?? this.name, icon: icon ?? this.icon);

  factory ApplicableRideType.fromJson(Map<String, dynamic> json) =>
      ApplicableRideType(name: json["name"], icon: json["icon"]);

  Map<String, dynamic> toJson() => {"name": name, "icon": icon};
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  int? from;
  int? to;
  bool? hasMorePages;

  Pagination({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.from,
    this.to,
    this.hasMorePages,
  });

  Pagination copyWith({
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
    int? from,
    int? to,
    bool? hasMorePages,
  }) => Pagination(
    currentPage: currentPage ?? this.currentPage,
    lastPage: lastPage ?? this.lastPage,
    perPage: perPage ?? this.perPage,
    total: total ?? this.total,
    from: from ?? this.from,
    to: to ?? this.to,
    hasMorePages: hasMorePages ?? this.hasMorePages,
  );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
    from: json["from"],
    to: json["to"],
    hasMorePages: json["has_more_pages"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
    "from": from,
    "to": to,
    "has_more_pages": hasMorePages,
  };
}
