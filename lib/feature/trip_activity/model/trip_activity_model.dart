
import 'dart:convert';

TripActivityModel tripActivityModelFromJson(String str) =>
    TripActivityModel.fromJson(json.decode(str));

String tripActivityModelToJson(TripActivityModel data) =>
    json.encode(data.toJson());

class TripActivityModel {
  bool? success;
  Data? data;

  TripActivityModel({this.success, this.data});

  TripActivityModel copyWith({bool? success, Data? data}) => TripActivityModel(
    success: success ?? this.success,
    data: data ?? this.data,
  );

  factory TripActivityModel.fromJson(Map<String, dynamic> json) =>
      TripActivityModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  List<Trip>? trips;
  Pagination? pagination;
  Summary? summary;
  Filters? filters;

  Data({this.trips, this.pagination, this.summary, this.filters});

  Data copyWith({
    List<Trip>? trips,
    Pagination? pagination,
    Summary? summary,
    Filters? filters,
  }) => Data(
    trips: trips ?? this.trips,
    pagination: pagination ?? this.pagination,
    summary: summary ?? this.summary,
    filters: filters ?? this.filters,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    trips: json["trips"] == null
        ? []
        : List<Trip>.from(json["trips"]!.map((x) => Trip.fromJson(x))),
    pagination: json["pagination"] == null
        ? null
        : Pagination.fromJson(json["pagination"]),
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
    filters: json["filters"] == null ? null : Filters.fromJson(json["filters"]),
  );

  Map<String, dynamic> toJson() => {
    "trips": trips == null
        ? []
        : List<dynamic>.from(trips!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
    "summary": summary?.toJson(),
    "filters": filters?.toJson(),
  };
}

class Filters {
  String? status;
  String? tripType;
  String? paymentMode;
  String? period;
  String? dateFrom;
  String? dateTo;
  String? distanceMin;
  String? distanceMax;
  String? amountMin;
  String? amountMax;
  String? cancelledBy;

  Filters({
    this.status,
    this.tripType,
    this.paymentMode,
    this.period,
    this.dateFrom,
    this.dateTo,
    this.distanceMin,
    this.distanceMax,
    this.amountMin,
    this.amountMax,
    this.cancelledBy,
  });

  Filters copyWith({
    String? status,
    String? tripType,
    String? paymentMode,
    String? period,
    String? dateFrom,
    String? dateTo,
    String? distanceMin,
    String? distanceMax,
    String? amountMin,
    String? amountMax,
    String? cancelledBy,
  }) => Filters(
    status: status ?? this.status,
    tripType: tripType ?? this.tripType,
    paymentMode: paymentMode ?? this.paymentMode,
    period: period ?? this.period,
    dateFrom: dateFrom ?? this.dateFrom,
    dateTo: dateTo ?? this.dateTo,
    distanceMin: distanceMin ?? this.distanceMin,
    distanceMax: distanceMax ?? this.distanceMax,
    amountMin: amountMin ?? this.amountMin,
    amountMax: amountMax ?? this.amountMax,
    cancelledBy: cancelledBy ?? this.cancelledBy,
  );

  factory Filters.fromJson(Map<String, dynamic> json) => Filters(
    status: json["status"],
    tripType: json["trip_type"],
    paymentMode: json["payment_mode"],
    period: json["period"],
    dateFrom: json["date_from"],
    dateTo: json["date_to"],
    distanceMin: json["distance_min"],
    distanceMax: json["distance_max"],
    amountMin: json["amount_min"],
    amountMax: json["amount_max"],
    cancelledBy: json["cancelled_by"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "trip_type": tripType,
    "payment_mode": paymentMode,
    "period": period,
    "date_from": dateFrom,
    "date_to": dateTo,
    "distance_min": distanceMin,
    "distance_max": distanceMax,
    "amount_min": amountMin,
    "amount_max": amountMax,
    "cancelled_by": cancelledBy,
  };
}

class Pagination {
  int? currentPage;
  int? perPage;
  int? total;
  int? lastPage;
  bool? hasMore;

  Pagination({
    this.currentPage,
    this.perPage,
    this.total,
    this.lastPage,
    this.hasMore,
  });

  Pagination copyWith({
    int? currentPage,
    int? perPage,
    int? total,
    int? lastPage,
    bool? hasMore,
  }) => Pagination(
    currentPage: currentPage ?? this.currentPage,
    perPage: perPage ?? this.perPage,
    total: total ?? this.total,
    lastPage: lastPage ?? this.lastPage,
    hasMore: hasMore ?? this.hasMore,
  );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    perPage: json["per_page"],
    total: json["total"],
    lastPage: json["last_page"],
    hasMore: json["has_more"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "per_page": perPage,
    "total": total,
    "last_page": lastPage,
    "has_more": hasMore,
  };
}

class Summary {
  String? totalTrips;
  String? completedTrips;
  String? cancelledTrips;
  String? totalEarnings;
  String? totalDistance;
  String? totalOnlineHours;
  String? averageRating;
  dynamic completionRate;

  Summary({
    this.totalTrips,
    this.completedTrips,
    this.cancelledTrips,
    this.totalEarnings,
    this.totalDistance,
    this.totalOnlineHours,
    this.averageRating,
    this.completionRate,
  });

  Summary copyWith({
    String? totalTrips,
    String? completedTrips,
    String? cancelledTrips,
    String? totalEarnings,
    String? totalDistance,
    String? totalOnlineHours,
    String? averageRating,
    String? completionRate,
  }) => Summary(
    totalTrips: totalTrips ?? this.totalTrips,
    completedTrips: completedTrips ?? this.completedTrips,
    cancelledTrips: cancelledTrips ?? this.cancelledTrips,
    totalEarnings: totalEarnings ?? this.totalEarnings,
    totalDistance: totalDistance ?? this.totalDistance,
    totalOnlineHours: totalOnlineHours ?? this.totalOnlineHours,
    averageRating: averageRating ?? this.averageRating,
    completionRate: completionRate ?? this.completionRate,
  );

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    totalTrips: json["total_trips"],
    completedTrips: json["completed_trips"],
    cancelledTrips: json["cancelled_trips"],
    totalEarnings: json["total_earnings"],
    totalDistance: json["total_distance"],
    totalOnlineHours: json["total_online_hours"],
    averageRating: json["average_rating"],
    completionRate: json["completion_rate"],
  );

  Map<String, dynamic> toJson() => {
    "total_trips": totalTrips,
    "completed_trips": completedTrips,
    "cancelled_trips": cancelledTrips,
    "total_earnings": totalEarnings,
    "total_distance": totalDistance,
    "total_online_hours": totalOnlineHours,
    "average_rating": averageRating,
    "completion_rate": completionRate,
  };
}

class Trip {
  dynamic id;
  String? bookingCode;
  String? status;
  String? statusLabel;
  String? createdAt;
  String? createdAtFormatted;
  String? pickupAddress;
  String? dropoffAddress;
  String? paymentMethod;
  String? paymentMethodLabel;
  RideType? rideType;
  User? user;
  Financial? financial;
  Timestamps? timestamps;
  Cancellation? cancellation;

  Trip({
    this.id,
    this.bookingCode,
    this.status,
    this.statusLabel,
    this.createdAt,
    this.createdAtFormatted,
    this.pickupAddress,
    this.dropoffAddress,
    this.paymentMethod,
    this.paymentMethodLabel,
    this.rideType,
    this.user,
    this.financial,
    this.timestamps,
    this.cancellation,
  });

  Trip copyWith({
    dynamic id,
    String? bookingCode,
    String? status,
    String? statusLabel,
    String? createdAt,
    String? createdAtFormatted,
    String? pickupAddress,
    String? dropoffAddress,
    String? paymentMethod,
    String? paymentMethodLabel,
    RideType? rideType,
    User? user,
    Financial? financial,
    Timestamps? timestamps,
    Cancellation? cancellation,
  }) => Trip(
    id: id ?? this.id,
    bookingCode: bookingCode ?? this.bookingCode,
    status: status ?? this.status,
    statusLabel: statusLabel ?? this.statusLabel,
    createdAt: createdAt ?? this.createdAt,
    createdAtFormatted: createdAtFormatted ?? this.createdAtFormatted,
    pickupAddress: pickupAddress ?? this.pickupAddress,
    dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paymentMethodLabel: paymentMethodLabel ?? this.paymentMethodLabel,
    rideType: rideType ?? this.rideType,
    user: user ?? this.user,
    financial: financial ?? this.financial,
    timestamps: timestamps ?? this.timestamps,
    cancellation: cancellation ?? this.cancellation,
  );

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json["id"],
    bookingCode: json["booking_code"],
    status: json["status"],
    statusLabel: json["status_label"],
    createdAt: json["created_at"],
    createdAtFormatted: json["created_at_formatted"],
    pickupAddress: json["pickup_address"],
    dropoffAddress: json["dropoff_address"],
    paymentMethod: json["payment_method"],
    paymentMethodLabel: json["payment_method_label"],
    rideType: json["ride_type"] == null
        ? null
        : RideType.fromJson(json["ride_type"]),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    financial: json["financial"] == null
        ? null
        : Financial.fromJson(json["financial"]),
    timestamps: json["timestamps"] == null
        ? null
        : Timestamps.fromJson(json["timestamps"]),
    cancellation: json["cancellation"] == null
        ? null
        : Cancellation.fromJson(json["cancellation"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_code": bookingCode,
    "status": status,
    "status_label": statusLabel,
    "created_at": createdAt,
    "created_at_formatted": createdAtFormatted,
    "pickup_address": pickupAddress,
    "dropoff_address": dropoffAddress,
    "payment_method": paymentMethod,
    "payment_method_label": paymentMethodLabel,
    "ride_type": rideType?.toJson(),
    "user": user?.toJson(),
    "financial": financial?.toJson(),
    "timestamps": timestamps?.toJson(),
    "cancellation": cancellation?.toJson(),
  };
}

class Cancellation {
  String? reason;
  String? cancelledBy;
  String? cancelledAt;
  dynamic cancellationCharge;

  Cancellation({
    this.reason,
    this.cancelledBy,
    this.cancelledAt,
    this.cancellationCharge,
  });

  Cancellation copyWith({
    String? reason,
    String? cancelledBy,
    String? cancelledAt,
    String? cancellationCharge,
  }) => Cancellation(
    reason: reason ?? this.reason,
    cancelledBy: cancelledBy ?? this.cancelledBy,
    cancelledAt: cancelledAt ?? this.cancelledAt,
    cancellationCharge: cancellationCharge ?? this.cancellationCharge,
  );

  factory Cancellation.fromJson(Map<String, dynamic> json) => Cancellation(
    reason: json["reason"],
    cancelledBy: json["cancelled_by"],
    cancelledAt: json["cancelled_at"],
    cancellationCharge: json["cancellation_charge"],
  );

  Map<String, dynamic> toJson() => {
    "reason": reason,
    "cancelled_by": cancelledBy,
    "cancelled_at": cancelledAt,
    "cancellation_charge": cancellationCharge,
  };
}

class Financial {
  dynamic totalFare;
  int? driverAmount;
  String? distance;
  String? duration;
  FareBreakdown? fareBreakdown;

  Financial({
    this.totalFare,
    this.driverAmount,
    this.distance,
    this.duration,
    this.fareBreakdown,
  });

  Financial copyWith({
    int? totalFare,
    int? driverAmount,
    String? distance,
    String? duration,
    FareBreakdown? fareBreakdown,
  }) => Financial(
    totalFare: totalFare ?? this.totalFare,
    driverAmount: driverAmount ?? this.driverAmount,
    distance: distance ?? this.distance,
    duration: duration ?? this.duration,
    fareBreakdown: fareBreakdown ?? this.fareBreakdown,
  );

  factory Financial.fromJson(Map<String, dynamic> json) => Financial(
    totalFare: json["total_fare"],
    driverAmount: json["driver_amount"],
    distance: json["distance"],
    duration: json["duration"],
    fareBreakdown: json["fare_breakdown"] == null
        ? null
        : FareBreakdown.fromJson(json["fare_breakdown"]),
  );

  Map<String, dynamic> toJson() => {
    "total_fare": totalFare,
    "driver_amount": driverAmount,
    "distance": distance,
    "duration": duration,
    "fare_breakdown": fareBreakdown?.toJson(),
  };
}

class FareBreakdown {
  dynamic baseFare;
  dynamic distanceFare;
  String? timeFare;
  String? waitingCharge;
  String? nightCharge;
  String? surgeAmount;
  String? subtotal;
  String? taxAmount;
  String? totalAmount;
  String? driverAmount;
  String? tipAmount;
  String? discountAmount;
  dynamic debtAmount;

  FareBreakdown({
    this.baseFare,
    this.distanceFare,
    this.timeFare,
    this.waitingCharge,
    this.nightCharge,
    this.surgeAmount,
    this.subtotal,
    this.taxAmount,
    this.totalAmount,
    this.driverAmount,
    this.tipAmount,
    this.discountAmount,
    this.debtAmount,
  });

  FareBreakdown copyWith({
    String? baseFare,
    String? distanceFare,
    String? timeFare,
    String? waitingCharge,
    String? nightCharge,
    String? surgeAmount,
    String? subtotal,
    String? taxAmount,
    String? totalAmount,
    String? driverAmount,
    String? tipAmount,
    String? discountAmount,
    dynamic debtAmount,
  }) => FareBreakdown(
    baseFare: baseFare ?? this.baseFare,
    distanceFare: distanceFare ?? this.distanceFare,
    timeFare: timeFare ?? this.timeFare,
    waitingCharge: waitingCharge ?? this.waitingCharge,
    nightCharge: nightCharge ?? this.nightCharge,
    surgeAmount: surgeAmount ?? this.surgeAmount,
    subtotal: subtotal ?? this.subtotal,
    taxAmount: taxAmount ?? this.taxAmount,
    driverAmount: driverAmount ?? this.driverAmount,
    totalAmount: totalAmount ?? this.totalAmount,
    tipAmount: tipAmount ?? this.tipAmount,
    discountAmount: discountAmount ?? this.discountAmount,
    debtAmount: debtAmount ?? this.debtAmount,
  );

  factory FareBreakdown.fromJson(Map<String, dynamic> json) => FareBreakdown(
    baseFare: json["base_fare"].toString(),
    distanceFare: json["distance_fare"].toString(),
    timeFare: json["time_fare"].toString(),
    waitingCharge: json["waiting_charge"].toString(),
    nightCharge: json["night_charge"].toString(),
    surgeAmount: json["surge_amount"].toString(),
    subtotal: json["subtotal"].toString(),
    taxAmount: json["tax_amount"].toString(),
    totalAmount: json["total_amount"].toString(),
    driverAmount: json["driver_amount"].toString(),
    tipAmount: json["tip_amount"].toString(),
    discountAmount: json["offer_discount_amount"].toString(),
    debtAmount: json["debt_amount"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "base_fare": baseFare,
    "tip_amount": tipAmount,
    "distance_fare": distanceFare,
    "time_fare": timeFare,
    "waiting_charge": waitingCharge,
    "night_charge": nightCharge,
    "surge_amount": surgeAmount,
    "subtotal": subtotal,
    "tax_amount": taxAmount,
    "total_amount": totalAmount,
    "driver_amount": driverAmount,
    "offer_discount_amount": discountAmount,
    "debt_amount": debtAmount,
  };
}

class RideType {
  int? id;
  String? name;

  RideType({this.id, this.name});

  RideType copyWith({int? id, String? name}) =>
      RideType(id: id ?? this.id, name: name ?? this.name);

  factory RideType.fromJson(Map<String, dynamic> json) =>
      RideType(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class Timestamps {
  String? scheduledAt;
  String? startedAt;
  String? completedAt;
  String? cancelledAt;

  Timestamps({
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
  });

  Timestamps copyWith({
    String? scheduledAt,
    String? startedAt,
    String? completedAt,
    String? cancelledAt,
  }) => Timestamps(
    scheduledAt: scheduledAt ?? this.scheduledAt,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    cancelledAt: cancelledAt ?? this.cancelledAt,
  );

  factory Timestamps.fromJson(Map<String, dynamic> json) => Timestamps(
    scheduledAt: json["scheduled_at"],
    startedAt: json["started_at"],
    completedAt: json["completed_at"],
    cancelledAt: json["cancelled_at"],
  );

  Map<String, dynamic> toJson() => {
    "scheduled_at": scheduledAt,
    "started_at": startedAt,
    "completed_at": completedAt,
    "cancelled_at": cancelledAt,
  };
}

class User {
  dynamic id;
  String? name;
  String? phone;
  dynamic rating;
  String? comment;
  String? profilePhoto;

  User({
    this.id,
    this.name,
    this.phone,
    this.rating,
    this.comment,
    this.profilePhoto,
  });

  User copyWith({
    dynamic id,
    String? name,
    String? phone,
    dynamic rating,
    String? comment,
    String? profilePhoto,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    rating: rating ?? this.rating,
    comment: comment ?? this.comment,
    profilePhoto: profilePhoto ?? this.profilePhoto,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    rating: json["rating"],
    comment: json["comment"],
    profilePhoto: json["profile_photo"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "rating": rating,
    "comment": comment,
    "profile_photo": profilePhoto,
  };
}
