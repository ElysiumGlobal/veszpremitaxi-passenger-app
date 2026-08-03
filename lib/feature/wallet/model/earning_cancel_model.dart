

import 'dart:convert';

EarningcancelModel earningcancelModelFromJson(String str) =>
    EarningcancelModel.fromJson(json.decode(str));

String earningcancelModelToJson(EarningcancelModel data) =>
    json.encode(data.toJson());

class EarningcancelModel {
  bool? success;
  Data? data;

  EarningcancelModel({this.success, this.data});

  EarningcancelModel copyWith({bool? success, Data? data}) =>
      EarningcancelModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory EarningcancelModel.fromJson(Map<String, dynamic> json) =>
      EarningcancelModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  String? transactionId;
  int? walletTransactionId;
  int? amount;
  String? type;
  String? transactionType;
  String? bookingCode;
  int? bookingId;
  String? tripCode;
  String? date;
  String? reason;
  String? description;
  bool? latePenaltyRefundApproved;
  String? actionButtonText;

  Data({
    this.transactionId,
    this.walletTransactionId,
    this.amount,
    this.type,
    this.transactionType,
    this.bookingCode,
    this.bookingId,
    this.tripCode,
    this.date,
    this.reason,
    this.description,
    this.latePenaltyRefundApproved,
    this.actionButtonText,
  });

  Data copyWith({
    String? transactionId,
    int? walletTransactionId,
    int? amount,
    String? type,
    String? transactionType,
    String? bookingCode,
    int? bookingId,
    String? tripCode,
    String? date,
    String? reason,
    String? description,
    bool? latePenaltyRefundApproved,
    String? actionButtonText,
  }) => Data(
    transactionId: transactionId ?? this.transactionId,
    walletTransactionId: walletTransactionId ?? this.walletTransactionId,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    transactionType: transactionType ?? this.transactionType,
    bookingCode: bookingCode ?? this.bookingCode,
    bookingId: bookingId ?? this.bookingId,
    tripCode: tripCode ?? this.tripCode,
    date: date ?? this.date,
    reason: reason ?? this.reason,
    description: description ?? this.description,
    latePenaltyRefundApproved:
        latePenaltyRefundApproved ?? this.latePenaltyRefundApproved,
    actionButtonText: actionButtonText ?? this.actionButtonText,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    transactionId: json["transaction_id"],
    walletTransactionId: json["wallet_transaction_id"],
    amount: json["amount"],
    type: json["type"],
    transactionType: json["transaction_type"],
    bookingCode: json["booking_code"],
    bookingId: json["booking_id"],
    tripCode: json["trip_code"],
    date: json["date"],
    reason: json["reason"],
    description: json["description"],
    latePenaltyRefundApproved: json["late_penalty_refund_approved"],
    actionButtonText: json["action_button_text"],
  );

  Map<String, dynamic> toJson() => {
    "transaction_id": transactionId,
    "wallet_transaction_id": walletTransactionId,
    "amount": amount,
    "type": type,
    "transaction_type": transactionType,
    "booking_code": bookingCode,
    "booking_id": bookingId,
    "trip_code": tripCode,
    "date": date,
    "reason": reason,
    "description": description,
    "late_penalty_refund_approved": latePenaltyRefundApproved,
    "action_button_text": actionButtonText,
  };
}
