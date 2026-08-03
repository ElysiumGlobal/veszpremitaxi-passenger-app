

import 'dart:convert';

DriverTransactionModel driverTransactionModelFromJson(String str) =>
    DriverTransactionModel.fromJson(json.decode(str));

String driverTransactionModelToJson(DriverTransactionModel data) =>
    json.encode(data.toJson());

class DriverTransactionModel {
  bool? success;
  Data? data;

  DriverTransactionModel({this.success, this.data});

  DriverTransactionModel copyWith({bool? success, Data? data}) =>
      DriverTransactionModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory DriverTransactionModel.fromJson(Map<String, dynamic> json) =>
      DriverTransactionModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  Filters? filters;
  List<Earning>? earnings;

  Data({this.filters, this.earnings});

  Data copyWith({Filters? filters, List<Earning>? earnings}) => Data(
    filters: filters ?? this.filters,
    earnings: earnings ?? this.earnings,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    filters: json["filters"] == null ? null : Filters.fromJson(json["filters"]),
    earnings: json["earnings"] == null
        ? []
        : List<Earning>.from(json["earnings"]!.map((x) => Earning.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "filters": filters?.toJson(),
    "earnings": earnings == null
        ? []
        : List<dynamic>.from(earnings!.map((x) => x.toJson())),
  };
}

class Earning {
  String? date;
  double? dailyTotalEarnings;
  List<Transaction>? transactions;

  Earning({this.date, this.dailyTotalEarnings, this.transactions});

  Earning copyWith({
    String? date,
    double? dailyTotalEarnings,
    List<Transaction>? transactions,
  }) => Earning(
    date: date ?? this.date,
    dailyTotalEarnings: dailyTotalEarnings ?? this.dailyTotalEarnings,
    transactions: transactions ?? this.transactions,
  );

  factory Earning.fromJson(Map<String, dynamic> json) => Earning(
    date: json["date"],
    dailyTotalEarnings: json["daily_total_earnings"]?.toDouble(),
    transactions: json["transactions"] == null
        ? []
        : List<Transaction>.from(
            json["transactions"]!.map((x) => Transaction.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "daily_total_earnings": dailyTotalEarnings,
    "transactions": transactions == null
        ? []
        : List<dynamic>.from(transactions!.map((x) => x.toJson())),
  };
}

class Transaction {
  int? id;
  String? type;
  String? description;
  String? time;
  double? amount;
  String? currency;
  bool? isPositive;
  String? bookingCode;
  String? transactionType;
  dynamic transactionId;
  int? isApprove;

  Transaction({
    this.id,
    this.type,
    this.description,
    this.time,
    this.amount,
    this.currency,
    this.isPositive,
    this.bookingCode,
    this.transactionType,
    this.transactionId,
    this.isApprove,
  });

  Transaction copyWith({
    int? id,
    int? isApprove,
    String? type,
    String? description,
    String? time,
    double? amount,
    String? currency,
    bool? isPositive,
    String? bookingCode,
    String? transactionType,
    dynamic transactionId,
  }) => Transaction(
    id: id ?? this.id,
    isApprove: isApprove ?? this.isApprove,
    type: type ?? this.type,
    description: description ?? this.description,
    time: time ?? this.time,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    isPositive: isPositive ?? this.isPositive,
    bookingCode: bookingCode ?? this.bookingCode,
    transactionType: transactionType ?? this.transactionType,
    transactionId: transactionId ?? this.transactionId,
  );

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json["id"],
    isApprove: json["is_approve"],
    type: json["type"],
    description: json["description"],
    time: json["time"],
    amount: json["amount"]?.toDouble(),
    currency: json["currency"],
    isPositive: json["is_positive"],
    bookingCode: json["booking_code"],
    transactionType: json["transaction_type"],
    transactionId: json["transaction_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "is_approve": isApprove,
    "type": type,
    "description": description,
    "time": time,
    "amount": amount,
    "currency": currency,
    "is_positive": isPositive,
    "booking_code": bookingCode,
    "transaction_type": transactionType,
    "transaction_id": transactionId,
  };
}

class Filters {
  String? paymentSource;
  String? earningType;
  String? amount;

  Filters({this.paymentSource, this.earningType, this.amount});

  Filters copyWith({
    String? paymentSource,
    String? earningType,
    String? amount,
  }) => Filters(
    paymentSource: paymentSource ?? this.paymentSource,
    earningType: earningType ?? this.earningType,
    amount: amount ?? this.amount,
  );

  factory Filters.fromJson(Map<String, dynamic> json) => Filters(
    paymentSource: json["payment_source"],
    earningType: json["earning_type"],
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "payment_source": paymentSource,
    "earning_type": earningType,
    "amount": amount,
  };
}
