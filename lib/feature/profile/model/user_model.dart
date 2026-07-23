import '../../home/model/get_socket_model.dart';

class UserProfileModel {
  bool? success;
  String? message;
  UserModel? data;
  SocketDataModel? currentBooking;
  List<Booking>? allBookings;

  int? isCash;

  UserProfileModel({
    this.success,
    this.message,
    this.data,
    this.currentBooking,
    this.allBookings,
    this.isCash,
  });

  UserProfileModel copyWith({
    bool? success,
    String? message,
    UserModel? data,
    SocketDataModel? currentBooking,
    List<Booking>? allBookings,
    int? isCash,
  }) => UserProfileModel(
    success: success ?? this.success,
    message: message ?? this.message,
    data: data ?? this.data,
    currentBooking: currentBooking ?? this.currentBooking,
    allBookings: allBookings ?? this.allBookings,
    isCash: isCash ?? this.isCash,
  );

  factory UserProfileModel.fromJson(
    Map<String, dynamic> json,
  ) => UserProfileModel(
    success: json["success"],
    message: json["message"],
    isCash: json["is_cash"],
    data: json["data"] == null ? null : UserModel.fromJson(json["data"]),
    currentBooking: json["current_booking"] == null
        ? null
        : SocketDataModel.fromJson(json["current_booking"]),
    // allBookings: json["all_bookings"] == null ? [] : List<Booking>.from(json["all_bookings"]!.map((x) => Booking.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "current_booking": currentBooking?.toJson(),
    "isCash": isCash,
    "all_bookings": allBookings == null
        ? []
        : List<dynamic>.from(allBookings!.map((x) => x.toJson())),
  };
}

class Booking {
  String? bookingId;
  Passenger? passenger;
  TripDetails? tripDetails;
  int? acceptanceTimer;
  BookingClass? booking;
  Invoice? invoice;
  CurrentBookingDriver? driver;
  Dropoff? pickup;
  Dropoff? dropoff;
  String? eventType;
  String? status;
  String? timestamp;

  Booking({
    this.bookingId,
    this.passenger,
    this.tripDetails,
    this.acceptanceTimer,
    this.booking,
    this.invoice,
    this.driver,
    this.pickup,
    this.dropoff,
    this.eventType,
    this.status,
    this.timestamp,
  });

  Booking copyWith({
    String? bookingId,
    Passenger? passenger,
    TripDetails? tripDetails,
    int? acceptanceTimer,
    BookingClass? booking,
    Invoice? invoice,
    CurrentBookingDriver? driver,
    Dropoff? pickup,
    Dropoff? dropoff,
    String? eventType,
    String? status,
    String? timestamp,
  }) => Booking(
    bookingId: bookingId ?? this.bookingId,
    passenger: passenger ?? this.passenger,
    tripDetails: tripDetails ?? this.tripDetails,
    acceptanceTimer: acceptanceTimer ?? this.acceptanceTimer,
    booking: booking ?? this.booking,
    invoice: invoice ?? this.invoice,
    driver: driver ?? this.driver,
    pickup: pickup ?? this.pickup,
    dropoff: dropoff ?? this.dropoff,
    eventType: eventType ?? this.eventType,
    status: status ?? this.status,
    timestamp: timestamp ?? this.timestamp,
  );

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    bookingId: json["booking_id"],
    passenger: json["passenger"] == null
        ? null
        : Passenger.fromJson(json["passenger"]),
    tripDetails: json["trip_details"] == null
        ? null
        : TripDetails.fromJson(json["trip_details"]),
    acceptanceTimer: json["acceptance_timer"],
    booking: json["booking"] == null
        ? null
        : BookingClass.fromJson(json["booking"]),
    invoice: json["invoice"] == null ? null : Invoice.fromJson(json["invoice"]),
    driver: json["driver"] == null
        ? null
        : CurrentBookingDriver.fromJson(json["driver"]),
    pickup: json["pickup"] == null ? null : Dropoff.fromJson(json["pickup"]),
    dropoff: json["dropoff"] == null ? null : Dropoff.fromJson(json["dropoff"]),
    eventType: json["event_type"],
    status: json["status"],
    timestamp: json["timestamp"],
  );

  Map<String, dynamic> toJson() => {
    "booking_id": bookingId,
    "passenger": passenger?.toJson(),
    "trip_details": tripDetails?.toJson(),
    "acceptance_timer": acceptanceTimer,
    "booking": booking?.toJson(),
    "invoice": invoice?.toJson(),
    "driver": driver?.toJson(),
    "pickup": pickup?.toJson(),
    "dropoff": dropoff?.toJson(),
    "event_type": eventType,
    "status": status,
    "timestamp": timestamp,
  };
}

class BookingClass {
  String? id;
  String? bookingCode;
  String? userId;
  String? driverId;
  String? pickupAddress;
  String? dropoffAddress;
  String? status;
  String? paymentMethod;
  String? paymentStatus;
  String? estimatedFare;
  String? finalFare;
  String? otp;
  String? tripCode;
  String? createdAt;
  String? updatedAt;
  User? user;
  BookingRideType? rideType;

  BookingClass({
    this.id,
    this.bookingCode,
    this.userId,
    this.driverId,
    this.pickupAddress,
    this.dropoffAddress,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.estimatedFare,
    this.finalFare,
    this.otp,
    this.tripCode,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.rideType,
  });

  BookingClass copyWith({
    String? id,
    String? bookingCode,
    String? userId,
    String? driverId,
    String? pickupAddress,
    String? dropoffAddress,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    String? estimatedFare,
    String? finalFare,
    String? otp,
    String? tripCode,
    String? createdAt,
    String? updatedAt,
    User? user,
    BookingRideType? rideType,
  }) => BookingClass(
    id: id ?? this.id,
    bookingCode: bookingCode ?? this.bookingCode,
    userId: userId ?? this.userId,
    driverId: driverId ?? this.driverId,
    pickupAddress: pickupAddress ?? this.pickupAddress,
    dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    status: status ?? this.status,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    estimatedFare: estimatedFare ?? this.estimatedFare,
    finalFare: finalFare ?? this.finalFare,
    otp: otp ?? this.otp,
    tripCode: tripCode ?? this.tripCode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    user: user ?? this.user,
    rideType: rideType ?? this.rideType,
  );

  factory BookingClass.fromJson(Map<String, dynamic> json) => BookingClass(
    id: json["id"],
    bookingCode: json["booking_code"],
    userId: json["user_id"],
    driverId: json["driver_id"],
    pickupAddress: json["pickup_address"],
    dropoffAddress: json["dropoff_address"],
    status: json["status"],
    paymentMethod: json["payment_method"],
    paymentStatus: json["payment_status"],
    estimatedFare: json["estimated_fare"],
    finalFare: json["final_fare"],
    otp: json["otp"],
    tripCode: json["trip_code"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    rideType: json["ride_type"] == null
        ? null
        : BookingRideType.fromJson(json["ride_type"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_code": bookingCode,
    "user_id": userId,
    "driver_id": driverId,
    "pickup_address": pickupAddress,
    "dropoff_address": dropoffAddress,
    "status": status,
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
    "estimated_fare": estimatedFare,
    "final_fare": finalFare,
    "otp": otp,
    "trip_code": tripCode,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "user": user?.toJson(),
    "ride_type": rideType?.toJson(),
  };
}

class BookingRideType {
  String? id;
  String? name;
  String? basePrice;
  String? pricePerKm;
  String? pricePerMinute;

  BookingRideType({
    this.id,
    this.name,
    this.basePrice,
    this.pricePerKm,
    this.pricePerMinute,
  });

  BookingRideType copyWith({
    String? id,
    String? name,
    String? basePrice,
    String? pricePerKm,
    String? pricePerMinute,
  }) => BookingRideType(
    id: id ?? this.id,
    name: name ?? this.name,
    basePrice: basePrice ?? this.basePrice,
    pricePerKm: pricePerKm ?? this.pricePerKm,
    pricePerMinute: pricePerMinute ?? this.pricePerMinute,
  );

  factory BookingRideType.fromJson(Map<String, dynamic> json) =>
      BookingRideType(
        id: json["id"],
        name: json["name"],
        basePrice: json["base_price"],
        pricePerKm: json["price_per_km"],
        pricePerMinute: json["price_per_minute"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "base_price": basePrice,
    "price_per_km": pricePerKm,
    "price_per_minute": pricePerMinute,
  };
}

class User {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? profilePhoto;
  String? rating;
  UserVehicle? vehicle;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profilePhoto,
    this.rating,
    this.vehicle,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profilePhoto,
    String? rating,
    UserVehicle? vehicle,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    rating: rating ?? this.rating,
    vehicle: vehicle ?? this.vehicle,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    profilePhoto: json["profile_photo"],
    rating: json["rating"],
    vehicle: json["vehicle"] == null
        ? null
        : UserVehicle.fromJson(json["vehicle"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "profile_photo": profilePhoto,
    "rating": rating,
    "vehicle": vehicle?.toJson(),
  };
}

class UserVehicle {
  String? brand;
  String? model;
  String? licensePlate;
  String? color;

  UserVehicle({this.brand, this.model, this.licensePlate, this.color});

  UserVehicle copyWith({
    String? brand,
    String? model,
    String? licensePlate,
    String? color,
  }) => UserVehicle(
    brand: brand ?? this.brand,
    model: model ?? this.model,
    licensePlate: licensePlate ?? this.licensePlate,
    color: color ?? this.color,
  );

  factory UserVehicle.fromJson(Map<String, dynamic> json) => UserVehicle(
    brand: json["brand"],
    model: json["model"],
    licensePlate: json["license_plate"],
    color: json["color"],
  );

  Map<String, dynamic> toJson() => {
    "brand": brand,
    "model": model,
    "license_plate": licensePlate,
    "color": color,
  };
}

class CurrentBookingDriver {
  String? id;
  String? name;
  String? phone;
  String? rating;
  PurpleVehicle? vehicle;
  String? isOnline;

  CurrentBookingDriver({
    this.id,
    this.name,
    this.phone,
    this.rating,
    this.vehicle,
    this.isOnline,
  });

  CurrentBookingDriver copyWith({
    String? id,
    String? name,
    String? phone,
    String? rating,
    PurpleVehicle? vehicle,
    String? isOnline,
  }) => CurrentBookingDriver(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    rating: rating ?? this.rating,
    vehicle: vehicle ?? this.vehicle,
    isOnline: isOnline ?? this.isOnline,
  );

  factory CurrentBookingDriver.fromJson(Map<String, dynamic> json) =>
      CurrentBookingDriver(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        rating: json["rating"],
        vehicle: json["vehicle"] == null
            ? null
            : PurpleVehicle.fromJson(json["vehicle"]),
        isOnline: json["is_online"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "rating": rating,
    "vehicle": vehicle?.toJson(),
    "is_online": isOnline,
  };
}

class PurpleVehicle {
  String? model;
  String? numberPlate;

  PurpleVehicle({this.model, this.numberPlate});

  PurpleVehicle copyWith({String? model, String? numberPlate}) => PurpleVehicle(
    model: model ?? this.model,
    numberPlate: numberPlate ?? this.numberPlate,
  );

  factory PurpleVehicle.fromJson(Map<String, dynamic> json) =>
      PurpleVehicle(model: json["model"], numberPlate: json["number_plate"]);

  Map<String, dynamic> toJson() => {
    "model": model,
    "number_plate": numberPlate,
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

class Invoice {
  String? invoiceNumber;
  String? bookingCode;
  String? invoiceDate;
  Customer? customer;
  InvoiceDriver? driver;
  PaymentDetails? paymentDetails;

  Invoice({
    this.invoiceNumber,
    this.bookingCode,
    this.invoiceDate,
    this.customer,
    this.driver,
    this.paymentDetails,
  });

  Invoice copyWith({
    String? invoiceNumber,
    String? bookingCode,
    String? invoiceDate,
    Customer? customer,
    InvoiceDriver? driver,
    PaymentDetails? paymentDetails,
  }) => Invoice(
    invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    bookingCode: bookingCode ?? this.bookingCode,
    invoiceDate: invoiceDate ?? this.invoiceDate,
    customer: customer ?? this.customer,
    driver: driver ?? this.driver,
    paymentDetails: paymentDetails ?? this.paymentDetails,
  );

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    invoiceNumber: json["invoice_number"],
    bookingCode: json["booking_code"],
    invoiceDate: json["invoice_date"],
    customer: json["customer"] == null
        ? null
        : Customer.fromJson(json["customer"]),
    driver: json["driver"] == null
        ? null
        : InvoiceDriver.fromJson(json["driver"]),
    paymentDetails: json["payment_details"] == null
        ? null
        : PaymentDetails.fromJson(json["payment_details"]),
  );

  Map<String, dynamic> toJson() => {
    "invoice_number": invoiceNumber,
    "booking_code": bookingCode,
    "invoice_date": invoiceDate,
    "customer": customer?.toJson(),
    "driver": driver?.toJson(),
    "payment_details": paymentDetails?.toJson(),
  };
}

class Customer {
  String? name;
  String? phone;
  String? email;

  Customer({this.name, this.phone, this.email});

  Customer copyWith({String? name, String? phone, String? email}) => Customer(
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
  );

  factory Customer.fromJson(Map<String, dynamic> json) =>
      Customer(name: json["name"], phone: json["phone"], email: json["email"]);

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

  PaymentDetails({this.paymentMethod, this.paymentStatus});

  PaymentDetails copyWith({String? paymentMethod, String? paymentStatus}) =>
      PaymentDetails(
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
      );

  factory PaymentDetails.fromJson(Map<String, dynamic> json) => PaymentDetails(
    paymentMethod: json["payment_method"],
    paymentStatus: json["payment_status"],
  );

  Map<String, dynamic> toJson() => {
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
  };
}

class Passenger {
  String? name;
  String? phone;
  String? photo;
  String? rating;

  Passenger({this.name, this.phone, this.photo, this.rating});

  Passenger copyWith({
    String? name,
    String? phone,
    String? photo,
    String? rating,
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

class TripDetails {
  String? distance;
  String? fare;
  String? duration;

  TripDetails({this.distance, this.fare, this.duration});

  TripDetails copyWith({String? distance, String? fare, String? duration}) =>
      TripDetails(
        distance: distance ?? this.distance,
        fare: fare ?? this.fare,
        duration: duration ?? this.duration,
      );

  factory TripDetails.fromJson(Map<String, dynamic> json) => TripDetails(
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

class UserModel {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? countryCode;
  String? gender;
  String? dateOfBirth;
  String? profilePhoto;
  String? roleId;
  String? role;
  String? status;
  String? isOnline;
  String? isVerified;
  String? verifiedAt;
  String? emailVerifiedAt;
  String? phoneVerifiedAt;
  String? lastLocationAt;
  String? lastLatitude;
  String? lastLongitude;
  String? selectLatitude;
  String? selectLongitude;
  String? referralCode;
  String? referredBy;
  String? isRegister;
  String? loginDevice;
  String? step0;
  String? step1;
  String? step2;
  String? step3;
  String? currentBookingId;
  String? createdAt;
  String? updatedAt;
  Wallet? wallet;
  Referrer? referrer;
  String? referralsCount;
  List<RecentBooking>? recentBookings;
  BookingStatistics? bookingStatistics;
  PaymentMethods? paymentMethods;
  List<MonthlyStatistic>? monthlyStatistics;
  List<dynamic>? recentTransactions;
  List<PromoUsage>? promoUsage;
  List<dynamic>? supportTickets;
  List<dynamic>? walletTransactions;
  List<TripHistory>? tripHistory;
  TripHistoryStatistics? tripHistoryStatistics;

  // TripHistoryByStatus? tripHistoryByStatus;
  ComprehensiveStatistics? comprehensiveStatistics;
  String? refundTime;
  List? availablePayment;

  UserModel({
    this.id,
    this.refundTime,
    this.loginDevice,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.countryCode,
    this.gender,
    this.dateOfBirth,
    this.profilePhoto,
    this.roleId,
    this.role,
    this.status,
    this.isOnline,
    this.isVerified,
    this.verifiedAt,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    this.lastLocationAt,
    this.lastLatitude,
    this.lastLongitude,
    this.selectLatitude,
    this.selectLongitude,
    this.referralCode,
    this.referredBy,
    this.isRegister,
    this.step0,
    this.step1,
    this.step2,
    this.step3,
    this.currentBookingId,
    this.createdAt,
    this.updatedAt,
    this.wallet,
    this.referrer,
    this.referralsCount,
    this.recentBookings,
    this.bookingStatistics,
    this.paymentMethods,
    this.monthlyStatistics,
    this.recentTransactions,
    this.promoUsage,
    this.supportTickets,
    this.walletTransactions,
    this.tripHistory,
    this.tripHistoryStatistics,
    // this.tripHistoryByStatus,
    this.comprehensiveStatistics,
    this.availablePayment,
  });

  UserModel copyWith({
    String? id,
    String? refundTime,
    String? loginDevice,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? countryCode,
    String? gender,
    String? dateOfBirth,
    String? profilePhoto,
    String? roleId,
    String? role,
    String? status,
    String? isOnline,
    String? isVerified,
    String? verifiedAt,
    String? emailVerifiedAt,
    String? phoneVerifiedAt,
    String? lastLocationAt,
    String? lastLatitude,
    String? lastLongitude,
    String? selectLatitude,
    String? selectLongitude,
    String? referralCode,
    String? referredBy,
    String? isRegister,
    String? step0,
    String? step1,
    String? step2,
    String? step3,
    String? currentBookingId,
    String? createdAt,
    String? updatedAt,
    Wallet? wallet,
    Referrer? referrer,
    String? referralsCount,
    List<RecentBooking>? recentBookings,
    BookingStatistics? bookingStatistics,
    PaymentMethods? paymentMethods,
    List<MonthlyStatistic>? monthlyStatistics,
    List<dynamic>? recentTransactions,
    List<PromoUsage>? promoUsage,
    List<dynamic>? supportTickets,
    List<dynamic>? walletTransactions,
    List<TripHistory>? tripHistory,
    TripHistoryStatistics? tripHistoryStatistics,
    TripHistoryByStatus? tripHistoryByStatus,
    ComprehensiveStatistics? comprehensiveStatistics,
    List? availablePayment,
  }) => UserModel(
    id: id ?? this.id,
    refundTime: refundTime ?? this.refundTime,
    loginDevice: loginDevice ?? this.loginDevice,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    countryCode: countryCode ?? this.countryCode,
    gender: gender ?? this.gender,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    roleId: roleId ?? this.roleId,
    role: role ?? this.role,
    status: status ?? this.status,
    isOnline: isOnline ?? this.isOnline,
    isVerified: isVerified ?? this.isVerified,
    verifiedAt: verifiedAt ?? this.verifiedAt,
    emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    phoneVerifiedAt: phoneVerifiedAt ?? this.phoneVerifiedAt,
    lastLocationAt: lastLocationAt ?? this.lastLocationAt,
    lastLatitude: lastLatitude ?? this.lastLatitude,
    lastLongitude: lastLongitude ?? this.lastLongitude,
    selectLatitude: selectLatitude ?? this.selectLatitude,
    selectLongitude: selectLongitude ?? this.selectLongitude,
    referralCode: referralCode ?? this.referralCode,
    referredBy: referredBy ?? this.referredBy,
    isRegister: isRegister ?? this.isRegister,
    step0: step0 ?? this.step0,
    step1: step1 ?? this.step1,
    step2: step2 ?? this.step2,
    step3: step3 ?? this.step3,
    currentBookingId: currentBookingId ?? this.currentBookingId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    wallet: wallet ?? this.wallet,
    referrer: referrer ?? this.referrer,
    referralsCount: referralsCount ?? this.referralsCount,
    recentBookings: recentBookings ?? this.recentBookings,
    bookingStatistics: bookingStatistics ?? this.bookingStatistics,
    paymentMethods: paymentMethods ?? this.paymentMethods,
    monthlyStatistics: monthlyStatistics ?? this.monthlyStatistics,
    recentTransactions: recentTransactions ?? this.recentTransactions,
    promoUsage: promoUsage ?? this.promoUsage,
    supportTickets: supportTickets ?? this.supportTickets,
    walletTransactions: walletTransactions ?? this.walletTransactions,
    tripHistory: tripHistory ?? this.tripHistory,
    tripHistoryStatistics: tripHistoryStatistics ?? this.tripHistoryStatistics,
    // tripHistoryByStatus: tripHistoryByStatus ?? this.tripHistoryByStatus,
    comprehensiveStatistics:
        comprehensiveStatistics ?? this.comprehensiveStatistics,
    availablePayment: availablePayment ?? this.availablePayment,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    refundTime: json["refund_time"],
    loginDevice: json["login_device"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    address: json["address"],
    countryCode: json["country_code"],
    gender: json["gender"],
    dateOfBirth: json["date_of_birth"],
    profilePhoto: json["profile_photo"],
    roleId: json["role_id"],
    role: json["role"],
    status: json["status"],
    isOnline: json["is_online"],
    isVerified: json["is_verified"],
    verifiedAt: json["verified_at"],
    emailVerifiedAt: json["email_verified_at"],
    phoneVerifiedAt: json["phone_verified_at"],
    lastLocationAt: json["last_location_at"],
    lastLatitude: json["last_latitude"],
    lastLongitude: json["last_longitude"],
    selectLatitude: json["select_latitude"],
    selectLongitude: json["select_longitude"],
    referralCode: json["referral_code"],
    referredBy: json["referred_by"],
    isRegister: json["is_register"],
    step0: json["step_0"],
    step1: json["step_1"],
    step2: json["step_2"],
    step3: json["step_3"],
    currentBookingId: json["current_booking_id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    wallet: json["wallet"] == null ? null : Wallet.fromJson(json["wallet"]),
    referrer: json["referrer"] == null
        ? null
        : Referrer.fromJson(json["referrer"]),
    referralsCount: json["referrals_count"],
    recentBookings: json["recent_bookings"] == null
        ? []
        : List<RecentBooking>.from(
            json["recent_bookings"]!.map((x) => RecentBooking.fromJson(x)),
          ),
    bookingStatistics: json["booking_statistics"] == null
        ? null
        : BookingStatistics.fromJson(json["booking_statistics"]),
    paymentMethods: json["payment_methods"] == null
        ? null
        : PaymentMethods.fromJson(json["payment_methods"]),
    monthlyStatistics: json["monthly_statistics"] == null
        ? []
        : List<MonthlyStatistic>.from(
            json["monthly_statistics"]!.map(
              (x) => MonthlyStatistic.fromJson(x),
            ),
          ),
    recentTransactions: json["recent_transactions"] == null
        ? []
        : List<dynamic>.from(json["recent_transactions"]!.map((x) => x)),
    promoUsage: json["promo_usage"] == null
        ? []
        : List<PromoUsage>.from(
            json["promo_usage"]!.map((x) => PromoUsage.fromJson(x)),
          ),
    supportTickets: json["support_tickets"] == null
        ? []
        : List<dynamic>.from(json["support_tickets"]!.map((x) => x)),
    walletTransactions: json["wallet_transactions"] == null
        ? []
        : List<dynamic>.from(json["wallet_transactions"]!.map((x) => x)),
    tripHistory: json["trip_history"] == null
        ? []
        : List<TripHistory>.from(
            json["trip_history"]!.map((x) => TripHistory.fromJson(x)),
          ),
    tripHistoryStatistics: json["trip_history_statistics"] == null
        ? null
        : TripHistoryStatistics.fromJson(json["trip_history_statistics"]),
    // tripHistoryByStatus: json["trip_history_by_status"] == null ? null : TripHistoryByStatus.fromJson(json["trip_history_by_status"]),
    comprehensiveStatistics: json["comprehensive_statistics"] == null
        ? null
        : ComprehensiveStatistics.fromJson(json["comprehensive_statistics"]),
    availablePayment: json["available_payment"] == null
        ? []
        : List<dynamic>.from(json["available_payment"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "refund_time": refundTime,
    "login_device": loginDevice,
    "name": name,
    "email": email,
    "phone": phone,
    "address": address,
    "country_code": countryCode,
    "gender": gender,
    "date_of_birth": dateOfBirth,
    "profile_photo": profilePhoto,
    "role_id": roleId,
    "role": role,
    "status": status,
    "is_online": isOnline,
    "is_verified": isVerified,
    "verified_at": verifiedAt,
    "email_verified_at": emailVerifiedAt,
    "phone_verified_at": phoneVerifiedAt,
    "last_location_at": lastLocationAt,
    "last_latitude": lastLatitude,
    "last_longitude": lastLongitude,
    "select_latitude": selectLatitude,
    "select_longitude": selectLongitude,
    "referral_code": referralCode,
    "referred_by": referredBy,
    "is_register": isRegister,
    "step_0": step0,
    "step_1": step1,
    "step_2": step2,
    "step_3": step3,
    "current_booking_id": currentBookingId,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "wallet": wallet?.toJson(),
    "referrer": referrer?.toJson(),
    "referrals_count": referralsCount,
    "recent_bookings": recentBookings == null
        ? []
        : List<dynamic>.from(recentBookings!.map((x) => x.toJson())),
    "booking_statistics": bookingStatistics?.toJson(),
    "payment_methods": paymentMethods?.toJson(),
    "monthly_statistics": monthlyStatistics == null
        ? []
        : List<dynamic>.from(monthlyStatistics!.map((x) => x.toJson())),
    "recent_transactions": recentTransactions == null
        ? []
        : List<dynamic>.from(recentTransactions!.map((x) => x)),
    "promo_usage": promoUsage == null
        ? []
        : List<dynamic>.from(promoUsage!.map((x) => x.toJson())),
    "support_tickets": supportTickets == null
        ? []
        : List<dynamic>.from(supportTickets!.map((x) => x)),
    "wallet_transactions": walletTransactions == null
        ? []
        : List<dynamic>.from(walletTransactions!.map((x) => x)),
    "trip_history": tripHistory == null
        ? []
        : List<dynamic>.from(tripHistory!.map((x) => x.toJson())),
    "trip_history_statistics": tripHistoryStatistics?.toJson(),
    // "trip_history_by_status": tripHistoryByStatus?.toJson(),
    "comprehensive_statistics": comprehensiveStatistics?.toJson(),
    "available_payment": availablePayment == null
        ? []
        : List<dynamic>.from(availablePayment!.map((e) => e)),
  };
}

class BookingStatistics {
  String? totalBookings;
  String? completedBookings;
  String? cancelledBookings;
  String? pendingBookings;
  String? acceptedBookings;
  String? startedBookings;
  String? expiredBookings;
  String? totalSpent;
  String? totalDistance;
  String? totalDuration;
  String? averageRatingGiven;
  String? averageRatingReceived;
  String? totalPromoSavings;
  String? walletUsage;
  String? cashPayments;
  String? onlinePayments;

  BookingStatistics({
    this.totalBookings,
    this.completedBookings,
    this.cancelledBookings,
    this.pendingBookings,
    this.acceptedBookings,
    this.startedBookings,
    this.expiredBookings,
    this.totalSpent,
    this.totalDistance,
    this.totalDuration,
    this.averageRatingGiven,
    this.averageRatingReceived,
    this.totalPromoSavings,
    this.walletUsage,
    this.cashPayments,
    this.onlinePayments,
  });

  BookingStatistics copyWith({
    String? totalBookings,
    String? completedBookings,
    String? cancelledBookings,
    String? pendingBookings,
    String? acceptedBookings,
    String? startedBookings,
    String? expiredBookings,
    String? totalSpent,
    String? totalDistance,
    String? totalDuration,
    String? averageRatingGiven,
    String? averageRatingReceived,
    String? totalPromoSavings,
    String? walletUsage,
    String? cashPayments,
    String? onlinePayments,
  }) => BookingStatistics(
    totalBookings: totalBookings ?? this.totalBookings,
    completedBookings: completedBookings ?? this.completedBookings,
    cancelledBookings: cancelledBookings ?? this.cancelledBookings,
    pendingBookings: pendingBookings ?? this.pendingBookings,
    acceptedBookings: acceptedBookings ?? this.acceptedBookings,
    startedBookings: startedBookings ?? this.startedBookings,
    expiredBookings: expiredBookings ?? this.expiredBookings,
    totalSpent: totalSpent ?? this.totalSpent,
    totalDistance: totalDistance ?? this.totalDistance,
    totalDuration: totalDuration ?? this.totalDuration,
    averageRatingGiven: averageRatingGiven ?? this.averageRatingGiven,
    averageRatingReceived: averageRatingReceived ?? this.averageRatingReceived,
    totalPromoSavings: totalPromoSavings ?? this.totalPromoSavings,
    walletUsage: walletUsage ?? this.walletUsage,
    cashPayments: cashPayments ?? this.cashPayments,
    onlinePayments: onlinePayments ?? this.onlinePayments,
  );

  factory BookingStatistics.fromJson(Map<String, dynamic> json) =>
      BookingStatistics(
        totalBookings: json["total_bookings"],
        completedBookings: json["completed_bookings"],
        cancelledBookings: json["cancelled_bookings"],
        pendingBookings: json["pending_bookings"],
        acceptedBookings: json["accepted_bookings"],
        startedBookings: json["started_bookings"],
        expiredBookings: json["expired_bookings"],
        totalSpent: json["total_spent"],
        totalDistance: json["total_distance"],
        totalDuration: json["total_duration"],
        averageRatingGiven: json["average_rating_given"],
        averageRatingReceived: json["average_rating_received"],
        totalPromoSavings: json["total_promo_savings"],
        walletUsage: json["wallet_usage"],
        cashPayments: json["cash_payments"],
        onlinePayments: json["online_payments"],
      );

  Map<String, dynamic> toJson() => {
    "total_bookings": totalBookings,
    "completed_bookings": completedBookings,
    "cancelled_bookings": cancelledBookings,
    "pending_bookings": pendingBookings,
    "accepted_bookings": acceptedBookings,
    "started_bookings": startedBookings,
    "expired_bookings": expiredBookings,
    "total_spent": totalSpent,
    "total_distance": totalDistance,
    "total_duration": totalDuration,
    "average_rating_given": averageRatingGiven,
    "average_rating_received": averageRatingReceived,
    "total_promo_savings": totalPromoSavings,
    "wallet_usage": walletUsage,
    "cash_payments": cashPayments,
    "online_payments": onlinePayments,
  };
}

class ComprehensiveStatistics {
  String? totalTransactions;
  String? totalPromoUsages;
  String? totalSupportTickets;
  String? openSupportTickets;
  String? resolvedSupportTickets;
  String? totalWalletTransactions;
  String? totalPromoSavings;
  String? totalTransactionAmount;

  ComprehensiveStatistics({
    this.totalTransactions,
    this.totalPromoUsages,
    this.totalSupportTickets,
    this.openSupportTickets,
    this.resolvedSupportTickets,
    this.totalWalletTransactions,
    this.totalPromoSavings,
    this.totalTransactionAmount,
  });

  ComprehensiveStatistics copyWith({
    String? totalTransactions,
    String? totalPromoUsages,
    String? totalSupportTickets,
    String? openSupportTickets,
    String? resolvedSupportTickets,
    String? totalWalletTransactions,
    String? totalPromoSavings,
    String? totalTransactionAmount,
  }) => ComprehensiveStatistics(
    totalTransactions: totalTransactions ?? this.totalTransactions,
    totalPromoUsages: totalPromoUsages ?? this.totalPromoUsages,
    totalSupportTickets: totalSupportTickets ?? this.totalSupportTickets,
    openSupportTickets: openSupportTickets ?? this.openSupportTickets,
    resolvedSupportTickets:
        resolvedSupportTickets ?? this.resolvedSupportTickets,
    totalWalletTransactions:
        totalWalletTransactions ?? this.totalWalletTransactions,
    totalPromoSavings: totalPromoSavings ?? this.totalPromoSavings,
    totalTransactionAmount:
        totalTransactionAmount ?? this.totalTransactionAmount,
  );

  factory ComprehensiveStatistics.fromJson(Map<String, dynamic> json) =>
      ComprehensiveStatistics(
        totalTransactions: json["total_transactions"],
        totalPromoUsages: json["total_promo_usages"],
        totalSupportTickets: json["total_support_tickets"],
        openSupportTickets: json["open_support_tickets"],
        resolvedSupportTickets: json["resolved_support_tickets"],
        totalWalletTransactions: json["total_wallet_transactions"],
        totalPromoSavings: json["total_promo_savings"],
        totalTransactionAmount: json["total_transaction_amount"],
      );

  Map<String, dynamic> toJson() => {
    "total_transactions": totalTransactions,
    "total_promo_usages": totalPromoUsages,
    "total_support_tickets": totalSupportTickets,
    "open_support_tickets": openSupportTickets,
    "resolved_support_tickets": resolvedSupportTickets,
    "total_wallet_transactions": totalWalletTransactions,
    "total_promo_savings": totalPromoSavings,
    "total_transaction_amount": totalTransactionAmount,
  };
}

class MonthlyStatistic {
  String? month;
  String? monthName;
  String? totalBookings;
  String? completedBookings;
  String? totalSpent;
  String? totalDistance;

  MonthlyStatistic({
    this.month,
    this.monthName,
    this.totalBookings,
    this.completedBookings,
    this.totalSpent,
    this.totalDistance,
  });

  MonthlyStatistic copyWith({
    String? month,
    String? monthName,
    String? totalBookings,
    String? completedBookings,
    String? totalSpent,
    String? totalDistance,
  }) => MonthlyStatistic(
    month: month ?? this.month,
    monthName: monthName ?? this.monthName,
    totalBookings: totalBookings ?? this.totalBookings,
    completedBookings: completedBookings ?? this.completedBookings,
    totalSpent: totalSpent ?? this.totalSpent,
    totalDistance: totalDistance ?? this.totalDistance,
  );

  factory MonthlyStatistic.fromJson(Map<String, dynamic> json) =>
      MonthlyStatistic(
        month: json["month"],
        monthName: json["month_name"],
        totalBookings: json["total_bookings"],
        completedBookings: json["completed_bookings"],
        totalSpent: json["total_spent"],
        totalDistance: json["total_distance"],
      );

  Map<String, dynamic> toJson() => {
    "month": month,
    "month_name": monthName,
    "total_bookings": totalBookings,
    "completed_bookings": completedBookings,
    "total_spent": totalSpent,
    "total_distance": totalDistance,
  };
}

class PaymentMethods {
  String? cash;
  String? wallet;
  String? online;
  String? split;

  PaymentMethods({this.cash, this.wallet, this.online, this.split});

  PaymentMethods copyWith({
    String? cash,
    String? wallet,
    String? online,
    String? split,
  }) => PaymentMethods(
    cash: cash ?? this.cash,
    wallet: wallet ?? this.wallet,
    online: online ?? this.online,
    split: split ?? this.split,
  );

  factory PaymentMethods.fromJson(Map<String, dynamic> json) => PaymentMethods(
    cash: json["cash"],
    wallet: json["wallet"],
    online: json["online"],
    split: json["split"],
  );

  Map<String, dynamic> toJson() => {
    "cash": cash,
    "wallet": wallet,
    "online": online,
    "split": split,
  };
}

class PromoUsage {
  String? id;
  String? promoCode;
  String? promoDescription;
  String? originalAmount;
  String? discountAmount;
  String? finalAmount;
  String? bookingId;
  String? createdAt;

  PromoUsage({
    this.id,
    this.promoCode,
    this.promoDescription,
    this.originalAmount,
    this.discountAmount,
    this.finalAmount,
    this.bookingId,
    this.createdAt,
  });

  PromoUsage copyWith({
    String? id,
    String? promoCode,
    String? promoDescription,
    String? originalAmount,
    String? discountAmount,
    String? finalAmount,
    String? bookingId,
    String? createdAt,
  }) => PromoUsage(
    id: id ?? this.id,
    promoCode: promoCode ?? this.promoCode,
    promoDescription: promoDescription ?? this.promoDescription,
    originalAmount: originalAmount ?? this.originalAmount,
    discountAmount: discountAmount ?? this.discountAmount,
    finalAmount: finalAmount ?? this.finalAmount,
    bookingId: bookingId ?? this.bookingId,
    createdAt: createdAt ?? this.createdAt,
  );

  factory PromoUsage.fromJson(Map<String, dynamic> json) => PromoUsage(
    id: json["id"],
    promoCode: json["promo_code"],
    promoDescription: json["promo_description"],
    originalAmount: json["original_amount"],
    discountAmount: json["discount_amount"],
    finalAmount: json["final_amount"],
    bookingId: json["booking_id"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "promo_code": promoCode,
    "promo_description": promoDescription,
    "original_amount": originalAmount,
    "discount_amount": discountAmount,
    "final_amount": finalAmount,
    "booking_id": bookingId,
    "created_at": createdAt,
  };
}

class RecentBooking {
  String? id;
  String? bookingCode;
  String? status;
  String? paymentMethod;
  String? paymentStatus;
  String? pickupAddress;
  String? dropoffAddress;
  String? pickupLatitude;
  String? pickupLongitude;
  String? dropoffLatitude;
  String? dropoffLongitude;
  String? estimatedDistance;
  String? actualDistance;
  String? estimatedDuration;
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
  String? taxAmount;
  String? totalAmount;
  String? discountAmount;
  String? walletAmount;
  String? onlinePaidAmount;
  String? cashAmount;
  String? promoCode;
  String? userRating;
  String? userReview;
  String? driverRating;
  String? driverReview;
  String? waitingTime;
  String? otp;
  String? tripCode;
  String? scheduledAt;
  String? startedAt;
  String? completedAt;
  String? cancelledAt;
  String? cancellationReason;
  String? cancelledByType;
  String? cancelledById;
  String? driverArrivalTime;
  String? pickupTime;
  String? dropoffTime;
  User? driver;
  RecentBookingRideType? rideType;
  RecentBookingDropoffZone? pickupZone;
  RecentBookingDropoffZone? dropoffZone;
  String? createdAt;
  String? updatedAt;

  RecentBooking({
    this.id,
    this.bookingCode,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.pickupAddress,
    this.dropoffAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.estimatedDistance,
    this.actualDistance,
    this.estimatedDuration,
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
    this.taxAmount,
    this.totalAmount,
    this.discountAmount,
    this.walletAmount,
    this.onlinePaidAmount,
    this.cashAmount,
    this.promoCode,
    this.userRating,
    this.userReview,
    this.driverRating,
    this.driverReview,
    this.waitingTime,
    this.otp,
    this.tripCode,
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.cancelledByType,
    this.cancelledById,
    this.driverArrivalTime,
    this.pickupTime,
    this.dropoffTime,
    this.driver,
    this.rideType,
    this.pickupZone,
    this.dropoffZone,
    this.createdAt,
    this.updatedAt,
  });

  RecentBooking copyWith({
    String? id,
    String? bookingCode,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    String? pickupAddress,
    String? dropoffAddress,
    String? pickupLatitude,
    String? pickupLongitude,
    String? dropoffLatitude,
    String? dropoffLongitude,
    String? estimatedDistance,
    String? actualDistance,
    String? estimatedDuration,
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
    String? taxAmount,
    String? totalAmount,
    String? discountAmount,
    String? walletAmount,
    String? onlinePaidAmount,
    String? cashAmount,
    String? promoCode,
    String? userRating,
    String? userReview,
    String? driverRating,
    String? driverReview,
    String? waitingTime,
    String? otp,
    String? tripCode,
    String? scheduledAt,
    String? startedAt,
    String? completedAt,
    String? cancelledAt,
    String? cancellationReason,
    String? cancelledByType,
    String? cancelledById,
    String? driverArrivalTime,
    String? pickupTime,
    String? dropoffTime,
    User? driver,
    RecentBookingRideType? rideType,
    RecentBookingDropoffZone? pickupZone,
    RecentBookingDropoffZone? dropoffZone,
    String? createdAt,
    String? updatedAt,
  }) => RecentBooking(
    id: id ?? this.id,
    bookingCode: bookingCode ?? this.bookingCode,
    status: status ?? this.status,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    pickupAddress: pickupAddress ?? this.pickupAddress,
    dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    pickupLatitude: pickupLatitude ?? this.pickupLatitude,
    pickupLongitude: pickupLongitude ?? this.pickupLongitude,
    dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
    dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
    estimatedDistance: estimatedDistance ?? this.estimatedDistance,
    actualDistance: actualDistance ?? this.actualDistance,
    estimatedDuration: estimatedDuration ?? this.estimatedDuration,
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
    taxAmount: taxAmount ?? this.taxAmount,
    totalAmount: totalAmount ?? this.totalAmount,
    discountAmount: discountAmount ?? this.discountAmount,
    walletAmount: walletAmount ?? this.walletAmount,
    onlinePaidAmount: onlinePaidAmount ?? this.onlinePaidAmount,
    cashAmount: cashAmount ?? this.cashAmount,
    promoCode: promoCode ?? this.promoCode,
    userRating: userRating ?? this.userRating,
    userReview: userReview ?? this.userReview,
    driverRating: driverRating ?? this.driverRating,
    driverReview: driverReview ?? this.driverReview,
    waitingTime: waitingTime ?? this.waitingTime,
    otp: otp ?? this.otp,
    tripCode: tripCode ?? this.tripCode,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    cancelledAt: cancelledAt ?? this.cancelledAt,
    cancellationReason: cancellationReason ?? this.cancellationReason,
    cancelledByType: cancelledByType ?? this.cancelledByType,
    cancelledById: cancelledById ?? this.cancelledById,
    driverArrivalTime: driverArrivalTime ?? this.driverArrivalTime,
    pickupTime: pickupTime ?? this.pickupTime,
    dropoffTime: dropoffTime ?? this.dropoffTime,
    driver: driver ?? this.driver,
    rideType: rideType ?? this.rideType,
    pickupZone: pickupZone ?? this.pickupZone,
    dropoffZone: dropoffZone ?? this.dropoffZone,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory RecentBooking.fromJson(Map<String, dynamic> json) => RecentBooking(
    id: json["id"],
    bookingCode: json["booking_code"],
    status: json["status"],
    paymentMethod: json["payment_method"],
    paymentStatus: json["payment_status"],
    pickupAddress: json["pickup_address"],
    dropoffAddress: json["dropoff_address"],
    pickupLatitude: json["pickup_latitude"],
    pickupLongitude: json["pickup_longitude"],
    dropoffLatitude: json["dropoff_latitude"],
    dropoffLongitude: json["dropoff_longitude"],
    estimatedDistance: json["estimated_distance"],
    actualDistance: json["actual_distance"],
    estimatedDuration: json["estimated_duration"],
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
    taxAmount: json["tax_amount"],
    totalAmount: json["total_amount"],
    discountAmount: json["discount_amount"],
    walletAmount: json["wallet_amount"],
    onlinePaidAmount: json["online_paid_amount"],
    cashAmount: json["cash_amount"],
    promoCode: json["promo_code"],
    userRating: json["user_rating"],
    userReview: json["user_review"],
    driverRating: json["driver_rating"],
    driverReview: json["driver_review"],
    waitingTime: json["waiting_time"],
    otp: json["otp"],
    tripCode: json["trip_code"],
    scheduledAt: json["scheduled_at"],
    startedAt: json["started_at"],
    completedAt: json["completed_at"],
    cancelledAt: json["cancelled_at"],
    cancellationReason: json["cancellation_reason"],
    cancelledByType: json["cancelled_by_type"],
    cancelledById: json["cancelled_by_id"],
    driverArrivalTime: json["driver_arrival_time"],
    pickupTime: json["pickup_time"],
    dropoffTime: json["dropoff_time"],
    driver: json["driver"] == null ? null : User.fromJson(json["driver"]),
    rideType: json["ride_type"] == null
        ? null
        : RecentBookingRideType.fromJson(json["ride_type"]),
    pickupZone: json["pickup_zone"] == null
        ? null
        : RecentBookingDropoffZone.fromJson(json["pickup_zone"]),
    dropoffZone: json["dropoff_zone"] == null
        ? null
        : RecentBookingDropoffZone.fromJson(json["dropoff_zone"]),
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_code": bookingCode,
    "status": status,
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
    "pickup_address": pickupAddress,
    "dropoff_address": dropoffAddress,
    "pickup_latitude": pickupLatitude,
    "pickup_longitude": pickupLongitude,
    "dropoff_latitude": dropoffLatitude,
    "dropoff_longitude": dropoffLongitude,
    "estimated_distance": estimatedDistance,
    "actual_distance": actualDistance,
    "estimated_duration": estimatedDuration,
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
    "tax_amount": taxAmount,
    "total_amount": totalAmount,
    "discount_amount": discountAmount,
    "wallet_amount": walletAmount,
    "online_paid_amount": onlinePaidAmount,
    "cash_amount": cashAmount,
    "promo_code": promoCode,
    "user_rating": userRating,
    "user_review": userReview,
    "driver_rating": driverRating,
    "driver_review": driverReview,
    "waiting_time": waitingTime,
    "otp": otp,
    "trip_code": tripCode,
    "scheduled_at": scheduledAt,
    "started_at": startedAt,
    "completed_at": completedAt,
    "cancelled_at": cancelledAt,
    "cancellation_reason": cancellationReason,
    "cancelled_by_type": cancelledByType,
    "cancelled_by_id": cancelledById,
    "driver_arrival_time": driverArrivalTime,
    "pickup_time": pickupTime,
    "dropoff_time": dropoffTime,
    "driver": driver?.toJson(),
    "ride_type": rideType?.toJson(),
    "pickup_zone": pickupZone?.toJson(),
    "dropoff_zone": dropoffZone?.toJson(),
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class RecentBookingDropoffZone {
  String? id;
  String? name;

  RecentBookingDropoffZone({this.id, this.name});

  RecentBookingDropoffZone copyWith({String? id, String? name}) =>
      RecentBookingDropoffZone(id: id ?? this.id, name: name ?? this.name);

  factory RecentBookingDropoffZone.fromJson(Map<String, dynamic> json) =>
      RecentBookingDropoffZone(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class RecentBookingRideType {
  String? id;
  String? name;
  String? description;

  RecentBookingRideType({this.id, this.name, this.description});

  RecentBookingRideType copyWith({
    String? id,
    String? name,
    String? description,
  }) => RecentBookingRideType(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
  );

  factory RecentBookingRideType.fromJson(Map<String, dynamic> json) =>
      RecentBookingRideType(
        id: json["id"],
        name: json["name"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
  };
}

class Referrer {
  String? id;
  String? name;
  String? phone;
  String? referralCode;

  Referrer({this.id, this.name, this.phone, this.referralCode});

  Referrer copyWith({
    String? id,
    String? name,
    String? phone,
    String? referralCode,
  }) => Referrer(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    referralCode: referralCode ?? this.referralCode,
  );

  factory Referrer.fromJson(Map<String, dynamic> json) => Referrer(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    referralCode: json["referral_code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "referral_code": referralCode,
  };
}

class TripHistory {
  String? id;
  String? bookingCode;
  String? tripCode;
  String? status;
  String? paymentMethod;
  String? paymentStatus;
  String? pickupAddress;
  String? dropoffAddress;
  String? pickupLatitude;
  String? pickupLongitude;
  String? dropoffLatitude;
  String? dropoffLongitude;
  String? estimatedDistance;
  String? actualDistance;
  String? estimatedDuration;
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
  String? taxAmount;
  String? totalAmount;
  String? discountAmount;
  String? walletAmount;
  String? onlinePaidAmount;
  String? cashAmount;
  String? promoCode;
  String? userRating;
  String? userReview;
  String? driverRating;
  String? driverReview;
  String? waitingTime;
  String? otp;
  String? scheduledAt;
  String? startedAt;
  String? completedAt;
  String? cancelledAt;
  String? cancellationReason;
  String? cancelledByType;
  String? cancelledById;
  String? driverArrivalTime;
  String? pickupTime;
  String? dropoffTime;
  User? driver;
  TripHistoryRideType? rideType;
  TripHistoryDropoffZone? pickupZone;
  TripHistoryDropoffZone? dropoffZone;
  List<Transaction>? transactions;
  String? createdAt;
  String? updatedAt;

  TripHistory({
    this.id,
    this.bookingCode,
    this.tripCode,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.pickupAddress,
    this.dropoffAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.estimatedDistance,
    this.actualDistance,
    this.estimatedDuration,
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
    this.taxAmount,
    this.totalAmount,
    this.discountAmount,
    this.walletAmount,
    this.onlinePaidAmount,
    this.cashAmount,
    this.promoCode,
    this.userRating,
    this.userReview,
    this.driverRating,
    this.driverReview,
    this.waitingTime,
    this.otp,
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.cancelledByType,
    this.cancelledById,
    this.driverArrivalTime,
    this.pickupTime,
    this.dropoffTime,
    this.driver,
    this.rideType,
    this.pickupZone,
    this.dropoffZone,
    this.transactions,
    this.createdAt,
    this.updatedAt,
  });

  TripHistory copyWith({
    String? id,
    String? bookingCode,
    String? tripCode,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    String? pickupAddress,
    String? dropoffAddress,
    String? pickupLatitude,
    String? pickupLongitude,
    String? dropoffLatitude,
    String? dropoffLongitude,
    String? estimatedDistance,
    String? actualDistance,
    String? estimatedDuration,
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
    String? taxAmount,
    String? totalAmount,
    String? discountAmount,
    String? walletAmount,
    String? onlinePaidAmount,
    String? cashAmount,
    String? promoCode,
    String? userRating,
    String? userReview,
    String? driverRating,
    String? driverReview,
    String? waitingTime,
    String? otp,
    String? scheduledAt,
    String? startedAt,
    String? completedAt,
    String? cancelledAt,
    String? cancellationReason,
    String? cancelledByType,
    String? cancelledById,
    String? driverArrivalTime,
    String? pickupTime,
    String? dropoffTime,
    User? driver,
    TripHistoryRideType? rideType,
    TripHistoryDropoffZone? pickupZone,
    TripHistoryDropoffZone? dropoffZone,
    List<Transaction>? transactions,
    String? createdAt,
    String? updatedAt,
  }) => TripHistory(
    id: id ?? this.id,
    bookingCode: bookingCode ?? this.bookingCode,
    tripCode: tripCode ?? this.tripCode,
    status: status ?? this.status,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    pickupAddress: pickupAddress ?? this.pickupAddress,
    dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    pickupLatitude: pickupLatitude ?? this.pickupLatitude,
    pickupLongitude: pickupLongitude ?? this.pickupLongitude,
    dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
    dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
    estimatedDistance: estimatedDistance ?? this.estimatedDistance,
    actualDistance: actualDistance ?? this.actualDistance,
    estimatedDuration: estimatedDuration ?? this.estimatedDuration,
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
    taxAmount: taxAmount ?? this.taxAmount,
    totalAmount: totalAmount ?? this.totalAmount,
    discountAmount: discountAmount ?? this.discountAmount,
    walletAmount: walletAmount ?? this.walletAmount,
    onlinePaidAmount: onlinePaidAmount ?? this.onlinePaidAmount,
    cashAmount: cashAmount ?? this.cashAmount,
    promoCode: promoCode ?? this.promoCode,
    userRating: userRating ?? this.userRating,
    userReview: userReview ?? this.userReview,
    driverRating: driverRating ?? this.driverRating,
    driverReview: driverReview ?? this.driverReview,
    waitingTime: waitingTime ?? this.waitingTime,
    otp: otp ?? this.otp,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    cancelledAt: cancelledAt ?? this.cancelledAt,
    cancellationReason: cancellationReason ?? this.cancellationReason,
    cancelledByType: cancelledByType ?? this.cancelledByType,
    cancelledById: cancelledById ?? this.cancelledById,
    driverArrivalTime: driverArrivalTime ?? this.driverArrivalTime,
    pickupTime: pickupTime ?? this.pickupTime,
    dropoffTime: dropoffTime ?? this.dropoffTime,
    driver: driver ?? this.driver,
    rideType: rideType ?? this.rideType,
    pickupZone: pickupZone ?? this.pickupZone,
    dropoffZone: dropoffZone ?? this.dropoffZone,
    transactions: transactions ?? this.transactions,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory TripHistory.fromJson(Map<String, dynamic> json) => TripHistory(
    id: json["id"],
    bookingCode: json["booking_code"],
    tripCode: json["trip_code"],
    status: json["status"],
    paymentMethod: json["payment_method"],
    paymentStatus: json["payment_status"],
    pickupAddress: json["pickup_address"],
    dropoffAddress: json["dropoff_address"],
    pickupLatitude: json["pickup_latitude"],
    pickupLongitude: json["pickup_longitude"],
    dropoffLatitude: json["dropoff_latitude"],
    dropoffLongitude: json["dropoff_longitude"],
    estimatedDistance: json["estimated_distance"],
    actualDistance: json["actual_distance"],
    estimatedDuration: json["estimated_duration"],
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
    taxAmount: json["tax_amount"],
    totalAmount: json["total_amount"],
    discountAmount: json["discount_amount"],
    walletAmount: json["wallet_amount"],
    onlinePaidAmount: json["online_paid_amount"],
    cashAmount: json["cash_amount"],
    promoCode: json["promo_code"],
    userRating: json["user_rating"],
    userReview: json["user_review"],
    driverRating: json["driver_rating"],
    driverReview: json["driver_review"],
    waitingTime: json["waiting_time"],
    otp: json["otp"],
    scheduledAt: json["scheduled_at"],
    startedAt: json["started_at"],
    completedAt: json["completed_at"],
    cancelledAt: json["cancelled_at"],
    cancellationReason: json["cancellation_reason"],
    cancelledByType: json["cancelled_by_type"],
    cancelledById: json["cancelled_by_id"],
    driverArrivalTime: json["driver_arrival_time"],
    pickupTime: json["pickup_time"],
    dropoffTime: json["dropoff_time"],
    driver: json["driver"] == null ? null : User.fromJson(json["driver"]),
    rideType: json["ride_type"] == null
        ? null
        : TripHistoryRideType.fromJson(json["ride_type"]),
    pickupZone: json["pickup_zone"] == null
        ? null
        : TripHistoryDropoffZone.fromJson(json["pickup_zone"]),
    dropoffZone: json["dropoff_zone"] == null
        ? null
        : TripHistoryDropoffZone.fromJson(json["dropoff_zone"]),
    transactions: json["transactions"] == null
        ? []
        : List<Transaction>.from(
            json["transactions"]!.map((x) => Transaction.fromJson(x)),
          ),
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_code": bookingCode,
    "trip_code": tripCode,
    "status": status,
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
    "pickup_address": pickupAddress,
    "dropoff_address": dropoffAddress,
    "pickup_latitude": pickupLatitude,
    "pickup_longitude": pickupLongitude,
    "dropoff_latitude": dropoffLatitude,
    "dropoff_longitude": dropoffLongitude,
    "estimated_distance": estimatedDistance,
    "actual_distance": actualDistance,
    "estimated_duration": estimatedDuration,
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
    "tax_amount": taxAmount,
    "total_amount": totalAmount,
    "discount_amount": discountAmount,
    "wallet_amount": walletAmount,
    "online_paid_amount": onlinePaidAmount,
    "cash_amount": cashAmount,
    "promo_code": promoCode,
    "user_rating": userRating,
    "user_review": userReview,
    "driver_rating": driverRating,
    "driver_review": driverReview,
    "waiting_time": waitingTime,
    "otp": otp,
    "scheduled_at": scheduledAt,
    "started_at": startedAt,
    "completed_at": completedAt,
    "cancelled_at": cancelledAt,
    "cancellation_reason": cancellationReason,
    "cancelled_by_type": cancelledByType,
    "cancelled_by_id": cancelledById,
    "driver_arrival_time": driverArrivalTime,
    "pickup_time": pickupTime,
    "dropoff_time": dropoffTime,
    "driver": driver?.toJson(),
    "ride_type": rideType?.toJson(),
    "pickup_zone": pickupZone?.toJson(),
    "dropoff_zone": dropoffZone?.toJson(),
    "transactions": transactions == null
        ? []
        : List<dynamic>.from(transactions!.map((x) => x.toJson())),
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class TripHistoryDropoffZone {
  String? id;
  String? name;
  String? city;

  TripHistoryDropoffZone({this.id, this.name, this.city});

  TripHistoryDropoffZone copyWith({String? id, String? name, String? city}) =>
      TripHistoryDropoffZone(
        id: id ?? this.id,
        name: name ?? this.name,
        city: city ?? this.city,
      );

  factory TripHistoryDropoffZone.fromJson(Map<String, dynamic> json) =>
      TripHistoryDropoffZone(
        id: json["id"],
        name: json["name"],
        city: json["city"],
      );

  Map<String, dynamic> toJson() => {"id": id, "name": name, "city": city};
}

class TripHistoryRideType {
  String? id;
  String? name;
  String? description;
  String? baseFare;
  String? perKmRate;
  String? perMinuteRate;

  TripHistoryRideType({
    this.id,
    this.name,
    this.description,
    this.baseFare,
    this.perKmRate,
    this.perMinuteRate,
  });

  TripHistoryRideType copyWith({
    String? id,
    String? name,
    String? description,
    String? baseFare,
    String? perKmRate,
    String? perMinuteRate,
  }) => TripHistoryRideType(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    baseFare: baseFare ?? this.baseFare,
    perKmRate: perKmRate ?? this.perKmRate,
    perMinuteRate: perMinuteRate ?? this.perMinuteRate,
  );

  factory TripHistoryRideType.fromJson(Map<String, dynamic> json) =>
      TripHistoryRideType(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        baseFare: json["base_fare"],
        perKmRate: json["per_km_rate"],
        perMinuteRate: json["per_minute_rate"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "base_fare": baseFare,
    "per_km_rate": perKmRate,
    "per_minute_rate": perMinuteRate,
  };
}

class Transaction {
  String? id;
  String? transactionId;
  String? type;
  String? amount;
  String? status;
  String? paymentMethod;
  String? createdAt;

  Transaction({
    this.id,
    this.transactionId,
    this.type,
    this.amount,
    this.status,
    this.paymentMethod,
    this.createdAt,
  });

  Transaction copyWith({
    String? id,
    String? transactionId,
    String? type,
    String? amount,
    String? status,
    String? paymentMethod,
    String? createdAt,
  }) => Transaction(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    status: status ?? this.status,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    createdAt: createdAt ?? this.createdAt,
  );

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json["id"],
    transactionId: json["transaction_id"],
    type: json["type"],
    amount: json["amount"],
    status: json["status"],
    paymentMethod: json["payment_method"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "transaction_id": transactionId,
    "type": type,
    "amount": amount,
    "status": status,
    "payment_method": paymentMethod,
    "created_at": createdAt,
  };
}

class TripHistoryByStatus {
  List<Completed>? completed;
  List<Cancelled>? cancelled;
  List<Pending>? pending;

  TripHistoryByStatus({this.completed, this.cancelled, this.pending});

  TripHistoryByStatus copyWith({
    List<Completed>? completed,
    List<Cancelled>? cancelled,
    List<Pending>? pending,
  }) => TripHistoryByStatus(
    completed: completed ?? this.completed,
    cancelled: cancelled ?? this.cancelled,
    pending: pending ?? this.pending,
  );

  factory TripHistoryByStatus.fromJson(Map<String, dynamic> json) =>
      TripHistoryByStatus(
        completed: json["completed"] == null
            ? []
            : List<Completed>.from(
                json["completed"]!.map((x) => Completed.fromJson(x)),
              ),
        cancelled: json["cancelled"] == null
            ? []
            : List<Cancelled>.from(
                json["cancelled"]!.map((x) => Cancelled.fromJson(x)),
              ),
        pending: json["pending"] == null
            ? []
            : List<Pending>.from(
                json["pending"]!.map((x) => Pending.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "completed": completed == null
        ? []
        : List<dynamic>.from(completed!.map((x) => x.toJson())),
    "cancelled": cancelled == null
        ? []
        : List<dynamic>.from(cancelled!.map((x) => x.toJson())),
    "pending": pending == null
        ? []
        : List<dynamic>.from(pending!.map((x) => x.toJson())),
  };
}

class Cancelled {
  String? id;
  String? bookingCode;
  String? cancellationReason;
  String? cancelledByType;
  String? cancelledAt;

  Cancelled({
    this.id,
    this.bookingCode,
    this.cancellationReason,
    this.cancelledByType,
    this.cancelledAt,
  });

  Cancelled copyWith({
    String? id,
    String? bookingCode,
    String? cancellationReason,
    String? cancelledByType,
    String? cancelledAt,
  }) => Cancelled(
    id: id ?? this.id,
    bookingCode: bookingCode ?? this.bookingCode,
    cancellationReason: cancellationReason ?? this.cancellationReason,
    cancelledByType: cancelledByType ?? this.cancelledByType,
    cancelledAt: cancelledAt ?? this.cancelledAt,
  );

  factory Cancelled.fromJson(Map<String, dynamic> json) => Cancelled(
    id: json["id"],
    bookingCode: json["booking_code"],
    cancellationReason: json["cancellation_reason"],
    cancelledByType: json["cancelled_by_type"],
    cancelledAt: json["cancelled_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_code": bookingCode,
    "cancellation_reason": cancellationReason,
    "cancelled_by_type": cancelledByType,
    "cancelled_at": cancelledAt,
  };
}

class Completed {
  String? id;
  String? bookingCode;
  String? totalAmount;
  String? actualDistance;
  String? actualDuration;
  String? driverRating;
  String? completedAt;

  Completed({
    this.id,
    this.bookingCode,
    this.totalAmount,
    this.actualDistance,
    this.actualDuration,
    this.driverRating,
    this.completedAt,
  });

  Completed copyWith({
    String? id,
    String? bookingCode,
    String? totalAmount,
    String? actualDistance,
    String? actualDuration,
    String? driverRating,
    String? completedAt,
  }) => Completed(
    id: id ?? this.id,
    bookingCode: bookingCode ?? this.bookingCode,
    totalAmount: totalAmount ?? this.totalAmount,
    actualDistance: actualDistance ?? this.actualDistance,
    actualDuration: actualDuration ?? this.actualDuration,
    driverRating: driverRating ?? this.driverRating,
    completedAt: completedAt ?? this.completedAt,
  );

  factory Completed.fromJson(Map<String, dynamic> json) => Completed(
    id: json["id"],
    bookingCode: json["booking_code"],
    totalAmount: json["total_amount"],
    actualDistance: json["actual_distance"],
    actualDuration: json["actual_duration"],
    driverRating: json["driver_rating"],
    completedAt: json["completed_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_code": bookingCode,
    "total_amount": totalAmount,
    "actual_distance": actualDistance,
    "actual_duration": actualDuration,
    "driver_rating": driverRating,
    "completed_at": completedAt,
  };
}

class Pending {
  String? id;
  String? bookingCode;
  String? pickupAddress;
  String? dropoffAddress;
  String? estimatedAmount;
  String? createdAt;

  Pending({
    this.id,
    this.bookingCode,
    this.pickupAddress,
    this.dropoffAddress,
    this.estimatedAmount,
    this.createdAt,
  });

  Pending copyWith({
    String? id,
    String? bookingCode,
    String? pickupAddress,
    String? dropoffAddress,
    String? estimatedAmount,
    String? createdAt,
  }) => Pending(
    id: id ?? this.id,
    bookingCode: bookingCode ?? this.bookingCode,
    pickupAddress: pickupAddress ?? this.pickupAddress,
    dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    estimatedAmount: estimatedAmount ?? this.estimatedAmount,
    createdAt: createdAt ?? this.createdAt,
  );

  factory Pending.fromJson(Map<String, dynamic> json) => Pending(
    id: json["id"],
    bookingCode: json["booking_code"],
    pickupAddress: json["pickup_address"],
    dropoffAddress: json["dropoff_address"],
    estimatedAmount: json["estimated_amount"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_code": bookingCode,
    "pickup_address": pickupAddress,
    "dropoff_address": dropoffAddress,
    "estimated_amount": estimatedAmount,
    "created_at": createdAt,
  };
}

class TripHistoryStatistics {
  String? totalTrips;
  String? completedTrips;
  String? cancelledTrips;
  String? pendingTrips;
  String? acceptedTrips;
  String? startedTrips;
  String? expiredTrips;
  String? totalSpent;
  String? totalDistanceTraveled;
  String? totalTimeSpent;
  String? averageTripCost;
  String? averageTripDistance;
  String? averageTripDuration;
  String? averageRatingGiven;
  String? averageRatingReceived;
  String? totalPromoSavings;
  String? totalWalletUsed;
  String? totalCashPaid;
  String? totalOnlinePaid;
  String? completionRate;
  String? cancellationRate;

  TripHistoryStatistics({
    this.totalTrips,
    this.completedTrips,
    this.cancelledTrips,
    this.pendingTrips,
    this.acceptedTrips,
    this.startedTrips,
    this.expiredTrips,
    this.totalSpent,
    this.totalDistanceTraveled,
    this.totalTimeSpent,
    this.averageTripCost,
    this.averageTripDistance,
    this.averageTripDuration,
    this.averageRatingGiven,
    this.averageRatingReceived,
    this.totalPromoSavings,
    this.totalWalletUsed,
    this.totalCashPaid,
    this.totalOnlinePaid,
    this.completionRate,
    this.cancellationRate,
  });

  TripHistoryStatistics copyWith({
    String? totalTrips,
    String? completedTrips,
    String? cancelledTrips,
    String? pendingTrips,
    String? acceptedTrips,
    String? startedTrips,
    String? expiredTrips,
    String? totalSpent,
    String? totalDistanceTraveled,
    String? totalTimeSpent,
    String? averageTripCost,
    String? averageTripDistance,
    String? averageTripDuration,
    String? averageRatingGiven,
    String? averageRatingReceived,
    String? totalPromoSavings,
    String? totalWalletUsed,
    String? totalCashPaid,
    String? totalOnlinePaid,
    String? completionRate,
    String? cancellationRate,
  }) => TripHistoryStatistics(
    totalTrips: totalTrips ?? this.totalTrips,
    completedTrips: completedTrips ?? this.completedTrips,
    cancelledTrips: cancelledTrips ?? this.cancelledTrips,
    pendingTrips: pendingTrips ?? this.pendingTrips,
    acceptedTrips: acceptedTrips ?? this.acceptedTrips,
    startedTrips: startedTrips ?? this.startedTrips,
    expiredTrips: expiredTrips ?? this.expiredTrips,
    totalSpent: totalSpent ?? this.totalSpent,
    totalDistanceTraveled: totalDistanceTraveled ?? this.totalDistanceTraveled,
    totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
    averageTripCost: averageTripCost ?? this.averageTripCost,
    averageTripDistance: averageTripDistance ?? this.averageTripDistance,
    averageTripDuration: averageTripDuration ?? this.averageTripDuration,
    averageRatingGiven: averageRatingGiven ?? this.averageRatingGiven,
    averageRatingReceived: averageRatingReceived ?? this.averageRatingReceived,
    totalPromoSavings: totalPromoSavings ?? this.totalPromoSavings,
    totalWalletUsed: totalWalletUsed ?? this.totalWalletUsed,
    totalCashPaid: totalCashPaid ?? this.totalCashPaid,
    totalOnlinePaid: totalOnlinePaid ?? this.totalOnlinePaid,
    completionRate: completionRate ?? this.completionRate,
    cancellationRate: cancellationRate ?? this.cancellationRate,
  );

  factory TripHistoryStatistics.fromJson(Map<String, dynamic> json) =>
      TripHistoryStatistics(
        totalTrips: json["total_trips"],
        completedTrips: json["completed_trips"],
        cancelledTrips: json["cancelled_trips"],
        pendingTrips: json["pending_trips"],
        acceptedTrips: json["accepted_trips"],
        startedTrips: json["started_trips"],
        expiredTrips: json["expired_trips"],
        totalSpent: json["total_spent"],
        totalDistanceTraveled: json["total_distance_traveled"],
        totalTimeSpent: json["total_time_spent"],
        averageTripCost: json["average_trip_cost"],
        averageTripDistance: json["average_trip_distance"],
        averageTripDuration: json["average_trip_duration"],
        averageRatingGiven: json["average_rating_given"],
        averageRatingReceived: json["average_rating_received"],
        totalPromoSavings: json["total_promo_savings"],
        totalWalletUsed: json["total_wallet_used"],
        totalCashPaid: json["total_cash_paid"],
        totalOnlinePaid: json["total_online_paid"],
        completionRate: json["completion_rate"],
        cancellationRate: json["cancellation_rate"],
      );

  Map<String, dynamic> toJson() => {
    "total_trips": totalTrips,
    "completed_trips": completedTrips,
    "cancelled_trips": cancelledTrips,
    "pending_trips": pendingTrips,
    "accepted_trips": acceptedTrips,
    "started_trips": startedTrips,
    "expired_trips": expiredTrips,
    "total_spent": totalSpent,
    "total_distance_traveled": totalDistanceTraveled,
    "total_time_spent": totalTimeSpent,
    "average_trip_cost": averageTripCost,
    "average_trip_distance": averageTripDistance,
    "average_trip_duration": averageTripDuration,
    "average_rating_given": averageRatingGiven,
    "average_rating_received": averageRatingReceived,
    "total_promo_savings": totalPromoSavings,
    "total_wallet_used": totalWalletUsed,
    "total_cash_paid": totalCashPaid,
    "total_online_paid": totalOnlinePaid,
    "completion_rate": completionRate,
    "cancellation_rate": cancellationRate,
  };
}

class Wallet {
  String? id;
  String? balance;
  String? currency;
  String? createdAt;
  String? updatedAt;

  Wallet({
    this.id,
    this.balance,
    this.currency,
    this.createdAt,
    this.updatedAt,
  });

  Wallet copyWith({
    String? id,
    String? balance,
    String? currency,
    String? createdAt,
    String? updatedAt,
  }) => Wallet(
    id: id ?? this.id,
    balance: balance ?? this.balance,
    currency: currency ?? this.currency,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json["id"],
    balance: json["balance"],
    currency: json["currency"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "balance": balance,
    "currency": currency,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
