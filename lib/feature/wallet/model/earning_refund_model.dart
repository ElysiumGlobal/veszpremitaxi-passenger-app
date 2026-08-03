class EarningRefundModel {
  bool? success;
  Data? data;

  EarningRefundModel({this.success, this.data});

  EarningRefundModel copyWith({bool? success, Data? data}) =>
      EarningRefundModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory EarningRefundModel.fromJson(Map<String, dynamic> json) =>
      EarningRefundModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  int? amount;
  String? description;
  String? status;
  int? creditedToWallet;
  String? reviewedBy;
  String? creditedOn;
  String? referenceId;
  String? infoMessage;
  String? actionButtonText;

  Data({
    this.amount,
    this.description,
    this.status,
    this.creditedToWallet,
    this.reviewedBy,
    this.creditedOn,
    this.referenceId,
    this.infoMessage,
    this.actionButtonText,
  });

  Data copyWith({
    int? amount,
    String? description,
    String? status,
    int? creditedToWallet,
    String? reviewedBy,
    String? creditedOn,
    String? referenceId,
    String? infoMessage,
    String? actionButtonText,
  }) => Data(
    amount: amount ?? this.amount,
    description: description ?? this.description,
    status: status ?? this.status,
    creditedToWallet: creditedToWallet ?? this.creditedToWallet,
    reviewedBy: reviewedBy ?? this.reviewedBy,
    creditedOn: creditedOn ?? this.creditedOn,
    referenceId: referenceId ?? this.referenceId,
    infoMessage: infoMessage ?? this.infoMessage,
    actionButtonText: actionButtonText ?? this.actionButtonText,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    amount: json["amount"],
    description: json["description"],
    status: json["status"],
    creditedToWallet: json["credited_to_wallet"],
    reviewedBy: json["reviewed_by"],
    creditedOn: json["credited_on"],
    referenceId: json["reference_id"],
    infoMessage: json["info_message"],
    actionButtonText: json["action_button_text"],
  );

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "description": description,
    "status": status,
    "credited_to_wallet": creditedToWallet,
    "reviewed_by": reviewedBy,
    "credited_on": creditedOn,
    "reference_id": referenceId,
    "info_message": infoMessage,
    "action_button_text": actionButtonText,
  };
}
