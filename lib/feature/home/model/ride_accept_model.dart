class RideBookingModel {
  bool? success;
  String? message;
  Booking? booking;

  RideBookingModel({this.success, this.message, this.booking});

  RideBookingModel copyWith({
    bool? success,
    String? message,
    Booking? booking,
  }) => RideBookingModel(
    success: success ?? this.success,
    message: message ?? this.message,
    booking: booking ?? this.booking,
  );

  factory RideBookingModel.fromJson(Map<String, dynamic> json) =>
      RideBookingModel(
        success: json["success"],
        message: json["message"],
        booking: json["booking"] == null
            ? null
            : Booking.fromJson(json["booking"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "booking": booking?.toJson(),
  };
}

class Booking {
  String? id;
  String? bookingCode;
  String? userId;
  String? driverId;
  String? cityId;
  String? rideTypeId;
  String? pickupZoneId;
  String? dropoffZoneId;
  String? pickupLocation;
  String? pickupLatitude;
  String? pickupLongitude;
  String? dropoffLocation;
  String? dropoffLatitude;
  String? dropoffLongitude;
  String? pickupAddress;
  String? dropoffAddress;
  String? status;
  String? isConform;
  String? isConfirm;
  String? paymentMethod;
  String? paymentStatus;
  String? estimatedDistance;
  String? estimatedDuration;
  String? distance;
  String? duration;
  String? actualDistance;
  String? actualDuration;
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
  String? estimatedFare;
  String? finalFare;
  String? adminCommissionRate;
  String? adminCommission;
  String? driverAmount;
  String? promoCode;
  String? discountAmount;
  String? walletAmount;
  String? onlinePaidAmount;
  String? cashAmount;
  String? scheduledAt;
  String? acceptedAt;
  String? driverEtaMinutes;
  String? driverExpectedArrivalAt;
  String? startedAt;
  String? completedAt;
  String? cancelledAt;
  String? cancellationReason;
  String? cancelledByType;
  String? cancelledById;
  String? userRating;
  String? userReview;
  String? driverRating;
  String? driverReview;
  String? waitingTime;
  String? otp;
  String? tripCode;
  String? metaData;
  String? createdAt;
  String? updatedAt;
  String? autoArrivingScheduledAt;
  String? deletedAt;
  String? walletTransactionId;
  String? promoUsageId;
  User? user;
  RideType? rideType;

  Booking({
    this.id,
    this.bookingCode,
    this.userId,
    this.driverId,
    this.cityId,
    this.rideTypeId,
    this.pickupZoneId,
    this.dropoffZoneId,
    this.pickupLocation,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLocation,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.pickupAddress,
    this.dropoffAddress,
    this.status,
    this.isConform,
    this.isConfirm,
    this.paymentMethod,
    this.paymentStatus,
    this.estimatedDistance,
    this.estimatedDuration,
    this.distance,
    this.duration,
    this.actualDistance,
    this.actualDuration,
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
    this.estimatedFare,
    this.finalFare,
    this.adminCommissionRate,
    this.adminCommission,
    this.driverAmount,
    this.promoCode,
    this.discountAmount,
    this.walletAmount,
    this.onlinePaidAmount,
    this.cashAmount,
    this.scheduledAt,
    this.acceptedAt,
    this.driverEtaMinutes,
    this.driverExpectedArrivalAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.cancelledByType,
    this.cancelledById,
    this.userRating,
    this.userReview,
    this.driverRating,
    this.driverReview,
    this.waitingTime,
    this.otp,
    this.tripCode,
    this.metaData,
    this.createdAt,
    this.updatedAt,
    this.autoArrivingScheduledAt,
    this.deletedAt,
    this.walletTransactionId,
    this.promoUsageId,
    this.user,
    this.rideType,
  });

  Booking copyWith({
    String? id,
    String? bookingCode,
    String? userId,
    String? driverId,
    String? cityId,
    String? rideTypeId,
    String? pickupZoneId,
    String? dropoffZoneId,
    String? pickupLocation,
    String? pickupLatitude,
    String? pickupLongitude,
    String? dropoffLocation,
    String? dropoffLatitude,
    String? dropoffLongitude,
    String? pickupAddress,
    String? dropoffAddress,
    String? status,
    String? isConform,
    String? isConfirm,
    String? paymentMethod,
    String? paymentStatus,
    String? estimatedDistance,
    String? estimatedDuration,
    String? distance,
    String? duration,
    String? actualDistance,
    String? actualDuration,
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
    String? estimatedFare,
    String? finalFare,
    String? adminCommissionRate,
    String? adminCommission,
    String? driverAmount,
    String? promoCode,
    String? discountAmount,
    String? walletAmount,
    String? onlinePaidAmount,
    String? cashAmount,
    String? scheduledAt,
    String? acceptedAt,
    String? driverEtaMinutes,
    String? driverExpectedArrivalAt,
    String? startedAt,
    String? completedAt,
    String? cancelledAt,
    String? cancellationReason,
    String? cancelledByType,
    String? cancelledById,
    String? userRating,
    String? userReview,
    String? driverRating,
    String? driverReview,
    String? waitingTime,
    String? otp,
    String? tripCode,
    String? metaData,
    String? createdAt,
    String? updatedAt,
    String? autoArrivingScheduledAt,
    String? deletedAt,
    String? walletTransactionId,
    String? promoUsageId,
    User? user,
    RideType? rideType,
  }) => Booking(
    id: id ?? this.id,
    bookingCode: bookingCode ?? this.bookingCode,
    userId: userId ?? this.userId,
    driverId: driverId ?? this.driverId,
    cityId: cityId ?? this.cityId,
    rideTypeId: rideTypeId ?? this.rideTypeId,
    pickupZoneId: pickupZoneId ?? this.pickupZoneId,
    dropoffZoneId: dropoffZoneId ?? this.dropoffZoneId,
    pickupLocation: pickupLocation ?? this.pickupLocation,
    pickupLatitude: pickupLatitude ?? this.pickupLatitude,
    pickupLongitude: pickupLongitude ?? this.pickupLongitude,
    dropoffLocation: dropoffLocation ?? this.dropoffLocation,
    dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
    dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
    pickupAddress: pickupAddress ?? this.pickupAddress,
    dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    status: status ?? this.status,
    isConform: isConform ?? this.isConform,
    isConfirm: isConfirm ?? this.isConfirm,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    estimatedDistance: estimatedDistance ?? this.estimatedDistance,
    estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    distance: distance ?? this.distance,
    duration: duration ?? this.duration,
    actualDistance: actualDistance ?? this.actualDistance,
    actualDuration: actualDuration ?? this.actualDuration,
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
    estimatedFare: estimatedFare ?? this.estimatedFare,
    finalFare: finalFare ?? this.finalFare,
    adminCommissionRate: adminCommissionRate ?? this.adminCommissionRate,
    adminCommission: adminCommission ?? this.adminCommission,
    driverAmount: driverAmount ?? this.driverAmount,
    promoCode: promoCode ?? this.promoCode,
    discountAmount: discountAmount ?? this.discountAmount,
    walletAmount: walletAmount ?? this.walletAmount,
    onlinePaidAmount: onlinePaidAmount ?? this.onlinePaidAmount,
    cashAmount: cashAmount ?? this.cashAmount,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    acceptedAt: acceptedAt ?? this.acceptedAt,
    driverEtaMinutes: driverEtaMinutes ?? this.driverEtaMinutes,
    driverExpectedArrivalAt:
        driverExpectedArrivalAt ?? this.driverExpectedArrivalAt,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    cancelledAt: cancelledAt ?? this.cancelledAt,
    cancellationReason: cancellationReason ?? this.cancellationReason,
    cancelledByType: cancelledByType ?? this.cancelledByType,
    cancelledById: cancelledById ?? this.cancelledById,
    userRating: userRating ?? this.userRating,
    userReview: userReview ?? this.userReview,
    driverRating: driverRating ?? this.driverRating,
    driverReview: driverReview ?? this.driverReview,
    waitingTime: waitingTime ?? this.waitingTime,
    otp: otp ?? this.otp,
    tripCode: tripCode ?? this.tripCode,
    metaData: metaData ?? this.metaData,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    autoArrivingScheduledAt:
        autoArrivingScheduledAt ?? this.autoArrivingScheduledAt,
    deletedAt: deletedAt ?? this.deletedAt,
    walletTransactionId: walletTransactionId ?? this.walletTransactionId,
    promoUsageId: promoUsageId ?? this.promoUsageId,
    user: user ?? this.user,
    rideType: rideType ?? this.rideType,
  );

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json["id"],
    bookingCode: json["booking_code"],
    userId: json["user_id"],
    driverId: json["driver_id"],
    cityId: json["city_id"],
    rideTypeId: json["ride_type_id"],
    pickupZoneId: json["pickup_zone_id"],
    dropoffZoneId: json["dropoff_zone_id"],
    pickupLocation: json["pickup_location"],
    pickupLatitude: json["pickup_latitude"],
    pickupLongitude: json["pickup_longitude"],
    dropoffLocation: json["dropoff_location"],
    dropoffLatitude: json["dropoff_latitude"],
    dropoffLongitude: json["dropoff_longitude"],
    pickupAddress: json["pickup_address"],
    dropoffAddress: json["dropoff_address"],
    status: json["status"],
    isConform: json["is_conform"],
    isConfirm: json["is_confirm"],
    paymentMethod: json["payment_method"],
    paymentStatus: json["payment_status"],
    estimatedDistance: json["estimated_distance"],
    estimatedDuration: json["estimated_duration"],
    distance: json["distance"],
    duration: json["duration"],
    actualDistance: json["actual_distance"],
    actualDuration: json["actual_duration"],
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
    estimatedFare: json["estimated_fare"],
    finalFare: json["final_fare"],
    adminCommissionRate: json["admin_commission_rate"],
    adminCommission: json["admin_commission"],
    driverAmount: json["driver_amount"],
    promoCode: json["promo_code"],
    discountAmount: json["discount_amount"],
    walletAmount: json["wallet_amount"],
    onlinePaidAmount: json["online_paid_amount"],
    cashAmount: json["cash_amount"],
    scheduledAt: json["scheduled_at"],
    acceptedAt: json["accepted_at"],
    driverEtaMinutes: json["driver_eta_minutes"]?.toString(),
    driverExpectedArrivalAt: json["driver_expected_arrival_at"]?.toString(),
    startedAt: json["started_at"],
    completedAt: json["completed_at"],
    cancelledAt: json["cancelled_at"],
    cancellationReason: json["cancellation_reason"],
    cancelledByType: json["cancelled_by_type"],
    cancelledById: json["cancelled_by_id"],
    userRating: json["user_rating"],
    userReview: json["user_review"],
    driverRating: json["driver_rating"],
    driverReview: json["driver_review"],
    waitingTime: json["waiting_time"],
    otp: json["otp"],
    tripCode: json["trip_code"],
    metaData: json["meta_data"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    autoArrivingScheduledAt: json["auto_arriving_scheduled_at"],
    deletedAt: json["deleted_at"],
    walletTransactionId: json["wallet_transaction_id"],
    promoUsageId: json["promo_usage_id"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    rideType: json["ride_type"] == null
        ? null
        : RideType.fromJson(json["ride_type"]),
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
    "pickup_location": pickupLocation,
    "pickup_latitude": pickupLatitude,
    "pickup_longitude": pickupLongitude,
    "dropoff_location": dropoffLocation,
    "dropoff_latitude": dropoffLatitude,
    "dropoff_longitude": dropoffLongitude,
    "pickup_address": pickupAddress,
    "dropoff_address": dropoffAddress,
    "status": status,
    "is_conform": isConform,
    "is_confirm": isConfirm,
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
    "estimated_distance": estimatedDistance,
    "estimated_duration": estimatedDuration,
    "distance": distance,
    "duration": duration,
    "actual_distance": actualDistance,
    "actual_duration": actualDuration,
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
    "estimated_fare": estimatedFare,
    "final_fare": finalFare,
    "admin_commission_rate": adminCommissionRate,
    "admin_commission": adminCommission,
    "driver_amount": driverAmount,
    "promo_code": promoCode,
    "discount_amount": discountAmount,
    "wallet_amount": walletAmount,
    "online_paid_amount": onlinePaidAmount,
    "cash_amount": cashAmount,
    "scheduled_at": scheduledAt,
    "accepted_at": acceptedAt,
    "driver_eta_minutes": driverEtaMinutes,
    "driver_expected_arrival_at": driverExpectedArrivalAt,
    "started_at": startedAt,
    "completed_at": completedAt,
    "cancelled_at": cancelledAt,
    "cancellation_reason": cancellationReason,
    "cancelled_by_type": cancelledByType,
    "cancelled_by_id": cancelledById,
    "user_rating": userRating,
    "user_review": userReview,
    "driver_rating": driverRating,
    "driver_review": driverReview,
    "waiting_time": waitingTime,
    "otp": otp,
    "trip_code": tripCode,
    "meta_data": metaData,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "auto_arriving_scheduled_at": autoArrivingScheduledAt,
    "deleted_at": deletedAt,
    "wallet_transaction_id": walletTransactionId,
    "promo_usage_id": promoUsageId,
    "user": user?.toJson(),
    "ride_type": rideType?.toJson(),
  };
}

class RideType {
  String? id;
  String? name;
  String? code;
  String? description;
  String? icon;
  String? capacity;
  String? status;
  String? order;
  String? baseDistance;
  String? basePrice;
  String? pricePerKm;
  String? pricePerMinute;
  String? minimumFare;
  String? cancellationCharge;
  String? waitingChargePerMinute;
  String? waitingTimeLimit;
  String? commissionRate;
  List<dynamic>? driverRequirements;
  List<dynamic>? vehicleRequirements;
  String? metaData;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  RideType({
    this.id,
    this.name,
    this.code,
    this.description,
    this.icon,
    this.capacity,
    this.status,
    this.order,
    this.baseDistance,
    this.basePrice,
    this.pricePerKm,
    this.pricePerMinute,
    this.minimumFare,
    this.cancellationCharge,
    this.waitingChargePerMinute,
    this.waitingTimeLimit,
    this.commissionRate,
    this.driverRequirements,
    this.vehicleRequirements,
    this.metaData,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  RideType copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? icon,
    String? capacity,
    String? status,
    String? order,
    String? baseDistance,
    String? basePrice,
    String? pricePerKm,
    String? pricePerMinute,
    String? minimumFare,
    String? cancellationCharge,
    String? waitingChargePerMinute,
    String? waitingTimeLimit,
    String? commissionRate,
    List<dynamic>? driverRequirements,
    List<dynamic>? vehicleRequirements,
    String? metaData,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) => RideType(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code ?? this.code,
    description: description ?? this.description,
    icon: icon ?? this.icon,
    capacity: capacity ?? this.capacity,
    status: status ?? this.status,
    order: order ?? this.order,
    baseDistance: baseDistance ?? this.baseDistance,
    basePrice: basePrice ?? this.basePrice,
    pricePerKm: pricePerKm ?? this.pricePerKm,
    pricePerMinute: pricePerMinute ?? this.pricePerMinute,
    minimumFare: minimumFare ?? this.minimumFare,
    cancellationCharge: cancellationCharge ?? this.cancellationCharge,
    waitingChargePerMinute:
        waitingChargePerMinute ?? this.waitingChargePerMinute,
    waitingTimeLimit: waitingTimeLimit ?? this.waitingTimeLimit,
    commissionRate: commissionRate ?? this.commissionRate,
    driverRequirements: driverRequirements ?? this.driverRequirements,
    vehicleRequirements: vehicleRequirements ?? this.vehicleRequirements,
    metaData: metaData ?? this.metaData,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );

  factory RideType.fromJson(Map<String, dynamic> json) => RideType(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    description: json["description"],
    icon: json["icon"],
    capacity: json["capacity"],
    status: json["status"],
    order: json["order"],
    baseDistance: json["base_distance"],
    basePrice: json["base_price"],
    pricePerKm: json["price_per_km"],
    pricePerMinute: json["price_per_minute"],
    minimumFare: json["minimum_fare"],
    cancellationCharge: json["cancellation_charge"],
    waitingChargePerMinute: json["waiting_charge_per_minute"],
    waitingTimeLimit: json["waiting_time_limit"],
    commissionRate: json["commission_rate"],
    driverRequirements: json["driver_requirements"] == null
        ? []
        : List<dynamic>.from(json["driver_requirements"]!.map((x) => x)),
    vehicleRequirements: json["vehicle_requirements"] == null
        ? []
        : List<dynamic>.from(json["vehicle_requirements"]!.map((x) => x)),
    metaData: json["meta_data"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "description": description,
    "icon": icon,
    "capacity": capacity,
    "status": status,
    "order": order,
    "base_distance": baseDistance,
    "base_price": basePrice,
    "price_per_km": pricePerKm,
    "price_per_minute": pricePerMinute,
    "minimum_fare": minimumFare,
    "cancellation_charge": cancellationCharge,
    "waiting_charge_per_minute": waitingChargePerMinute,
    "waiting_time_limit": waitingTimeLimit,
    "commission_rate": commissionRate,
    "driver_requirements": driverRequirements == null
        ? []
        : List<dynamic>.from(driverRequirements!.map((x) => x)),
    "vehicle_requirements": vehicleRequirements == null
        ? []
        : List<dynamic>.from(vehicleRequirements!.map((x) => x)),
    "meta_data": metaData,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
  };
}

class User {
  String? id;
  String? name;
  String? email;
  String? googleId;
  String? appleId;
  String? gender;
  String? phone;
  String? countryCode;
  String? dateOfBirth;
  String? passwordResetToken;
  String? passwordResetExpiresAt;
  String? roleId;
  String? profilePhoto;
  String? tokenExpiresAt;
  String? isOnline;
  String? isVerified;
  String? verifiedAt;
  String? lastLocationAt;
  String? lastLatitude;
  String? lastLongitude;
  String? selectLatitude;
  String? selectLongitude;
  String? emailVerifiedAt;
  String? phoneVerifiedAt;
  String? status;
  String? isRegister;
  String? step0;
  String? step1;
  String? step2;
  String? step3;
  String? referralCode;
  String? referredBy;
  String? metaData;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? currentBookingId;
  String? driverProfile;

  User({
    this.id,
    this.name,
    this.email,
    this.googleId,
    this.appleId,
    this.gender,
    this.phone,
    this.countryCode,
    this.dateOfBirth,
    this.passwordResetToken,
    this.passwordResetExpiresAt,
    this.roleId,
    this.profilePhoto,
    this.tokenExpiresAt,
    this.isOnline,
    this.isVerified,
    this.verifiedAt,
    this.lastLocationAt,
    this.lastLatitude,
    this.lastLongitude,
    this.selectLatitude,
    this.selectLongitude,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    this.status,
    this.isRegister,
    this.step0,
    this.step1,
    this.step2,
    this.step3,
    this.referralCode,
    this.referredBy,
    this.metaData,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.currentBookingId,
    this.driverProfile,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? googleId,
    String? appleId,
    String? gender,
    String? phone,
    String? countryCode,
    String? dateOfBirth,
    String? passwordResetToken,
    String? passwordResetExpiresAt,
    String? roleId,
    String? profilePhoto,
    String? tokenExpiresAt,
    String? isOnline,
    String? isVerified,
    String? verifiedAt,
    String? lastLocationAt,
    String? lastLatitude,
    String? lastLongitude,
    String? selectLatitude,
    String? selectLongitude,
    String? emailVerifiedAt,
    String? phoneVerifiedAt,
    String? status,
    String? isRegister,
    String? step0,
    String? step1,
    String? step2,
    String? step3,
    String? referralCode,
    String? referredBy,
    String? metaData,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    String? currentBookingId,
    String? driverProfile,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    googleId: googleId ?? this.googleId,
    appleId: appleId ?? this.appleId,
    gender: gender ?? this.gender,
    phone: phone ?? this.phone,
    countryCode: countryCode ?? this.countryCode,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    passwordResetToken: passwordResetToken ?? this.passwordResetToken,
    passwordResetExpiresAt:
        passwordResetExpiresAt ?? this.passwordResetExpiresAt,
    roleId: roleId ?? this.roleId,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
    isOnline: isOnline ?? this.isOnline,
    isVerified: isVerified ?? this.isVerified,
    verifiedAt: verifiedAt ?? this.verifiedAt,
    lastLocationAt: lastLocationAt ?? this.lastLocationAt,
    lastLatitude: lastLatitude ?? this.lastLatitude,
    lastLongitude: lastLongitude ?? this.lastLongitude,
    selectLatitude: selectLatitude ?? this.selectLatitude,
    selectLongitude: selectLongitude ?? this.selectLongitude,
    emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    phoneVerifiedAt: phoneVerifiedAt ?? this.phoneVerifiedAt,
    status: status ?? this.status,
    isRegister: isRegister ?? this.isRegister,
    step0: step0 ?? this.step0,
    step1: step1 ?? this.step1,
    step2: step2 ?? this.step2,
    step3: step3 ?? this.step3,
    referralCode: referralCode ?? this.referralCode,
    referredBy: referredBy ?? this.referredBy,
    metaData: metaData ?? this.metaData,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
    currentBookingId: currentBookingId ?? this.currentBookingId,
    driverProfile: driverProfile ?? this.driverProfile,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    googleId: json["google_id"],
    appleId: json["apple_id"],
    gender: json["gender"],
    phone: json["phone"],
    countryCode: json["country_code"],
    dateOfBirth: json["date_of_birth"],
    passwordResetToken: json["password_reset_token"],
    passwordResetExpiresAt: json["password_reset_expires_at"],
    roleId: json["role_id"],
    profilePhoto: json["profile_photo"],
    tokenExpiresAt: json["token_expires_at"],
    isOnline: json["is_online"],
    isVerified: json["is_verified"],
    verifiedAt: json["verified_at"],
    lastLocationAt: json["last_location_at"],
    lastLatitude: json["last_latitude"],
    lastLongitude: json["last_longitude"],
    selectLatitude: json["select_latitude"],
    selectLongitude: json["select_longitude"],
    emailVerifiedAt: json["email_verified_at"],
    phoneVerifiedAt: json["phone_verified_at"],
    status: json["status"],
    isRegister: json["is_register"],
    step0: json["step_0"],
    step1: json["step_1"],
    step2: json["step_2"],
    step3: json["step_3"],
    referralCode: json["referral_code"],
    referredBy: json["referred_by"],
    metaData: json["meta_data"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    currentBookingId: json["current_booking_id"],
    driverProfile: json["driver_profile"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "google_id": googleId,
    "apple_id": appleId,
    "gender": gender,
    "phone": phone,
    "country_code": countryCode,
    "date_of_birth": dateOfBirth,
    "password_reset_token": passwordResetToken,
    "password_reset_expires_at": passwordResetExpiresAt,
    "role_id": roleId,
    "profile_photo": profilePhoto,
    "token_expires_at": tokenExpiresAt,
    "is_online": isOnline,
    "is_verified": isVerified,
    "verified_at": verifiedAt,
    "last_location_at": lastLocationAt,
    "last_latitude": lastLatitude,
    "last_longitude": lastLongitude,
    "select_latitude": selectLatitude,
    "select_longitude": selectLongitude,
    "email_verified_at": emailVerifiedAt,
    "phone_verified_at": phoneVerifiedAt,
    "status": status,
    "is_register": isRegister,
    "step_0": step0,
    "step_1": step1,
    "step_2": step2,
    "step_3": step3,
    "referral_code": referralCode,
    "referred_by": referredBy,
    "meta_data": metaData,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "current_booking_id": currentBookingId,
    "driver_profile": driverProfile,
  };
}
