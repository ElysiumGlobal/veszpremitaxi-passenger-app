

import 'dart:convert';

TicketSupportModel ticketSupportModelFromJson(String str) =>
    TicketSupportModel.fromJson(json.decode(str));

String ticketSupportModelToJson(TicketSupportModel data) =>
    json.encode(data.toJson());

class TicketSupportModel {
  bool? success;
  String? message;
  Data? data;

  TicketSupportModel({this.success, this.message, this.data});

  TicketSupportModel copyWith({bool? success, String? message, Data? data}) =>
      TicketSupportModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory TicketSupportModel.fromJson(Map<String, dynamic> json) =>
      TicketSupportModel(
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
  int? id;
  String? ticketNumber;
  String? subject;
  String? category;
  String? priority;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? resolvedAt;
  String? closedAt;
  Booking? booking;
  List<Message>? messages;
  List<Attachment>? attachments;

  Data({
    this.id,
    this.ticketNumber,
    this.subject,
    this.category,
    this.priority,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.closedAt,
    this.booking,
    this.messages,
    this.attachments,
  });

  Data copyWith({
    int? id,
    String? ticketNumber,
    String? subject,
    String? category,
    String? priority,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? resolvedAt,
    String? closedAt,
    Booking? booking,
    List<Message>? messages,
    List<Attachment>? attachments,
  }) => Data(
    id: id ?? this.id,
    ticketNumber: ticketNumber ?? this.ticketNumber,
    subject: subject ?? this.subject,
    category: category ?? this.category,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    resolvedAt: resolvedAt ?? this.resolvedAt,
    closedAt: closedAt ?? this.closedAt,
    booking: booking ?? this.booking,
    messages: messages ?? this.messages,
    attachments: attachments ?? this.attachments,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    ticketNumber: json["ticket_number"],
    subject: json["subject"],
    category: json["category"],
    priority: json["priority"],
    status: json["status"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    resolvedAt: json["resolved_at"],
    closedAt: json["closed_at"],
    booking: json["booking"] == null ? null : Booking.fromJson(json["booking"]),
    messages: json["messages"] == null
        ? []
        : List<Message>.from(json["messages"]!.map((x) => Message.fromJson(x))),
    attachments: json["attachments"] == null
        ? []
        : List<Attachment>.from(
            json["attachments"]!.map((x) => Attachment.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ticket_number": ticketNumber,
    "subject": subject,
    "category": category,
    "priority": priority,
    "status": status,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "resolved_at": resolvedAt,
    "closed_at": closedAt,
    "booking": booking?.toJson(),
    "messages": messages == null
        ? []
        : List<dynamic>.from(messages!.map((x) => x.toJson())),
    "attachments": attachments == null
        ? []
        : List<dynamic>.from(attachments!.map((x) => x.toJson())),
  };
}

class Attachment {
  int? id;
  String? filename;
  String? originalName;
  int? fileSize;
  String? mimeType;
  String? downloadUrl;
  String? imageUrl;

  Attachment({
    this.id,
    this.filename,
    this.originalName,
    this.fileSize,
    this.mimeType,
    this.downloadUrl,
    this.imageUrl,
  });

  Attachment copyWith({
    int? id,
    String? filename,
    String? originalName,
    int? fileSize,
    String? mimeType,
    String? downloadUrl,
    String? imageUrl,
  }) => Attachment(
    id: id ?? this.id,
    filename: filename ?? this.filename,
    originalName: originalName ?? this.originalName,
    fileSize: fileSize ?? this.fileSize,
    mimeType: mimeType ?? this.mimeType,
    downloadUrl: downloadUrl ?? this.downloadUrl,
    imageUrl: imageUrl ?? this.imageUrl,
  );

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
    id: json["id"],
    filename: json["filename"],
    originalName: json["original_name"],
    fileSize: json["file_size"],
    mimeType: json["mime_type"],
    downloadUrl: json["download_url"],
    imageUrl: json["image_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "filename": filename,
    "original_name": originalName,
    "file_size": fileSize,
    "mime_type": mimeType,
    "download_url": downloadUrl,
    "image_url": imageUrl,
  };
}

class Booking {
  int? id;
  String? bookingNumber;
  String? tripId;
  String? pickupLocation;
  String? dropoffLocation;
  String? createdAt;

  Booking({
    this.id,
    this.bookingNumber,
    this.pickupLocation,
    this.dropoffLocation,
    this.createdAt,
    this.tripId,
  });

  Booking copyWith({
    int? id,
    String? bookingNumber,
    String? tripId,
    String? pickupLocation,
    String? dropoffLocation,
    String? createdAt,
  }) => Booking(
    id: id ?? this.id,
    bookingNumber: bookingNumber ?? this.bookingNumber,
    pickupLocation: pickupLocation ?? this.pickupLocation,
    dropoffLocation: dropoffLocation ?? this.dropoffLocation,
    createdAt: createdAt ?? this.createdAt,
    tripId: tripId ?? this.tripId,
  );

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json["id"],
    bookingNumber: json["booking_number"],
    pickupLocation: json["pickup_location"],
    dropoffLocation: json["dropoff_location"],
    createdAt: json["created_at"],
    tripId: json["trip_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "booking_number": bookingNumber,
    "pickup_location": pickupLocation,
    "dropoff_location": dropoffLocation,
    "created_at": createdAt,
    "trip_id": tripId,
  };
}

class Message {
  int? id;
  String? message;
  String? isFromSupport;
  String? createdAt;
  User? user;

  Message({
    this.id,
    this.message,
    this.isFromSupport,
    this.createdAt,
    this.user,
  });

  Message copyWith({
    int? id,
    String? message,
    String? isFromSupport,
    String? createdAt,
    User? user,
  }) => Message(
    id: id ?? this.id,
    message: message ?? this.message,
    isFromSupport: isFromSupport ?? this.isFromSupport,
    createdAt: createdAt ?? this.createdAt,
    user: user ?? this.user,
  );

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    message: json["message"],
    isFromSupport: json["is_from_support"],
    createdAt: json["created_at"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "message": message,
    "is_from_support": isFromSupport,
    "created_at": createdAt,
    "user": user?.toJson(),
  };
}

class User {
  int? id;
  String? name;
  String? role;

  User({this.id, this.name, this.role});

  User copyWith({int? id, String? name, String? role}) =>
      User(id: id ?? this.id, name: name ?? this.name, role: role ?? this.role);

  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json["id"], name: json["name"], role: json["role"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "role": role};
}
