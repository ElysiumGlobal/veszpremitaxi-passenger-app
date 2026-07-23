import 'dart:convert';

ChatListModel chatListModelFromJson(String str) =>
    ChatListModel.fromJson(json.decode(str));

String chatListModelToJson(ChatListModel data) => json.encode(data.toJson());

class ChatListModel {
  bool? success;
  List<Chat>? chats;
  Pagination? pagination;

  ChatListModel({this.success, this.chats, this.pagination});

  ChatListModel copyWith({
    bool? success,
    List<Chat>? chats,
    Pagination? pagination,
  }) => ChatListModel(
    success: success ?? this.success,
    chats: chats ?? this.chats,
    pagination: pagination ?? this.pagination,
  );

  factory ChatListModel.fromJson(Map<String, dynamic> json) => ChatListModel(
    success: json["success"],
    chats: json["chats"] == null
        ? []
        : List<Chat>.from(json["chats"]!.map((x) => Chat.fromJson(x))),
    pagination: json["pagination"] == null
        ? null
        : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "chats": chats == null
        ? []
        : List<dynamic>.from(chats!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Chat {
  String? id;
  String? bookingId;
  String? bookingStatus;
  String? message;
  String? messageType;
  List<dynamic>? metadata;
  bool? isRead;
  bool? isFromMe;
  OtherParticipant? sender;
  OtherParticipant? receiver;
  OtherParticipant? otherParticipant;
  String? createdAt;
  String? updatedAt;
  String? readAt;

  Chat({
    this.id,
    this.bookingId,
    this.bookingStatus,
    this.message,
    this.messageType,
    this.metadata,
    this.isRead,
    this.isFromMe,
    this.sender,
    this.receiver,
    this.otherParticipant,
    this.createdAt,
    this.updatedAt,
    this.readAt,
  });

  Chat copyWith({
    String? id,
    String? bookingId,
    String? bookingStatus,
    String? message,
    String? messageType,
    List<dynamic>? metadata,
    bool? isRead,
    bool? isFromMe,
    OtherParticipant? sender,
    OtherParticipant? receiver,
    OtherParticipant? otherParticipant,
    String? createdAt,
    String? updatedAt,
    String? readAt,
  }) => Chat(
    id: id ?? this.id,
    bookingId: bookingId ?? this.bookingId,
    bookingStatus: bookingStatus ?? this.bookingStatus,
    message: message ?? this.message,
    messageType: messageType ?? this.messageType,
    metadata: metadata ?? this.metadata,
    isRead: isRead ?? this.isRead,
    isFromMe: isFromMe ?? this.isFromMe,
    sender: sender ?? this.sender,
    receiver: receiver ?? this.receiver,
    otherParticipant: otherParticipant ?? this.otherParticipant,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    readAt: readAt ?? this.readAt,
  );

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json["id"],
    bookingId: json["booking_id"],
    bookingStatus: json["booking_status"],
    message: json["message"],
    messageType: json["message_type"],
    metadata: json["metadata"] == null
        ? []
        : List<dynamic>.from(json["metadata"]!.map((x) => x)),
    isRead: json["is_read"],
    isFromMe: json["is_from_me"],
    sender: json["sender"] == null
        ? null
        : OtherParticipant.fromJson(json["sender"]),
    receiver: json["receiver"] == null
        ? null
        : OtherParticipant.fromJson(json["receiver"]),
    otherParticipant: json["other_participant"] == null
        ? null
        : OtherParticipant.fromJson(json["other_participant"]),
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    readAt: json["read_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_id": bookingId,
    "booking_status": bookingStatus,
    "message": message,
    "message_type": messageType,
    "metadata": metadata == null
        ? []
        : List<dynamic>.from(metadata!.map((x) => x)),
    "is_read": isRead,
    "is_from_me": isFromMe,
    "sender": sender?.toJson(),
    "receiver": receiver?.toJson(),
    "other_participant": otherParticipant?.toJson(),
    "created_at": createdAt,
    "updated_at": updatedAt,
    "read_at": readAt,
  };
}

class OtherParticipant {
  String? id;
  String? name;
  String? phone;
  String? profilePhoto;
  String? role;
  String? senderType;

  OtherParticipant({
    this.id,
    this.name,
    this.phone,
    this.profilePhoto,
    this.role,
    this.senderType,
  });

  OtherParticipant copyWith({
    String? id,
    String? name,
    String? phone,
    String? profilePhoto,
    String? role,
    String? senderType,
  }) => OtherParticipant(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    role: role ?? this.role,
    senderType: senderType ?? this.senderType,
  );

  factory OtherParticipant.fromJson(Map<String, dynamic> json) =>
      OtherParticipant(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        profilePhoto: json["profile_photo"],
        role: json["role"],
        senderType: json["sender_type"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "profile_photo": profilePhoto,
    "role": role,
    "sender_type": senderType,
  };
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  int? from;
  int? to;

  Pagination({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.from,
    this.to,
  });

  Pagination copyWith({
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
    int? from,
    int? to,
  }) => Pagination(
    currentPage: currentPage ?? this.currentPage,
    lastPage: lastPage ?? this.lastPage,
    perPage: perPage ?? this.perPage,
    total: total ?? this.total,
    from: from ?? this.from,
    to: to ?? this.to,
  );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
    from: json["from"],
    to: json["to"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
    "from": from,
    "to": to,
  };
}
