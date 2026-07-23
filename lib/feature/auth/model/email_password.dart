class AuthPhoneEmailModel {
  final String email;
  final String phone;
  final String countryCode;
  final String password;

  AuthPhoneEmailModel({
    this.email = "",
    this.phone = "",
    this.countryCode = "+36",
    this.password = "",
  });

  factory AuthPhoneEmailModel.fromJson(Map<String, dynamic> json) {
    return AuthPhoneEmailModel(
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      countryCode: json['countryCode'] ?? "+36",
      password: json['password'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "phone": phone,
      "countryCode": countryCode,
      "password": password,
    };
  }
}
