class SupportChatModel {
  bool? success;
  List<ChatModel>? data;

  SupportChatModel({this.success, this.data});

  SupportChatModel copyWith({bool? success, List<ChatModel>? data}) =>
      SupportChatModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory SupportChatModel.fromJson(Map<String, dynamic> json) =>
      SupportChatModel(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<ChatModel>.from(
                json["data"]!.map((x) => ChatModel.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class ChatModel {
  int? id;
  String? userId;
  String? bookingId;
  String? adminId;
  String? senderType;
  String? message;
  String? messageType;

  // List<dynamic>? metadata;
  bool? isRead;
  dynamic readAt;
  String? status;
  String? subject;
  String? priority;
  String? createdAt;
  String? updatedAt;

  ChatModel({
    this.id,
    this.userId,
    this.bookingId,
    this.adminId,
    this.senderType,
    this.message,
    this.messageType,
    // this.metadata,
    this.isRead,
    this.readAt,
    this.status,
    this.subject,
    this.priority,
    this.createdAt,
    this.updatedAt,
  });

  ChatModel copyWith({
    int? id,
    String? userId,
    String? bookingId,
    String? adminId,
    String? senderType,
    String? message,
    String? messageType,
    List<dynamic>? metadata,
    bool? isRead,
    dynamic readAt,
    String? status,
    String? subject,
    String? priority,
    String? createdAt,
    String? updatedAt,
  }) => ChatModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    bookingId: bookingId ?? this.bookingId,
    adminId: adminId ?? this.adminId,
    senderType: senderType ?? this.senderType,
    message: message ?? this.message,
    messageType: messageType ?? this.messageType,
    // metadata: metadata ?? this.metadata,
    isRead: isRead ?? this.isRead,
    readAt: readAt ?? this.readAt,
    status: status ?? this.status,
    subject: subject ?? this.subject,
    priority: priority ?? this.priority,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
    id: json["id"],
    userId: json["user_id"],
    bookingId: json["booking_id"],
    adminId: json["admin_id"],
    senderType: json["sender_type"],
    message: json["message"],
    messageType: json["message_type"],
    // metadata: json["metadata"] == null ? [] : List<dynamic>.from(json["metadata"]!.map((x) => x)),
    isRead: json["is_read"],
    readAt: json["read_at"],
    status: json["status"],
    subject: json["subject"],
    priority: json["priority"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "booking_id": bookingId,
    "admin_id": adminId,
    "sender_type": senderType,
    "message": message,
    "message_type": messageType,
    // "metadata": metadata == null ? [] : List<dynamic>.from(metadata!.map((x) => x)),
    "is_read": isRead,
    "read_at": readAt,
    "status": status,
    "subject": subject,
    "priority": priority,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
