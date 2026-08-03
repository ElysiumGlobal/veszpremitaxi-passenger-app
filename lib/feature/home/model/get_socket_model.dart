import 'dart:convert';

String? _stringValue(dynamic value) {
  if (value == null) return null;
  final String text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int? _intValue(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

class NewRideModel {
  String? event;
  SocketDataModel? data;
  String? channel;

  NewRideModel({this.event, this.data, this.channel});

  NewRideModel copyWith({
    String? event,
    SocketDataModel? data,
    String? channel,
  }) => NewRideModel(
    event: event ?? this.event,
    data: data ?? this.data,
    channel: channel ?? this.channel,
  );

  factory NewRideModel.fromJson(Map<String, dynamic> json) => NewRideModel(
    event: json["event"],
    data: json["data"] == null
        ? null
        : SocketDataModel.fromJson(jsonDecode(json["data"])),
    channel: json["channel"],
  );

  Map<String, dynamic> toJson() => {
    "event": event,
    "data": data?.toJson(),
    "channel": channel,
  };
}

class SocketDataModel {
  bool? success;
  String? type;
  String? message;
  String? bookingId;
  Passenger? passenger;
  DataTripDetails? tripDetails;
  int? acceptanceTimer;
  Booking? booking;
  Fare? fare;
  Invoice? invoice;
  DataCustomer? customer;
  DataDriver? driver;
  Dropoff? pickup;
  Dropoff? dropoff;
  String? driverAuthToken;
  String? eventType;
  String? status;
  List<dynamic>? data;
  String? timestamp;
  int? driverEtaMinutes;
  String? driverExpectedArrivalAt;

  SocketDataModel({
    this.success,
    this.type,
    this.message,
    this.bookingId,
    this.passenger,
    this.tripDetails,
    this.acceptanceTimer,
    this.booking,
    this.fare,
    this.invoice,
    this.customer,
    this.driver,
    this.pickup,
    this.dropoff,
    this.driverAuthToken,
    this.eventType,
    this.status,
    this.data,
    this.timestamp,
    this.driverEtaMinutes,
    this.driverExpectedArrivalAt,
  });

  SocketDataModel copyWith({
    bool? success,
    String? type,
    String? message,
    String? bookingId,
    Passenger? passenger,
    DataTripDetails? tripDetails,
    int? acceptanceTimer,
    Booking? booking,
    Fare? fare,
    Invoice? invoice,
    DataCustomer? customer,
    DataDriver? driver,
    Dropoff? pickup,
    Dropoff? dropoff,
    String? driverAuthToken,
    String? eventType,
    String? status,
    List<dynamic>? data,
    String? timestamp,
    int? driverEtaMinutes,
    String? driverExpectedArrivalAt,
  }) => SocketDataModel(
    success: success ?? this.success,
    type: type ?? this.type,
    message: message ?? this.message,
    bookingId: bookingId ?? this.bookingId,
    passenger: passenger ?? this.passenger,
    tripDetails: tripDetails ?? this.tripDetails,
    acceptanceTimer: acceptanceTimer ?? this.acceptanceTimer,
    booking: booking ?? this.booking,
    fare: fare ?? this.fare,
    invoice: invoice ?? this.invoice,
    customer: customer ?? this.customer,
    driver: driver ?? this.driver,
    pickup: pickup ?? this.pickup,
    dropoff: dropoff ?? this.dropoff,
    driverAuthToken: driverAuthToken ?? this.driverAuthToken,
    eventType: eventType ?? this.eventType,
    status: status ?? this.status,
    data: data ?? this.data,
    timestamp: timestamp ?? this.timestamp,
    driverEtaMinutes: driverEtaMinutes ?? this.driverEtaMinutes,
    driverExpectedArrivalAt:
        driverExpectedArrivalAt ?? this.driverExpectedArrivalAt,
  );

  factory SocketDataModel.fromJson(
    Map<String, dynamic> json,
  ) => SocketDataModel(
    success: json["success"],
    type: json["type"],
    message: json["message"],
    bookingId: json["booking_id"],
    passenger: json["passenger"] == null
        ? null
        : Passenger.fromJson(json["passenger"]),
    tripDetails: json["trip_details"] == null
        ? null
        : DataTripDetails.fromJson(json["trip_details"]),
    acceptanceTimer: json["acceptance_timer"],
    booking: json["booking"] == null ? null : Booking.fromJson(json["booking"]),
    fare: json["fare"] == null ? null : Fare.fromJson(json["fare"]),
    invoice: json["invoice"] == null ? null : Invoice.fromJson(json["invoice"]),
    customer: json["customer"] == null
        ? null
        : DataCustomer.fromJson(json["customer"]),
    driver: json["driver"] == null ? null : DataDriver.fromJson(json["driver"]),
    pickup: json["pickup"] == null ? null : Dropoff.fromJson(json["pickup"]),
    dropoff: json["dropoff"] == null ? null : Dropoff.fromJson(json["dropoff"]),
    driverAuthToken: json["driver_auth_token"],
    eventType: json["event_type"],
    status: json["status"],
    data: json["data"] == null
        ? []
        : List<dynamic>.from(json["data"]!.map((x) => x)),
    timestamp: _stringValue(json["timestamp"]),
    driverEtaMinutes: _intValue(json["driver_eta_minutes"]),
    driverExpectedArrivalAt:
        _stringValue(json["driver_expected_arrival_at"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "type": type,
    "message": message,
    "booking_id": bookingId,
    "passenger": passenger?.toJson(),
    "trip_details": tripDetails?.toJson(),
    "acceptance_timer": acceptanceTimer,
    "booking": booking?.toJson(),
    "fare": fare?.toJson(),
    "invoice": invoice?.toJson(),
    "customer": customer?.toJson(),
    "driver": driver?.toJson(),
    "pickup": pickup?.toJson(),
    "dropoff": dropoff?.toJson(),
    "driver_auth_token": driverAuthToken,
    "event_type": eventType,
    "status": status,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x)),
    "timestamp": timestamp,
    "driver_eta_minutes": driverEtaMinutes,
    "driver_expected_arrival_at": driverExpectedArrivalAt,
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
  String? userComment;
  String? driverRating;
  String? driverReview;
  String? driverComment;
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
  String? paymentMode;

  Booking({
    this.paymentMode,
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
    this.userComment,
    this.driverRating,
    this.driverReview,
    this.driverComment,
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
    String? userComment,
    String? driverRating,
    String? driverReview,
    String? driverComment,
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
    userComment: userComment ?? this.userComment,
    driverRating: driverRating ?? this.driverRating,
    driverReview: driverReview ?? this.driverReview,
    driverComment: driverComment ?? this.driverComment,
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
    scheduledAt: _stringValue(json["scheduled_at"]),
    acceptedAt: _stringValue(json["accepted_at"]),
    driverEtaMinutes: _stringValue(json["driver_eta_minutes"]),
    driverExpectedArrivalAt:
        _stringValue(json["driver_expected_arrival_at"]),
    startedAt: _stringValue(json["started_at"]),
    completedAt: json["completed_at"],
    cancelledAt: json["cancelled_at"],
    cancellationReason: json["cancellation_reason"],
    cancelledByType: json["cancelled_by_type"],
    cancelledById: json["cancelled_by_id"],
    userRating: json["user_rating"],
    userReview: json["user_review"],
    userComment: json["user_comment"],
    driverRating: json["driver_rating"],
    driverReview: json["driver_review"],
    driverComment: json["driver_comment"],
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
    "user_comment": userComment,
    "driver_rating": driverRating,
    "driver_review": driverReview,
    "driver_comment": driverComment,
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
  String? selectAddress;
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
    this.selectAddress,
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
    String? selectAddress,
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
    selectAddress: selectAddress ?? this.selectAddress,
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
    selectAddress: json["select_address"],
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
    "select_address": selectAddress,
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
  };
}

class DataCustomer {
  String? customerName;
  String? customerPhoto;
  int? customerRating;
  double? distanceToCustomer;
  String? etaToCustomer;

  DataCustomer({
    this.customerName,
    this.customerPhoto,
    this.customerRating,
    this.distanceToCustomer,
    this.etaToCustomer,
  });

  DataCustomer copyWith({
    String? customerName,
    String? customerPhoto,
    int? customerRating,
    double? distanceToCustomer,
    String? etaToCustomer,
  }) => DataCustomer(
    customerName: customerName ?? this.customerName,
    customerPhoto: customerPhoto ?? this.customerPhoto,
    customerRating: customerRating ?? this.customerRating,
    distanceToCustomer: distanceToCustomer ?? this.distanceToCustomer,
    etaToCustomer: etaToCustomer ?? this.etaToCustomer,
  );

  factory DataCustomer.fromJson(Map<String, dynamic> json) => DataCustomer(
    customerName: json["customer_name"],
    customerPhoto: json["customer_photo"],
    customerRating: json["customer_rating"],
    distanceToCustomer: json["distance_to_customer"]?.toDouble(),
    etaToCustomer: json["eta_to_customer"],
  );

  Map<String, dynamic> toJson() => {
    "customer_name": customerName,
    "customer_photo": customerPhoto,
    "customer_rating": customerRating,
    "distance_to_customer": distanceToCustomer,
    "eta_to_customer": etaToCustomer,
  };
}

class DataDriver {
  String? id;
  String? name;
  String? phone;
  String? email;
  String? profilePhoto;
  String? rating;
  String? totalTrips;
  Vehicle? vehicle;
  String? isOnline;
  String? lastLatitude;
  String? lastLongitude;
  String? lastLocationAt;
  CurrentLocation? currentLocation;

  DataDriver({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.profilePhoto,
    this.rating,
    this.totalTrips,
    this.vehicle,
    this.isOnline,
    this.lastLatitude,
    this.lastLongitude,
    this.lastLocationAt,
    this.currentLocation,
  });

  DataDriver copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? profilePhoto,
    String? rating,
    String? totalTrips,
    Vehicle? vehicle,
    String? isOnline,
    String? lastLatitude,
    String? lastLongitude,
    String? lastLocationAt,
    CurrentLocation? currentLocation,
  }) => DataDriver(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    rating: rating ?? this.rating,
    totalTrips: totalTrips ?? this.totalTrips,
    vehicle: vehicle ?? this.vehicle,
    isOnline: isOnline ?? this.isOnline,
    lastLatitude: lastLatitude ?? this.lastLatitude,
    lastLongitude: lastLongitude ?? this.lastLongitude,
    lastLocationAt: lastLocationAt ?? this.lastLocationAt,
    currentLocation: currentLocation ?? this.currentLocation,
  );

  factory DataDriver.fromJson(Map<String, dynamic> json) => DataDriver(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    email: json["email"],
    profilePhoto: json["profile_photo"],
    rating: json["rating"],
    totalTrips: json["total_trips"],
    vehicle: json["vehicle"] == null ? null : Vehicle.fromJson(json["vehicle"]),
    isOnline: json["is_online"],
    lastLatitude: json["last_latitude"],
    lastLongitude: json["last_longitude"],
    lastLocationAt: json["last_location_at"],
    currentLocation: json["current_location"] == null
        ? null
        : CurrentLocation.fromJson(json["current_location"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "email": email,
    "profile_photo": profilePhoto,
    "rating": rating,
    "total_trips": totalTrips,
    "vehicle": vehicle?.toJson(),
    "is_online": isOnline,
    "last_latitude": lastLatitude,
    "last_longitude": lastLongitude,
    "last_location_at": lastLocationAt,
    "current_location": currentLocation?.toJson(),
  };
}

class CurrentLocation {
  String? latitude;
  String? longitude;
  String? address;
  String? heading;
  String? speed;
  String? recordedAt;

  CurrentLocation({
    this.latitude,
    this.longitude,
    this.address,
    this.heading,
    this.speed,
    this.recordedAt,
  });

  CurrentLocation copyWith({
    String? latitude,
    String? longitude,
    String? address,
    String? heading,
    String? speed,
    String? recordedAt,
  }) => CurrentLocation(
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    address: address ?? this.address,
    heading: heading ?? this.heading,
    speed: speed ?? this.speed,
    recordedAt: recordedAt ?? this.recordedAt,
  );

  factory CurrentLocation.fromJson(Map<String, dynamic> json) =>
      CurrentLocation(
        latitude: json["latitude"],
        longitude: json["longitude"],
        address: json["address"],
        heading: json["heading"],
        speed: json["speed"],
        recordedAt: json["recorded_at"],
      );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
    "address": address,
    "heading": heading,
    "speed": speed,
    "recorded_at": recordedAt,
  };
}

class Vehicle {
  String? model;
  String? make;
  String? year;
  String? color;
  String? numberPlate;
  String? licensePlate;

  Vehicle({
    this.model,
    this.make,
    this.year,
    this.color,
    this.numberPlate,
    this.licensePlate,
  });

  Vehicle copyWith({
    String? model,
    String? make,
    String? year,
    String? color,
    String? numberPlate,
    String? licensePlate,
  }) => Vehicle(
    model: model ?? this.model,
    make: make ?? this.make,
    year: year ?? this.year,
    color: color ?? this.color,
    numberPlate: numberPlate ?? this.numberPlate,
    licensePlate: licensePlate ?? this.licensePlate,
  );

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    model: json["model"],
    make: json["make"],
    year: json["year"],
    color: json["color"],
    numberPlate: json["number_plate"],
    licensePlate: json["license_plate"],
  );

  Map<String, dynamic> toJson() => {
    "model": model,
    "make": make,
    "year": year,
    "color": color,
    "number_plate": numberPlate,
    "license_plate": licensePlate,
  };
}

class Dropoff {
  String? address;
  String? latitude;
  String? longitude;

  Dropoff({this.address, this.latitude, this.longitude});

  Dropoff copyWith({String? address, String? latitude, String? longitude}) =>
      Dropoff(
        address: address ?? this.address,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
    address: json["address"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
  };
}

class Fare {
  String? baseFare;
  String? distanceFare;
  String? timeFare;
  String? waitingCharge;
  String? nightCharge;
  String? surgeAmount;
  String? subtotal;
  String? discountAmount;
  String? taxAmount;
  String? totalAmount;
  String? adminCommission;
  String? driverAmount;

  Fare({
    this.baseFare,
    this.distanceFare,
    this.timeFare,
    this.waitingCharge,
    this.nightCharge,
    this.surgeAmount,
    this.subtotal,
    this.discountAmount,
    this.taxAmount,
    this.totalAmount,
    this.adminCommission,
    this.driverAmount,
  });

  Fare copyWith({
    String? baseFare,
    String? distanceFare,
    String? timeFare,
    String? waitingCharge,
    String? nightCharge,
    String? surgeAmount,
    String? subtotal,
    String? discountAmount,
    String? taxAmount,
    String? totalAmount,
    String? adminCommission,
    String? driverAmount,
  }) => Fare(
    baseFare: baseFare ?? this.baseFare,
    distanceFare: distanceFare ?? this.distanceFare,
    timeFare: timeFare ?? this.timeFare,
    waitingCharge: waitingCharge ?? this.waitingCharge,
    nightCharge: nightCharge ?? this.nightCharge,
    surgeAmount: surgeAmount ?? this.surgeAmount,
    subtotal: subtotal ?? this.subtotal,
    discountAmount: discountAmount ?? this.discountAmount,
    taxAmount: taxAmount ?? this.taxAmount,
    totalAmount: totalAmount ?? this.totalAmount,
    adminCommission: adminCommission ?? this.adminCommission,
    driverAmount: driverAmount ?? this.driverAmount,
  );

  factory Fare.fromJson(Map<String, dynamic> json) => Fare(
    baseFare: json["base_fare"],
    distanceFare: json["distance_fare"],
    timeFare: json["time_fare"],
    waitingCharge: json["waiting_charge"],
    nightCharge: json["night_charge"],
    surgeAmount: json["surge_amount"],
    subtotal: json["subtotal"],
    discountAmount: json["discount_amount"],
    taxAmount: json["tax_amount"],
    totalAmount: json["total_amount"],
    adminCommission: json["admin_commission"],
    driverAmount: json["driver_amount"],
  );

  Map<String, dynamic> toJson() => {
    "base_fare": baseFare,
    "distance_fare": distanceFare,
    "time_fare": timeFare,
    "waiting_charge": waitingCharge,
    "night_charge": nightCharge,
    "surge_amount": surgeAmount,
    "subtotal": subtotal,
    "discount_amount": discountAmount,
    "tax_amount": taxAmount,
    "total_amount": totalAmount,
    "admin_commission": adminCommission,
    "driver_amount": driverAmount,
  };
}

class Invoice {
  String? invoiceNumber;
  String? bookingId;
  String? bookingCode;
  String? invoiceDate;
  InvoiceCustomer? customer;
  InvoiceDriver? driver;
  InvoiceTripDetails? tripDetails;
  Fare? fareBreakdown;
  PaymentDetails? paymentDetails;

  Invoice({
    this.invoiceNumber,
    this.bookingId,
    this.bookingCode,
    this.invoiceDate,
    this.customer,
    this.driver,
    this.tripDetails,
    this.fareBreakdown,
    this.paymentDetails,
  });

  Invoice copyWith({
    String? invoiceNumber,
    String? bookingId,
    String? bookingCode,
    String? invoiceDate,
    InvoiceCustomer? customer,
    InvoiceDriver? driver,
    InvoiceTripDetails? tripDetails,
    Fare? fareBreakdown,
    PaymentDetails? paymentDetails,
  }) => Invoice(
    invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    bookingId: bookingId ?? this.bookingId,
    bookingCode: bookingCode ?? this.bookingCode,
    invoiceDate: invoiceDate ?? this.invoiceDate,
    customer: customer ?? this.customer,
    driver: driver ?? this.driver,
    tripDetails: tripDetails ?? this.tripDetails,
    fareBreakdown: fareBreakdown ?? this.fareBreakdown,
    paymentDetails: paymentDetails ?? this.paymentDetails,
  );

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    invoiceNumber: json["invoice_number"],
    bookingId: json["booking_id"],
    bookingCode: json["booking_code"],
    invoiceDate: json["invoice_date"],
    customer: json["customer"] == null
        ? null
        : InvoiceCustomer.fromJson(json["customer"]),
    driver: json["driver"] == null
        ? null
        : InvoiceDriver.fromJson(json["driver"]),
    tripDetails: json["trip_details"] == null
        ? null
        : InvoiceTripDetails.fromJson(json["trip_details"]),
    fareBreakdown: json["fare_breakdown"] == null
        ? null
        : Fare.fromJson(json["fare_breakdown"]),
    paymentDetails: json["payment_details"] == null
        ? null
        : PaymentDetails.fromJson(json["payment_details"]),
  );

  Map<String, dynamic> toJson() => {
    "invoice_number": invoiceNumber,
    "booking_id": bookingId,
    "booking_code": bookingCode,
    "invoice_date": invoiceDate,
    "customer": customer?.toJson(),
    "driver": driver?.toJson(),
    "trip_details": tripDetails?.toJson(),
    "fare_breakdown": fareBreakdown?.toJson(),
    "payment_details": paymentDetails?.toJson(),
  };
}

class InvoiceCustomer {
  String? name;
  String? phone;
  String? email;

  InvoiceCustomer({this.name, this.phone, this.email});

  InvoiceCustomer copyWith({String? name, String? phone, String? email}) =>
      InvoiceCustomer(
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
      );

  factory InvoiceCustomer.fromJson(Map<String, dynamic> json) =>
      InvoiceCustomer(
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "phone": phone,
    "email": email,
  };
}

class InvoiceDriver {
  String? name;
  String? phone;
  String? vehicle;
  String? licensePlate;

  InvoiceDriver({this.name, this.phone, this.vehicle, this.licensePlate});

  InvoiceDriver copyWith({
    String? name,
    String? phone,
    String? vehicle,
    String? licensePlate,
  }) => InvoiceDriver(
    name: name ?? this.name,
    phone: phone ?? this.phone,
    vehicle: vehicle ?? this.vehicle,
    licensePlate: licensePlate ?? this.licensePlate,
  );

  factory InvoiceDriver.fromJson(Map<String, dynamic> json) => InvoiceDriver(
    name: json["name"],
    phone: json["phone"],
    vehicle: json["vehicle"],
    licensePlate: json["license_plate"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "phone": phone,
    "vehicle": vehicle,
    "license_plate": licensePlate,
  };
}

class PaymentDetails {
  String? paymentMethod;
  String? paymentStatus;
  String? driverAmount;
  String? platformCommission;
  String? driverCommissionRate;
  String? platformCommissionRate;

  PaymentDetails({
    this.paymentMethod,
    this.paymentStatus,
    this.driverAmount,
    this.platformCommission,
    this.driverCommissionRate,
    this.platformCommissionRate,
  });

  PaymentDetails copyWith({
    String? paymentMethod,
    String? paymentStatus,
    String? driverAmount,
    String? platformCommission,
    String? driverCommissionRate,
    String? platformCommissionRate,
  }) => PaymentDetails(
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    driverAmount: driverAmount ?? this.driverAmount,
    platformCommission: platformCommission ?? this.platformCommission,
    driverCommissionRate: driverCommissionRate ?? this.driverCommissionRate,
    platformCommissionRate:
        platformCommissionRate ?? this.platformCommissionRate,
  );

  factory PaymentDetails.fromJson(Map<String, dynamic> json) => PaymentDetails(
    paymentMethod: json["payment_method"],
    paymentStatus: json["payment_status"],
    driverAmount: json["driver_amount"],
    platformCommission: json["platform_commission"],
    driverCommissionRate: json["driver_commission_rate"],
    platformCommissionRate: json["platform_commission_rate"],
  );

  Map<String, dynamic> toJson() => {
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
    "driver_amount": driverAmount,
    "platform_commission": platformCommission,
    "driver_commission_rate": driverCommissionRate,
    "platform_commission_rate": platformCommissionRate,
  };
}

class InvoiceTripDetails {
  String? pickupAddress;
  String? dropoffAddress;
  String? distance;
  String? duration;
  String? startedAt;
  String? completedAt;

  InvoiceTripDetails({
    this.pickupAddress,
    this.dropoffAddress,
    this.distance,
    this.duration,
    this.startedAt,
    this.completedAt,
  });

  InvoiceTripDetails copyWith({
    String? pickupAddress,
    String? dropoffAddress,
    String? distance,
    String? duration,
    String? startedAt,
    String? completedAt,
  }) => InvoiceTripDetails(
    pickupAddress: pickupAddress ?? this.pickupAddress,
    dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    distance: distance ?? this.distance,
    duration: duration ?? this.duration,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
  );

  factory InvoiceTripDetails.fromJson(Map<String, dynamic> json) =>
      InvoiceTripDetails(
        pickupAddress: json["pickup_address"],
        dropoffAddress: json["dropoff_address"],
        distance: json["distance"],
        duration: json["duration"],
        startedAt: json["started_at"],
        completedAt: json["completed_at"],
      );

  Map<String, dynamic> toJson() => {
    "pickup_address": pickupAddress,
    "dropoff_address": dropoffAddress,
    "distance": distance,
    "duration": duration,
    "started_at": startedAt,
    "completed_at": completedAt,
  };
}

class Passenger {
  String? name;
  String? phone;
  String? photo;
  dynamic rating;

  Passenger({this.name, this.phone, this.photo, this.rating});

  Passenger copyWith({
    String? name,
    String? phone,
    String? photo,
    int? rating,
  }) => Passenger(
    name: name ?? this.name,
    phone: phone ?? this.phone,
    photo: photo ?? this.photo,
    rating: rating ?? this.rating,
  );

  factory Passenger.fromJson(Map<String, dynamic> json) => Passenger(
    name: json["name"],
    phone: json["phone"],
    photo: json["photo"],
    rating: json["rating"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "phone": phone,
    "photo": photo,
    "rating": rating,
  };
}

class DataTripDetails {
  String? distance;
  String? fare;
  String? duration;

  DataTripDetails({this.distance, this.fare, this.duration});

  DataTripDetails copyWith({
    String? distance,
    String? fare,
    String? duration,
  }) => DataTripDetails(
    distance: distance ?? this.distance,
    fare: fare ?? this.fare,
    duration: duration ?? this.duration,
  );

  factory DataTripDetails.fromJson(Map<String, dynamic> json) =>
      DataTripDetails(
        distance: json["distance"],
        fare: json["fare"],
        duration: json["duration"],
      );

  Map<String, dynamic> toJson() => {
    "distance": distance,
    "fare": fare,
    "duration": duration,
  };
}
