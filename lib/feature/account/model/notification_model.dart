

import 'dart:convert';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

class NotificationModel {
  bool? success;
  String? message;
  NotificationModelData? data;

  NotificationModel({this.success, this.message, this.data});

  NotificationModel copyWith({
    bool? success,
    String? message,
    NotificationModelData? data,
  }) => NotificationModel(
    success: success ?? this.success,
    message: message ?? this.message,
    data: data ?? this.data,
  );

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : NotificationModelData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class NotificationModelData {
  List<NotificationList>? notifications;
  Pagination? pagination;

  NotificationModelData({this.notifications, this.pagination});

  NotificationModelData copyWith({
    List<NotificationList>? notifications,
    Pagination? pagination,
  }) => NotificationModelData(
    notifications: notifications ?? this.notifications,
    pagination: pagination ?? this.pagination,
  );

  factory NotificationModelData.fromJson(Map<String, dynamic> json) =>
      NotificationModelData(
        notifications: json["notifications"] == null
            ? []
            : List<NotificationList>.from(
                json["notifications"]!.map((x) => NotificationList.fromJson(x)),
              ),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "notifications": notifications == null
        ? []
        : List<dynamic>.from(notifications!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class NotificationList {
  int? id;
  String? userId;
  String? type;
  String? title;
  String? body;
  NotificationData? data;
  bool? isRead;
  String? readAt;
  bool? isSent;
  String? sentAt;
  String? fcmMessageId;
  String? status;
  String? errorMessage;
  String? createdAt;
  String? updatedAt;

  NotificationList({
    this.id,
    this.userId,
    this.type,
    this.title,
    this.body,
    this.data,
    this.isRead,
    this.readAt,
    this.isSent,
    this.sentAt,
    this.fcmMessageId,
    this.status,
    this.errorMessage,
    this.createdAt,
    this.updatedAt,
  });

  NotificationList copyWith({
    int? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    NotificationData? data,
    bool? isRead,
    String? readAt,
    bool? isSent,
    String? sentAt,
    String? fcmMessageId,
    String? status,
    String? errorMessage,
    String? createdAt,
    String? updatedAt,
  }) => NotificationList(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    type: type ?? this.type,
    title: title ?? this.title,
    body: body ?? this.body,
    data: data ?? this.data,
    isRead: isRead ?? this.isRead,
    readAt: readAt ?? this.readAt,
    isSent: isSent ?? this.isSent,
    sentAt: sentAt ?? this.sentAt,
    fcmMessageId: fcmMessageId ?? this.fcmMessageId,
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory NotificationList.fromJson(Map<String, dynamic> json) =>
      NotificationList(
        id: json["id"],
        userId: json["user_id"],
        type: json["type"],
        title: json["title"],
        body: json["body"],
        data: json["data"] == null
            ? null
            : NotificationData.fromJson(json["data"]),
        isRead: json["is_read"],
        readAt: json["read_at"],
        isSent: json["is_sent"],
        sentAt: json["sent_at"],
        fcmMessageId: json["fcm_message_id"],
        status: json["status"],
        errorMessage: json["error_message"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "type": type,
    "title": title,
    "body": body,
    "data": data?.toJson(),
    "is_read": isRead,
    "read_at": readAt,
    "is_sent": isSent,
    "sent_at": sentAt,
    "fcm_message_id": fcmMessageId,
    "status": status,
    "error_message": errorMessage,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class NotificationData {
  String? type;
  String? bookingId;
  String? bookingCode;
  String? status;
  String? driverId;

  NotificationData({
    this.type,
    this.bookingId,
    this.bookingCode,
    this.status,
    this.driverId,
  });

  NotificationData copyWith({
    String? type,
    String? bookingId,
    String? bookingCode,
    String? status,
    String? driverId,
  }) => NotificationData(
    type: type ?? this.type,
    bookingId: bookingId ?? this.bookingId,
    bookingCode: bookingCode ?? this.bookingCode,
    status: status ?? this.status,
    driverId: driverId ?? this.driverId,
  );

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        type: json["type"],
        bookingId: json["booking_id"],
        bookingCode: json["booking_code"],
        status: json["status"],
        driverId: json["driver_id"],
      );

  Map<String, dynamic> toJson() => {
    "type": type,
    "booking_id": bookingId,
    "booking_code": bookingCode,
    "status": status,
    "driver_id": driverId,
  };
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  bool? hasMore;

  Pagination({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.hasMore,
  });

  Pagination copyWith({
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
    bool? hasMore,
  }) => Pagination(
    currentPage: currentPage ?? this.currentPage,
    lastPage: lastPage ?? this.lastPage,
    perPage: perPage ?? this.perPage,
    total: total ?? this.total,
    hasMore: hasMore ?? this.hasMore,
  );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
    hasMore: json["has_more"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
    "has_more": hasMore,
  };
}
