
import 'dart:convert';

EarningDetailsModel earningDetailsModelFromJson(String str) =>
    EarningDetailsModel.fromJson(json.decode(str));

String earningDetailsModelToJson(EarningDetailsModel data) =>
    json.encode(data.toJson());

class EarningDetailsModel {
  bool? success;
  Data? data;

  EarningDetailsModel({this.success, this.data});

  EarningDetailsModel copyWith({bool? success, Data? data}) =>
      EarningDetailsModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory EarningDetailsModel.fromJson(Map<String, dynamic> json) =>
      EarningDetailsModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  String? bookingCode;
  int? bookingId;
  String? distance;
  String? duration;
  double? totalEarning;
  String? paymentType;
  EarningBreakdown? earningBreakdown;
  DeductionBreakdown? deductionBreakdown;
  double? finalEarning;
  String? actionButtonText;
  String? downloadLink;

  Data({
    this.bookingCode,
    this.bookingId,
    this.distance,
    this.duration,
    this.totalEarning,
    this.paymentType,
    this.earningBreakdown,
    this.deductionBreakdown,
    this.finalEarning,
    this.actionButtonText,
    this.downloadLink,
  });

  Data copyWith({
    String? bookingCode,
    int? bookingId,
    String? distance,
    String? duration,
    double? totalEarning,
    String? paymentType,
    EarningBreakdown? earningBreakdown,
    DeductionBreakdown? deductionBreakdown,
    double? finalEarning,
    String? actionButtonText,
    String? downloadLink,
  }) => Data(
    bookingCode: bookingCode ?? this.bookingCode,
    bookingId: bookingId ?? this.bookingId,
    distance: distance ?? this.distance,
    duration: duration ?? this.duration,
    totalEarning: totalEarning ?? this.totalEarning,
    paymentType: paymentType ?? this.paymentType,
    earningBreakdown: earningBreakdown ?? this.earningBreakdown,
    deductionBreakdown: deductionBreakdown ?? this.deductionBreakdown,
    finalEarning: finalEarning ?? this.finalEarning,
    actionButtonText: actionButtonText ?? this.actionButtonText,
    downloadLink: downloadLink ?? this.downloadLink,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    bookingCode: json["booking_code"],
    bookingId: json["booking_id"],
    distance: json["distance"],
    duration: json["duration"],
    totalEarning: json["total_earning"]?.toDouble(),
    paymentType: json["payment_type"],
    earningBreakdown: json["earning_breakdown"] == null
        ? null
        : EarningBreakdown.fromJson(json["earning_breakdown"]),
    deductionBreakdown: json["deduction_breakdown"] == null
        ? null
        : DeductionBreakdown.fromJson(json["deduction_breakdown"]),
    finalEarning: json["final_earning"]?.toDouble(),
    actionButtonText: json["action_button_text"],
    downloadLink: json["download_link"],
  );

  Map<String, dynamic> toJson() => {
    "booking_code": bookingCode,
    "booking_id": bookingId,
    "distance": distance,
    "duration": duration,
    "total_earning": totalEarning,
    "payment_type": paymentType,
    "earning_breakdown": earningBreakdown?.toJson(),
    "deduction_breakdown": deductionBreakdown?.toJson(),
    "final_earning": finalEarning,
    "action_button_text": actionButtonText,
    "download_link": downloadLink,
  };
}

class DeductionBreakdown {
  double? platformFee;
  double? tax;
  int? lateArrivalPenalty;
  double? totalDeduction;
  dynamic discount;

  DeductionBreakdown({
    this.platformFee,
    this.tax,
    this.lateArrivalPenalty,
    this.totalDeduction,
    this.discount,
  });

  DeductionBreakdown copyWith({
    double? platformFee,
    double? tax,
    int? lateArrivalPenalty,
    double? totalDeduction,
    dynamic discount,
  }) => DeductionBreakdown(
    platformFee: platformFee ?? this.platformFee,
    tax: tax ?? this.tax,
    lateArrivalPenalty: lateArrivalPenalty ?? this.lateArrivalPenalty,
    totalDeduction: totalDeduction ?? this.totalDeduction,
    discount: discount ?? this.discount,
  );

  factory DeductionBreakdown.fromJson(Map<String, dynamic> json) =>
      DeductionBreakdown(
        platformFee: json["platform_fee"]?.toDouble(),
        tax: json["tax"]?.toDouble(),
        lateArrivalPenalty: json["late_arrival_penalty"],
        totalDeduction: json["total_deduction"]?.toDouble(),
        discount: json["promocode_applied"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "platform_fee": platformFee,
    "tax": tax,
    "late_arrival_penalty": lateArrivalPenalty,
    "total_deduction": totalDeduction,
    "promocode_applied": discount,
  };
}

class EarningBreakdown {
  dynamic baseFare;
  dynamic distanceFare;
  dynamic waitingCharge;
  dynamic tipReceived;
  dynamic totalFare;
  dynamic timeFare;
  dynamic nightCharge;
  dynamic bookingFee;
  dynamic surgeAmount;
  dynamic taxAmount;

  EarningBreakdown({
    this.baseFare,
    this.distanceFare,
    this.waitingCharge,
    this.tipReceived,
    this.totalFare,
    this.timeFare,
    this.nightCharge,
    this.bookingFee,
    this.surgeAmount,
    this.taxAmount,
  });

  EarningBreakdown copyWith({
    dynamic baseFare,
    dynamic distanceFare,
    dynamic waitingCharge,
    dynamic tipReceived,
    int? totalFare,
    dynamic taxAmount,
  }) => EarningBreakdown(
    baseFare: baseFare ?? this.baseFare,
    distanceFare: distanceFare ?? this.distanceFare,
    waitingCharge: waitingCharge ?? this.waitingCharge,
    tipReceived: tipReceived ?? this.tipReceived,
    totalFare: totalFare ?? this.totalFare,
    taxAmount: taxAmount ?? this.taxAmount,
  );

  factory EarningBreakdown.fromJson(Map<String, dynamic> json) =>
      EarningBreakdown(
        baseFare: json["base_fare"],
        distanceFare: json["distance_fare"],
        waitingCharge: json["waiting_charge"],
        tipReceived: json["tip_received"],
        totalFare: json["total_fare"],
        timeFare: json["time_fare"],
        nightCharge: json["night_charge"],
        bookingFee: json["booking_fee"],
        surgeAmount: json["surge_amount"],
        taxAmount: json["tax_amount"],
      );

  Map<String, dynamic> toJson() => {
    "base_fare": baseFare,
    "distance_fare": distanceFare,
    "waiting_charge": waitingCharge,
    "tip_received": tipReceived,
    "total_fare": totalFare,
    "tax_amount": taxAmount,
  };
}
