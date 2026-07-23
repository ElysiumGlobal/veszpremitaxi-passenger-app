class WalletDataModel {
  bool? success;
  Data? data;

  WalletDataModel({this.success, this.data});

  WalletDataModel copyWith({bool? success, Data? data}) => WalletDataModel(
    success: success ?? this.success,
    data: data ?? this.data,
  );

  factory WalletDataModel.fromJson(Map<String, dynamic> json) =>
      WalletDataModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  WalletInfo? walletInfo;
  Transactions? transactions;
  Stats? stats;

  Data({this.walletInfo, this.transactions, this.stats});

  Data copyWith({
    WalletInfo? walletInfo,
    Transactions? transactions,
    Stats? stats,
  }) => Data(
    walletInfo: walletInfo ?? this.walletInfo,
    transactions: transactions ?? this.transactions,
    stats: stats ?? this.stats,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    walletInfo: json["wallet_info"] == null
        ? null
        : WalletInfo.fromJson(json["wallet_info"]),
    transactions: json["transactions"] == null
        ? null
        : Transactions.fromJson(json["transactions"]),
    stats: json["stats"] == null ? null : Stats.fromJson(json["stats"]),
  );

  Map<String, dynamic> toJson() => {
    "wallet_info": walletInfo?.toJson(),
    "transactions": transactions?.toJson(),
    "stats": stats?.toJson(),
  };
}

class Stats {
  int? totalTransactions;
  int? creditCount;
  int? debitCount;
  dynamic totalCreditAmount;
  dynamic totalDebitAmount;

  Stats({
    this.totalTransactions,
    this.creditCount,
    this.debitCount,
    this.totalCreditAmount,
    this.totalDebitAmount,
  });

  Stats copyWith({
    int? totalTransactions,
    int? creditCount,
    int? debitCount,
    dynamic totalCreditAmount,
    dynamic totalDebitAmount,
  }) => Stats(
    totalTransactions: totalTransactions ?? this.totalTransactions,
    creditCount: creditCount ?? this.creditCount,
    debitCount: debitCount ?? this.debitCount,
    totalCreditAmount: totalCreditAmount ?? this.totalCreditAmount,
    totalDebitAmount: totalDebitAmount ?? this.totalDebitAmount,
  );

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    totalTransactions: json["total_transactions"],
    creditCount: json["credit_count"],
    debitCount: json["debit_count"],
    totalCreditAmount: json["total_credit_amount"],
    totalDebitAmount: json["total_debit_amount"],
  );

  Map<String, dynamic> toJson() => {
    "total_transactions": totalTransactions,
    "credit_count": creditCount,
    "debit_count": debitCount,
    "total_credit_amount": totalCreditAmount,
    "total_debit_amount": totalDebitAmount,
  };
}

class Transactions {
  List<Datum>? data;
  int? currentPage;
  int? perPage;
  int? total;
  int? lastPage;
  int? from;
  int? to;

  Transactions({
    this.data,
    this.currentPage,
    this.perPage,
    this.total,
    this.lastPage,
    this.from,
    this.to,
  });

  Transactions copyWith({
    List<Datum>? data,
    int? currentPage,
    int? perPage,
    int? total,
    int? lastPage,
    int? from,
    int? to,
  }) => Transactions(
    data: data ?? this.data,
    currentPage: currentPage ?? this.currentPage,
    perPage: perPage ?? this.perPage,
    total: total ?? this.total,
    lastPage: lastPage ?? this.lastPage,
    from: from ?? this.from,
    to: to ?? this.to,
  );

  factory Transactions.fromJson(Map<String, dynamic> json) => Transactions(
    data: json["data"] == null
        ? []
        : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    currentPage: json["current_page"],
    perPage: json["per_page"],
    total: json["total"],
    lastPage: json["last_page"],
    from: json["from"],
    to: json["to"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "current_page": currentPage,
    "per_page": perPage,
    "total": total,
    "last_page": lastPage,
    "from": from,
    "to": to,
  };
}

class Datum {
  String? month;
  String? totalAmount;
  List<Transaction>? transactions;

  Datum({this.month, this.totalAmount, this.transactions});

  Datum copyWith({
    String? month,
    String? totalAmount,
    List<Transaction>? transactions,
  }) => Datum(
    month: month ?? this.month,
    totalAmount: totalAmount ?? this.totalAmount,
    transactions: transactions ?? this.transactions,
  );

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    month: json["month"],
    totalAmount: json["total_amount"],
    transactions: json["transactions"] == null
        ? []
        : List<Transaction>.from(
            json["transactions"]!.map((x) => Transaction.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "month": month,
    "total_amount": totalAmount,
    "transactions": transactions == null
        ? []
        : List<dynamic>.from(transactions!.map((x) => x.toJson())),
  };
}

class Transaction {
  int? id;
  String? type;
  String? amount;
  String? balance;
  String? description;
  String? status;
  String? referenceType;
  String? referenceId;
  String? createdAt;
  String? updatedAt;
  dynamic metaData;
  String? month;
  String? date;
  String? time;
  int? isRefunded;
  int? referralBonus;

  Transaction({
    this.id,
    this.type,
    this.amount,
    this.balance,
    this.description,
    this.status,
    this.referenceType,
    this.referenceId,
    this.createdAt,
    this.updatedAt,
    this.metaData,
    this.month,
    this.date,
    this.time,
    this.isRefunded,
    this.referralBonus,
  });

  Transaction copyWith({
    int? id,
    int? referralBonus,
    int? isRefunded,
    String? type,
    String? amount,
    String? balance,
    String? description,
    String? status,
    String? referenceType,
    String? referenceId,
    String? createdAt,
    String? updatedAt,
    dynamic metaData,
    String? month,
    String? date,
    String? time,
  }) => Transaction(
    id: id ?? this.id,
    referralBonus: referralBonus ?? this.referralBonus,
    isRefunded: isRefunded ?? this.isRefunded,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    balance: balance ?? this.balance,
    description: description ?? this.description,
    status: status ?? this.status,
    referenceType: referenceType ?? this.referenceType,
    referenceId: referenceId ?? this.referenceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    metaData: metaData ?? this.metaData,
    month: month ?? this.month,
    date: date ?? this.date,
    time: time ?? this.time,
  );

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json["id"],
    type: json["type"],
    amount: json["amount"],
    balance: json["balance"],
    description: json["description"],
    status: json["status"],
    referenceType: json["reference_type"],
    referenceId: json["reference_id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    metaData: json["meta_data"],
    month: json["month"],
    date: json["date"],
    time: json["time"],
    isRefunded: json["is_refunded"],
    referralBonus: json["referral_bonus"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "amount": amount,
    "balance": balance,
    "description": description,
    "status": status,
    "reference_type": referenceType,
    "reference_id": referenceId,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "meta_data": metaData,
    "month": month,
    "date": date,
    "time": time,
    "is_refunded": isRefunded,
    "referral_bonus": referralBonus,
  };
}

class WalletInfo {
  String? month;
  String? balance;
  int? holdAmount;
  dynamic availableBalance;
  bool? isActive;
  String? lastTransactionAt;
  String? totalCredit;
  String? totalDebit;

  WalletInfo({
    this.month,
    this.balance,
    this.holdAmount,
    this.availableBalance,
    this.isActive,
    this.lastTransactionAt,
    this.totalCredit,
    this.totalDebit,
  });

  WalletInfo copyWith({
    String? month,
    String? balance,
    int? holdAmount,
    dynamic availableBalance,
    bool? isActive,
    String? lastTransactionAt,
    String? totalCredit,
    String? totalDebit,
  }) => WalletInfo(
    month: month ?? this.month,
    balance: balance ?? this.balance,
    holdAmount: holdAmount ?? this.holdAmount,
    availableBalance: availableBalance ?? this.availableBalance,
    isActive: isActive ?? this.isActive,
    lastTransactionAt: lastTransactionAt ?? this.lastTransactionAt,
    totalCredit: totalCredit ?? this.totalCredit,
    totalDebit: totalDebit ?? this.totalDebit,
  );

  factory WalletInfo.fromJson(Map<String, dynamic> json) => WalletInfo(
    month: json["month"],
    balance: json["balance"],
    holdAmount: json["hold_amount"],
    availableBalance: json["available_balance"],
    isActive: json["is_active"],
    lastTransactionAt: json["last_transaction_at"],
    totalCredit: json["total_credit"],
    totalDebit: json["total_debit"],
  );

  Map<String, dynamic> toJson() => {
    "month": month,
    "balance": balance,
    "hold_amount": holdAmount,
    "available_balance": availableBalance,
    "is_active": isActive,
    "last_transaction_at": lastTransactionAt,
    "total_credit": totalCredit,
    "total_debit": totalDebit,
  };
}
