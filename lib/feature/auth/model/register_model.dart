import 'dart:convert';

RegisterModel registerModelFromJson(String str) =>
    RegisterModel.fromJson(json.decode(str));

String registerModelToJson(RegisterModel data) => json.encode(data.toJson());

class RegisterModel {
  bool? success;
  String? message;
  String? token;
  User? user;

  RegisterModel({this.success, this.message, this.token, this.user});

  RegisterModel copyWith({
    bool? success,
    String? message,
    String? token,
    User? user,
  }) => RegisterModel(
    success: success ?? this.success,
    message: message ?? this.message,
    token: token ?? this.token,
    user: user ?? this.user,
  );

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
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
  String? email;
  String? password;
  String? gender;
  String? role;
  String? profilePhoto;
  String? status;
  String? referralCode;
  String? walletBalance;
  int? isEmail;
  int? newRegister;

  User({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.password,
    this.gender,
    this.role,
    this.profilePhoto,
    this.status,
    this.referralCode,
    this.walletBalance,
    this.isEmail,
    this.newRegister,
  });

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? password,
    String? gender,
    String? role,
    String? profilePhoto,
    String? status,
    String? referralCode,
    String? walletBalance,
    int? isEmail,
    int? newRegister,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    password: password ?? this.password,
    gender: gender ?? this.gender,
    role: role ?? this.role,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    status: status ?? this.status,
    referralCode: referralCode ?? this.referralCode,
    walletBalance: walletBalance ?? this.walletBalance,
    isEmail: isEmail ?? this.isEmail,
    newRegister: newRegister ?? this.newRegister,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    email: json["email"],
    password: json["password"],
    gender: json["gender"],
    role: json["role"],
    profilePhoto: json["profile_photo"],
    status: json["status"],
    referralCode: json["referral_code"],
    walletBalance: json["wallet_balance"],
    isEmail: json["is_email"],
    newRegister: json["new_register"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "email": email,
    "password": password,
    "gender": gender,
    "role": role,
    "profile_photo": profilePhoto,
    "status": status,
    "referral_code": referralCode,
    "wallet_balance": walletBalance,
    "is_email": isEmail,
    "new_register": newRegister,
  };
}
