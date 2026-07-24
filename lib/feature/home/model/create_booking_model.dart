import 'dart:convert';

BookingCreateModel bookingCreateModelFromJson(String str) =>
    BookingCreateModel.fromJson(json.decode(str));

String bookingCreateModelToJson(BookingCreateModel data) =>
    json.encode(data.toJson());

class BookingCreateModel {
  bool? success;
  String? message;
  Data? data;

  BookingCreateModel({this.success, this.message, this.data});

  BookingCreateModel copyWith({
    bool? success,
    String? message,
    Data? data,
    dynamic debtAmount,
  }) => BookingCreateModel(
    success: success ?? this.success,
    message: message ?? this.message,
    data: data ?? this.data,
  );

  factory BookingCreateModel.fromJson(Map<String, dynamic> json) =>
      BookingCreateModel(
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
  BookingModel? booking;
  String? tripCode;
  RideTypeEstimate? rideTypeEstimate;
  List<RideOption>? rideOptions;
  DetectedCity? detectedCity;
  FareBreakdown? fareBreakdown;
  dynamic debtAmount;

  Data({
    this.booking,
    this.tripCode,
    this.rideTypeEstimate,
    this.rideOptions,
    this.fareBreakdown,
    this.detectedCity,
    this.debtAmount,
  });

  Data copyWith({
    BookingModel? booking,
    String? tripCode,
    RideTypeEstimate? rideTypeEstimate,
    List<RideOption>? rideOptions,
    DetectedCity? detectedCity,
    FareBreakdown? fareBreakdown,
    dynamic debtAmount,
  }) => Data(
    booking: booking ?? this.booking,
    tripCode: tripCode ?? this.tripCode,
    rideTypeEstimate: rideTypeEstimate ?? this.rideTypeEstimate,
    rideOptions: rideOptions ?? this.rideOptions,
    detectedCity: detectedCity ?? this.detectedCity,
    fareBreakdown: fareBreakdown ?? this.fareBreakdown,
    debtAmount: debtAmount ?? this.debtAmount,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    booking: json["booking"] == null
        ? null
        : BookingModel.fromJson(json["booking"]),
    tripCode: json["trip_code"],
    rideTypeEstimate: json["ride_type_estimate"] == null
        ? null
        : RideTypeEstimate.fromJson(json["ride_type_estimate"]),
    rideOptions: json["ride_options"] == null
        ? []
        : List<RideOption>.from(
            json["ride_options"]!.map((x) => RideOption.fromJson(x)),
          ),
    detectedCity: json["detected_city"] == null
        ? null
        : DetectedCity.fromJson(json["detected_city"]),
    fareBreakdown: json["fare_breakdown"] == null
        ? null
        : FareBreakdown.fromJson(json["fare_breakdown"]),
    debtAmount: json["debt_amount"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "booking": booking?.toJson(),
    "trip_code": tripCode,
    "ride_type_estimate": rideTypeEstimate?.toJson(),
    "ride_options": rideOptions == null
        ? []
        : List<dynamic>.from(rideOptions!.map((x) => x.toJson())),
    "detected_city": detectedCity?.toJson(),
    "FareBreakdown": fareBreakdown?.toJson(),
    "debt_amount": debtAmount,
  };
}

class BookingModel {
  String? id;
  String? bookingCode;
  String? userId;
  String? driverId;
  String? cityId;
  String? rideTypeId;
  String? pickupZoneId;
  String? dropoffZoneId;
  String? pickupLatitude;
  String? pickupLongitude;
  String? pickupAddress;
  String? dropoffLatitude;
  String? dropoffLongitude;
  String? dropoffAddress;
  String? distance;
  String? duration;
  String? estimatedFare;
  String? finalFare;
  String? paymentMethod;
  String? paymentStatus;
  String? status;
  String? isConfirm;
  String? tripCode;
  String? otp;
  String? baseFare;
  String? distanceFare;
  String? timeFare;
  String? waitingCharge;
  String? cancellationCharge;
  String? nightCharge;
  String? surgeMultiplier;
  String? surgeAmount;
  String? subtotal;
  String? taxRate;
  String? taxAmount;
  String? totalAmount;
  String? createdAt;
  String? updatedAt;

  BookingModel({
    this.id,
    this.bookingCode,
    this.userId,
    this.driverId,
    this.cityId,
    this.rideTypeId,
    this.pickupZoneId,
    this.dropoffZoneId,
    this.pickupLatitude,
    this.pickupLongitude,
    this.pickupAddress,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.dropoffAddress,
    this.distance,
    this.duration,
    this.estimatedFare,
    this.finalFare,
    this.paymentMethod,
    this.paymentStatus,
    this.status,
    this.isConfirm,
    this.tripCode,
    this.otp,
    this.baseFare,
    this.distanceFare,
    this.timeFare,
    this.waitingCharge,
    this.cancellationCharge,
    this.nightCharge,
    this.surgeMultiplier,
    this.surgeAmount,
    this.subtotal,
    this.taxRate,
    this.taxAmount,
    this.totalAmount,
    this.createdAt,
    this.updatedAt,
  });

  BookingModel copyWith({
    String? id,
    String? bookingCode,
    String? userId,
    String? driverId,
    String? cityId,
    String? rideTypeId,
    String? pickupZoneId,
    String? dropoffZoneId,
    String? pickupLatitude,
    String? pickupLongitude,
    String? pickupAddress,
    String? dropoffLatitude,
    String? dropoffLongitude,
    String? dropoffAddress,
    String? distance,
    String? duration,
    String? estimatedFare,
    String? finalFare,
    String? paymentMethod,
    String? paymentStatus,
    String? status,
    String? isConfirm,
    String? tripCode,
    String? otp,
    String? baseFare,
    String? distanceFare,
    String? timeFare,
    String? waitingCharge,
    String? cancellationCharge,
    String? nightCharge,
    String? surgeMultiplier,
    String? surgeAmount,
    String? subtotal,
    String? taxRate,
    String? taxAmount,
    String? totalAmount,
    String? createdAt,
    String? updatedAt,
  }) => BookingModel(
    id: id ?? this.id,
    bookingCode: bookingCode ?? this.bookingCode,
    userId: userId ?? this.userId,
    driverId: driverId ?? this.driverId,
    cityId: cityId ?? this.cityId,
    rideTypeId: rideTypeId ?? this.rideTypeId,
    pickupZoneId: pickupZoneId ?? this.pickupZoneId,
    dropoffZoneId: dropoffZoneId ?? this.dropoffZoneId,
    pickupLatitude: pickupLatitude ?? this.pickupLatitude,
    pickupLongitude: pickupLongitude ?? this.pickupLongitude,
    pickupAddress: pickupAddress ?? this.pickupAddress,
    dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
    dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
    dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    distance: distance ?? this.distance,
    duration: duration ?? this.duration,
    estimatedFare: estimatedFare ?? this.estimatedFare,
    finalFare: finalFare ?? this.finalFare,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    status: status ?? this.status,
    isConfirm: isConfirm ?? this.isConfirm,
    tripCode: tripCode ?? this.tripCode,
    otp: otp ?? this.otp,
    baseFare: baseFare ?? this.baseFare,
    distanceFare: distanceFare ?? this.distanceFare,
    timeFare: timeFare ?? this.timeFare,
    waitingCharge: waitingCharge ?? this.waitingCharge,
    cancellationCharge: cancellationCharge ?? this.cancellationCharge,
    nightCharge: nightCharge ?? this.nightCharge,
    surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
    surgeAmount: surgeAmount ?? this.surgeAmount,
    subtotal: subtotal ?? this.subtotal,
    taxRate: taxRate ?? this.taxRate,
    taxAmount: taxAmount ?? this.taxAmount,
    totalAmount: totalAmount ?? this.totalAmount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id: json["id"],
    bookingCode: json["booking_code"],
    userId: json["user_id"],
    driverId: json["driver_id"],
    cityId: json["city_id"],
    rideTypeId: json["ride_type_id"],
    pickupZoneId: json["pickup_zone_id"],
    dropoffZoneId: json["dropoff_zone_id"],
    pickupLatitude: json["pickup_latitude"],
    pickupLongitude: json["pickup_longitude"],
    pickupAddress: json["pickup_address"],
    dropoffLatitude: json["dropoff_latitude"],
    dropoffLongitude: json["dropoff_longitude"],
    dropoffAddress: json["dropoff_address"],
    distance: json["distance"],
    duration: json["duration"],
    estimatedFare: json["estimated_fare"],
    finalFare: json["final_fare"],
    paymentMethod: json["payment_method"],
    paymentStatus: json["payment_status"],
    status: json["status"],
    isConfirm: json["is_confirm"],
    tripCode: json["trip_code"],
    otp: json["otp"],
    baseFare: json["base_fare"],
    distanceFare: json["distance_fare"],
    timeFare: json["time_fare"],
    waitingCharge: json["waiting_charge"],
    cancellationCharge: json["cancellation_charge"],
    nightCharge: json["night_charge"],
    surgeMultiplier: json["surge_multiplier"],
    surgeAmount: json["surge_amount"],
    subtotal: json["subtotal"],
    taxRate: json["tax_rate"],
    taxAmount: json["tax_amount"],
    totalAmount: json["total_amount"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_code": bookingCode,
    "user_id": userId,
    "driver_id": driverId,
    "city_id": cityId,
    "ride_type_id": rideTypeId,
    "pickup_zone_id": pickupZoneId,
    "dropoff_zone_id": dropoffZoneId,
    "pickup_latitude": pickupLatitude,
    "pickup_longitude": pickupLongitude,
    "pickup_address": pickupAddress,
    "dropoff_latitude": dropoffLatitude,
    "dropoff_longitude": dropoffLongitude,
    "dropoff_address": dropoffAddress,
    "distance": distance,
    "duration": duration,
    "estimated_fare": estimatedFare,
    "final_fare": finalFare,
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
    "status": status,
    "is_confirm": isConfirm,
    "trip_code": tripCode,
    "otp": otp,
    "base_fare": baseFare,
    "distance_fare": distanceFare,
    "time_fare": timeFare,
    "waiting_charge": waitingCharge,
    "cancellation_charge": cancellationCharge,
    "night_charge": nightCharge,
    "surge_multiplier": surgeMultiplier,
    "surge_amount": surgeAmount,
    "subtotal": subtotal,
    "tax_rate": taxRate,
    "tax_amount": taxAmount,
    "total_amount": totalAmount,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class DetectedCity {
  String? id;
  String? name;
  String? distanceFromCenter;

  DetectedCity({this.id, this.name, this.distanceFromCenter});

  DetectedCity copyWith({
    String? id,
    String? name,
    String? distanceFromCenter,
  }) => DetectedCity(
    id: id ?? this.id,
    name: name ?? this.name,
    distanceFromCenter: distanceFromCenter ?? this.distanceFromCenter,
  );

  factory DetectedCity.fromJson(Map<String, dynamic> json) => DetectedCity(
    id: json["id"],
    name: json["name"],
    distanceFromCenter: json["distance_from_center"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "distance_from_center": distanceFromCenter,
  };
}

class RideOption {
  String? type;
  String? description;
  String? icon;
  String? capacity;
  String? estimatedTime;
  String? dropoffTime;
  String? currentPrice;
  String? originalPrice;
  String? hasDiscount;
  String? discountPercentage;
  String? rideTypeId;
  String? surgeMultiplier;
  String? isAvailable;
  String? driverCount;
  String? nearestDriverDistance;
  String? averageDriverDistance;
  String? etaConfidence;
  String? estimatedDropoffTime;

  RideOption({
    this.type,
    this.description,
    this.icon,
    this.capacity,
    this.estimatedTime,
    this.dropoffTime,
    this.currentPrice,
    this.originalPrice,
    this.hasDiscount,
    this.discountPercentage,
    this.rideTypeId,
    this.surgeMultiplier,
    this.isAvailable,
    this.driverCount,
    this.nearestDriverDistance,
    this.averageDriverDistance,
    this.etaConfidence,
    this.estimatedDropoffTime,
  });

  RideOption copyWith({
    String? type,
    String? description,
    String? icon,
    String? capacity,
    String? estimatedTime,
    String? dropoffTime,
    String? currentPrice,
    String? originalPrice,
    String? hasDiscount,
    String? discountPercentage,
    String? rideTypeId,
    String? surgeMultiplier,
    String? isAvailable,
    String? driverCount,
    String? nearestDriverDistance,
    String? averageDriverDistance,
    String? etaConfidence,
    String? estimatedDropoffTime,
  }) => RideOption(
    type: type ?? this.type,
    description: description ?? this.description,
    icon: icon ?? this.icon,
    capacity: capacity ?? this.capacity,
    estimatedTime: estimatedTime ?? this.estimatedTime,
    dropoffTime: dropoffTime ?? this.dropoffTime,
    currentPrice: currentPrice ?? this.currentPrice,
    originalPrice: originalPrice ?? this.originalPrice,
    hasDiscount: hasDiscount ?? this.hasDiscount,
    discountPercentage: discountPercentage ?? this.discountPercentage,
    rideTypeId: rideTypeId ?? this.rideTypeId,
    surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
    isAvailable: isAvailable ?? this.isAvailable,
    driverCount: driverCount ?? this.driverCount,
    nearestDriverDistance: nearestDriverDistance ?? this.nearestDriverDistance,
    averageDriverDistance: averageDriverDistance ?? this.averageDriverDistance,
    etaConfidence: etaConfidence ?? this.etaConfidence,
    estimatedDropoffTime: estimatedDropoffTime ?? this.estimatedDropoffTime,
  );

  factory RideOption.fromJson(Map<String, dynamic> json) => RideOption(
    type: json["type"],
    description: json["description"],
    icon: json["icon"],
    capacity: json["capacity"],
    estimatedTime: json["estimated_time"],
    dropoffTime: json["dropoff_time"],
    currentPrice: json["current_price"]?.toString(),
    originalPrice: json["original_price"]?.toString(),
    hasDiscount: json["has_discount"],
    discountPercentage: json["discount_percentage"],
    rideTypeId: json["ride_type_id"],
    surgeMultiplier: json["surge_multiplier"],
    isAvailable: json["is_available"],
    driverCount: json["driver_count"],
    nearestDriverDistance: json["nearest_driver_distance"],
    averageDriverDistance: json["average_driver_distance"],
    etaConfidence: json["eta_confidence"],
    estimatedDropoffTime: json["estimated_dropoff_time"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "description": description,
    "icon": icon,
    "capacity": capacity,
    "estimated_time": estimatedTime,
    "dropoff_time": dropoffTime,
    "current_price": currentPrice,
    "original_price": originalPrice,
    "has_discount": hasDiscount,
    "discount_percentage": discountPercentage,
    "ride_type_id": rideTypeId,
    "surge_multiplier": surgeMultiplier,
    "is_available": isAvailable,
    "driver_count": driverCount,
    "nearest_driver_distance": nearestDriverDistance,
    "average_driver_distance": averageDriverDistance,
    "eta_confidence": etaConfidence,
    "estimated_dropoff_time": estimatedDropoffTime,
  };
}

class RideTypeEstimate {
  FareBreakdown? fareBreakdown;
  String? distance;
  String? duration;
  String? estimatedEta;
  String? estimateArrivedTime;
  EtaBreakdown? etaBreakdown;
  MatchedDriver? matchedDriver;

  RideTypeEstimate({
    this.fareBreakdown,
    this.distance,
    this.duration,
    this.estimatedEta,
    this.estimateArrivedTime,
    this.etaBreakdown,
    this.matchedDriver,
  });

  RideTypeEstimate copyWith({
    FareBreakdown? fareBreakdown,
    String? distance,
    String? duration,
    String? estimatedEta,
    String? estimateArrivedTime,
    EtaBreakdown? etaBreakdown,
    MatchedDriver? matchedDriver,
  }) => RideTypeEstimate(
    fareBreakdown: fareBreakdown ?? this.fareBreakdown,
    distance: distance ?? this.distance,
    duration: duration ?? this.duration,
    estimatedEta: estimatedEta ?? this.estimatedEta,
    estimateArrivedTime: estimateArrivedTime ?? this.estimateArrivedTime,
    etaBreakdown: etaBreakdown ?? this.etaBreakdown,
    matchedDriver: matchedDriver ?? this.matchedDriver,
  );

  factory RideTypeEstimate.fromJson(Map<String, dynamic> json) =>
      RideTypeEstimate(
        fareBreakdown: json["fare_breakdown"] == null
            ? null
            : FareBreakdown.fromJson(json["fare_breakdown"]),
        distance: json["distance"]?.toString(),
        duration: json["duration"]?.toString(),
        estimatedEta: json["estimated_eta"]?.toString(),
        estimateArrivedTime: json["estimate_arrived_time"]?.toString(),
        etaBreakdown: json["eta_breakdown"] == null
            ? null
            : EtaBreakdown.fromJson(json["eta_breakdown"]),
        matchedDriver: json["matched_driver"] == null
            ? null
            : MatchedDriver.fromJson(json["matched_driver"]),
      );

  Map<String, dynamic> toJson() => {
    "fare_breakdown": fareBreakdown?.toJson(),
    "distance": distance,
    "duration": duration,
    "estimated_eta": estimatedEta,
    "estimate_arrived_time": estimateArrivedTime,
    "eta_breakdown": etaBreakdown?.toJson(),
    "matched_driver": matchedDriver?.toJson(),
  };
}

class EtaBreakdown {
  String? baseMinutes;
  String? distanceToPickup;
  String? trafficFactor;
  String? timeOfDayFactor;
  String? vehicleTypeFactor;
  String? totalMinutes;
  String? matchedDriver;
  String? bufferMinutes;

  EtaBreakdown({
    this.baseMinutes,
    this.distanceToPickup,
    this.trafficFactor,
    this.timeOfDayFactor,
    this.vehicleTypeFactor,
    this.totalMinutes,
    this.matchedDriver,
    this.bufferMinutes,
  });

  EtaBreakdown copyWith({
    String? baseMinutes,
    String? distanceToPickup,
    String? trafficFactor,
    String? timeOfDayFactor,
    String? vehicleTypeFactor,
    String? totalMinutes,
    String? matchedDriver,
    String? bufferMinutes,
  }) => EtaBreakdown(
    baseMinutes: baseMinutes ?? this.baseMinutes,
    distanceToPickup: distanceToPickup ?? this.distanceToPickup,
    trafficFactor: trafficFactor ?? this.trafficFactor,
    timeOfDayFactor: timeOfDayFactor ?? this.timeOfDayFactor,
    vehicleTypeFactor: vehicleTypeFactor ?? this.vehicleTypeFactor,
    totalMinutes: totalMinutes ?? this.totalMinutes,
    matchedDriver: matchedDriver ?? this.matchedDriver,
    bufferMinutes: bufferMinutes ?? this.bufferMinutes,
  );

  factory EtaBreakdown.fromJson(Map<String, dynamic> json) => EtaBreakdown(
    baseMinutes: json["base_minutes"],
    distanceToPickup: json["distance_to_pickup"],
    trafficFactor: json["traffic_factor"],
    timeOfDayFactor: json["time_of_day_factor"],
    vehicleTypeFactor: json["vehicle_type_factor"],
    totalMinutes: json["total_minutes"],
    matchedDriver: json["matched_driver"],
    bufferMinutes: json["buffer_minutes"],
  );

  Map<String, dynamic> toJson() => {
    "base_minutes": baseMinutes,
    "distance_to_pickup": distanceToPickup,
    "traffic_factor": trafficFactor,
    "time_of_day_factor": timeOfDayFactor,
    "vehicle_type_factor": vehicleTypeFactor,
    "total_minutes": totalMinutes,
    "matched_driver": matchedDriver,
    "buffer_minutes": bufferMinutes,
  };
}

class FareBreakdown {
  String? baseFare;
  String? distanceFare;
  String? timeFare;
  String? subtotal;
  String? surgeMultiplier;
  String? surgeAmount;
  String? nightChargesMultiplier;
  String? nightChargesAmount;
  String? bookingFee;
  String? taxRate;
  String? taxAmount;
  String? total;
  String? currency;

  FareBreakdown({
    this.baseFare,
    this.distanceFare,
    this.timeFare,
    this.subtotal,
    this.surgeMultiplier,
    this.surgeAmount,
    this.nightChargesMultiplier,
    this.nightChargesAmount,
    this.bookingFee,
    this.taxRate,
    this.taxAmount,
    this.total,
    this.currency,
  });

  FareBreakdown copyWith({
    String? baseFare,
    String? distanceFare,
    String? timeFare,
    String? subtotal,
    String? surgeMultiplier,
    String? surgeAmount,
    String? nightChargesMultiplier,
    String? nightChargesAmount,
    String? bookingFee,
    String? taxRate,
    String? taxAmount,
    String? total,
    String? currency,
  }) => FareBreakdown(
    baseFare: baseFare ?? this.baseFare,
    distanceFare: distanceFare ?? this.distanceFare,
    timeFare: timeFare ?? this.timeFare,
    subtotal: subtotal ?? this.subtotal,
    surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
    surgeAmount: surgeAmount ?? this.surgeAmount,
    nightChargesMultiplier:
        nightChargesMultiplier ?? this.nightChargesMultiplier,
    nightChargesAmount: nightChargesAmount ?? this.nightChargesAmount,
    bookingFee: bookingFee ?? this.bookingFee,
    taxRate: taxRate ?? this.taxRate,
    taxAmount: taxAmount ?? this.taxAmount,
    total: total ?? this.total,
    currency: currency ?? this.currency,
  );

  factory FareBreakdown.fromJson(Map<String, dynamic> json) => FareBreakdown(
    baseFare: json["base_fare"],
    distanceFare: json["distance_fare"],
    timeFare: json["time_fare"],
    subtotal: json["subtotal"],
    surgeMultiplier: json["surge_multiplier"],
    surgeAmount: json["surge_amount"],
    nightChargesMultiplier: json["night_charges_multiplier"],
    nightChargesAmount: json["night_charges_amount"],
    bookingFee: json["booking_fee"],
    taxRate: json["tax_rate"],
    taxAmount: json["tax_amount"],
    total: json["total"],
    currency: json["currency"],
  );

  Map<String, dynamic> toJson() => {
    "base_fare": baseFare,
    "distance_fare": distanceFare,
    "time_fare": timeFare,
    "subtotal": subtotal,
    "surge_multiplier": surgeMultiplier,
    "surge_amount": surgeAmount,
    "night_charges_multiplier": nightChargesMultiplier,
    "night_charges_amount": nightChargesAmount,
    "booking_fee": bookingFee,
    "tax_rate": taxRate,
    "tax_amount": taxAmount,
    "total": total,
    "currency": currency,
  };
}

class MatchedDriver {
  String? id;
  String? name;
  String? phone;
  String? vehicle;
  String? distanceToPickup;
  String? driverLatitude;
  String? driverLongitude;

  MatchedDriver({
    this.id,
    this.name,
    this.phone,
    this.vehicle,
    this.distanceToPickup,
    this.driverLatitude,
    this.driverLongitude,
  });

  MatchedDriver copyWith({
    String? id,
    String? name,
    String? phone,
    String? vehicle,
    String? distanceToPickup,
    String? driverLatitude,
    String? driverLongitude,
  }) => MatchedDriver(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    vehicle: vehicle ?? this.vehicle,
    distanceToPickup: distanceToPickup ?? this.distanceToPickup,
    driverLatitude: driverLatitude ?? this.driverLatitude,
    driverLongitude: driverLongitude ?? this.driverLongitude,
  );

  factory MatchedDriver.fromJson(Map<String, dynamic> json) => MatchedDriver(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    vehicle: json["vehicle"],
    distanceToPickup: json["distance_to_pickup"],
    driverLatitude: json["driver_latitude"],
    driverLongitude: json["driver_longitude"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "vehicle": vehicle,
    "distance_to_pickup": distanceToPickup,
    "driver_latitude": driverLatitude,
    "driver_longitude": driverLongitude,
  };
}
