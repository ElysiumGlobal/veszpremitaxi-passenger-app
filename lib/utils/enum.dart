enum LoginType {
  otp("Otp"),
  email("Email"),
  google("Google"),
  apple("Apple");

  final String name;

  const LoginType(this.name);
}
