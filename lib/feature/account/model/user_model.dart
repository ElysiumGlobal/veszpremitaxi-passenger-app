

import 'dart:convert';
import '../../home/model/new_ride_model.dart';

UserDataModel userDataModelFromJson(String str) =>
    UserDataModel.fromJson(json.decode(str));

String userDataModelToJson(UserDataModel data) => json.encode(data.toJson());

class UserDataModel {
  bool? success;
  String? message;
  UserModel? data;
  NewRideModel? currentRide;
  dynamic completeTrip;
  String? transsactionId;

  UserDataModel({
    this.success,
    this.message,
    this.data,
    this.currentRide,
    this.completeTrip,
    this.transsactionId,
  });

  UserDataModel copyWith({
    bool? success,
    String? message,
    UserModel? data,
    NewRideModel? currentRide,
    dynamic rideData,
    String? transsactionId,
  }) => UserDataModel(
    success: success ?? this.success,
    message: message ?? this.message,
    data: data ?? this.data,
    currentRide: currentRide ?? this.currentRide,
    completeTrip: rideData ?? this.completeTrip,
    transsactionId: transsactionId ?? this.transsactionId,
  );

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : UserModel.fromJson(json["data"]),
      currentRide: json["current_booking"] == null
          ? null
          : NewRideModel.fromJson(json["current_booking"]),
      completeTrip: json["complete_trip"] == null
          ? null
          : json["complete_trip"],
      transsactionId: json["transaction_id"] == null
          ? null
          : json["transaction_id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "current_booking": currentRide?.toJson(),
    "complete_trip": completeTrip,
    "transaction_id": transsactionId,
  };
}

class UserModel {
  String? id;
  String? name;
  String? loginDevice;

  String? email;
  String? phone;
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
  String? step0;
  String? step1;
  String? step2;
  String? step3;
  String? currentBookingId;
  String? createdAt;
  String? updatedAt;
  DriverProfile? driverProfile;
  Vehicle? vehicle;
  Wallet? wallet;
  List<VehicleDocument>? documents;
  List<VehicleDocument>? vehicleDocuments;
  CurrentLocation? currentLocation;
  CurrentAttendance? currentAttendance;
  Statistics? statistics;
  List<RecentBooking>? recentBookings;
  BookingStatistics? bookingStatistics;
  PaymentMethods? paymentMethods;
  List<MonthlyEarning>? monthlyEarnings;
  Referrer? referrer;
  String? referralsCount;
  List<RecentTransaction>? recentTransactions;
  List<SupportTicket>? supportTickets;
  List<WalletTransaction>? walletTransactions;
  List<CurrentAttendance>? attendanceHistory;
  List<CurrentLocation>? locationHistory;
  ComprehensiveStatistics? comprehensiveStatistics;
  List<TripHistory>? tripHistory;
  TripHistoryStatistics? tripHistoryStatistics;
  TripHistoryByStatus? tripHistoryByStatus;
  PerformanceMetrics? performanceMetrics;

  List<String>? availablePayment;
  WeeklyGoal? weeklyGoal;
  NightRidersBonus? nightRidersBonus;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
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
    this.driverProfile,
    this.vehicle,
    this.loginDevice,
    this.wallet,
    this.documents,
    this.vehicleDocuments,
    this.currentLocation,
    this.currentAttendance,
    this.statistics,
    this.recentBookings,
    this.bookingStatistics,
    this.paymentMethods,
    this.monthlyEarnings,
    this.referrer,
    this.referralsCount,
    this.recentTransactions,
    this.supportTickets,
    this.walletTransactions,
    this.attendanceHistory,
    this.locationHistory,
    this.comprehensiveStatistics,
    this.tripHistory,
    this.tripHistoryStatistics,
    this.tripHistoryByStatus,
    this.performanceMetrics,
    this.availablePayment,
    this.weeklyGoal,
    this.nightRidersBonus,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
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
    String? loginDevice,
    String? step2,
    String? step3,
    String? currentBookingId,
    String? createdAt,
    String? updatedAt,
    DriverProfile? driverProfile,
    Vehicle? vehicle,
    Wallet? wallet,
    List<VehicleDocument>? documents,
    List<VehicleDocument>? vehicleDocuments,
    CurrentLocation? currentLocation,
    CurrentAttendance? currentAttendance,
    Statistics? statistics,
    List<RecentBooking>? recentBookings,
    BookingStatistics? bookingStatistics,
    PaymentMethods? paymentMethods,
    List<MonthlyEarning>? monthlyEarnings,
    Referrer? referrer,
    String? referralsCount,
    List<RecentTransaction>? recentTransactions,
    List<SupportTicket>? supportTickets,
    List<WalletTransaction>? walletTransactions,
    List<CurrentAttendance>? attendanceHistory,
    List<CurrentLocation>? locationHistory,
    ComprehensiveStatistics? comprehensiveStatistics,
    List<TripHistory>? tripHistory,
    TripHistoryStatistics? tripHistoryStatistics,
    TripHistoryByStatus? tripHistoryByStatus,
    PerformanceMetrics? performanceMetrics,
    List<String>? availablePayment,
    WeeklyGoal? weeklyGoal,
    NightRidersBonus? nightRidersBonus,
  }) => UserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    loginDevice: name ?? this.loginDevice,
    email: email ?? this.email,
    phone: phone ?? this.phone,
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
    driverProfile: driverProfile ?? this.driverProfile,
    vehicle: vehicle ?? this.vehicle,
    wallet: wallet ?? this.wallet,
    documents: documents ?? this.documents,
    vehicleDocuments: vehicleDocuments ?? this.vehicleDocuments,
    currentLocation: currentLocation ?? this.currentLocation,
    currentAttendance: currentAttendance ?? this.currentAttendance,
    statistics: statistics ?? this.statistics,
    recentBookings: recentBookings ?? this.recentBookings,
    bookingStatistics: bookingStatistics ?? this.bookingStatistics,
    paymentMethods: paymentMethods ?? this.paymentMethods,
    monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
    referrer: referrer ?? this.referrer,
    referralsCount: referralsCount ?? this.referralsCount,
    recentTransactions: recentTransactions ?? this.recentTransactions,
    supportTickets: supportTickets ?? this.supportTickets,
    walletTransactions: walletTransactions ?? this.walletTransactions,
    attendanceHistory: attendanceHistory ?? this.attendanceHistory,
    locationHistory: locationHistory ?? this.locationHistory,
    comprehensiveStatistics:
        comprehensiveStatistics ?? this.comprehensiveStatistics,
    tripHistory: tripHistory ?? this.tripHistory,
    tripHistoryStatistics: tripHistoryStatistics ?? this.tripHistoryStatistics,
    tripHistoryByStatus: tripHistoryByStatus ?? this.tripHistoryByStatus,
    performanceMetrics: performanceMetrics ?? this.performanceMetrics,
    availablePayment: availablePayment ?? this.availablePayment,
    weeklyGoal: weeklyGoal ?? this.weeklyGoal,
    nightRidersBonus: nightRidersBonus ?? this.nightRidersBonus,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    loginDevice: json["login_device"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    countryCode: json["country_code"],
    gender: json["gender"],
    dateOfBirth: json["date_of_birth"] == null ? null : json["date_of_birth"],
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
    driverProfile: json["driver_profile"] == null
        ? null
        : DriverProfile.fromJson(json["driver_profile"]),
    vehicle: json["vehicle"] == null ? null : Vehicle.fromJson(json["vehicle"]),
    wallet: json["wallet"] == null ? null : Wallet.fromJson(json["wallet"]),
    documents: json["documents"] == null
        ? []
        : List<VehicleDocument>.from(
            json["documents"]!.map((x) => VehicleDocument.fromJson(x)),
          ),
    vehicleDocuments: json["vehicle_documents"] == null
        ? []
        : List<VehicleDocument>.from(
            json["vehicle_documents"]!.map((x) => VehicleDocument.fromJson(x)),
          ),
    currentLocation: json["current_location"] == null
        ? null
        : CurrentLocation.fromJson(json["current_location"]),
    currentAttendance: json["current_attendance"] == null
        ? null
        : CurrentAttendance.fromJson(json["current_attendance"]),
    statistics: json["statistics"] == null
        ? null
        : Statistics.fromJson(json["statistics"]),
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
    monthlyEarnings: json["monthly_earnings"] == null
        ? []
        : List<MonthlyEarning>.from(
            json["monthly_earnings"]!.map((x) => MonthlyEarning.fromJson(x)),
          ),
    referrer: json["referrer"] == null
        ? null
        : Referrer.fromJson(json["referrer"]),
    referralsCount: json["referrals_count"],
    recentTransactions: json["recent_transactions"] == null
        ? []
        : List<RecentTransaction>.from(
            json["recent_transactions"]!.map(
              (x) => RecentTransaction.fromJson(x),
            ),
          ),
    supportTickets: json["support_tickets"] == null
        ? []
        : List<SupportTicket>.from(
            json["support_tickets"]!.map((x) => SupportTicket.fromJson(x)),
          ),
    walletTransactions: json["wallet_transactions"] == null
        ? []
        : List<WalletTransaction>.from(
            json["wallet_transactions"]!.map(
              (x) => WalletTransaction.fromJson(x),
            ),
          ),
    attendanceHistory: json["attendance_history"] == null
        ? []
        : List<CurrentAttendance>.from(
            json["attendance_history"]!.map(
              (x) => CurrentAttendance.fromJson(x),
            ),
          ),
    locationHistory: json["location_history"] == null
        ? []
        : List<CurrentLocation>.from(
            json["location_history"]!.map((x) => CurrentLocation.fromJson(x)),
          ),
    comprehensiveStatistics: json["comprehensive_statistics"] == null
        ? null
        : ComprehensiveStatistics.fromJson(json["comprehensive_statistics"]),
    tripHistory: json["trip_history"] == null
        ? []
        : List<TripHistory>.from(
            json["trip_history"]!.map((x) => TripHistory.fromJson(x)),
          ),
    tripHistoryStatistics: json["trip_history_statistics"] == null
        ? null
        : TripHistoryStatistics.fromJson(json["trip_history_statistics"]),
    tripHistoryByStatus: json["trip_history_by_status"] == null
        ? null
        : TripHistoryByStatus.fromJson(json["trip_history_by_status"]),
    performanceMetrics: json["performance_metrics"] == null
        ? null
        : PerformanceMetrics.fromJson(json["performance_metrics"]),
    availablePayment: json["available_payment"] == null
        ? []
        : List<String>.from(json["available_payment"]!.map((x) => x)),
    weeklyGoal: json["weekly_goal"] == null
        ? null
        : WeeklyGoal.fromJson(json["weekly_goal"]),
    nightRidersBonus: json["night_riders_bonus"] == null
        ? null
        : NightRidersBonus.fromJson(json["night_riders_bonus"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "login_device": loginDevice,
    "name": name,
    "email": email,
    "phone": phone,
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
    "driver_profile": driverProfile?.toJson(),
    "vehicle": vehicle?.toJson(),
    "wallet": wallet?.toJson(),
    "documents": documents == null
        ? []
        : List<dynamic>.from(documents!.map((x) => x.toJson())),
    "vehicle_documents": vehicleDocuments == null
        ? []
        : List<dynamic>.from(vehicleDocuments!.map((x) => x.toJson())),
    "current_location": currentLocation?.toJson(),
    "current_attendance": currentAttendance?.toJson(),
    "statistics": statistics?.toJson(),
    "recent_bookings": recentBookings == null
        ? []
        : List<dynamic>.from(recentBookings!.map((x) => x.toJson())),
    "booking_statistics": bookingStatistics?.toJson(),
    "payment_methods": paymentMethods?.toJson(),
    "monthly_earnings": monthlyEarnings == null
        ? []
        : List<dynamic>.from(monthlyEarnings!.map((x) => x.toJson())),
    "referrer": referrer?.toJson(),
    "referrals_count": referralsCount,
    "recent_transactions": recentTransactions == null
        ? []
        : List<dynamic>.from(recentTransactions!.map((x) => x.toJson())),
    "support_tickets": supportTickets == null
        ? []
        : List<dynamic>.from(supportTickets!.map((x) => x.toJson())),
    "wallet_transactions": walletTransactions == null
        ? []
        : List<dynamic>.from(walletTransactions!.map((x) => x.toJson())),
    "attendance_history": attendanceHistory == null
        ? []
        : List<dynamic>.from(attendanceHistory!.map((x) => x.toJson())),
    "location_history": locationHistory == null
        ? []
        : List<dynamic>.from(locationHistory!.map((x) => x.toJson())),
    "comprehensive_statistics": comprehensiveStatistics?.toJson(),
    "trip_history": tripHistory == null
        ? []
        : List<dynamic>.from(tripHistory!.map((x) => x.toJson())),
    "trip_history_statistics": tripHistoryStatistics?.toJson(),
    "trip_history_by_status": tripHistoryByStatus?.toJson(),
    "performance_metrics": performanceMetrics?.toJson(),
    "available_payment": availablePayment == null
        ? []
        : List<dynamic>.from(availablePayment!.map((x) => x)),
    "weekly_goal": weeklyGoal?.toJson(),
    "night_riders_bonus": nightRidersBonus?.toJson(),
  };
}

class CurrentAttendance {
  String? id;
  String? onlineTime;
  String? offlineTime;
  String? totalOnlineHours;
  String? status;
  String? createdAt;

  CurrentAttendance({
    this.id,
    this.onlineTime,
    this.offlineTime,
    this.totalOnlineHours,
    this.status,
    this.createdAt,
  });

  CurrentAttendance copyWith({
    String? id,
    String? onlineTime,
    String? offlineTime,
    String? totalOnlineHours,
    String? status,
    String? createdAt,
  }) => CurrentAttendance(
    id: id ?? this.id,
    onlineTime: onlineTime ?? this.onlineTime,
    offlineTime: offlineTime ?? this.offlineTime,
    totalOnlineHours: totalOnlineHours ?? this.totalOnlineHours,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );

  factory CurrentAttendance.fromJson(Map<String, dynamic> json) =>
      CurrentAttendance(
        id: json["id"],
        onlineTime: json["online_time"],
        offlineTime: json["offline_time"],
        totalOnlineHours: json["total_online_hours"],
        status: json["status"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "online_time": onlineTime,
    "offline_time": offlineTime,
    "total_online_hours": totalOnlineHours,
    "status": status,
    "created_at": createdAt,
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
  String? totalEarnings;
  String? totalCommissionPaid;
  String? totalDistance;
  String? totalDuration;
  String? averageRatingReceived;
  String? averageRatingGiven;
  String? totalWaitingTime;
  String? totalWaitingCharges;
  String? totalSurgeEarnings;

  BookingStatistics({
    this.totalBookings,
    this.completedBookings,
    this.cancelledBookings,
    this.pendingBookings,
    this.acceptedBookings,
    this.startedBookings,
    this.expiredBookings,
    this.totalEarnings,
    this.totalCommissionPaid,
    this.totalDistance,
    this.totalDuration,
    this.averageRatingReceived,
    this.averageRatingGiven,
    this.totalWaitingTime,
    this.totalWaitingCharges,
    this.totalSurgeEarnings,
  });

  BookingStatistics copyWith({
    String? totalBookings,
    String? completedBookings,
    String? cancelledBookings,
    String? pendingBookings,
    String? acceptedBookings,
    String? startedBookings,
    String? expiredBookings,
    String? totalEarnings,
    String? totalCommissionPaid,
    String? totalDistance,
    String? totalDuration,
    String? averageRatingReceived,
    String? averageRatingGiven,
    String? totalWaitingTime,
    String? totalWaitingCharges,
    String? totalSurgeEarnings,
  }) => BookingStatistics(
    totalBookings: totalBookings ?? this.totalBookings,
    completedBookings: completedBookings ?? this.completedBookings,
    cancelledBookings: cancelledBookings ?? this.cancelledBookings,
    pendingBookings: pendingBookings ?? this.pendingBookings,
    acceptedBookings: acceptedBookings ?? this.acceptedBookings,
    startedBookings: startedBookings ?? this.startedBookings,
    expiredBookings: expiredBookings ?? this.expiredBookings,
    totalEarnings: totalEarnings ?? this.totalEarnings,
    totalCommissionPaid: totalCommissionPaid ?? this.totalCommissionPaid,
    totalDistance: totalDistance ?? this.totalDistance,
    totalDuration: totalDuration ?? this.totalDuration,
    averageRatingReceived: averageRatingReceived ?? this.averageRatingReceived,
    averageRatingGiven: averageRatingGiven ?? this.averageRatingGiven,
    totalWaitingTime: totalWaitingTime ?? this.totalWaitingTime,
    totalWaitingCharges: totalWaitingCharges ?? this.totalWaitingCharges,
    totalSurgeEarnings: totalSurgeEarnings ?? this.totalSurgeEarnings,
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
        totalEarnings: json["total_earnings"],
        totalCommissionPaid: json["total_commission_paid"],
        totalDistance: json["total_distance"],
        totalDuration: json["total_duration"],
        averageRatingReceived: json["average_rating_received"],
        averageRatingGiven: json["average_rating_given"],
        totalWaitingTime: json["total_waiting_time"],
        totalWaitingCharges: json["total_waiting_charges"],
        totalSurgeEarnings: json["total_surge_earnings"],
      );

  Map<String, dynamic> toJson() => {
    "total_bookings": totalBookings,
    "completed_bookings": completedBookings,
    "cancelled_bookings": cancelledBookings,
    "pending_bookings": pendingBookings,
    "accepted_bookings": acceptedBookings,
    "started_bookings": startedBookings,
    "expired_bookings": expiredBookings,
    "total_earnings": totalEarnings,
    "total_commission_paid": totalCommissionPaid,
    "total_distance": totalDistance,
    "total_duration": totalDuration,
    "average_rating_received": averageRatingReceived,
    "average_rating_given": averageRatingGiven,
    "total_waiting_time": totalWaitingTime,
    "total_waiting_charges": totalWaitingCharges,
    "total_surge_earnings": totalSurgeEarnings,
  };
}

class ComprehensiveStatistics {
  String? totalTransactions;
  String? totalSupportTickets;
  String? openSupportTickets;
  String? resolvedSupportTickets;
  String? totalWalletTransactions;
  String? totalAttendanceSessions;
  String? totalLocationUpdates;
  String? totalTransactionAmount;
  String? averageSessionDuration;
  String? totalOnlineHours;

  ComprehensiveStatistics({
    this.totalTransactions,
    this.totalSupportTickets,
    this.openSupportTickets,
    this.resolvedSupportTickets,
    this.totalWalletTransactions,
    this.totalAttendanceSessions,
    this.totalLocationUpdates,
    this.totalTransactionAmount,
    this.averageSessionDuration,
    this.totalOnlineHours,
  });

  ComprehensiveStatistics copyWith({
    String? totalTransactions,
    String? totalSupportTickets,
    String? openSupportTickets,
    String? resolvedSupportTickets,
    String? totalWalletTransactions,
    String? totalAttendanceSessions,
    String? totalLocationUpdates,
    String? totalTransactionAmount,
    String? averageSessionDuration,
    String? totalOnlineHours,
  }) => ComprehensiveStatistics(
    totalTransactions: totalTransactions ?? this.totalTransactions,
    totalSupportTickets: totalSupportTickets ?? this.totalSupportTickets,
    openSupportTickets: openSupportTickets ?? this.openSupportTickets,
    resolvedSupportTickets:
        resolvedSupportTickets ?? this.resolvedSupportTickets,
    totalWalletTransactions:
        totalWalletTransactions ?? this.totalWalletTransactions,
    totalAttendanceSessions:
        totalAttendanceSessions ?? this.totalAttendanceSessions,
    totalLocationUpdates: totalLocationUpdates ?? this.totalLocationUpdates,
    totalTransactionAmount:
        totalTransactionAmount ?? this.totalTransactionAmount,
    averageSessionDuration:
        averageSessionDuration ?? this.averageSessionDuration,
    totalOnlineHours: totalOnlineHours ?? this.totalOnlineHours,
  );

  factory ComprehensiveStatistics.fromJson(Map<String, dynamic> json) =>
      ComprehensiveStatistics(
        totalTransactions: json["total_transactions"],
        totalSupportTickets: json["total_support_tickets"],
        openSupportTickets: json["open_support_tickets"],
        resolvedSupportTickets: json["resolved_support_tickets"],
        totalWalletTransactions: json["total_wallet_transactions"],
        totalAttendanceSessions: json["total_attendance_sessions"],
        totalLocationUpdates: json["total_location_updates"],
        totalTransactionAmount: json["total_transaction_amount"],
        averageSessionDuration: json["average_session_duration"],
        totalOnlineHours: json["total_online_hours"],
      );

  Map<String, dynamic> toJson() => {
    "total_transactions": totalTransactions,
    "total_support_tickets": totalSupportTickets,
    "open_support_tickets": openSupportTickets,
    "resolved_support_tickets": resolvedSupportTickets,
    "total_wallet_transactions": totalWalletTransactions,
    "total_attendance_sessions": totalAttendanceSessions,
    "total_location_updates": totalLocationUpdates,
    "total_transaction_amount": totalTransactionAmount,
    "average_session_duration": averageSessionDuration,
    "total_online_hours": totalOnlineHours,
  };
}

class CurrentLocation {
  String? id;
  String? latitude;
  String? longitude;
  String? address;
  String? heading;
  String? speed;
  String? accuracy;
  String? batteryLevel;
  String? isCharging;
  String? isActive;
  String? recordedAt;

  CurrentLocation({
    this.id,
    this.latitude,
    this.longitude,
    this.address,
    this.heading,
    this.speed,
    this.accuracy,
    this.batteryLevel,
    this.isCharging,
    this.isActive,
    this.recordedAt,
  });

  CurrentLocation copyWith({
    String? id,
    String? latitude,
    String? longitude,
    String? address,
    String? heading,
    String? speed,
    String? accuracy,
    String? batteryLevel,
    String? isCharging,
    String? isActive,
    String? recordedAt,
  }) => CurrentLocation(
    id: id ?? this.id,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    address: address ?? this.address,
    heading: heading ?? this.heading,
    speed: speed ?? this.speed,
    accuracy: accuracy ?? this.accuracy,
    batteryLevel: batteryLevel ?? this.batteryLevel,
    isCharging: isCharging ?? this.isCharging,
    isActive: isActive ?? this.isActive,
    recordedAt: recordedAt ?? this.recordedAt,
  );

  factory CurrentLocation.fromJson(Map<String, dynamic> json) =>
      CurrentLocation(
        id: json["id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        address: json["address"],
        heading: json["heading"],
        speed: json["speed"],
        accuracy: json["accuracy"],
        batteryLevel: json["battery_level"],
        isCharging: json["is_charging"],
        isActive: json["is_active"],
        recordedAt: json["recorded_at"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "latitude": latitude,
    "longitude": longitude,
    "address": address,
    "heading": heading,
    "speed": speed,
    "accuracy": accuracy,
    "battery_level": batteryLevel,
    "is_charging": isCharging,
    "is_active": isActive,
    "recorded_at": recordedAt,
  };
}

class DriverProfile {
  String? id;
  String? cityId;
  String? cityName;
  String? address;
  String? licenseNumber;
  String? licenseExpiry;
  String? identityNumber;
  String? identityType;
  String? identityExpiry;
  String? bankName;
  String? bankAccountNumber;
  String? bankIfsc;
  String? bankBranch;
  String? accountHolderName;
  String? commissionRate;
  String? totalTrips;
  String? completedTrips;
  String? cancelledTrips;
  String? totalEarnings;
  String? totalCommission;
  String? rating;
  String? identityVerifiedAt;
  String? bankVerifiedAt;
  String? addressVerifiedAt;
  String? rejectionReason;
  String? createdAt;
  String? updatedAt;

  DriverProfile({
    this.id,
    this.cityId,
    this.cityName,
    this.address,
    this.licenseNumber,
    this.licenseExpiry,
    this.identityNumber,
    this.identityType,
    this.identityExpiry,
    this.bankName,
    this.bankAccountNumber,
    this.bankIfsc,
    this.bankBranch,
    this.accountHolderName,
    this.commissionRate,
    this.totalTrips,
    this.completedTrips,
    this.cancelledTrips,
    this.totalEarnings,
    this.totalCommission,
    this.rating,
    this.identityVerifiedAt,
    this.bankVerifiedAt,
    this.addressVerifiedAt,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  DriverProfile copyWith({
    String? id,
    String? cityId,
    String? cityName,
    String? address,
    String? licenseNumber,
    String? licenseExpiry,
    String? identityNumber,
    String? identityType,
    String? identityExpiry,
    String? bankName,
    String? bankAccountNumber,
    String? bankIfsc,
    String? bankBranch,
    String? accountHolderName,
    String? commissionRate,
    String? totalTrips,
    String? completedTrips,
    String? cancelledTrips,
    String? totalEarnings,
    String? totalCommission,
    String? rating,
    String? identityVerifiedAt,
    String? bankVerifiedAt,
    String? addressVerifiedAt,
    String? rejectionReason,
    String? createdAt,
    String? updatedAt,
  }) => DriverProfile(
    id: id ?? this.id,
    cityId: cityId ?? this.cityId,
    cityName: cityName ?? this.cityName,
    address: address ?? this.address,
    licenseNumber: licenseNumber ?? this.licenseNumber,
    licenseExpiry: licenseExpiry ?? this.licenseExpiry,
    identityNumber: identityNumber ?? this.identityNumber,
    identityType: identityType ?? this.identityType,
    identityExpiry: identityExpiry ?? this.identityExpiry,
    bankName: bankName ?? this.bankName,
    bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
    bankIfsc: bankIfsc ?? this.bankIfsc,
    bankBranch: bankBranch ?? this.bankBranch,
    accountHolderName: accountHolderName ?? this.accountHolderName,
    commissionRate: commissionRate ?? this.commissionRate,
    totalTrips: totalTrips ?? this.totalTrips,
    completedTrips: completedTrips ?? this.completedTrips,
    cancelledTrips: cancelledTrips ?? this.cancelledTrips,
    totalEarnings: totalEarnings ?? this.totalEarnings,
    totalCommission: totalCommission ?? this.totalCommission,
    rating: rating ?? this.rating,
    identityVerifiedAt: identityVerifiedAt ?? this.identityVerifiedAt,
    bankVerifiedAt: bankVerifiedAt ?? this.bankVerifiedAt,
    addressVerifiedAt: addressVerifiedAt ?? this.addressVerifiedAt,
    rejectionReason: rejectionReason ?? this.rejectionReason,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory DriverProfile.fromJson(Map<String, dynamic> json) => DriverProfile(
    id: json["id"],
    cityId: json["city_id"],
    cityName: json["city_name"],
    address: json["address"],
    licenseNumber: json["license_number"],
    licenseExpiry: json["license_expiry"],
    identityNumber: json["identity_number"],
    identityType: json["identity_type"],
    identityExpiry: json["identity_expiry"],
    bankName: json["bank_name"],
    bankAccountNumber: json["bank_account_number"],
    bankIfsc: json["bank_ifsc"],
    bankBranch: json["bank_branch"],
    accountHolderName: json["account_holder_name"],
    commissionRate: json["commission_rate"],
    totalTrips: json["total_trips"],
    completedTrips: json["completed_trips"],
    cancelledTrips: json["cancelled_trips"],
    totalEarnings: json["total_earnings"],
    totalCommission: json["total_commission"],
    rating: json["rating"],
    identityVerifiedAt: json["identity_verified_at"],
    bankVerifiedAt: json["bank_verified_at"],
    addressVerifiedAt: json["address_verified_at"],
    rejectionReason: json["rejection_reason"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "city_id": cityId,
    "city_name": cityName,
    "address": address,
    "license_number": licenseNumber,
    "license_expiry": licenseExpiry,
    "identity_number": identityNumber,
    "identity_type": identityType,
    "identity_expiry": identityExpiry,
    "bank_name": bankName,
    "bank_account_number": bankAccountNumber,
    "bank_ifsc": bankIfsc,
    "bank_branch": bankBranch,
    "account_holder_name": accountHolderName,
    "commission_rate": commissionRate,
    "total_trips": totalTrips,
    "completed_trips": completedTrips,
    "cancelled_trips": cancelledTrips,
    "total_earnings": totalEarnings,
    "total_commission": totalCommission,
    "rating": rating,
    "identity_verified_at": identityVerifiedAt,
    "bank_verified_at": bankVerifiedAt,
    "address_verified_at": addressVerifiedAt,
    "rejection_reason": rejectionReason,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class MonthlyEarning {
  String? month;
  String? monthName;
  String? totalBookings;
  String? completedBookings;
  String? totalEarnings;
  String? totalCommission;
  String? totalDistance;
  String? averageRating;

  MonthlyEarning({
    this.month,
    this.monthName,
    this.totalBookings,
    this.completedBookings,
    this.totalEarnings,
    this.totalCommission,
    this.totalDistance,
    this.averageRating,
  });

  MonthlyEarning copyWith({
    String? month,
    String? monthName,
    String? totalBookings,
    String? completedBookings,
    String? totalEarnings,
    String? totalCommission,
    String? totalDistance,
    String? averageRating,
  }) => MonthlyEarning(
    month: month ?? this.month,
    monthName: monthName ?? this.monthName,
    totalBookings: totalBookings ?? this.totalBookings,
    completedBookings: completedBookings ?? this.completedBookings,
    totalEarnings: totalEarnings ?? this.totalEarnings,
    totalCommission: totalCommission ?? this.totalCommission,
    totalDistance: totalDistance ?? this.totalDistance,
    averageRating: averageRating ?? this.averageRating,
  );

  factory MonthlyEarning.fromJson(Map<String, dynamic> json) => MonthlyEarning(
    month: json["month"],
    monthName: json["month_name"],
    totalBookings: json["total_bookings"],
    completedBookings: json["completed_bookings"],
    totalEarnings: json["total_earnings"],
    totalCommission: json["total_commission"],
    totalDistance: json["total_distance"],
    averageRating: json["average_rating"],
  );

  Map<String, dynamic> toJson() => {
    "month": month,
    "month_name": monthName,
    "total_bookings": totalBookings,
    "completed_bookings": completedBookings,
    "total_earnings": totalEarnings,
    "total_commission": totalCommission,
    "total_distance": totalDistance,
    "average_rating": averageRating,
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

class PerformanceMetrics {
  String? acceptanceRate;
  String? completionRate;
  String? cancellationRate;
  String? averageRating;
  String? total5StarRatings;
  String? total4StarRatings;
  String? total3StarRatings;
  String? total2StarRatings;
  String? total1StarRatings;

  PerformanceMetrics({
    this.acceptanceRate,
    this.completionRate,
    this.cancellationRate,
    this.averageRating,
    this.total5StarRatings,
    this.total4StarRatings,
    this.total3StarRatings,
    this.total2StarRatings,
    this.total1StarRatings,
  });

  PerformanceMetrics copyWith({
    String? acceptanceRate,
    String? completionRate,
    String? cancellationRate,
    String? averageRating,
    String? total5StarRatings,
    String? total4StarRatings,
    String? total3StarRatings,
    String? total2StarRatings,
    String? total1StarRatings,
  }) => PerformanceMetrics(
    acceptanceRate: acceptanceRate ?? this.acceptanceRate,
    completionRate: completionRate ?? this.completionRate,
    cancellationRate: cancellationRate ?? this.cancellationRate,
    averageRating: averageRating ?? this.averageRating,
    total5StarRatings: total5StarRatings ?? this.total5StarRatings,
    total4StarRatings: total4StarRatings ?? this.total4StarRatings,
    total3StarRatings: total3StarRatings ?? this.total3StarRatings,
    total2StarRatings: total2StarRatings ?? this.total2StarRatings,
    total1StarRatings: total1StarRatings ?? this.total1StarRatings,
  );

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      PerformanceMetrics(
        acceptanceRate: json["acceptance_rate"],
        completionRate: json["completion_rate"],
        cancellationRate: json["cancellation_rate"],
        averageRating: json["average_rating"],
        total5StarRatings: json["total_5_star_ratings"],
        total4StarRatings: json["total_4_star_ratings"],
        total3StarRatings: json["total_3_star_ratings"],
        total2StarRatings: json["total_2_star_ratings"],
        total1StarRatings: json["total_1_star_ratings"],
      );

  Map<String, dynamic> toJson() => {
    "acceptance_rate": acceptanceRate,
    "completion_rate": completionRate,
    "cancellation_rate": cancellationRate,
    "average_rating": averageRating,
    "total_5_star_ratings": total5StarRatings,
    "total_4_star_ratings": total4StarRatings,
    "total_3_star_ratings": total3StarRatings,
    "total_2_star_ratings": total2StarRatings,
    "total_1_star_ratings": total1StarRatings,
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
  String? adminCommissionRate;
  String? adminCommission;
  String? platformCommission;
  String? driverAmount;
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
  Referrer? user;
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
    this.adminCommissionRate,
    this.adminCommission,
    this.platformCommission,
    this.driverAmount,
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
    this.user,
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
    String? adminCommissionRate,
    String? adminCommission,
    String? platformCommission,
    String? driverAmount,
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
    Referrer? user,
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
    adminCommissionRate: adminCommissionRate ?? this.adminCommissionRate,
    adminCommission: adminCommission ?? this.adminCommission,
    platformCommission: platformCommission ?? this.platformCommission,
    driverAmount: driverAmount ?? this.driverAmount,
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
    user: user ?? this.user,
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
    adminCommissionRate: json["admin_commission_rate"],
    adminCommission: json["admin_commission"],
    platformCommission: json["platform_commission"],
    driverAmount: json["driver_amount"],
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
    user: json["user"] == null ? null : Referrer.fromJson(json["user"]),
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
    "admin_commission_rate": adminCommissionRate,
    "admin_commission": adminCommission,
    "platform_commission": platformCommission,
    "driver_amount": driverAmount,
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
    "user": user?.toJson(),
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
  String? profilePhoto;
  String? referralCode;
  String? rating;

  Referrer({
    this.id,
    this.name,
    this.phone,
    this.profilePhoto,
    this.referralCode,
    this.rating,
  });

  Referrer copyWith({
    String? id,
    String? name,
    String? phone,
    String? profilePhoto,
    String? referralCode,
    String? rating,
  }) => Referrer(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    referralCode: referralCode ?? this.referralCode,
    rating: rating ?? this.rating,
  );

  factory Referrer.fromJson(Map<String, dynamic> json) => Referrer(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    profilePhoto: json["profile_photo"],
    referralCode: json["referral_code"],
    rating: json["rating"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "profile_photo": profilePhoto,
    "referral_code": referralCode,
    "rating": rating,
  };
}

class RecentTransaction {
  String? id;
  String? transactionId;
  String? type;
  String? amount;
  String? balance;
  String? description;
  String? status;
  String? paymentMethod;
  String? currency;
  String? gatewayTransactionId;
  String? processedAt;
  String? failedAt;
  String? createdAt;

  RecentTransaction({
    this.id,
    this.transactionId,
    this.type,
    this.amount,
    this.balance,
    this.description,
    this.status,
    this.paymentMethod,
    this.currency,
    this.gatewayTransactionId,
    this.processedAt,
    this.failedAt,
    this.createdAt,
  });

  RecentTransaction copyWith({
    String? id,
    String? transactionId,
    String? type,
    String? amount,
    String? balance,
    String? description,
    String? status,
    String? paymentMethod,
    String? currency,
    String? gatewayTransactionId,
    String? processedAt,
    String? failedAt,
    String? createdAt,
  }) => RecentTransaction(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    balance: balance ?? this.balance,
    description: description ?? this.description,
    status: status ?? this.status,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    currency: currency ?? this.currency,
    gatewayTransactionId: gatewayTransactionId ?? this.gatewayTransactionId,
    processedAt: processedAt ?? this.processedAt,
    failedAt: failedAt ?? this.failedAt,
    createdAt: createdAt ?? this.createdAt,
  );

  factory RecentTransaction.fromJson(Map<String, dynamic> json) =>
      RecentTransaction(
        id: json["id"],
        transactionId: json["transaction_id"],
        type: json["type"],
        amount: json["amount"],
        balance: json["balance"],
        description: json["description"],
        status: json["status"],
        paymentMethod: json["payment_method"],
        currency: json["currency"],
        gatewayTransactionId: json["gateway_transaction_id"],
        processedAt: json["processed_at"],
        failedAt: json["failed_at"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "transaction_id": transactionId,
    "type": type,
    "amount": amount,
    "balance": balance,
    "description": description,
    "status": status,
    "payment_method": paymentMethod,
    "currency": currency,
    "gateway_transaction_id": gatewayTransactionId,
    "processed_at": processedAt,
    "failed_at": failedAt,
    "created_at": createdAt,
  };
}

class Statistics {
  String? totalTimeOnline;
  String? totalRide;
  String? totalRideCompleted;
  String? completionRate;
  String? avgRating;
  RecentTrip? recentTrip;
  HotspotArea? hotspotArea;

  Statistics({
    this.totalTimeOnline,
    this.totalRide,
    this.totalRideCompleted,
    this.completionRate,
    this.avgRating,
    this.recentTrip,
    this.hotspotArea,
  });

  Statistics copyWith({
    String? totalTimeOnline,
    String? totalRide,
    String? totalRideCompleted,
    String? completionRate,
    String? avgRating,
    RecentTrip? recentTrip,
    HotspotArea? hotspotArea,
  }) => Statistics(
    totalTimeOnline: totalTimeOnline ?? this.totalTimeOnline,
    totalRide: totalRide ?? this.totalRide,
    totalRideCompleted: totalRideCompleted ?? this.totalRideCompleted,
    completionRate: completionRate ?? this.completionRate,
    avgRating: avgRating ?? this.avgRating,
    recentTrip: recentTrip ?? this.recentTrip,
    hotspotArea: hotspotArea ?? this.hotspotArea,
  );

  factory Statistics.fromJson(Map<String, dynamic> json) => Statistics(
    totalTimeOnline: json["total_time_online"],
    totalRide: json["total_ride"],
    totalRideCompleted: json["total_ride_completed"],
    completionRate: json["completion_rate"],
    avgRating: json["avg_rating"],
    recentTrip: json["recent_trip"] == null || json["recent_trip"] == ""
        ? null
        : RecentTrip.fromJson(json["recent_trip"]),
    hotspotArea: json["hotspot_area"] == null
        ? null
        : HotspotArea.fromJson(json["hotspot_area"]),
  );

  Map<String, dynamic> toJson() => {
    "total_time_online": totalTimeOnline,
    "total_ride": totalRide,
    "total_ride_completed": totalRideCompleted,
    "completion_rate": completionRate,
    "avg_rating": avgRating,
    "recent_trip": recentTrip?.toJson(),
    "hotspot_area": hotspotArea?.toJson(),
  };
}

class HotspotArea {
  String? zoneName;
  String? tripCount;
  String? peakHours;
  String? surgeMultiplier;
  String? isSurgeActive;

  HotspotArea({
    this.zoneName,
    this.tripCount,
    this.peakHours,
    this.surgeMultiplier,
    this.isSurgeActive,
  });

  HotspotArea copyWith({
    String? zoneName,
    String? tripCount,
    String? peakHours,
    String? surgeMultiplier,
    String? isSurgeActive,
  }) => HotspotArea(
    zoneName: zoneName ?? this.zoneName,
    tripCount: tripCount ?? this.tripCount,
    peakHours: peakHours ?? this.peakHours,
    surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
    isSurgeActive: isSurgeActive ?? this.isSurgeActive,
  );

  factory HotspotArea.fromJson(Map<String, dynamic> json) => HotspotArea(
    zoneName: json["zone_name"],
    tripCount: json["trip_count"],
    peakHours: json["peak_hours"],
    surgeMultiplier: json["surge_multiplier"],
    isSurgeActive: json["is_surge_active"],
  );

  Map<String, dynamic> toJson() => {
    "zone_name": zoneName,
    "trip_count": tripCount,
    "peak_hours": peakHours,
    "surge_multiplier": surgeMultiplier,
    "is_surge_active": isSurgeActive,
  };
}

class RecentTrip {
  String? id;
  String? bookingCode;
  String? pickupAddress;
  String? dropoffAddress;
  String? pickupZoneName;
  String? totalAmount;
  String? paymentMethod;
  String? completedAt;
  String? duration;
  String? distance;
  String? rating;

  RecentTrip({
    this.id,
    this.bookingCode,
    this.pickupAddress,
    this.dropoffAddress,
    this.pickupZoneName,
    this.totalAmount,
    this.paymentMethod,
    this.completedAt,
    this.duration,
    this.distance,
    this.rating,
  });

  RecentTrip copyWith({
    String? id,
    String? bookingCode,
    String? pickupAddress,
    String? dropoffAddress,
    String? pickupZoneName,
    String? totalAmount,
    String? paymentMethod,
    String? completedAt,
    String? duration,
    String? distance,
    String? rating,
  }) => RecentTrip(
    id: id ?? this.id,
    bookingCode: bookingCode ?? this.bookingCode,
    pickupAddress: pickupAddress ?? this.pickupAddress,
    dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    pickupZoneName: pickupZoneName ?? this.pickupZoneName,
    totalAmount: totalAmount ?? this.totalAmount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    completedAt: completedAt ?? this.completedAt,
    duration: duration ?? this.duration,
    distance: distance ?? this.distance,
    rating: rating ?? this.rating,
  );

  factory RecentTrip.fromJson(Map<String, dynamic> json) => RecentTrip(
    id: json["id"],
    bookingCode: json["booking_code"],
    pickupAddress: json["pickup_address"],
    dropoffAddress: json["dropoff_address"],
    pickupZoneName: json["pickup_zone_name"],
    totalAmount: json["total_amount"],
    paymentMethod: json["payment_method"],
    completedAt: json["completed_at"],
    duration: json["duration"],
    distance: json["distance"],
    rating: json["rating"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_code": bookingCode,
    "pickup_address": pickupAddress,
    "dropoff_address": dropoffAddress,
    "pickup_zone_name": pickupZoneName,
    "total_amount": totalAmount,
    "payment_method": paymentMethod,
    "completed_at": completedAt,
    "duration": duration,
    "distance": distance,
    "rating": rating,
  };
}

class SupportTicket {
  String? id;
  String? ticketNumber;
  String? category;
  String? subject;
  String? priority;
  String? status;
  String? bookingId;
  String? lastReplyAt;
  String? resolvedAt;
  String? closedAt;
  String? createdAt;

  SupportTicket({
    this.id,
    this.ticketNumber,
    this.category,
    this.subject,
    this.priority,
    this.status,
    this.bookingId,
    this.lastReplyAt,
    this.resolvedAt,
    this.closedAt,
    this.createdAt,
  });

  SupportTicket copyWith({
    String? id,
    String? ticketNumber,
    String? category,
    String? subject,
    String? priority,
    String? status,
    String? bookingId,
    String? lastReplyAt,
    String? resolvedAt,
    String? closedAt,
    String? createdAt,
  }) => SupportTicket(
    id: id ?? this.id,
    ticketNumber: ticketNumber ?? this.ticketNumber,
    category: category ?? this.category,
    subject: subject ?? this.subject,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    bookingId: bookingId ?? this.bookingId,
    lastReplyAt: lastReplyAt ?? this.lastReplyAt,
    resolvedAt: resolvedAt ?? this.resolvedAt,
    closedAt: closedAt ?? this.closedAt,
    createdAt: createdAt ?? this.createdAt,
  );

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
    id: json["id"],
    ticketNumber: json["ticket_number"],
    category: json["category"],
    subject: json["subject"],
    priority: json["priority"],
    status: json["status"],
    bookingId: json["booking_id"],
    lastReplyAt: json["last_reply_at"],
    resolvedAt: json["resolved_at"],
    closedAt: json["closed_at"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ticket_number": ticketNumber,
    "category": category,
    "subject": subject,
    "priority": priority,
    "status": status,
    "booking_id": bookingId,
    "last_reply_at": lastReplyAt,
    "resolved_at": resolvedAt,
    "closed_at": closedAt,
    "created_at": createdAt,
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
  String? adminCommissionRate;
  String? adminCommission;
  String? platformCommission;
  String? driverAmount;
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
  Referrer? user;
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
    this.adminCommissionRate,
    this.adminCommission,
    this.platformCommission,
    this.driverAmount,
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
    this.user,
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
    String? adminCommissionRate,
    String? adminCommission,
    String? platformCommission,
    String? driverAmount,
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
    Referrer? user,
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
    adminCommissionRate: adminCommissionRate ?? this.adminCommissionRate,
    adminCommission: adminCommission ?? this.adminCommission,
    platformCommission: platformCommission ?? this.platformCommission,
    driverAmount: driverAmount ?? this.driverAmount,
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
    user: user ?? this.user,
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
    adminCommissionRate: json["admin_commission_rate"],
    adminCommission: json["admin_commission"],
    platformCommission: json["platform_commission"],
    driverAmount: json["driver_amount"],
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
    user: json["user"] == null ? null : Referrer.fromJson(json["user"]),
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
    "admin_commission_rate": adminCommissionRate,
    "admin_commission": adminCommission,
    "platform_commission": platformCommission,
    "driver_amount": driverAmount,
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
    "user": user?.toJson(),
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
  List<dynamic>? pending;

  TripHistoryByStatus({this.completed, this.cancelled, this.pending});

  TripHistoryByStatus copyWith({
    List<Completed>? completed,
    List<Cancelled>? cancelled,
    List<dynamic>? pending,
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
            : List<dynamic>.from(json["pending"]!.map((x) => x)),
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
        : List<dynamic>.from(pending!.map((x) => x)),
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
  String? driverAmount;
  String? adminCommission;
  String? actualDistance;
  String? actualDuration;
  String? driverRating;
  String? userRating;
  String? completedAt;

  Completed({
    this.id,
    this.bookingCode,
    this.driverAmount,
    this.adminCommission,
    this.actualDistance,
    this.actualDuration,
    this.driverRating,
    this.userRating,
    this.completedAt,
  });

  Completed copyWith({
    String? id,
    String? bookingCode,
    String? driverAmount,
    String? adminCommission,
    String? actualDistance,
    String? actualDuration,
    String? driverRating,
    String? userRating,
    String? completedAt,
  }) => Completed(
    id: id ?? this.id,
    bookingCode: bookingCode ?? this.bookingCode,
    driverAmount: driverAmount ?? this.driverAmount,
    adminCommission: adminCommission ?? this.adminCommission,
    actualDistance: actualDistance ?? this.actualDistance,
    actualDuration: actualDuration ?? this.actualDuration,
    driverRating: driverRating ?? this.driverRating,
    userRating: userRating ?? this.userRating,
    completedAt: completedAt ?? this.completedAt,
  );

  factory Completed.fromJson(Map<String, dynamic> json) => Completed(
    id: json["id"],
    bookingCode: json["booking_code"],
    driverAmount: json["driver_amount"],
    adminCommission: json["admin_commission"],
    actualDistance: json["actual_distance"],
    actualDuration: json["actual_duration"],
    driverRating: json["driver_rating"],
    userRating: json["user_rating"],
    completedAt: json["completed_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_code": bookingCode,
    "driver_amount": driverAmount,
    "admin_commission": adminCommission,
    "actual_distance": actualDistance,
    "actual_duration": actualDuration,
    "driver_rating": driverRating,
    "user_rating": userRating,
    "completed_at": completedAt,
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
  String? totalEarnings;
  String? totalCommissionPaid;
  String? totalDistanceDriven;
  String? totalTimeDriven;
  String? averageTripEarning;
  String? averageTripDistance;
  String? averageTripDuration;
  String? averageRatingReceived;
  String? averageRatingGiven;
  String? totalWaitingTime;
  String? totalWaitingCharges;
  String? totalSurgeEarnings;
  String? totalNightCharges;
  String? completionRate;
  String? cancellationRate;
  String? acceptanceRate;

  TripHistoryStatistics({
    this.totalTrips,
    this.completedTrips,
    this.cancelledTrips,
    this.pendingTrips,
    this.acceptedTrips,
    this.startedTrips,
    this.expiredTrips,
    this.totalEarnings,
    this.totalCommissionPaid,
    this.totalDistanceDriven,
    this.totalTimeDriven,
    this.averageTripEarning,
    this.averageTripDistance,
    this.averageTripDuration,
    this.averageRatingReceived,
    this.averageRatingGiven,
    this.totalWaitingTime,
    this.totalWaitingCharges,
    this.totalSurgeEarnings,
    this.totalNightCharges,
    this.completionRate,
    this.cancellationRate,
    this.acceptanceRate,
  });

  TripHistoryStatistics copyWith({
    String? totalTrips,
    String? completedTrips,
    String? cancelledTrips,
    String? pendingTrips,
    String? acceptedTrips,
    String? startedTrips,
    String? expiredTrips,
    String? totalEarnings,
    String? totalCommissionPaid,
    String? totalDistanceDriven,
    String? totalTimeDriven,
    String? averageTripEarning,
    String? averageTripDistance,
    String? averageTripDuration,
    String? averageRatingReceived,
    String? averageRatingGiven,
    String? totalWaitingTime,
    String? totalWaitingCharges,
    String? totalSurgeEarnings,
    String? totalNightCharges,
    String? completionRate,
    String? cancellationRate,
    String? acceptanceRate,
  }) => TripHistoryStatistics(
    totalTrips: totalTrips ?? this.totalTrips,
    completedTrips: completedTrips ?? this.completedTrips,
    cancelledTrips: cancelledTrips ?? this.cancelledTrips,
    pendingTrips: pendingTrips ?? this.pendingTrips,
    acceptedTrips: acceptedTrips ?? this.acceptedTrips,
    startedTrips: startedTrips ?? this.startedTrips,
    expiredTrips: expiredTrips ?? this.expiredTrips,
    totalEarnings: totalEarnings ?? this.totalEarnings,
    totalCommissionPaid: totalCommissionPaid ?? this.totalCommissionPaid,
    totalDistanceDriven: totalDistanceDriven ?? this.totalDistanceDriven,
    totalTimeDriven: totalTimeDriven ?? this.totalTimeDriven,
    averageTripEarning: averageTripEarning ?? this.averageTripEarning,
    averageTripDistance: averageTripDistance ?? this.averageTripDistance,
    averageTripDuration: averageTripDuration ?? this.averageTripDuration,
    averageRatingReceived: averageRatingReceived ?? this.averageRatingReceived,
    averageRatingGiven: averageRatingGiven ?? this.averageRatingGiven,
    totalWaitingTime: totalWaitingTime ?? this.totalWaitingTime,
    totalWaitingCharges: totalWaitingCharges ?? this.totalWaitingCharges,
    totalSurgeEarnings: totalSurgeEarnings ?? this.totalSurgeEarnings,
    totalNightCharges: totalNightCharges ?? this.totalNightCharges,
    completionRate: completionRate ?? this.completionRate,
    cancellationRate: cancellationRate ?? this.cancellationRate,
    acceptanceRate: acceptanceRate ?? this.acceptanceRate,
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
        totalEarnings: json["total_earnings"],
        totalCommissionPaid: json["total_commission_paid"],
        totalDistanceDriven: json["total_distance_driven"],
        totalTimeDriven: json["total_time_driven"],
        averageTripEarning: json["average_trip_earning"],
        averageTripDistance: json["average_trip_distance"],
        averageTripDuration: json["average_trip_duration"],
        averageRatingReceived: json["average_rating_received"],
        averageRatingGiven: json["average_rating_given"],
        totalWaitingTime: json["total_waiting_time"],
        totalWaitingCharges: json["total_waiting_charges"],
        totalSurgeEarnings: json["total_surge_earnings"],
        totalNightCharges: json["total_night_charges"],
        completionRate: json["completion_rate"],
        cancellationRate: json["cancellation_rate"],
        acceptanceRate: json["acceptance_rate"],
      );

  Map<String, dynamic> toJson() => {
    "total_trips": totalTrips,
    "completed_trips": completedTrips,
    "cancelled_trips": cancelledTrips,
    "pending_trips": pendingTrips,
    "accepted_trips": acceptedTrips,
    "started_trips": startedTrips,
    "expired_trips": expiredTrips,
    "total_earnings": totalEarnings,
    "total_commission_paid": totalCommissionPaid,
    "total_distance_driven": totalDistanceDriven,
    "total_time_driven": totalTimeDriven,
    "average_trip_earning": averageTripEarning,
    "average_trip_distance": averageTripDistance,
    "average_trip_duration": averageTripDuration,
    "average_rating_received": averageRatingReceived,
    "average_rating_given": averageRatingGiven,
    "total_waiting_time": totalWaitingTime,
    "total_waiting_charges": totalWaitingCharges,
    "total_surge_earnings": totalSurgeEarnings,
    "total_night_charges": totalNightCharges,
    "completion_rate": completionRate,
    "cancellation_rate": cancellationRate,
    "acceptance_rate": acceptanceRate,
  };
}

class Vehicle {
  String? id;
  String? brand;
  String? model;
  String? year;
  String? registrationNumber;
  String? licensePlate;
  String? color;
  String? rideTypeId;
  String? rideTypeName;
  String? status;
  String? registrationExpiry;
  String? insuranceExpiry;
  String? registrationStatus;
  String? rejectionReason;
  String? createdAt;
  String? updatedAt;

  Vehicle({
    this.id,
    this.registrationStatus,
    this.rejectionReason,
    this.brand,
    this.model,
    this.year,
    this.registrationNumber,
    this.licensePlate,
    this.color,
    this.rideTypeId,
    this.rideTypeName,
    this.status,
    this.registrationExpiry,
    this.insuranceExpiry,
    this.createdAt,
    this.updatedAt,
  });

  Vehicle copyWith({
    String? id,
    String? rejectionReason,
    String? registrationStatus,
    String? brand,
    String? model,
    String? year,
    String? registrationNumber,
    String? licensePlate,
    String? color,
    String? rideTypeId,
    String? rideTypeName,
    String? status,
    String? registrationExpiry,
    String? insuranceExpiry,
    String? createdAt,
    String? updatedAt,
  }) => Vehicle(
    id: id ?? this.id,
    registrationStatus: registrationStatus ?? this.registrationStatus,
    rejectionReason: rejectionReason ?? this.rejectionReason,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    year: year ?? this.year,
    registrationNumber: registrationNumber ?? this.registrationNumber,
    licensePlate: licensePlate ?? this.licensePlate,
    color: color ?? this.color,
    rideTypeId: rideTypeId ?? this.rideTypeId,
    rideTypeName: rideTypeName ?? this.rideTypeName,
    status: status ?? this.status,
    registrationExpiry: registrationExpiry ?? this.registrationExpiry,
    insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json["id"],
    rejectionReason: json["registration_rejection_reason"],
    registrationStatus: json["registration_status"],
    brand: json["brand"],
    model: json["model"],
    year: json["year"],
    registrationNumber: json["registration_number"],
    licensePlate: json["license_plate"],
    color: json["color"],
    rideTypeId: json["ride_type_id"],
    rideTypeName: json["ride_type_name"],
    status: json["status"],
    registrationExpiry: json["registration_expiry"] == null
        ? null
        : json["registration_expiry"],
    insuranceExpiry: json["insurance_expiry"] == null
        ? null
        : json["insurance_expiry"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "registration_status": registrationStatus,
    "registration_rejection_reason": rejectionReason,
    "brand": brand,
    "model": model,
    "year": year,
    "registration_number": registrationNumber,
    "license_plate": licensePlate,
    "color": color,
    "ride_type_id": rideTypeId,
    "ride_type_name": rideTypeName,
    "status": status,
    "registration_expiry": registrationExpiry,
    "insurance_expiry": insuranceExpiry,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class VehicleDocument {
  String? id;
  String? type;
  String? number;
  String? fileFront;
  String? fileBack;
  String? fileFrontUrl;
  String? fileBackUrl;
  String? expiryDate;
  String? status;
  String? rejectionReason;
  String? verifiedAt;
  String? verifiedBy;
  String? createdAt;
  String? updatedAt;
  String? isNew;
  String? name;

  VehicleDocument({
    this.id,
    this.isNew,
    this.type,
    this.number,
    this.fileFront,
    this.fileBack,
    this.fileFrontUrl,
    this.fileBackUrl,
    this.expiryDate,
    this.status,
    this.rejectionReason,
    this.verifiedAt,
    this.verifiedBy,
    this.createdAt,
    this.updatedAt,
    this.name,
  });

  VehicleDocument copyWith({
    String? id,
    String? iNew,
    String? type,
    String? number,
    String? fileFront,
    String? fileBack,
    String? fileFrontUrl,
    String? fileBackUrl,
    String? expiryDate,
    String? status,
    String? rejectionReason,
    String? verifiedAt,
    String? verifiedBy,
    String? createdAt,
    String? updatedAt,
    String? name,
  }) => VehicleDocument(
    id: id ?? this.id,
    isNew: isNew ?? this.isNew,
    type: type ?? this.type,
    number: number ?? this.number,
    fileFront: fileFront ?? this.fileFront,
    fileBack: fileBack ?? this.fileBack,
    fileFrontUrl: fileFrontUrl ?? this.fileFrontUrl,
    fileBackUrl: fileBackUrl ?? this.fileBackUrl,
    expiryDate: expiryDate ?? this.expiryDate,
    status: status ?? this.status,
    rejectionReason: rejectionReason ?? this.rejectionReason,
    verifiedAt: verifiedAt ?? this.verifiedAt,
    verifiedBy: verifiedBy ?? this.verifiedBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
  );

  factory VehicleDocument.fromJson(Map<String, dynamic> json) =>
      VehicleDocument(
        id: json["id"],
        isNew: json["is_new"],
        type: json["type"],
        number: json["number"],
        fileFront: json["file_front"],
        fileBack: json["file_back"],
        fileFrontUrl: json["file_front_url"],
        fileBackUrl: json["file_back_url"],
        expiryDate: json["expiry_date"],
        status: json["status"],
        rejectionReason: json["rejection_reason"],
        verifiedAt: json["verified_at"],
        verifiedBy: json["verified_by"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "is_new": isNew,
    "type": type,
    "number": number,
    "file_front": fileFront,
    "file_back": fileBack,
    "file_front_url": fileFrontUrl,
    "file_back_url": fileBackUrl,
    "expiry_date": expiryDate,
    "status": status,
    "rejection_reason": rejectionReason,
    "verified_at": verifiedAt,
    "verified_by": verifiedBy,
    "created_at": createdAt,
    "updated_at": updatedAt,
    'name': name,
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

class WalletTransaction {
  String? id;
  String? type;
  String? amount;
  String? balance;
  String? description;
  String? status;
  String? referenceType;
  String? referenceId;
  String? createdAt;

  WalletTransaction({
    this.id,
    this.type,
    this.amount,
    this.balance,
    this.description,
    this.status,
    this.referenceType,
    this.referenceId,
    this.createdAt,
  });

  WalletTransaction copyWith({
    String? id,
    String? type,
    String? amount,
    String? balance,
    String? description,
    String? status,
    String? referenceType,
    String? referenceId,
    String? createdAt,
  }) => WalletTransaction(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    balance: balance ?? this.balance,
    description: description ?? this.description,
    status: status ?? this.status,
    referenceType: referenceType ?? this.referenceType,
    referenceId: referenceId ?? this.referenceId,
    createdAt: createdAt ?? this.createdAt,
  );

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json["id"],
        type: json["type"],
        amount: json["amount"],
        balance: json["balance"],
        description: json["description"],
        status: json["status"],
        referenceType: json["reference_type"],
        referenceId: json["reference_id"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "amount": amount,
    "balance": balance,
    "description": description,
    "status": status,
    "reference_type": referenceType,
    "reference_id": referenceId,
    "created_at": createdAt,
  };
}

class WeeklyGoal {
  String? targetAmount;
  String? currentEarnings;
  String? bonusAmount;
  String? progressPercentage;
  String? isCompleted;
  String? deadline;
  String? weekStart;
  String? weekEnd;

  WeeklyGoal({
    this.targetAmount,
    this.currentEarnings,
    this.bonusAmount,
    this.progressPercentage,
    this.isCompleted,
    this.deadline,
    this.weekStart,
    this.weekEnd,
  });

  WeeklyGoal copyWith({
    String? targetAmount,
    String? currentEarnings,
    String? bonusAmount,
    String? progressPercentage,
    String? isCompleted,
    String? deadline,
    String? weekStart,
    String? weekEnd,
  }) => WeeklyGoal(
    targetAmount: targetAmount ?? this.targetAmount,
    currentEarnings: currentEarnings ?? this.currentEarnings,
    bonusAmount: bonusAmount ?? this.bonusAmount,
    progressPercentage: progressPercentage ?? this.progressPercentage,
    isCompleted: isCompleted ?? this.isCompleted,
    deadline: deadline ?? this.deadline,
    weekStart: weekStart ?? this.weekStart,
    weekEnd: weekEnd ?? this.weekEnd,
  );

  factory WeeklyGoal.fromJson(Map<String, dynamic> json) => WeeklyGoal(
    targetAmount: json["target_amount"],
    currentEarnings: json["current_earnings"],
    bonusAmount: json["bonus_amount"],
    progressPercentage: json["progress_percentage"],
    isCompleted: json["is_completed"],
    deadline: json["deadline"],
    weekStart: json["week_start"] == null ? null : json["week_start"],
    weekEnd: json["week_end"] == null ? null : json["week_end"],
  );

  Map<String, dynamic> toJson() => {
    "target_amount": targetAmount,
    "current_earnings": currentEarnings,
    "bonus_amount": bonusAmount,
    "progress_percentage": progressPercentage,
    "is_completed": isCompleted,
    "deadline": deadline,
    "week_start": weekStart,
    "week_end": weekEnd,
  };
}

class NightRidersBonus {
  String? title;
  String? description;
  String? targetRides;
  String? currentRides;
  String? remainingRides;
  String? bonusAmount;
  String? progressPercentage;
  String? isCompleted;
  String? timeSlot;
  String? timeSlotStart;
  String? timeSlotEnd;

  NightRidersBonus({
    this.title,
    this.description,
    this.targetRides,
    this.currentRides,
    this.remainingRides,
    this.bonusAmount,
    this.progressPercentage,
    this.isCompleted,
    this.timeSlot,
    this.timeSlotStart,
    this.timeSlotEnd,
  });

  NightRidersBonus copyWith({
    String? title,
    String? description,
    String? targetRides,
    String? currentRides,
    String? remainingRides,
    String? bonusAmount,
    String? progressPercentage,
    String? isCompleted,
    String? timeSlot,
    String? timeSlotStart,
    String? timeSlotEnd,
  }) => NightRidersBonus(
    title: title ?? this.title,
    description: description ?? this.description,
    targetRides: targetRides ?? this.targetRides,
    currentRides: currentRides ?? this.currentRides,
    remainingRides: remainingRides ?? this.remainingRides,
    bonusAmount: bonusAmount ?? this.bonusAmount,
    progressPercentage: progressPercentage ?? this.progressPercentage,
    isCompleted: isCompleted ?? this.isCompleted,
    timeSlot: timeSlot ?? this.timeSlot,
    timeSlotStart: timeSlotStart ?? this.timeSlotStart,
    timeSlotEnd: timeSlotEnd ?? this.timeSlotEnd,
  );

  factory NightRidersBonus.fromJson(Map<String, dynamic> json) =>
      NightRidersBonus(
        title: json["title"],
        description: json["description"],
        targetRides: json["target_rides"],
        currentRides: json["current_rides"],
        remainingRides: json["remaining_rides"],
        bonusAmount: json["bonus_amount"],
        progressPercentage: json["progress_percentage"],
        isCompleted: json["is_completed"],
        timeSlot: json["time_slot"],
        timeSlotStart: json["time_slot_start"],
        timeSlotEnd: json["time_slot_end"],
      );

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "target_rides": targetRides,
    "current_rides": currentRides,
    "remaining_rides": remainingRides,
    "bonus_amount": bonusAmount,
    "progress_percentage": progressPercentage,
    "is_completed": isCompleted,
    "time_slot": timeSlot,
    "time_slot_start": timeSlotStart,
    "time_slot_end": timeSlotEnd,
  };
}
