

import 'dart:convert';

IncentiveModel incentiveModelFromJson(String str) =>
    IncentiveModel.fromJson(json.decode(str));

String incentiveModelToJson(IncentiveModel data) => json.encode(data.toJson());

class IncentiveModel {
  bool? success;
  Data? data;
  String? message;

  IncentiveModel({this.success, this.data, this.message});

  IncentiveModel copyWith({bool? success, Data? data, String? message}) =>
      IncentiveModel(
        success: success ?? this.success,
        data: data ?? this.data,
        message: message ?? this.message,
      );

  factory IncentiveModel.fromJson(Map<String, dynamic> json) => IncentiveModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
    "message": message,
  };
}

class Data {
  String? filter;
  DateTime? currentDate;
  List<DateSelector>? dateSelector;
  String? totalIncentiveEarning;
  List<Incentive>? incentives;
  Summary? summary;

  Data({
    this.filter,
    this.currentDate,
    this.dateSelector,
    this.totalIncentiveEarning,
    this.incentives,
    this.summary,
  });

  Data copyWith({
    String? filter,
    DateTime? currentDate,
    List<DateSelector>? dateSelector,
    String? totalIncentiveEarning,
    List<Incentive>? incentives,
    Summary? summary,
  }) => Data(
    filter: filter ?? this.filter,
    currentDate: currentDate ?? this.currentDate,
    dateSelector: dateSelector ?? this.dateSelector,
    totalIncentiveEarning: totalIncentiveEarning ?? this.totalIncentiveEarning,
    incentives: incentives ?? this.incentives,
    summary: summary ?? this.summary,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    filter: json["filter"],
    currentDate: json["current_date"] == null
        ? null
        : DateTime.parse(json["current_date"]),
    dateSelector: json["date_selector"] == null
        ? []
        : List<DateSelector>.from(
            json["date_selector"]!.map((x) => DateSelector.fromJson(x)),
          ),
    totalIncentiveEarning: json["total_incentive_earning"],
    incentives: json["incentives"] == null
        ? []
        : List<Incentive>.from(
            json["incentives"]!.map((x) => Incentive.fromJson(x)),
          ),
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
  );

  Map<String, dynamic> toJson() => {
    "filter": filter,
    "current_date":
        "${currentDate!.year.toString().padLeft(4, '0')}-${currentDate!.month.toString().padLeft(2, '0')}-${currentDate!.day.toString().padLeft(2, '0')}",
    "date_selector": dateSelector == null
        ? []
        : List<dynamic>.from(dateSelector!.map((x) => x.toJson())),
    "total_incentive_earning": totalIncentiveEarning,
    "incentives": incentives == null
        ? []
        : List<dynamic>.from(incentives!.map((x) => x.toJson())),
    "summary": summary?.toJson(),
  };
}

class DateSelector {
  DateTime? date;
  String? formatted;
  bool? isSelected;
  bool? isToday;

  DateSelector({this.date, this.formatted, this.isSelected, this.isToday});

  DateSelector copyWith({
    DateTime? date,
    String? formatted,
    bool? isSelected,
    bool? isToday,
  }) => DateSelector(
    date: date ?? this.date,
    formatted: formatted ?? this.formatted,
    isSelected: isSelected ?? this.isSelected,
    isToday: isToday ?? this.isToday,
  );

  factory DateSelector.fromJson(Map<String, dynamic> json) => DateSelector(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    formatted: json["formatted"],
    isSelected: json["is_selected"],
    isToday: json["is_today"],
  );

  Map<String, dynamic> toJson() => {
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "formatted": formatted,
    "is_selected": isSelected,
    "is_today": isToday,
  };
}

class Incentive {
  int? id;
  String? status;
  String? title;
  String? description;
  String? timeInfo;
  String? timeLabel;
  String? earnedAmount;
  String? rewardAmount;
  Progress? progress;
  List<Milestone>? milestones;
  bool? isLive;
  bool? isCompleted;
  bool? isUpcoming;

  Incentive({
    this.id,
    this.status,
    this.title,
    this.description,
    this.timeInfo,
    this.timeLabel,
    this.earnedAmount,
    this.rewardAmount,
    this.progress,
    this.milestones,
    this.isLive,
    this.isCompleted,
    this.isUpcoming,
  });

  Incentive copyWith({
    int? id,
    String? status,
    String? title,
    String? description,
    String? timeInfo,
    String? timeLabel,
    String? earnedAmount,
    String? rewardAmount,
    Progress? progress,
    List<Milestone>? milestones,
    bool? isLive,
    bool? isCompleted,
    bool? isUpcoming,
  }) => Incentive(
    id: id ?? this.id,
    status: status ?? this.status,
    title: title ?? this.title,
    description: description ?? this.description,
    timeInfo: timeInfo ?? this.timeInfo,
    timeLabel: timeLabel ?? this.timeLabel,
    earnedAmount: earnedAmount ?? this.earnedAmount,
    rewardAmount: rewardAmount ?? this.rewardAmount,
    progress: progress ?? this.progress,
    milestones: milestones ?? this.milestones,
    isLive: isLive ?? this.isLive,
    isCompleted: isCompleted ?? this.isCompleted,
    isUpcoming: isUpcoming ?? this.isUpcoming,
  );

  factory Incentive.fromJson(Map<String, dynamic> json) => Incentive(
    id: json["id"],
    status: json["status"],
    title: json["title"],
    description: json["description"],
    timeInfo: json["time_info"],
    timeLabel: json["time_label"],
    earnedAmount: json["earned_amount"],
    rewardAmount: json["reward_amount"],
    progress: json["progress"] == null
        ? null
        : Progress.fromJson(json["progress"]),
    milestones: json["milestones"] == null
        ? []
        : List<Milestone>.from(
            json["milestones"]!.map((x) => Milestone.fromJson(x)),
          ),
    isLive: json["is_live"],
    isCompleted: json["is_completed"],
    isUpcoming: json["is_upcoming"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "title": title,
    "description": description,
    "time_info": timeInfo,
    "time_label": timeLabel,
    "earned_amount": earnedAmount,
    "reward_amount": rewardAmount,
    "progress": progress?.toJson(),
    "milestones": milestones == null
        ? []
        : List<dynamic>.from(milestones!.map((x) => x.toJson())),
    "is_live": isLive,
    "is_completed": isCompleted,
    "is_upcoming": isUpcoming,
  };
}

class Milestone {
  String? id;
  String? target;
  String? title;
  String? status;
  String? statusText;
  String? reward;
  String? rewardDisplay;
  bool? achieved;
  dynamic rewardEarned;
  String? achievedAt;

  Milestone({
    this.id,
    this.target,
    this.title,
    this.status,
    this.statusText,
    this.reward,
    this.rewardDisplay,
    this.achieved,
    this.rewardEarned,
    this.achievedAt,
  });

  Milestone copyWith({
    String? id,
    String? target,
    String? title,
    String? status,
    String? statusText,
    String? reward,
    String? rewardDisplay,
    bool? achieved,
    dynamic rewardEarned,
    String? achievedAt,
  }) => Milestone(
    id: id ?? this.id,
    target: target ?? this.target,
    title: title ?? this.title,
    status: status ?? this.status,
    statusText: statusText ?? this.statusText,
    reward: reward ?? this.reward,
    rewardDisplay: rewardDisplay ?? this.rewardDisplay,
    achieved: achieved ?? this.achieved,
    rewardEarned: rewardEarned ?? this.rewardEarned,
    achievedAt: achievedAt ?? this.achievedAt,
  );

  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
    id: json["id"],
    target: json["target"],
    title: json["title"],
    status: json["status"],
    statusText: json["status_text"],
    reward: json["reward"],
    rewardDisplay: json["reward_display"],
    achieved: json["achieved"],
    rewardEarned: json["reward_earned"],
    achievedAt: json["achieved_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "target": target,
    "title": title,
    "status": status,
    "status_text": statusText,
    "reward": reward,
    "reward_display": rewardDisplay,
    "achieved": achieved,
    "reward_earned": rewardEarned,
    "achieved_at": achievedAt,
  };
}

class Progress {
  int? current;
  String? target;
  num? percentage;
  String? display;

  Progress({this.current, this.target, this.percentage, this.display});

  Progress copyWith({
    int? current,
    String? target,
    int? percentage,
    String? display,
  }) => Progress(
    current: current ?? this.current,
    target: target ?? this.target,
    percentage: percentage ?? this.percentage,
    display: display ?? this.display,
  );

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
    current: json["current"],
    target: json["target"] == null ? null : "${json['target']}",
    percentage: json["percentage"],
    display: json["display"],
  );

  Map<String, dynamic> toJson() => {
    "current": current,
    "target": target,
    "percentage": percentage,
    "display": display,
  };
}

class Summary {
  String? totalEarned;
  String? periodEarned;
  int? totalLive;
  int? totalCompleted;
  int? totalUpcoming;

  Summary({
    this.totalEarned,
    this.periodEarned,
    this.totalLive,
    this.totalCompleted,
    this.totalUpcoming,
  });

  Summary copyWith({
    String? totalEarned,
    String? periodEarned,
    int? totalLive,
    int? totalCompleted,
    int? totalUpcoming,
  }) => Summary(
    totalEarned: totalEarned ?? this.totalEarned,
    periodEarned: periodEarned ?? this.periodEarned,
    totalLive: totalLive ?? this.totalLive,
    totalCompleted: totalCompleted ?? this.totalCompleted,
    totalUpcoming: totalUpcoming ?? this.totalUpcoming,
  );

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    totalEarned: json["total_earned"] == null
        ? null
        : "${json["total_earned"]}",
    periodEarned: json["period_earned"] == null
        ? null
        : '${json["period_earned"]}',
    totalLive: json["total_live"],
    totalCompleted: json["total_completed"],
    totalUpcoming: json["total_upcoming"],
  );

  Map<String, dynamic> toJson() => {
    "total_earned": totalEarned,
    "period_earned": periodEarned,
    "total_live": totalLive,
    "total_completed": totalCompleted,
    "total_upcoming": totalUpcoming,
  };
}
