class PerformerDataModel {
  bool? success;
  String? message;
  Data? data;

  PerformerDataModel({this.success, this.message, this.data});

  PerformerDataModel copyWith({bool? success, String? message, Data? data}) =>
      PerformerDataModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory PerformerDataModel.fromJson(Map<String, dynamic> json) =>
      PerformerDataModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  AllTimePerformance? allTimePerformance;
  Last20Orders? last20Orders;
  List<RiderReview>? riderReviews;

  Data({this.allTimePerformance, this.last20Orders, this.riderReviews});

  Data copyWith({
    AllTimePerformance? allTimePerformance,
    Last20Orders? last20Orders,
    List<RiderReview>? riderReviews,
  }) => Data(
    allTimePerformance: allTimePerformance ?? this.allTimePerformance,
    last20Orders: last20Orders ?? this.last20Orders,
    riderReviews: riderReviews ?? this.riderReviews,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    allTimePerformance: json["all_time_performance"] == null
        ? null
        : AllTimePerformance.fromJson(json["all_time_performance"]),
    last20Orders: json["last_20_orders"] == null
        ? null
        : Last20Orders.fromJson(json["last_20_orders"]),
    riderReviews: json["rider_reviews"] == null
        ? []
        : List<RiderReview>.from(
            json["rider_reviews"]!.map((x) => RiderReview.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "all_time_performance": allTimePerformance?.toJson(),
    "last_20_orders": last20Orders?.toJson(),
    "rider_reviews": riderReviews == null
        ? []
        : List<dynamic>.from(riderReviews!.map((x) => x.toJson())),
  };
}

class AllTimePerformance {
  String? timeOnlineHrs;
  String? totalRides;
  String? completedRides;
  String? completionRate;
  String? avgRating;

  AllTimePerformance({
    this.timeOnlineHrs,
    this.totalRides,
    this.completedRides,
    this.completionRate,
    this.avgRating,
  });

  AllTimePerformance copyWith({
    String? timeOnlineHrs,
    String? totalRides,
    String? completedRides,
    String? completionRate,
    String? avgRating,
  }) => AllTimePerformance(
    timeOnlineHrs: timeOnlineHrs ?? this.timeOnlineHrs,
    totalRides: totalRides ?? this.totalRides,
    completedRides: completedRides ?? this.completedRides,
    completionRate: completionRate ?? this.completionRate,
    avgRating: avgRating ?? this.avgRating,
  );

  factory AllTimePerformance.fromJson(Map<String, dynamic> json) =>
      AllTimePerformance(
        timeOnlineHrs: json["time_online_hrs"],
        totalRides: json["total_rides"],
        completedRides: json["completed_rides"],
        completionRate: json["completion_rate"],
        avgRating: json["avg_rating"],
      );

  Map<String, dynamic> toJson() => {
    "time_online_hrs": timeOnlineHrs,
    "total_rides": totalRides,
    "completed_rides": completedRides,
    "completion_rate": completionRate,
    "avg_rating": avgRating,
  };
}

class Last20Orders {
  String? completed;
  String? completionRate;
  String? avgRating;
  PerformanceIndicator? performanceIndicator;

  Last20Orders({
    this.completed,
    this.completionRate,
    this.avgRating,
    this.performanceIndicator,
  });

  Last20Orders copyWith({
    String? completed,
    String? completionRate,
    String? avgRating,
    PerformanceIndicator? performanceIndicator,
  }) => Last20Orders(
    completed: completed ?? this.completed,
    completionRate: completionRate ?? this.completionRate,
    avgRating: avgRating ?? this.avgRating,
    performanceIndicator: performanceIndicator ?? this.performanceIndicator,
  );

  factory Last20Orders.fromJson(Map<String, dynamic> json) => Last20Orders(
    completed: json["completed"],
    completionRate: json["completion_rate"],
    avgRating: json["avg_rating"],
    performanceIndicator: json["performance_indicator"] == null
        ? null
        : PerformanceIndicator.fromJson(json["performance_indicator"]),
  );

  Map<String, dynamic> toJson() => {
    "completed": completed,
    "completion_rate": completionRate,
    "avg_rating": avgRating,
    "performance_indicator": performanceIndicator?.toJson(),
  };
}

class PerformanceIndicator {
  String? category;
  String? label;
  String? range;
  String? color;

  PerformanceIndicator({this.category, this.label, this.range, this.color});

  PerformanceIndicator copyWith({
    String? category,
    String? label,
    String? range,
    String? color,
  }) => PerformanceIndicator(
    category: category ?? this.category,
    label: label ?? this.label,
    range: range ?? this.range,
    color: color ?? this.color,
  );

  factory PerformanceIndicator.fromJson(Map<String, dynamic> json) =>
      PerformanceIndicator(
        category: json["category"],
        label: json["label"],
        range: json["range"],
        color: json["color"],
      );

  Map<String, dynamic> toJson() => {
    "category": category,
    "label": label,
    "range": range,
    "color": color,
  };
}

class RiderReview {
  Rider? rider;
  String? rating;
  String? reviewText;
  List<dynamic>? tags;
  String? reviewedAt;
  String? reviewedAtIso;

  RiderReview({
    this.rider,
    this.rating,
    this.reviewText,
    this.tags,
    this.reviewedAt,
    this.reviewedAtIso,
  });

  RiderReview copyWith({
    Rider? rider,
    String? rating,
    String? reviewText,
    List<dynamic>? tags,
    String? reviewedAt,
    String? reviewedAtIso,
  }) => RiderReview(
    rider: rider ?? this.rider,
    rating: rating ?? this.rating,
    reviewText: reviewText ?? this.reviewText,
    tags: tags ?? this.tags,
    reviewedAt: reviewedAt ?? this.reviewedAt,
    reviewedAtIso: reviewedAtIso ?? this.reviewedAtIso,
  );

  factory RiderReview.fromJson(Map<String, dynamic> json) => RiderReview(
    rider: json["rider"] == null ? null : Rider.fromJson(json["rider"]),
    rating: json["rating"],
    reviewText: json["review_text"],
    tags: json["tags"] == null
        ? []
        : List<dynamic>.from(json["tags"]!.map((x) => x)),
    reviewedAt: json["reviewed_at"],
    reviewedAtIso: json["reviewed_at_iso"],
  );

  Map<String, dynamic> toJson() => {
    "rider": rider?.toJson(),
    "rating": rating,
    "review_text": reviewText,
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "reviewed_at": reviewedAt,
    "reviewed_at_iso": reviewedAtIso,
  };
}

class Rider {
  String? id;
  String? name;
  String? profilePhoto;

  Rider({this.id, this.name, this.profilePhoto});

  Rider copyWith({String? id, String? name, String? profilePhoto}) => Rider(
    id: id ?? this.id,
    name: name ?? this.name,
    profilePhoto: profilePhoto ?? this.profilePhoto,
  );

  factory Rider.fromJson(Map<String, dynamic> json) => Rider(
    id: json["id"],
    name: json["name"],
    profilePhoto: json["profile_photo"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "profile_photo": profilePhoto,
  };
}
