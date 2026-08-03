class UserLoginModel {
  bool? success;
  String? message;
  String? token;
  Driver? driver;

  UserLoginModel({this.success, this.message, this.token, this.driver});

  UserLoginModel copyWith({
    bool? success,
    String? message,
    String? token,
    Driver? driver,
  }) => UserLoginModel(
    success: success ?? this.success,
    message: message ?? this.message,
    token: token ?? this.token,
    driver: driver ?? this.driver,
  );

  factory UserLoginModel.fromJson(Map<String, dynamic> json) => UserLoginModel(
    success: json["success"],
    message: json["message"],
    token: json["token"],
    driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "token": token,
    "driver": driver?.toJson(),
  };
}

class Driver {
  String? id;
  String? name;
  String? phone;
  String? countryCode;
  String? email;
  String? gender;
  String? role;
  String? profilePhoto;
  String? status;
  String? referralCode;
  String? walletBalance;
  String? isVerified;
  String? city;
  String? rating;
  String? totalTrips;
  String? isOnline;
  String? isRegister;
  String? step0;
  String? step1;
  String? step2;
  String? step3;
  Vehicle? vehicle;

  Driver({
    this.id,
    this.name,
    this.phone,
    this.countryCode,
    this.email,
    this.gender,
    this.role,
    this.profilePhoto,
    this.status,
    this.referralCode,
    this.walletBalance,
    this.isVerified,
    this.city,
    this.rating,
    this.totalTrips,
    this.isOnline,
    this.isRegister,
    this.step0,
    this.step1,
    this.step2,
    this.step3,
    this.vehicle,
  });

  Driver copyWith({
    String? id,
    String? name,
    String? phone,
    String? countryCode,
    String? email,
    String? gender,
    String? role,
    String? profilePhoto,
    String? status,
    String? referralCode,
    String? walletBalance,
    String? isVerified,
    String? city,
    String? rating,
    String? totalTrips,
    String? isOnline,
    String? isRegister,
    String? step0,
    String? step1,
    String? step2,
    String? step3,
    Vehicle? vehicle,
  }) => Driver(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    countryCode: countryCode ?? this.countryCode,
    email: email ?? this.email,
    gender: gender ?? this.gender,
    role: role ?? this.role,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    status: status ?? this.status,
    referralCode: referralCode ?? this.referralCode,
    walletBalance: walletBalance ?? this.walletBalance,
    isVerified: isVerified ?? this.isVerified,
    city: city ?? this.city,
    rating: rating ?? this.rating,
    totalTrips: totalTrips ?? this.totalTrips,
    isOnline: isOnline ?? this.isOnline,
    isRegister: isRegister ?? this.isRegister,
    step0: step0 ?? this.step0,
    step1: step1 ?? this.step1,
    step2: step2 ?? this.step2,
    step3: step3 ?? this.step3,
    vehicle: vehicle ?? this.vehicle,
  );

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json["id"]?.toString(),
    name: json["name"]?.toString(),
    phone: json["phone"]?.toString(),
    countryCode: json["country_code"]?.toString(),
    email: json["email"]?.toString(),
    gender: json["gender"]?.toString(),
    role: json["role"]?.toString(),
    profilePhoto: json["profile_photo"]?.toString(),
    status: json["status"]?.toString(),
    referralCode: json["referral_code"]?.toString(),
    walletBalance: json["wallet_balance"]?.toString(),
    isVerified: json["is_verified"]?.toString(),
    city: json["city"]?.toString(),
    rating: json["rating"]?.toString(),
    totalTrips: json["total_trips"]?.toString(),
    isOnline: json["is_online"]?.toString(),
    isRegister: json["is_register"]?.toString(),
    step0: json["step_0"]?.toString(),
    step1: json["step_1"]?.toString(),
    step2: json["step_2"]?.toString(),
    step3: json["step_3"]?.toString(),
    vehicle: json["vehicle"] == null ? null : Vehicle.fromJson(json["vehicle"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "country_code": countryCode,
    "email": email,
    "gender": gender,
    "role": role,
    "profile_photo": profilePhoto,
    "status": status,
    "referral_code": referralCode,
    "wallet_balance": walletBalance,
    "is_verified": isVerified,
    "city": city,
    "rating": rating,
    "total_trips": totalTrips,
    "is_online": isOnline,
    "is_register": isRegister,
    "step_0": step0,
    "step_1": step1,
    "step_2": step2,
    "step_3": step3,
    "vehicle": vehicle?.toJson(),
  };
}

class Vehicle {
  String? id;
  String? brand;
  String? model;
  String? year;
  String? registrationNumber;
  String? licensePlate;
  String? color;
  String? rideType;

  Vehicle({
    this.id,
    this.brand,
    this.model,
    this.year,
    this.registrationNumber,
    this.licensePlate,
    this.color,
    this.rideType,
  });

  Vehicle copyWith({
    String? id,
    String? brand,
    String? model,
    String? year,
    String? registrationNumber,
    String? licensePlate,
    String? color,
    String? rideType,
  }) => Vehicle(
    id: id ?? this.id,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    year: year ?? this.year,
    registrationNumber: registrationNumber ?? this.registrationNumber,
    licensePlate: licensePlate ?? this.licensePlate,
    color: color ?? this.color,
    rideType: rideType ?? this.rideType,
  );

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json["id"]?.toString(),
    brand: json["brand"]?.toString(),
    model: json["model"]?.toString(),
    year: json["year"]?.toString(),
    registrationNumber: json["registration_number"]?.toString(),
    licensePlate: json["license_plate"]?.toString(),
    color: json["color"]?.toString(),
    rideType: json["ride_type"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "brand": brand,
    "model": model,
    "year": year,
    "registration_number": registrationNumber,
    "license_plate": licensePlate,
    "color": color,
    "ride_type": rideType,
  };
}
