class EarningTransactionModel {
  bool? success;
  Data? data;

  EarningTransactionModel({this.success, this.data});

  EarningTransactionModel copyWith({bool? success, Data? data}) =>
      EarningTransactionModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory EarningTransactionModel.fromJson(Map<String, dynamic> json) =>
      EarningTransactionModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  dynamic currentBalance;
  String? scheduledPayout;
  bool? hasBankAccount;
  List<RecentTransaction>? recentTransactions;
  List<Tab>? tabs;

  Data({
    this.currentBalance,
    this.scheduledPayout,
    this.hasBankAccount,
    this.recentTransactions,
    this.tabs,
  });

  Data copyWith({
    String? currentBalance,
    String? scheduledPayout,
    bool? hasBankAccount,
    List<RecentTransaction>? recentTransactions,
    List<Tab>? tabs,
  }) => Data(
    currentBalance: currentBalance ?? this.currentBalance,
    scheduledPayout: scheduledPayout ?? this.scheduledPayout,
    hasBankAccount: hasBankAccount ?? this.hasBankAccount,
    recentTransactions: recentTransactions ?? this.recentTransactions,
    tabs: tabs ?? this.tabs,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentBalance: json["current_balance"],
    scheduledPayout: json["scheduled_payout"],
    hasBankAccount: json["has_bank_account"],
    recentTransactions: json["recent_transactions"] == null
        ? []
        : List<RecentTransaction>.from(
            json["recent_transactions"]!.map(
              (x) => RecentTransaction.fromJson(x),
            ),
          ),
    tabs: json["tabs"] == null
        ? []
        : List<Tab>.from(json["tabs"]!.map((x) => Tab.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "current_balance": currentBalance,
    "scheduled_payout": scheduledPayout,
    "has_bank_account": hasBankAccount,
    "recent_transactions": recentTransactions == null
        ? []
        : List<dynamic>.from(recentTransactions!.map((x) => x.toJson())),
    "tabs": tabs == null
        ? []
        : List<dynamic>.from(tabs!.map((x) => x.toJson())),
  };
}

class RecentTransaction {
  int? id;
  String? type;
  String? description;
  dynamic amount;
  String? time;
  int? isPositive;

  RecentTransaction({
    this.id,
    this.type,
    this.description,
    this.amount,
    this.time,
    this.isPositive,
  });

  RecentTransaction copyWith({
    int? id,
    String? type,
    String? description,
    dynamic amount,
    String? time,
    int? isPositive,
  }) => RecentTransaction(
    id: id ?? this.id,
    type: type ?? this.type,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    time: time ?? this.time,
    isPositive: isPositive ?? this.isPositive,
  );

  factory RecentTransaction.fromJson(Map<String, dynamic> json) =>
      RecentTransaction(
        id: json["id"],
        type: json["type"],
        description: json["description"],
        amount: json["amount"],
        time: json["time"],
        isPositive: json["is_positive"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "description": description,
    "amount": amount,
    "time": time,
    "is_positive": isPositive,
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
