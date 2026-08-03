

import 'dart:convert';

SupportModel supportModelFromJson(String str) =>
    SupportModel.fromJson(json.decode(str));

String supportModelToJson(SupportModel data) => json.encode(data.toJson());

class SupportModel {
  bool? success;
  String? message;
  Data? data;

  SupportModel({this.success, this.message, this.data});

  SupportModel copyWith({bool? success, String? message, Data? data}) =>
      SupportModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory SupportModel.fromJson(Map<String, dynamic> json) => SupportModel(
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
  List<Category>? categories;
  RaisedTickets? raisedTickets;
  VirtualAssistant? virtualAssistant;
  ContactSupport? contactSupport;

  Data({
    this.categories,
    this.raisedTickets,
    this.virtualAssistant,
    this.contactSupport,
  });

  Data copyWith({
    List<Category>? categories,
    RaisedTickets? raisedTickets,
    VirtualAssistant? virtualAssistant,
    ContactSupport? contactSupport,
  }) => Data(
    categories: categories ?? this.categories,
    raisedTickets: raisedTickets ?? this.raisedTickets,
    virtualAssistant: virtualAssistant ?? this.virtualAssistant,
    contactSupport: contactSupport ?? this.contactSupport,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    categories: json["categories"] == null
        ? []
        : List<Category>.from(
            json["categories"]!.map((x) => Category.fromJson(x)),
          ),
    raisedTickets: json["raised_tickets"] == null
        ? null
        : RaisedTickets.fromJson(json["raised_tickets"]),
    virtualAssistant: json["virtual_assistant"] == null
        ? null
        : VirtualAssistant.fromJson(json["virtual_assistant"]),
    contactSupport: json["contact_support"] == null
        ? null
        : ContactSupport.fromJson(json["contact_support"]),
  );

  Map<String, dynamic> toJson() => {
    "categories": categories == null
        ? []
        : List<dynamic>.from(categories!.map((x) => x.toJson())),
    "raised_tickets": raisedTickets?.toJson(),
    "virtual_assistant": virtualAssistant?.toJson(),
    "contact_support": contactSupport?.toJson(),
  };
}

class Category {
  String? id;
  String? title;
  String? description;
  String? icon;
  List<Topic>? topics;

  Category({this.id, this.title, this.description, this.icon, this.topics});

  Category copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    List<Topic>? topics,
  }) => Category(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    icon: icon ?? this.icon,
    topics: topics ?? this.topics,
  );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    icon: json["icon"],
    topics: json["topics"] == null
        ? []
        : List<Topic>.from(json["topics"]!.map((x) => Topic.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "icon": icon,
    "topics": topics == null
        ? []
        : List<dynamic>.from(topics!.map((x) => x.toJson())),
  };
}

class Topic {
  String? title;
  String? description;

  Topic({this.title, this.description});

  Topic copyWith({String? title, String? description}) => Topic(
    title: title ?? this.title,
    description: description ?? this.description,
  );

  factory Topic.fromJson(Map<String, dynamic> json) =>
      Topic(title: json["title"], description: json["description"]);

  Map<String, dynamic> toJson() => {"title": title, "description": description};
}

class ContactSupport {
  bool? available;
  String? responseTime;
  List<String>? methods;

  ContactSupport({this.available, this.responseTime, this.methods});

  ContactSupport copyWith({
    bool? available,
    String? responseTime,
    List<String>? methods,
  }) => ContactSupport(
    available: available ?? this.available,
    responseTime: responseTime ?? this.responseTime,
    methods: methods ?? this.methods,
  );

  factory ContactSupport.fromJson(Map<String, dynamic> json) => ContactSupport(
    available: json["available"],
    responseTime: json["response_time"],
    methods: json["methods"] == null
        ? []
        : List<String>.from(json["methods"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "available": available,
    "response_time": responseTime,
    "methods": methods == null
        ? []
        : List<dynamic>.from(methods!.map((x) => x)),
  };
}

class RaisedTickets {
  List<Ticket>? tickets;
  int? totalCount;
  bool? hasMore;

  RaisedTickets({this.tickets, this.totalCount, this.hasMore});

  RaisedTickets copyWith({
    List<Ticket>? tickets,
    int? totalCount,
    bool? hasMore,
  }) => RaisedTickets(
    tickets: tickets ?? this.tickets,
    totalCount: totalCount ?? this.totalCount,
    hasMore: hasMore ?? this.hasMore,
  );

  factory RaisedTickets.fromJson(Map<String, dynamic> json) => RaisedTickets(
    tickets: json["tickets"] == null
        ? []
        : List<Ticket>.from(json["tickets"]!.map((x) => Ticket.fromJson(x))),
    totalCount: json["total_count"],
    hasMore: json["has_more"],
  );

  Map<String, dynamic> toJson() => {
    "tickets": tickets == null
        ? []
        : List<dynamic>.from(tickets!.map((x) => x.toJson())),
    "total_count": totalCount,
    "has_more": hasMore,
  };
}

class Ticket {
  String? id;
  String? ticketNumber;
  String? subject;
  String? category;
  String? priority;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? resolvedAt;
  String? closedAt;
  String? lastMessage;
  String? lastMessageAt;
  String? messageCount;
  String? attachmentCount;

  Ticket({
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
    this.lastMessage,
    this.lastMessageAt,
    this.messageCount,
    this.attachmentCount,
  });

  Ticket copyWith({
    String? id,
    String? ticketNumber,
    String? subject,
    String? category,
    String? priority,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? resolvedAt,
    String? closedAt,
    String? lastMessage,
    String? lastMessageAt,
    String? messageCount,
    String? attachmentCount,
  }) => Ticket(
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
    lastMessage: lastMessage ?? this.lastMessage,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    messageCount: messageCount ?? this.messageCount,
    attachmentCount: attachmentCount ?? this.attachmentCount,
  );

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
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
    lastMessage: json["last_message"],
    lastMessageAt: json["last_message_at"],
    messageCount: json["message_count"],
    attachmentCount: json["attachment_count"],
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
    "last_message": lastMessage,
    "last_message_at": lastMessageAt,
    "message_count": messageCount,
    "attachment_count": attachmentCount,
  };
}

class VirtualAssistant {
  String? greeting;
  String? description;
  List<QuickAction>? quickActions;

  VirtualAssistant({this.greeting, this.description, this.quickActions});

  VirtualAssistant copyWith({
    String? greeting,
    String? description,
    List<QuickAction>? quickActions,
  }) => VirtualAssistant(
    greeting: greeting ?? this.greeting,
    description: description ?? this.description,
    quickActions: quickActions ?? this.quickActions,
  );

  factory VirtualAssistant.fromJson(Map<String, dynamic> json) =>
      VirtualAssistant(
        greeting: json["greeting"],
        description: json["description"],
        quickActions: json["quick_actions"] == null
            ? []
            : List<QuickAction>.from(
                json["quick_actions"]!.map((x) => QuickAction.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "greeting": greeting,
    "description": description,
    "quick_actions": quickActions == null
        ? []
        : List<dynamic>.from(quickActions!.map((x) => x.toJson())),
  };
}

class QuickAction {
  String? id;
  String? title;
  String? icon;

  QuickAction({this.id, this.title, this.icon});

  QuickAction copyWith({String? id, String? title, String? icon}) =>
      QuickAction(
        id: id ?? this.id,
        title: title ?? this.title,
        icon: icon ?? this.icon,
      );

  factory QuickAction.fromJson(Map<String, dynamic> json) =>
      QuickAction(id: json["id"], title: json["title"], icon: json["icon"]);

  Map<String, dynamic> toJson() => {"id": id, "title": title, "icon": icon};
}
