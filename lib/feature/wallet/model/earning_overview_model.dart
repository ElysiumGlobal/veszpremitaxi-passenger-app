class EarningOverViewModel {
  bool? success;
  Data? data;

  EarningOverViewModel({this.success, this.data});

  EarningOverViewModel copyWith({bool? success, Data? data}) =>
      EarningOverViewModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory EarningOverViewModel.fromJson(Map<String, dynamic> json) =>
      EarningOverViewModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  List<Tab>? tabs;
  WeeklySummary? weeklySummary;
  DailyEarningsChart? dailyEarningsChart;
  DetailedEarningBreakdown? detailedEarningBreakdown;
  RideSummary? rideSummary;
  Support? support;

  Data({
    this.tabs,
    this.weeklySummary,
    this.dailyEarningsChart,
    this.detailedEarningBreakdown,
    this.rideSummary,
    this.support,
  });

  Data copyWith({
    List<Tab>? tabs,
    WeeklySummary? weeklySummary,
    DailyEarningsChart? dailyEarningsChart,
    DetailedEarningBreakdown? detailedEarningBreakdown,
    RideSummary? rideSummary,
    Support? support,
  }) => Data(
    tabs: tabs ?? this.tabs,
    weeklySummary: weeklySummary ?? this.weeklySummary,
    dailyEarningsChart: dailyEarningsChart ?? this.dailyEarningsChart,
    detailedEarningBreakdown:
        detailedEarningBreakdown ?? this.detailedEarningBreakdown,
    rideSummary: rideSummary ?? this.rideSummary,
    support: support ?? this.support,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    tabs: json["tabs"] == null
        ? []
        : List<Tab>.from(json["tabs"]!.map((x) => Tab.fromJson(x))),
    weeklySummary: json["weekly_summary"] == null
        ? null
        : WeeklySummary.fromJson(json["weekly_summary"]),
    dailyEarningsChart: json["daily_earnings_chart"] == null
        ? null
        : DailyEarningsChart.fromJson(json["daily_earnings_chart"]),
    detailedEarningBreakdown: json["detailed_earning_breakdown"] == null
        ? null
        : DetailedEarningBreakdown.fromJson(json["detailed_earning_breakdown"]),
    rideSummary: json["ride_summary"] == null
        ? null
        : RideSummary.fromJson(json["ride_summary"]),
    support: json["support"] == null ? null : Support.fromJson(json["support"]),
  );

  Map<String, dynamic> toJson() => {
    "tabs": tabs == null
        ? []
        : List<dynamic>.from(tabs!.map((x) => x.toJson())),
    "weekly_summary": weeklySummary?.toJson(),
    "daily_earnings_chart": dailyEarningsChart?.toJson(),
    "detailed_earning_breakdown": detailedEarningBreakdown?.toJson(),
    "ride_summary": rideSummary?.toJson(),
    "support": support?.toJson(),
  };
}

class DailyEarningsChart {
  String? yAxisLabel;
  int? yAxisMin;
  int? yAxisMax;
  List<DailyDatum>? dailyData;

  DailyEarningsChart({
    this.yAxisLabel,
    this.yAxisMin,
    this.yAxisMax,
    this.dailyData,
  });

  DailyEarningsChart copyWith({
    String? yAxisLabel,
    int? yAxisMin,
    int? yAxisMax,
    List<DailyDatum>? dailyData,
  }) => DailyEarningsChart(
    yAxisLabel: yAxisLabel ?? this.yAxisLabel,
    yAxisMin: yAxisMin ?? this.yAxisMin,
    yAxisMax: yAxisMax ?? this.yAxisMax,
    dailyData: dailyData ?? this.dailyData,
  );

  factory DailyEarningsChart.fromJson(Map<String, dynamic> json) =>
      DailyEarningsChart(
        yAxisLabel: json["y_axis_label"],
        yAxisMin: json["y_axis_min"],
        yAxisMax: json["y_axis_max"],
        dailyData: json["daily_data"] == null
            ? []
            : List<DailyDatum>.from(
                json["daily_data"]!.map((x) => DailyDatum.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "y_axis_label": yAxisLabel,
    "y_axis_min": yAxisMin,
    "y_axis_max": yAxisMax,
    "daily_data": dailyData == null
        ? []
        : List<dynamic>.from(dailyData!.map((x) => x.toJson())),
  };
}

class DailyDatum {
  String? date;
  String? day;
  double? earning;
  bool? highlighted;

  DailyDatum({this.date, this.day, this.earning, this.highlighted});

  DailyDatum copyWith({
    String? date,
    String? day,
    double? earning,
    bool? highlighted,
  }) => DailyDatum(
    date: date ?? this.date,
    day: day ?? this.day,
    earning: earning ?? this.earning,
    highlighted: highlighted ?? this.highlighted,
  );

  factory DailyDatum.fromJson(Map<String, dynamic> json) => DailyDatum(
    date: json["date"],
    day: json["day"],
    earning: json["earning"]?.toDouble(),
    highlighted: json["highlighted"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "day": day,
    "earning": earning,
    "highlighted": highlighted,
  };
}

class DetailedEarningBreakdown {
  dynamic selectedDayTotalEarning;
  dynamic walletEarning;
  dynamic cashEarning;
  int? incentiveReward;
  num? deduction;
  dynamic totalEarningForDay;

  DetailedEarningBreakdown({
    this.selectedDayTotalEarning,
    this.walletEarning,
    this.cashEarning,
    this.incentiveReward,
    this.deduction,
    this.totalEarningForDay,
  });

  DetailedEarningBreakdown copyWith({
    double? selectedDayTotalEarning,
    double? walletEarning,
    dynamic cashEarning,
    int? incentiveReward,
    double? deduction,
    double? totalEarningForDay,
  }) => DetailedEarningBreakdown(
    selectedDayTotalEarning:
        selectedDayTotalEarning ?? this.selectedDayTotalEarning,
    walletEarning: walletEarning ?? this.walletEarning,
    cashEarning: cashEarning ?? this.cashEarning,
    incentiveReward: incentiveReward ?? this.incentiveReward,
    deduction: deduction ?? this.deduction,
    totalEarningForDay: totalEarningForDay ?? this.totalEarningForDay,
  );

  factory DetailedEarningBreakdown.fromJson(Map<String, dynamic> json) =>
      DetailedEarningBreakdown(
        selectedDayTotalEarning: json["selected_day_total_earning"]?.toDouble(),
        walletEarning: json["wallet_earning"],
        cashEarning: json["cash_earning"],
        incentiveReward: json["incentive_reward"],
        deduction: json["deduction"],
        totalEarningForDay: json["total_earning_for_day"],
      );

  Map<String, dynamic> toJson() => {
    "selected_day_total_earning": selectedDayTotalEarning,
    "wallet_earning": walletEarning,
    "cash_earning": cashEarning,
    "incentive_reward": incentiveReward,
    "deduction": deduction,
    "total_earning_for_day": totalEarningForDay,
  };
}

class RideSummary {
  String? timeOnlineHrs;
  int? totalRides;
  int? completedRides;
  int? completionRatePercent;
  double? averageRating;

  RideSummary({
    this.timeOnlineHrs,
    this.totalRides,
    this.completedRides,
    this.completionRatePercent,
    this.averageRating,
  });

  RideSummary copyWith({
    String? timeOnlineHrs,
    int? totalRides,
    int? completedRides,
    int? completionRatePercent,
    double? averageRating,
  }) => RideSummary(
    timeOnlineHrs: timeOnlineHrs ?? this.timeOnlineHrs,
    totalRides: totalRides ?? this.totalRides,
    completedRides: completedRides ?? this.completedRides,
    completionRatePercent: completionRatePercent ?? this.completionRatePercent,
    averageRating: averageRating ?? this.averageRating,
  );

  factory RideSummary.fromJson(Map<String, dynamic> json) => RideSummary(
    timeOnlineHrs: json["time_online_hrs"],
    totalRides: json["total_rides"],
    completedRides: json["completed_rides"],
    completionRatePercent: json["completion_rate_percent"],
    averageRating: json["average_rating"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "time_online_hrs": timeOnlineHrs,
    "total_rides": totalRides,
    "completed_rides": completedRides,
    "completion_rate_percent": completionRatePercent,
    "average_rating": averageRating,
  };
}

class Support {
  String? text;
  int? iconNumber;

  Support({this.text, this.iconNumber});

  Support copyWith({String? text, int? iconNumber}) => Support(
    text: text ?? this.text,
    iconNumber: iconNumber ?? this.iconNumber,
  );

  factory Support.fromJson(Map<String, dynamic> json) =>
      Support(text: json["text"], iconNumber: json["icon_number"]);

  Map<String, dynamic> toJson() => {"text": text, "icon_number": iconNumber};
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

class WeeklySummary {
  String? dateRange;
  String? totalEarningThisWeek;

  WeeklySummary({this.dateRange, this.totalEarningThisWeek});

  WeeklySummary copyWith({String? dateRange, String? totalEarningThisWeek}) =>
      WeeklySummary(
        dateRange: dateRange ?? this.dateRange,
        totalEarningThisWeek: totalEarningThisWeek ?? this.totalEarningThisWeek,
      );

  factory WeeklySummary.fromJson(Map<String, dynamic> json) => WeeklySummary(
    dateRange: json["date_range"],
    totalEarningThisWeek: json["total_earning_this_week"],
  );

  Map<String, dynamic> toJson() => {
    "date_range": dateRange,
    "total_earning_this_week": totalEarningThisWeek,
  };
}
