class UserAccountListModel {
  bool? success;
  String? message;
  Data? data;

  UserAccountListModel({this.success, this.message, this.data});

  UserAccountListModel copyWith({bool? success, String? message, Data? data}) =>
      UserAccountListModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory UserAccountListModel.fromJson(Map<String, dynamic> json) =>
      UserAccountListModel(
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
  List<ContactModel>? contacts;
  int? totalCount;
  dynamic selectedContactId;
  String? privacyMessage;

  Data({
    this.contacts,
    this.totalCount,
    this.selectedContactId,
    this.privacyMessage,
  });

  Data copyWith({
    List<ContactModel>? contacts,
    int? totalCount,
    dynamic selectedContactId,
    String? privacyMessage,
  }) => Data(
    contacts: contacts ?? this.contacts,
    totalCount: totalCount ?? this.totalCount,
    selectedContactId: selectedContactId ?? this.selectedContactId,
    privacyMessage: privacyMessage ?? this.privacyMessage,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    contacts: json["contacts"] == null
        ? []
        : List<ContactModel>.from(
            json["contacts"]!.map((x) => ContactModel.fromJson(x)),
          ),
    totalCount: json["total_count"],
    selectedContactId: json["selected_contact_id"],
    privacyMessage: json["privacy_message"],
  );

  Map<String, dynamic> toJson() => {
    "contacts": contacts == null
        ? []
        : List<dynamic>.from(contacts!.map((x) => x.toJson())),
    "total_count": totalCount,
    "selected_contact_id": selectedContactId,
    "privacy_message": privacyMessage,
  };
}

class ContactModel {
  int? id;
  String? name;
  String? mobileNumber;
  bool? isPrimary;
  bool? isMyself;
  bool? isSelected;
  dynamic profilePic;
  String? createdAt;
  String? updatedAt;

  ContactModel({
    this.id,
    this.name,
    this.mobileNumber,
    this.isPrimary,
    this.isMyself,
    this.isSelected,
    this.profilePic,
    this.createdAt,
    this.updatedAt,
  });

  ContactModel copyWith({
    int? id,
    String? name,
    String? mobileNumber,
    bool? isPrimary,
    bool? isMyself,
    bool? isSelected,
    dynamic profilePic,
    String? createdAt,
    String? updatedAt,
  }) => ContactModel(
    id: id ?? this.id,
    name: name ?? this.name,
    mobileNumber: mobileNumber ?? this.mobileNumber,
    isPrimary: isPrimary ?? this.isPrimary,
    isMyself: isMyself ?? this.isMyself,
    isSelected: isSelected ?? this.isSelected,
    profilePic: profilePic ?? this.profilePic,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
    id: json["id"],
    name: json["name"],
    mobileNumber: json["mobile_number"],
    isPrimary: json["is_primary"],
    isMyself: json["is_myself"],
    isSelected: json["is_selected"],
    profilePic: json["profile_pic"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "mobile_number": mobileNumber,
    "is_primary": isPrimary,
    "is_myself": isMyself,
    "is_selected": isSelected,
    "profile_pic": profilePic,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
