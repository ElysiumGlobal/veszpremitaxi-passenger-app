class WalletTransactionDetailsModel {
  bool? success;
  Data? data;

  WalletTransactionDetailsModel({this.success, this.data});

  WalletTransactionDetailsModel copyWith({bool? success, Data? data}) =>
      WalletTransactionDetailsModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory WalletTransactionDetailsModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionDetailsModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  List<Tab>? tabs;
  Transaction? transaction;

  Data({this.tabs, this.transaction});

  Data copyWith({List<Tab>? tabs, Transaction? transaction}) => Data(
    tabs: tabs ?? this.tabs,
    transaction: transaction ?? this.transaction,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    tabs: json["tabs"] == null
        ? []
        : List<Tab>.from(json["tabs"]!.map((x) => Tab.fromJson(x))),
    transaction: json["transaction"] == null
        ? null
        : Transaction.fromJson(json["transaction"]),
  );

  Map<String, dynamic> toJson() => {
    "tabs": tabs == null
        ? []
        : List<dynamic>.from(tabs!.map((x) => x.toJson())),
    "transaction": transaction?.toJson(),
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

class Transaction {
  String? transactionId;
  dynamic amount;
  String? status;
  String? paymentMethod;
  String? tripId;
  String? date;
  String? time;
  List<Timeline>? timeline;
  String? actionButtonText;
  String? downloadLink;
  String? rejectReason;

  Transaction({
    this.transactionId,
    this.amount,
    this.status,
    this.paymentMethod,
    this.tripId,
    this.date,
    this.time,
    this.timeline,
    this.actionButtonText,
    this.downloadLink,
    this.rejectReason,
  });

  Transaction copyWith({
    String? transactionId,
    double? amount,
    String? status,
    String? paymentMethod,
    String? tripId,
    String? date,
    String? time,
    List<Timeline>? timeline,
    String? actionButtonText,
    String? downloadLink,
    String? rejectReason,
  }) => Transaction(
    transactionId: transactionId ?? this.transactionId,
    amount: amount ?? this.amount,
    status: status ?? this.status,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    tripId: tripId ?? this.tripId,
    date: date ?? this.date,
    time: time ?? this.time,
    timeline: timeline ?? this.timeline,
    actionButtonText: actionButtonText ?? this.actionButtonText,
    downloadLink: downloadLink ?? this.downloadLink,
    rejectReason: rejectReason ?? this.rejectReason,
  );

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    transactionId: json["transaction_id"],
    amount: json["amount"],
    status: json["status"],
    paymentMethod: json["payment_method"],
    tripId: json["trip_id"],
    date: json["date"],
    time: json["time"],
    timeline: json["timeline"] == null
        ? []
        : List<Timeline>.from(
            json["timeline"]!.map((x) => Timeline.fromJson(x)),
          ),
    actionButtonText: json["action_button_text"],
    downloadLink: json["download_link"],
    rejectReason: json["rejected_reason"],
  );

  Map<String, dynamic> toJson() => {
    "transaction_id": transactionId,
    "amount": amount,
    "status": status,
    "payment_method": paymentMethod,
    "trip_id": tripId,
    "date": date,
    "time": time,
    "timeline": timeline == null
        ? []
        : List<dynamic>.from(timeline!.map((x) => x.toJson())),
    "action_button_text": actionButtonText,
    "download_link": downloadLink,
    "rejected_reason": rejectReason,
  };
}

class Timeline {
  String? event;
  String? timestamp;
  String? statusText;
  String? icon;
  int? isRefund;

  Timeline({
    this.event,
    this.timestamp,
    this.statusText,
    this.icon,
    this.isRefund,
  });

  Timeline copyWith({
    String? event,
    String? timestamp,
    String? statusText,
    String? icon,
    int? isRefund,
  }) => Timeline(
    event: event ?? this.event,
    timestamp: timestamp ?? this.timestamp,
    icon: icon ?? this.icon,
    statusText: statusText ?? this.statusText,
    isRefund: isRefund ?? this.isRefund,
  );

  factory Timeline.fromJson(Map<String, dynamic> json) => Timeline(
    event: json["event"],
    timestamp: json["timestamp"],
    icon: json["icon"],
    statusText: json["status_text"],
    isRefund: json["is_refund"],
  );

  Map<String, dynamic> toJson() => {
    "event": event,
    "timestamp": timestamp,
    "icon": icon,
    "status_text": statusText,
    "is_refund": isRefund,
  };
}
