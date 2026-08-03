
import 'dart:convert';

CashCollectedModel cashCollectedModelFromJson(String str) =>
    CashCollectedModel.fromJson(json.decode(str));

String cashCollectedModelToJson(CashCollectedModel data) =>
    json.encode(data.toJson());

class CashCollectedModel {
  bool? success;
  String? message;
  Data? data;

  CashCollectedModel({this.success, this.message, this.data});

  CashCollectedModel copyWith({bool? success, String? message, Data? data}) =>
      CashCollectedModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory CashCollectedModel.fromJson(Map<String, dynamic> json) =>
      CashCollectedModel(
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
  String? totalPoints;
  List<CashCollectionPoint>? cashCollectionPoints;

  Data({this.totalPoints, this.cashCollectionPoints});

  Data copyWith({
    String? totalPoints,
    List<CashCollectionPoint>? cashCollectionPoints,
  }) => Data(
    totalPoints: totalPoints ?? this.totalPoints,
    cashCollectionPoints: cashCollectionPoints ?? this.cashCollectionPoints,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalPoints: json["total_points"],
    cashCollectionPoints: json["cash_collection_points"] == null
        ? []
        : List<CashCollectionPoint>.from(
            json["cash_collection_points"]!.map(
              (x) => CashCollectionPoint.fromJson(x),
            ),
          ),
  );

  Map<String, dynamic> toJson() => {
    "total_points": totalPoints,
    "cash_collection_points": cashCollectionPoints == null
        ? []
        : List<dynamic>.from(cashCollectionPoints!.map((x) => x.toJson())),
  };
}

class CashCollectionPoint {
  String? id;
  String? cityId;
  String? cityName;
  String? name;
  String? address;
  String? contactPerson;
  String? contactPhone;
  String? contactEmail;
  String? latitude;
  String? longitude;
  List<OperatingHour>? operatingHours;
  String? isActive;
  String? createdAt;
  String? updatedAt;

  CashCollectionPoint({
    this.id,
    this.cityId,
    this.cityName,
    this.name,
    this.address,
    this.contactPerson,
    this.contactPhone,
    this.contactEmail,
    this.latitude,
    this.longitude,
    this.operatingHours,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  CashCollectionPoint copyWith({
    String? id,
    String? cityId,
    String? cityName,
    String? name,
    String? address,
    String? contactPerson,
    String? contactPhone,
    String? contactEmail,
    String? latitude,
    String? longitude,
    List<OperatingHour>? operatingHours,
    String? isActive,
    String? createdAt,
    String? updatedAt,
  }) => CashCollectionPoint(
    id: id ?? this.id,
    cityId: cityId ?? this.cityId,
    cityName: cityName ?? this.cityName,
    name: name ?? this.name,
    address: address ?? this.address,
    contactPerson: contactPerson ?? this.contactPerson,
    contactPhone: contactPhone ?? this.contactPhone,
    contactEmail: contactEmail ?? this.contactEmail,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    operatingHours: operatingHours ?? this.operatingHours,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory CashCollectionPoint.fromJson(Map<String, dynamic> json) =>
      CashCollectionPoint(
        id: json["id"],
        cityId: json["city_id"],
        cityName: json["city_name"],
        name: json["name"],
        address: json["address"],
        contactPerson: json["contact_person"],
        contactPhone: json["contact_phone"],
        contactEmail: json["contact_email"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        operatingHours: json["operating_hours"] == null
            ? []
            : List<OperatingHour>.from(
                json["operating_hours"]!.map((x) => OperatingHour.fromJson(x)),
              ),
        isActive: json["is_active"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "city_id": cityId,
    "city_name": cityName,
    "name": name,
    "address": address,
    "contact_person": contactPerson,
    "contact_phone": contactPhone,
    "contact_email": contactEmail,
    "latitude": latitude,
    "longitude": longitude,
    "operating_hours": operatingHours == null
        ? []
        : List<dynamic>.from(operatingHours!.map((x) => x.toJson())),
    "is_active": isActive,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class OperatingHour {
  String? day;
  String? openTime;
  String? closeTime;
  bool? isClosed;

  OperatingHour({this.day, this.openTime, this.closeTime, this.isClosed});

  OperatingHour copyWith({
    String? day,
    String? openTime,
    String? closeTime,
    bool? isClosed,
  }) => OperatingHour(
    day: day ?? this.day,
    openTime: openTime ?? this.openTime,
    closeTime: closeTime ?? this.closeTime,
    isClosed: isClosed ?? this.isClosed,
  );

  factory OperatingHour.fromJson(Map<String, dynamic> json) => OperatingHour(
    day: json["day"],
    openTime: json["open_time"],
    closeTime: json["close_time"],
    isClosed: json["is_closed"],
  );

  Map<String, dynamic> toJson() => {
    "day": day,
    "open_time": openTime,
    "close_time": closeTime,
    "is_closed": isClosed,
  };
}
