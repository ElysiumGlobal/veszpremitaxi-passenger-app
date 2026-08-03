

import 'dart:convert';

LocationDataModel locationDataModelFromJson(String str) =>
    LocationDataModel.fromJson(json.decode(str));

String locationDataModelToJson(LocationDataModel data) =>
    json.encode(data.toJson());

class LocationDataModel {
  bool? success;
  List<LocationList>? data;

  LocationDataModel({this.success, this.data});

  LocationDataModel copyWith({bool? success, List<LocationList>? data}) =>
      LocationDataModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory LocationDataModel.fromJson(Map<String, dynamic> json) =>
      LocationDataModel(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<LocationList>.from(
                json["data"]!.map((x) => LocationList.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class LocationList {
  int? id;
  String? name;
  String? address;
  String? latitude;
  String? longitude;
  String? type;
  bool? isDefault;
  String? createdAt;

  LocationList({
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.type,
    this.isDefault,
    this.createdAt,
  });

  LocationList copyWith({
    int? id,
    String? name,
    String? address,
    String? latitude,
    String? longitude,
    String? type,
    bool? isDefault,
    String? createdAt,
  }) => LocationList(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    type: type ?? this.type,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
  );

  factory LocationList.fromJson(Map<String, dynamic> json) => LocationList(
    id: json["id"],
    name: json["name"],
    address: json["address"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    type: json["type"],
    isDefault: json["is_default"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
    "type": type,
    "is_default": isDefault,
    "created_at": createdAt,
  };
}
