import 'dart:convert';

TripDetailsModel tripDetailsModelFromJson(String str) =>
    TripDetailsModel.fromJson(json.decode(str));

String tripDetailsModelToJson(TripDetailsModel data) =>
    json.encode(data.toJson());

class TripDetailsModel {
  bool? success;
  Data? data;

  TripDetailsModel({this.success, this.data});

  TripDetailsModel copyWith({bool? success, Data? data}) => TripDetailsModel(
    success: success ?? this.success,
    data: data ?? this.data,
  );

  factory TripDetailsModel.fromJson(Map<String, dynamic> json) =>
      TripDetailsModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  dynamic currentTrip;
  bool? hasActiveTrip;
  List<TripHistory>? tripHistory;
  Stats? stats;
  Pagination? pagination;

  Data({
    this.currentTrip,
    this.hasActiveTrip,
    this.tripHistory,
    this.stats,
    this.pagination,
  });

  Data copyWith({
    dynamic currentTrip,
    bool? hasActiveTrip,
    List<TripHistory>? tripHistory,
    Stats? stats,
    Pagination? pagination,
  }) => Data(
    currentTrip: currentTrip ?? this.currentTrip,
    hasActiveTrip: hasActiveTrip ?? this.hasActiveTrip,
    tripHistory: tripHistory ?? this.tripHistory,
    stats: stats ?? this.stats,
    pagination: pagination ?? this.pagination,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentTrip: json["current_trip"],
    hasActiveTrip: json["has_active_trip"],
    tripHistory: json["trip_history"] == null
        ? []
        : List<TripHistory>.from(
            json["trip_history"]!.map((x) => TripHistory.fromJson(x)),
          ),
    stats: json["stats"] == null ? null : Stats.fromJson(json["stats"]),
    pagination: json["pagination"] == null
        ? null
        : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "current_trip": currentTrip,
    "has_active_trip": hasActiveTrip,
    "trip_history": tripHistory == null
        ? []
        : List<dynamic>.from(tripHistory!.map((x) => x.toJson())),
    "stats": stats?.toJson(),
    "pagination": pagination?.toJson(),
  };
}

class Pagination {
  int? currentPage;
  int? perPage;
  int? total;
  int? lastPage;
  int? from;
  int? to;
  bool? hasMorePages;

  Pagination({
    this.currentPage,
    this.perPage,
    this.total,
    this.lastPage,
    this.from,
    this.to,
    this.hasMorePages,
  });

  Pagination copyWith({
    int? currentPage,
    int? perPage,
    int? total,
    int? lastPage,
    int? from,
    int? to,
    bool? hasMorePages,
  }) => Pagination(
    currentPage: currentPage ?? this.currentPage,
    perPage: perPage ?? this.perPage,
    total: total ?? this.total,
    lastPage: lastPage ?? this.lastPage,
    from: from ?? this.from,
    to: to ?? this.to,
    hasMorePages: hasMorePages ?? this.hasMorePages,
  );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    perPage: json["per_page"],
    total: json["total"],
    lastPage: json["last_page"],
    from: json["from"],
    to: json["to"],
    hasMorePages: json["has_more_pages"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "per_page": perPage,
    "total": total,
    "last_page": lastPage,
    "from": from,
    "to": to,
    "has_more_pages": hasMorePages,
  };
}

class Stats {
  int? totalTrips;
  int? completedTrips;
  int? cancelledTrips;
  double? totalSpent;
  dynamic averageRatingGiven;
  double? averageRatingReceived;

  Stats({
    this.totalTrips,
    this.completedTrips,
    this.cancelledTrips,
    this.totalSpent,
    this.averageRatingGiven,
    this.averageRatingReceived,
  });

  Stats copyWith({
    int? totalTrips,
    int? completedTrips,
    int? cancelledTrips,
    double? totalSpent,
    dynamic averageRatingGiven,
    double? averageRatingReceived,
  }) => Stats(
    totalTrips: totalTrips ?? this.totalTrips,
    completedTrips: completedTrips ?? this.completedTrips,
    cancelledTrips: cancelledTrips ?? this.cancelledTrips,
    totalSpent: totalSpent ?? this.totalSpent,
    averageRatingGiven: averageRatingGiven ?? this.averageRatingGiven,
    averageRatingReceived: averageRatingReceived ?? this.averageRatingReceived,
  );

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    totalTrips: json["total_trips"],
    completedTrips: json["completed_trips"],
    cancelledTrips: json["cancelled_trips"],
    totalSpent: json["total_spent"]?.toDouble(),
    averageRatingGiven: json["average_rating_given"],
    averageRatingReceived: json["average_rating_received"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "total_trips": totalTrips,
    "completed_trips": completedTrips,
    "cancelled_trips": cancelledTrips,
    "total_spent": totalSpent,
    "average_rating_given": averageRatingGiven,
    "average_rating_received": averageRatingReceived,
  };
}

class TripHistory {
  TripInfo? tripInfo;
  Locations? locations;
  TimeInfo? timeInfo;
  Pricing? pricing;
  DriverInfoClass? driverInfo;
  RideType? rideType;
  Ratings? ratings;
  List<dynamic>? transactions;
  String? refundStatus;

  TripHistory({
    this.tripInfo,
    this.locations,
    this.timeInfo,
    this.pricing,
    this.driverInfo,
    this.rideType,
    this.ratings,
    this.transactions,
    this.refundStatus,
  });

  TripHistory copyWith({
    TripInfo? tripInfo,
    Locations? locations,
    TimeInfo? timeInfo,
    Pricing? pricing,
    DriverInfoClass? driverInfo,
    RideType? rideType,
    Ratings? ratings,
    List<dynamic>? transactions,
    String? refundStatus,
  }) => TripHistory(
    tripInfo: tripInfo ?? this.tripInfo,
    locations: locations ?? this.locations,
    timeInfo: timeInfo ?? this.timeInfo,
    pricing: pricing ?? this.pricing,
    driverInfo: driverInfo ?? this.driverInfo,
    rideType: rideType ?? this.rideType,
    ratings: ratings ?? this.ratings,
    transactions: transactions ?? this.transactions,
    refundStatus: refundStatus ?? this.refundStatus,
  );

  factory TripHistory.fromJson(Map<String, dynamic> json) => TripHistory(
    tripInfo: json["trip_info"] == null
        ? null
        : TripInfo.fromJson(json["trip_info"]),
    locations: json["locations"] == null
        ? null
        : Locations.fromJson(json["locations"]),
    timeInfo: json["time_info"] == null
        ? null
        : TimeInfo.fromJson(json["time_info"]),
    pricing: json["pricing"] == null ? null : Pricing.fromJson(json["pricing"]),
    driverInfo: json["driver_info"] == null || json["driver_info"] == ""
        ? null
        : DriverInfoClass.fromJson(json['driver_info']),
    rideType: json["ride_type"] == null
        ? null
        : RideType.fromJson(json["ride_type"]),
    ratings: json["ratings"] == null ? null : Ratings.fromJson(json["ratings"]),
    transactions: json["transactions"] == null
        ? []
        : List<dynamic>.from(json["transactions"]!.map((x) => x)),
    refundStatus: json["refund_status"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "trip_info": tripInfo?.toJson(),
    "locations": locations?.toJson(),
    "time_info": timeInfo?.toJson(),
    "pricing": pricing?.toJson(),
    "driver_info": driverInfo?.toJson(),
    "ride_type": rideType?.toJson(),
    "ratings": ratings?.toJson(),
    "transactions": transactions == null
        ? []
        : List<dynamic>.from(transactions!.map((x) => x)),
  };
}

class DriverInfoClass {
  String? id;
  String? name;
  String? phone;
  String? rating;
  String? driverRating;
  String? profilePhoto;
  Vehicle? vehicle;

  DriverInfoClass({
    this.id,
    this.name,
    this.phone,
    this.rating,
    this.driverRating,
    this.profilePhoto,
    this.vehicle,
  });

  DriverInfoClass copyWith({
    String? id,
    String? name,
    String? phone,
    String? rating,
    String? driverRating,
    String? profilePhoto,
    Vehicle? vehicle,
  }) => DriverInfoClass(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    rating: rating ?? this.rating,
    driverRating: driverRating ?? this.driverRating,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    vehicle: vehicle ?? this.vehicle,
  );

  factory DriverInfoClass.fromJson(Map<String, dynamic> json) =>
      DriverInfoClass(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        rating: json["rating"],
        driverRating: json["driver_rating"],
        profilePhoto: json["profile_photo"],
        vehicle: json["vehicle"] == null
            ? null
            : Vehicle.fromJson(json["vehicle"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "rating": rating,
    "driver_rating": driverRating,
    "profile_photo": profilePhoto,
    "vehicle": vehicle?.toJson(),
  };
}

class Vehicle {
  String? model;
  String? vehicleModel;
  String? color;
  String? vehiclePlateNumber;

  Vehicle({this.model, this.vehicleModel, this.color, this.vehiclePlateNumber});

  Vehicle copyWith({
    String? model,
    String? vehicleModel,
    String? color,
    String? vehiclePlateNumber,
  }) => Vehicle(
    model: model ?? this.model,
    vehicleModel: vehicleModel ?? this.vehicleModel,
    color: color ?? this.color,
    vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
  );

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    model: json["model"],
    vehicleModel: json["vehicle_model"],
    color: json["color"],
    vehiclePlateNumber: json["vehicle_plate_number"],
  );

  Map<String, dynamic> toJson() => {
    "model": model,
    "vehicle_model": vehicleModel,
    "color": color,
    "vehicle_plate_number": vehiclePlateNumber,
  };
}

class Locations {
  String? pickupAddress;
  String? pickupLatitude;
  String? pickupLongitude;
  String? dropoffAddress;
  String? dropoffLatitude;
  String? dropoffLongitude;
  String? estimatedDistance;
  String? actualDistance;
  String? estimatedDuration;
  String? actualDuration;
  String? distanceKm;
  String? tripTimeMinutes;

  Locations({
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffAddress,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.estimatedDistance,
    this.actualDistance,
    this.estimatedDuration,
    this.actualDuration,
    this.distanceKm,
    this.tripTimeMinutes,
  });

  Locations copyWith({
    String? pickupAddress,
    String? pickupLatitude,
    String? pickupLongitude,
    String? dropoffAddress,
    String? dropoffLatitude,
    String? dropoffLongitude,
    String? estimatedDistance,
    String? actualDistance,
    String? estimatedDuration,
    String? actualDuration,
    String? distanceKm,
    String? tripTimeMinutes,
  }) => Locations(
    pickupAddress: pickupAddress ?? this.pickupAddress,
    pickupLatitude: pickupLatitude ?? this.pickupLatitude,
    pickupLongitude: pickupLongitude ?? this.pickupLongitude,
    dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
    dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
    estimatedDistance: estimatedDistance ?? this.estimatedDistance,
    actualDistance: actualDistance ?? this.actualDistance,
    estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    actualDuration: actualDuration ?? this.actualDuration,
    distanceKm: distanceKm ?? this.distanceKm,
    tripTimeMinutes: tripTimeMinutes ?? this.tripTimeMinutes,
  );

  factory Locations.fromJson(Map<String, dynamic> json) => Locations(
    pickupAddress: json["pickup_address"],
    pickupLatitude: json["pickup_latitude"],
    pickupLongitude: json["pickup_longitude"],
    dropoffAddress: json["dropoff_address"],
    dropoffLatitude: json["dropoff_latitude"],
    dropoffLongitude: json["dropoff_longitude"],
    estimatedDistance: json["estimated_distance"],
    actualDistance: json["actual_distance"],
    estimatedDuration: json["estimated_duration"],
    actualDuration: json["actual_duration"],
    distanceKm: json["distance_km"],
    tripTimeMinutes: json["trip_time_minutes"],
  );

  Map<String, dynamic> toJson() => {
    "pickup_address": pickupAddress,
    "pickup_latitude": pickupLatitude,
    "pickup_longitude": pickupLongitude,
    "dropoff_address": dropoffAddress,
    "dropoff_latitude": dropoffLatitude,
    "dropoff_longitude": dropoffLongitude,
    "estimated_distance": estimatedDistance,
    "actual_distance": actualDistance,
    "estimated_duration": estimatedDuration,
    "actual_duration": actualDuration,
    "distance_km": distanceKm,
    "trip_time_minutes": tripTimeMinutes,
  };
}

class Pricing {
  String? baseFare;
  String? distanceFare;
  String? timeFare;
  String? waitingCharge;
  String? cancellationCharge;
  String? nightCharge;
  String? surgeMultiplier;
  String? surgeAmount;
  String? totalFare;
  String? finalFare;
  String? discountAmount;
  String? promoDiscount;
  String? rideFare;
  String? tipAmount;

  Pricing({
    this.baseFare,
    this.distanceFare,
    this.timeFare,
    this.waitingCharge,
    this.cancellationCharge,
    this.nightCharge,
    this.surgeMultiplier,
    this.surgeAmount,
    this.totalFare,
    this.finalFare,
    this.discountAmount,
    this.promoDiscount,
    this.rideFare,
    this.tipAmount,
  });

  Pricing copyWith({
    String? baseFare,
    String? distanceFare,
    String? timeFare,
    String? waitingCharge,
    String? cancellationCharge,
    String? nightCharge,
    String? surgeMultiplier,
    String? surgeAmount,
    String? totalFare,
    String? finalFare,
    String? discountAmount,
    String? promoDiscount,
    String? rideFare,
    String? tipAmount,
  }) => Pricing(
    baseFare: baseFare ?? this.baseFare,
    distanceFare: distanceFare ?? this.distanceFare,
    timeFare: timeFare ?? this.timeFare,
    waitingCharge: waitingCharge ?? this.waitingCharge,
    cancellationCharge: cancellationCharge ?? this.cancellationCharge,
    nightCharge: nightCharge ?? this.nightCharge,
    surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
    surgeAmount: surgeAmount ?? this.surgeAmount,
    totalFare: totalFare ?? this.totalFare,
    finalFare: finalFare ?? this.finalFare,
    discountAmount: discountAmount ?? this.discountAmount,
    promoDiscount: promoDiscount ?? this.promoDiscount,
    rideFare: rideFare ?? this.rideFare,
    tipAmount: tipAmount ?? this.tipAmount,
  );

  factory Pricing.fromJson(Map<String, dynamic> json) => Pricing(
    baseFare: json["base_fare"],
    distanceFare: json["distance_fare"],
    timeFare: json["time_fare"],
    waitingCharge: json["waiting_charge"],
    cancellationCharge: json["cancellation_charge"],
    nightCharge: json["night_charge"],
    surgeMultiplier: json["surge_multiplier"],
    surgeAmount: json["surge_amount"],
    totalFare: json["total_fare"],
    finalFare: json["final_fare"],
    discountAmount: json["discount_amount"],
    promoDiscount: json["promo_discount"],
    rideFare: json["ride_fare"],
    tipAmount: json["tip_amount"],
  );

  Map<String, dynamic> toJson() => {
    "base_fare": baseFare,
    "distance_fare": distanceFare,
    "time_fare": timeFare,
    "waiting_charge": waitingCharge,
    "cancellation_charge": cancellationCharge,
    "night_charge": nightCharge,
    "surge_multiplier": surgeMultiplier,
    "surge_amount": surgeAmount,
    "total_fare": totalFare,
    "final_fare": finalFare,
    "discount_amount": discountAmount,
    "promo_discount": promoDiscount,
    "ride_fare": rideFare,
    "tip_amount": tipAmount,
  };
}

class Ratings {
  String? userRating;
  String? userReview;
  String? driverRating;
  String? driverReview;

  Ratings({
    this.userRating,
    this.userReview,
    this.driverRating,
    this.driverReview,
  });

  Ratings copyWith({
    String? userRating,
    String? userReview,
    String? driverRating,
    String? driverReview,
  }) => Ratings(
    userRating: userRating ?? this.userRating,
    userReview: userReview ?? this.userReview,
    driverRating: driverRating ?? this.driverRating,
    driverReview: driverReview ?? this.driverReview,
  );

  factory Ratings.fromJson(Map<String, dynamic> json) => Ratings(
    userRating: json["user_rating"],
    userReview: json["user_review"],
    driverRating: json["driver_rating"],
    driverReview: json["driver_review"],
  );

  Map<String, dynamic> toJson() => {
    "user_rating": userRating,
    "user_review": userReview,
    "driver_rating": driverRating,
    "driver_review": driverReview,
  };
}

class RideType {
  String? id;
  String? name;
  String? rideTypeName;
  String? description;
  String? baseFare;
  String? icon;

  RideType({
    this.id,
    this.name,
    this.rideTypeName,
    this.description,
    this.baseFare,
    this.icon,
  });

  RideType copyWith({
    String? id,
    String? name,
    String? rideTypeName,
    String? description,
    String? baseFare,
    String? icon,
  }) => RideType(
    id: id ?? this.id,
    name: name ?? this.name,
    rideTypeName: rideTypeName ?? this.rideTypeName,
    description: description ?? this.description,
    baseFare: baseFare ?? this.baseFare,
    icon: icon ?? this.icon,
  );

  factory RideType.fromJson(Map<String, dynamic> json) => RideType(
    id: json["id"],
    name: json["name"],
    rideTypeName: json["ride_type_name"],
    description: json["description"],
    baseFare: json["base_fare"],
    icon: json["icon"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "ride_type_name": rideTypeName,
    "description": description,
    "base_fare": baseFare,
    "icon": icon,
  };
}

class TimeInfo {
  String? totalTripDuration;
  String? waitingTime;
  String? totalWaitingTime;
  String? driverArrivalTime;
  String? pickupTime;
  String? dropoffTime;

  TimeBreakdown? timeBreakdown;

  TimeInfo({
    this.totalTripDuration,
    this.waitingTime,
    this.totalWaitingTime,
    this.driverArrivalTime,
    this.pickupTime,
    this.dropoffTime,
    this.timeBreakdown,
  });

  TimeInfo copyWith({
    String? totalTripDuration,
    String? waitingTime,
    String? totalWaitingTime,
    String? driverArrivalTime,
    String? pickupTime,
    String? dropoffTime,
    String? invoic,
    TimeBreakdown? timeBreakdown,
  }) => TimeInfo(
    totalTripDuration: totalTripDuration ?? this.totalTripDuration,
    waitingTime: waitingTime ?? this.waitingTime,
    totalWaitingTime: totalWaitingTime ?? this.totalWaitingTime,
    driverArrivalTime: driverArrivalTime ?? this.driverArrivalTime,
    pickupTime: pickupTime ?? this.pickupTime,
    dropoffTime: dropoffTime ?? this.dropoffTime,
    timeBreakdown: timeBreakdown ?? this.timeBreakdown,
  );

  factory TimeInfo.fromJson(Map<String, dynamic> json) => TimeInfo(
    totalTripDuration: json["total_trip_duration"],
    waitingTime: json["waiting_time"],
    totalWaitingTime: json["total_waiting_time"],
    driverArrivalTime: json["driver_arrival_time"],
    pickupTime: json["pickup_time"],
    dropoffTime: json["dropoff_time"],
    timeBreakdown: json["time_breakdown"] == null
        ? null
        : TimeBreakdown.fromJson(json["time_breakdown"]),
  );

  Map<String, dynamic> toJson() => {
    "total_trip_duration": totalTripDuration,
    "waiting_time": waitingTime,
    "total_waiting_time": totalWaitingTime,
    "driver_arrival_time": driverArrivalTime,
    "pickup_time": pickupTime,
    "dropoff_time": dropoffTime,
    "time_breakdown": timeBreakdown?.toJson(),
  };
}

class TimeBreakdown {
  EstimatedVsActual? estimatedVsActual;
  WaitingTimes? waitingTimes;
  TripPhases? tripPhases;

  TimeBreakdown({this.estimatedVsActual, this.waitingTimes, this.tripPhases});

  TimeBreakdown copyWith({
    EstimatedVsActual? estimatedVsActual,
    WaitingTimes? waitingTimes,
    TripPhases? tripPhases,
  }) => TimeBreakdown(
    estimatedVsActual: estimatedVsActual ?? this.estimatedVsActual,
    waitingTimes: waitingTimes ?? this.waitingTimes,
    tripPhases: tripPhases ?? this.tripPhases,
  );

  factory TimeBreakdown.fromJson(Map<String, dynamic> json) => TimeBreakdown(
    estimatedVsActual: json["estimated_vs_actual"] == null
        ? null
        : EstimatedVsActual.fromJson(json["estimated_vs_actual"]),
    waitingTimes: json["waiting_times"] == null
        ? null
        : WaitingTimes.fromJson(json["waiting_times"]),
    tripPhases: json["trip_phases"] == null
        ? null
        : TripPhases.fromJson(json["trip_phases"]),
  );

  Map<String, dynamic> toJson() => {
    "estimated_vs_actual": estimatedVsActual?.toJson(),
    "waiting_times": waitingTimes?.toJson(),
    "trip_phases": tripPhases?.toJson(),
  };
}

class EstimatedVsActual {
  String? estimatedDuration;
  String? actualDuration;
  String? durationDifference;

  EstimatedVsActual({
    this.estimatedDuration,
    this.actualDuration,
    this.durationDifference,
  });

  EstimatedVsActual copyWith({
    String? estimatedDuration,
    String? actualDuration,
    String? durationDifference,
  }) => EstimatedVsActual(
    estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    actualDuration: actualDuration ?? this.actualDuration,
    durationDifference: durationDifference ?? this.durationDifference,
  );

  factory EstimatedVsActual.fromJson(Map<String, dynamic> json) =>
      EstimatedVsActual(
        estimatedDuration: json["estimated_duration"],
        actualDuration: json["actual_duration"],
        durationDifference: json["duration_difference"],
      );

  Map<String, dynamic> toJson() => {
    "estimated_duration": estimatedDuration,
    "actual_duration": actualDuration,
    "duration_difference": durationDifference,
  };
}

class TripPhases {
  String? bookingToDriverAssigned;
  String? driverArrivalToPickup;
  String? pickupToDropoff;
  String? totalTripTime;

  TripPhases({
    this.bookingToDriverAssigned,
    this.driverArrivalToPickup,
    this.pickupToDropoff,
    this.totalTripTime,
  });

  TripPhases copyWith({
    String? bookingToDriverAssigned,
    String? driverArrivalToPickup,
    String? pickupToDropoff,
    String? totalTripTime,
  }) => TripPhases(
    bookingToDriverAssigned:
        bookingToDriverAssigned ?? this.bookingToDriverAssigned,
    driverArrivalToPickup: driverArrivalToPickup ?? this.driverArrivalToPickup,
    pickupToDropoff: pickupToDropoff ?? this.pickupToDropoff,
    totalTripTime: totalTripTime ?? this.totalTripTime,
  );

  factory TripPhases.fromJson(Map<String, dynamic> json) => TripPhases(
    bookingToDriverAssigned: json["booking_to_driver_assigned"],
    driverArrivalToPickup: json["driver_arrival_to_pickup"],
    pickupToDropoff: json["pickup_to_dropoff"],
    totalTripTime: json["total_trip_time"],
  );

  Map<String, dynamic> toJson() => {
    "booking_to_driver_assigned": bookingToDriverAssigned,
    "driver_arrival_to_pickup": driverArrivalToPickup,
    "pickup_to_dropoff": pickupToDropoff,
    "total_trip_time": totalTripTime,
  };
}

class WaitingTimes {
  String? driverWaitingTime;
  String? totalWaitingTime;

  WaitingTimes({this.driverWaitingTime, this.totalWaitingTime});

  WaitingTimes copyWith({
    String? driverWaitingTime,
    String? totalWaitingTime,
  }) => WaitingTimes(
    driverWaitingTime: driverWaitingTime ?? this.driverWaitingTime,
    totalWaitingTime: totalWaitingTime ?? this.totalWaitingTime,
  );

  factory WaitingTimes.fromJson(Map<String, dynamic> json) => WaitingTimes(
    driverWaitingTime: json["driver_waiting_time"],
    totalWaitingTime: json["total_waiting_time"],
  );

  Map<String, dynamic> toJson() => {
    "driver_waiting_time": driverWaitingTime,
    "total_waiting_time": totalWaitingTime,
  };
}

class TripInfo {
  String? invoice;
  String? id;
  String? bookingCode;
  String? tripCode;
  String? otp;
  String? status;
  String? paymentMethod;
  String? paymentStatus;
  String? createdAt;
  String? scheduledAt;
  String? startedAt;
  String? completedAt;
  String? cancelledAt;
  String? cancellationReason;
  String? cancelledByType;
  String? statusLabel;
  String? bookingDateTime;

  TripInfo({
    this.id,
    this.invoice,
    this.bookingCode,
    this.tripCode,
    this.otp,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.createdAt,
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.cancelledByType,
    this.statusLabel,
    this.bookingDateTime,
  });

  TripInfo copyWith({
    String? id,
    String? invoice,
    String? bookingCode,
    String? tripCode,
    String? otp,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    String? createdAt,
    String? scheduledAt,
    String? startedAt,
    String? completedAt,
    String? cancelledAt,
    String? cancellationReason,
    String? cancelledByType,
    String? statusLabel,
    String? bookingDateTime,
  }) => TripInfo(
    id: id ?? this.id,
    invoice: invoice ?? this.invoice,
    bookingCode: bookingCode ?? this.bookingCode,
    tripCode: tripCode ?? this.tripCode,
    otp: otp ?? this.otp,
    status: status ?? this.status,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    createdAt: createdAt ?? this.createdAt,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    cancelledAt: cancelledAt ?? this.cancelledAt,
    cancellationReason: cancellationReason ?? this.cancellationReason,
    cancelledByType: cancelledByType ?? this.cancelledByType,
    statusLabel: statusLabel ?? this.statusLabel,
    bookingDateTime: bookingDateTime ?? this.bookingDateTime,
  );

  factory TripInfo.fromJson(Map<String, dynamic> json) => TripInfo(
    id: json["id"],
    invoice: json["invoice_download_link"],
    bookingCode: json["booking_code"],
    tripCode: json["trip_code"],
    otp: json["otp"],
    status: json["status"],
    paymentMethod: json["payment_method"],
    paymentStatus: json["payment_status"],
    createdAt: json["created_at"],
    scheduledAt: json["scheduled_at"],
    startedAt: json["started_at"],
    completedAt: json["completed_at"],
    cancelledAt: json["cancelled_at"],
    cancellationReason: json["cancellation_reason"],
    cancelledByType: json["cancelled_by_type"],
    statusLabel: json["status_label"],
    bookingDateTime: json["booking_date_time"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_code": bookingCode,
    "trip_code": tripCode,
    "otp": otp,
    "status": status,
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
    "created_at": createdAt,
    "scheduled_at": scheduledAt,
    "started_at": startedAt,
    "completed_at": completedAt,
    "cancelled_at": cancelledAt,
    "cancellation_reason": cancellationReason,
    "cancelled_by_type": cancelledByType,
    "status_label": statusLabel,
    "booking_date_time": bookingDateTime,
  };
}
