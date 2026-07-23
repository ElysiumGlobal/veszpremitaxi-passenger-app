import 'dart:convert';

UserAddressModel userAddressModelFromJson(String str) =>
    UserAddressModel.fromJson(json.decode(str));

String userAddressModelToJson(UserAddressModel data) =>
    json.encode(data.toJson());

class UserAddressModel {
  bool? success;
  List<AddressModel>? data;

  UserAddressModel({this.success, this.data});

  UserAddressModel copyWith({bool? success, List<AddressModel>? data}) =>
      UserAddressModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory UserAddressModel.fromJson(Map<String, dynamic> json) =>
      UserAddressModel(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<AddressModel>.from(
                json["data"]!.map((x) => AddressModel.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class AddressModel {
  int? id;
  String? name;
  String? address;
  String? latitude;
  String? longitude;
  String? type;
  bool? isDefault;
  String? createdAt;

  AddressModel({
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.type,
    this.isDefault,
    this.createdAt,
  });

  AddressModel copyWith({
    int? id,
    String? name,
    String? address,
    String? latitude,
    String? longitude,
    String? type,
    bool? isDefault,
    String? createdAt,
  }) => AddressModel(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    type: type ?? this.type,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
  );

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
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
