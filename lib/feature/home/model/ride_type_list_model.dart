import 'dart:convert';

RideTypeListModel rideTypeListModelFromJson(String str) =>
    RideTypeListModel.fromJson(json.decode(str));

String rideTypeListModelToJson(RideTypeListModel data) =>
    json.encode(data.toJson());

class RideTypeListModel {
  bool? success;
  String? message;
  Data? data;

  RideTypeListModel({this.success, this.message, this.data});

  RideTypeListModel copyWith({bool? success, String? message, Data? data}) =>
      RideTypeListModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory RideTypeListModel.fromJson(Map<String, dynamic> json) =>
      RideTypeListModel(
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
  List<RideType>? rideTypes;

  Data({this.rideTypes});

  Data copyWith({List<RideType>? rideTypes}) =>
      Data(rideTypes: rideTypes ?? this.rideTypes);

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    rideTypes: json["ride_types"] == null
        ? []
        : List<RideType>.from(
            json["ride_types"]!.map((x) => RideType.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "ride_types": rideTypes == null
        ? []
        : List<dynamic>.from(rideTypes!.map((x) => x.toJson())),
  };
}

class RideType {
  String? id;
  String? name;
  String? code;
  String? description;
  String? capacity;
  String? baseDistance;
  String? basePrice;
  String? pricePerKm;
  String? pricePerMinute;
  String? minimumFare;
  String? cancellationCharge;
  String? waitingChargePerMinute;
  String? waitingTimeLimit;
  String? status;
  String? icon;

  RideType({
    this.id,
    this.name,
    this.code,
    this.description,
    this.capacity,
    this.baseDistance,
    this.basePrice,
    this.pricePerKm,
    this.pricePerMinute,
    this.minimumFare,
    this.cancellationCharge,
    this.waitingChargePerMinute,
    this.waitingTimeLimit,
    this.status,
    this.icon,
  });

  RideType copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? capacity,
    String? baseDistance,
    String? basePrice,
    String? pricePerKm,
    String? pricePerMinute,
    String? minimumFare,
    String? cancellationCharge,
    String? waitingChargePerMinute,
    String? waitingTimeLimit,
    String? status,
    String? icon,
  }) => RideType(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code ?? this.code,
    description: description ?? this.description,
    capacity: capacity ?? this.capacity,
    baseDistance: baseDistance ?? this.baseDistance,
    basePrice: basePrice ?? this.basePrice,
    pricePerKm: pricePerKm ?? this.pricePerKm,
    pricePerMinute: pricePerMinute ?? this.pricePerMinute,
    minimumFare: minimumFare ?? this.minimumFare,
    cancellationCharge: cancellationCharge ?? this.cancellationCharge,
    waitingChargePerMinute:
        waitingChargePerMinute ?? this.waitingChargePerMinute,
    waitingTimeLimit: waitingTimeLimit ?? this.waitingTimeLimit,
    status: status ?? this.status,
    icon: icon ?? this.icon,
  );

  factory RideType.fromJson(Map<String, dynamic> json) => RideType(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    description: json["description"],
    capacity: json["capacity"],
    baseDistance: json["base_distance"],
    basePrice: json["base_price"],
    pricePerKm: json["price_per_km"],
    pricePerMinute: json["price_per_minute"],
    minimumFare: json["minimum_fare"],
    cancellationCharge: json["cancellation_charge"],
    waitingChargePerMinute: json["waiting_charge_per_minute"],
    waitingTimeLimit: json["waiting_time_limit"],
    status: json["status"],
    icon: json["icon"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "description": description,
    "capacity": capacity,
    "base_distance": baseDistance,
    "base_price": basePrice,
    "price_per_km": pricePerKm,
    "price_per_minute": pricePerMinute,
    "minimum_fare": minimumFare,
    "cancellation_charge": cancellationCharge,
    "waiting_charge_per_minute": waitingChargePerMinute,
    "waiting_time_limit": waitingTimeLimit,
    "status": status,
    "icon": icon,
  };
}
