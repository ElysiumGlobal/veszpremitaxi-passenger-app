class BankDetailsModel {
  bool? success;
  Data? data;

  BankDetailsModel({this.success, this.data});

  BankDetailsModel copyWith({bool? success, Data? data}) => BankDetailsModel(
    success: success ?? this.success,
    data: data ?? this.data,
  );

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) =>
      BankDetailsModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  List<Tab>? tabs;
  String? instructionText;
  AccountDetails? accountDetails;

  Data({this.tabs, this.instructionText, this.accountDetails});

  Data copyWith({
    List<Tab>? tabs,
    String? instructionText,
    AccountDetails? accountDetails,
  }) => Data(
    tabs: tabs ?? this.tabs,
    instructionText: instructionText ?? this.instructionText,
    accountDetails: accountDetails ?? this.accountDetails,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    tabs: json["tabs"] == null
        ? []
        : List<Tab>.from(json["tabs"]!.map((x) => Tab.fromJson(x))),
    instructionText: json["instruction_text"],
    accountDetails: json["account_details"] == null
        ? null
        : AccountDetails.fromJson(json["account_details"]),
  );

  Map<String, dynamic> toJson() => {
    "tabs": tabs == null
        ? []
        : List<dynamic>.from(tabs!.map((x) => x.toJson())),
    "instruction_text": instructionText,
    "account_details": accountDetails?.toJson(),
  };
}

class AccountDetails {
  dynamic id;
  String? accountHolderName;
  String? accountNumber;
  String? ifscCode;
  String? bankName;
  String? upiId;

  AccountDetails({
    this.id,
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.upiId,
  });

  AccountDetails copyWith({
    dynamic id,
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? bankName,
    String? upiId,
  }) => AccountDetails(
    id: id ?? this.id,
    accountHolderName: accountHolderName ?? this.accountHolderName,
    accountNumber: accountNumber ?? this.accountNumber,
    ifscCode: ifscCode ?? this.ifscCode,
    bankName: bankName ?? this.bankName,
    upiId: upiId ?? this.upiId,
  );

  factory AccountDetails.fromJson(Map<String, dynamic> json) => AccountDetails(
    id: json["id"],
    accountHolderName: json["account_holder_name"],
    accountNumber: json["account_number"],
    ifscCode: json["ifsc_code"],
    bankName: json["bank_name"],
    upiId: json["upi_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "account_holder_name": accountHolderName,
    "account_number": accountNumber,
    "ifsc_code": ifscCode,
    "bank_name": bankName,
    "upi_id": upiId,
  };
}

class Tab {
  String? name;
  bool? selected;

  Tab({this.name, this.selected});

  Tab copyWith({String? name, bool? selected}) =>
      Tab(name: name ?? this.name, selected: selected ?? this.selected);

  factory Tab.fromJson(Map<String, dynamic> json) =>
      Tab(name: json["name"], selected: json["selected"]);

  Map<String, dynamic> toJson() => {"name": name, "selected": selected};
}
