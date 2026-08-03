class EmergencyModel {
  bool? success;
  String? message;
  Data? data;

  EmergencyModel({this.success, this.message, this.data});

  EmergencyModel copyWith({bool? success, String? message, Data? data}) =>
      EmergencyModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory EmergencyModel.fromJson(Map<String, dynamic> json) => EmergencyModel(
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
  List<Contact>? contacts;
  int? totalCount;
  int? maxLimit;
  bool? canAddMore;

  Data({this.contacts, this.totalCount, this.maxLimit, this.canAddMore});

  Data copyWith({
    List<Contact>? contacts,
    int? totalCount,
    int? maxLimit,
    bool? canAddMore,
  }) => Data(
    contacts: contacts ?? this.contacts,
    totalCount: totalCount ?? this.totalCount,
    maxLimit: maxLimit ?? this.maxLimit,
    canAddMore: canAddMore ?? this.canAddMore,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    contacts: json["contacts"] == null
        ? []
        : List<Contact>.from(json["contacts"]!.map((x) => Contact.fromJson(x))),
    totalCount: json["total_count"],
    maxLimit: json["max_limit"],
    canAddMore: json["can_add_more"],
  );

  Map<String, dynamic> toJson() => {
    "contacts": contacts == null
        ? []
        : List<dynamic>.from(contacts!.map((x) => x.toJson())),
    "total_count": totalCount,
    "max_limit": maxLimit,
    "can_add_more": canAddMore,
  };
}

class Contact {
  int? id;
  String? name;
  String? mobileNumber;
  String? formattedMobile;
  bool? isPrimary;
  String? createdAt;
  String? updatedAt;

  Contact({
    this.id,
    this.name,
    this.mobileNumber,
    this.formattedMobile,
    this.isPrimary,
    this.createdAt,
    this.updatedAt,
  });

  Contact copyWith({
    int? id,
    String? name,
    String? mobileNumber,
    String? formattedMobile,
    bool? isPrimary,
    String? createdAt,
    String? updatedAt,
  }) => Contact(
    id: id ?? this.id,
    name: name ?? this.name,
    mobileNumber: mobileNumber ?? this.mobileNumber,
    formattedMobile: formattedMobile ?? this.formattedMobile,
    isPrimary: isPrimary ?? this.isPrimary,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    id: json["id"],
    name: json["name"],
    mobileNumber: json["mobile_number"],
    formattedMobile: json["formatted_mobile"],
    isPrimary: json["is_primary"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "mobile_number": mobileNumber,
    "formatted_mobile": formattedMobile,
    "is_primary": isPrimary,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
