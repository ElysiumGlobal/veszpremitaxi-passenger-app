class WalletTransactionModel {
  bool? success;
  Data? data;

  WalletTransactionModel({this.success, this.data});

  WalletTransactionModel copyWith({bool? success, Data? data}) =>
      WalletTransactionModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  Filters? filters;
  List<DataTransaction>? transactions;
  Pagination? pagination;

  Data({this.filters, this.transactions, this.pagination});

  Data copyWith({
    Filters? filters,
    List<DataTransaction>? transactions,
    Pagination? pagination,
  }) => Data(
    filters: filters ?? this.filters,
    transactions: transactions ?? this.transactions,
    pagination: pagination ?? this.pagination,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    filters: json["filters"] == null ? null : Filters.fromJson(json["filters"]),
    transactions: json["transactions"] == null
        ? []
        : List<DataTransaction>.from(
            json["transactions"]!.map((x) => DataTransaction.fromJson(x)),
          ),
    pagination: json["pagination"] == null
        ? null
        : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "filters": filters?.toJson(),
    "transactions": transactions == null
        ? []
        : List<dynamic>.from(transactions!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Filters {
  String? date;
  String? transactionType;
  String? amount;

  Filters({this.date, this.transactionType, this.amount});

  Filters copyWith({String? date, String? transactionType, String? amount}) =>
      Filters(
        date: date ?? this.date,
        transactionType: transactionType ?? this.transactionType,
        amount: amount ?? this.amount,
      );

  factory Filters.fromJson(Map<String, dynamic> json) => Filters(
    date: json["date"],
    transactionType: json["transaction_type"],
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "transaction_type": transactionType,
    "amount": amount,
  };
}

class Pagination {
  int? currentPage;
  int? perPage;
  int? total;
  int? lastPage;
  int? from;
  int? to;

  Pagination({
    this.currentPage,
    this.perPage,
    this.total,
    this.lastPage,
    this.from,
    this.to,
  });

  Pagination copyWith({
    int? currentPage,
    int? perPage,
    int? total,
    int? lastPage,
    int? from,
    int? to,
  }) => Pagination(
    currentPage: currentPage ?? this.currentPage,
    perPage: perPage ?? this.perPage,
    total: total ?? this.total,
    lastPage: lastPage ?? this.lastPage,
    from: from ?? this.from,
    to: to ?? this.to,
  );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    perPage: json["per_page"],
    total: json["total"],
    lastPage: json["last_page"],
    from: json["from"],
    to: json["to"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "per_page": perPage,
    "total": total,
    "last_page": lastPage,
    "from": from,
    "to": to,
  };
}

class DataTransaction {
  String? date;
  String? dailyTotal;
  List<TransactionTransaction>? transactions;

  DataTransaction({this.date, this.dailyTotal, this.transactions});

  DataTransaction copyWith({
    String? date,
    String? dailyTotal,
    List<TransactionTransaction>? transactions,
  }) => DataTransaction(
    date: date ?? this.date,
    dailyTotal: dailyTotal ?? this.dailyTotal,
    transactions: transactions ?? this.transactions,
  );

  factory DataTransaction.fromJson(Map<String, dynamic> json) =>
      DataTransaction(
        date: json["date"],
        dailyTotal: json["daily_total"],
        transactions: json["transactions"] == null
            ? []
            : List<TransactionTransaction>.from(
                json["transactions"]!.map(
                  (x) => TransactionTransaction.fromJson(x),
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
    "date": date,
    "daily_total": dailyTotal,
    "transactions": transactions == null
        ? []
        : List<dynamic>.from(transactions!.map((x) => x.toJson())),
  };
}

class TransactionTransaction {
  int? id;
  String? type;
  String? description;
  String? time;
  String? amount;
  String? currency;
  int? isPositive;
  String? createdAt;

  TransactionTransaction({
    this.id,
    this.type,
    this.description,
    this.time,
    this.amount,
    this.currency,
    this.isPositive,
    this.createdAt,
  });

  TransactionTransaction copyWith({
    int? id,
    String? type,
    String? description,
    String? time,
    String? amount,
    String? currency,
    int? isPositive,
    String? createdAt,
  }) => TransactionTransaction(
    id: id ?? this.id,
    type: type ?? this.type,
    description: description ?? this.description,
    time: time ?? this.time,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    isPositive: isPositive ?? this.isPositive,
    createdAt: createdAt ?? this.createdAt,
  );

  factory TransactionTransaction.fromJson(Map<String, dynamic> json) =>
      TransactionTransaction(
        id: json["id"],
        type: json["type"],
        description: json["description"],
        time: json["time"],
        amount: json["amount"],
        currency: json["currency"],
        isPositive: json["is_positive"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "description": description,
    "time": time,
    "amount": amount,
    "currency": currency,
    "is_positive": isPositive,
    "created_at": createdAt,
  };
}
