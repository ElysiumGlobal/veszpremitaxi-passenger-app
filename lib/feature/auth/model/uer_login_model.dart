// To parse this JSON data, do
//
//     final userLoginModel = userLoginModelFromJson(jsonString);

import 'dart:convert';

UserLoginModel userLoginModelFromJson(String str) =>
    UserLoginModel.fromJson(json.decode(str));

String userLoginModelToJson(UserLoginModel data) => json.encode(data.toJson());

class UserLoginModel {
  bool? success;
  String? message;
  String? token;
  User? user;

  UserLoginModel({this.success, this.message, this.token, this.user});

  UserLoginModel copyWith({
    bool? success,
    String? message,
    String? token,
    User? user,
  }) => UserLoginModel(
    success: success ?? this.success,
    message: message ?? this.message,
    token: token ?? this.token,
    user: user ?? this.user,
  );

  factory UserLoginModel.fromJson(Map<String, dynamic> json) => UserLoginModel(
    success: json["success"],
    message: json["message"],
    token: json["token"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "token": token,
    "user": user?.toJson(),
  };
}

class User {
  String? id;
  String? name;
  String? phone;
  String? countryCode;
  String? email;
  String? password;
  String? gender;
  String? role;
  String? profilePhoto;
  String? status;
  String? referralCode;
  String? walletBalance;
  String? isRegister;
  String? step0;
  String? step1;
  String? step2;
  String? step3;
  List<dynamic>? savedLocations;
  Driver? driver;

  User({
    this.id,
    this.name,
    this.phone,
    this.countryCode,
    this.email,
    this.password,
    this.gender,
    this.role,
    this.profilePhoto,
    this.status,
    this.referralCode,
    this.walletBalance,
    this.isRegister,
    this.step0,
    this.step1,
    this.step2,
    this.step3,
    this.savedLocations,
    this.driver,
  });

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? countryCode,
    String? email,
    String? password,
    String? gender,
    String? role,
    String? profilePhoto,
    String? status,
    String? referralCode,
    String? walletBalance,
    String? isRegister,
    String? step0,
    String? step1,
    String? step2,
    String? step3,
    List<dynamic>? savedLocations,
    Driver? driver,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    countryCode: countryCode ?? this.countryCode,
    email: email ?? this.email,
    password: password ?? this.password,
    gender: gender ?? this.gender,
    role: role ?? this.role,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    status: status ?? this.status,
    referralCode: referralCode ?? this.referralCode,
    walletBalance: walletBalance ?? this.walletBalance,
    isRegister: isRegister ?? this.isRegister,
    step0: step0 ?? this.step0,
    step1: step1 ?? this.step1,
    step2: step2 ?? this.step2,
    step3: step3 ?? this.step3,
    savedLocations: savedLocations ?? this.savedLocations,
    driver: driver ?? this.driver,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    countryCode: json["country_code"],
    email: json["email"],
    password: json["password"],
    gender: json["gender"],
    role: json["role"],
    profilePhoto: json["profile_photo"],
    status: json["status"],
    referralCode: json["referral_code"],
    walletBalance: json["wallet_balance"],
    isRegister: json["is_register"],
    step0: json["step_0"],
    step1: json["step_1"],
    step2: json["step_2"],
    step3: json["step_3"],
    savedLocations: json["saved_locations"] == null
        ? []
        : List<dynamic>.from(json["saved_locations"]!.map((x) => x)),
    driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "country_code": countryCode,
    "email": email,
    "password": password,
    "gender": gender,
    "role": role,
    "profile_photo": profilePhoto,
    "status": status,
    "referral_code": referralCode,
    "wallet_balance": walletBalance,
    "is_register": isRegister,
    "step_0": step0,
    "step_1": step1,
    "step_2": step2,
    "step_3": step3,
    "saved_locations": savedLocations == null
        ? []
        : List<dynamic>.from(savedLocations!.map((x) => x)),
    "driver": driver?.toJson(),
  };
}

class Driver {
  String? isVerified;
  String? city;
  String? rating;
  String? totalTrips;
  String? isOnline;
  DocumentsStatus? documentsStatus;

  Driver({
    this.isVerified,
    this.city,
    this.rating,
    this.totalTrips,
    this.isOnline,
    this.documentsStatus,
  });

  Driver copyWith({
    String? isVerified,
    String? city,
    String? rating,
    String? totalTrips,
    String? isOnline,
    DocumentsStatus? documentsStatus,
  }) => Driver(
    isVerified: isVerified ?? this.isVerified,
    city: city ?? this.city,
    rating: rating ?? this.rating,
    totalTrips: totalTrips ?? this.totalTrips,
    isOnline: isOnline ?? this.isOnline,
    documentsStatus: documentsStatus ?? this.documentsStatus,
  );

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    isVerified: json["is_verified"],
    city: json["city"],
    rating: json["rating"],
    totalTrips: json["total_trips"],
    isOnline: json["is_online"],
    documentsStatus: json["documents_status"] == null
        ? null
        : DocumentsStatus.fromJson(json["documents_status"]),
  );

  Map<String, dynamic> toJson() => {
    "is_verified": isVerified,
    "city": city,
    "rating": rating,
    "total_trips": totalTrips,
    "is_online": isOnline,
    "documents_status": documentsStatus?.toJson(),
  };
}

class DocumentsStatus {
  String? total;
  String? uploaded;
  String? approved;
  String? pending;
  String? rejected;
  String? isComplete;

  DocumentsStatus({
    this.total,
    this.uploaded,
    this.approved,
    this.pending,
    this.rejected,
    this.isComplete,
  });

  DocumentsStatus copyWith({
    String? total,
    String? uploaded,
    String? approved,
    String? pending,
    String? rejected,
    String? isComplete,
  }) => DocumentsStatus(
    total: total ?? this.total,
    uploaded: uploaded ?? this.uploaded,
    approved: approved ?? this.approved,
    pending: pending ?? this.pending,
    rejected: rejected ?? this.rejected,
    isComplete: isComplete ?? this.isComplete,
  );

  factory DocumentsStatus.fromJson(Map<String, dynamic> json) =>
      DocumentsStatus(
        total: json["total"],
        uploaded: json["uploaded"],
        approved: json["approved"],
        pending: json["pending"],
        rejected: json["rejected"],
        isComplete: json["is_complete"],
      );

  Map<String, dynamic> toJson() => {
    "total": total,
    "uploaded": uploaded,
    "approved": approved,
    "pending": pending,
    "rejected": rejected,
    "is_complete": isComplete,
  };
}
