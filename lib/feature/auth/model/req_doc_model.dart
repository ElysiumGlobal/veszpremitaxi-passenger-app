class RequiredDocModel {
  bool? success;
  String? message;
  Data? data;

  RequiredDocModel({this.success, this.message, this.data});

  RequiredDocModel copyWith({bool? success, String? message, Data? data}) =>
      RequiredDocModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory RequiredDocModel.fromJson(Map<String, dynamic> json) =>
      RequiredDocModel(
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
  int? totalDocuments;
  int? totalRequired;
  List<Document>? documents;
  List<String>? generalInstructions;
  List<String>? uploadGuidelines;

  Data({
    this.totalDocuments,
    this.totalRequired,
    this.documents,
    this.generalInstructions,
    this.uploadGuidelines,
  });

  Data copyWith({
    int? totalDocuments,
    int? totalRequired,
    List<Document>? documents,
    List<String>? generalInstructions,
    List<String>? uploadGuidelines,
  }) => Data(
    totalDocuments: totalDocuments ?? this.totalDocuments,
    totalRequired: totalRequired ?? this.totalRequired,
    documents: documents ?? this.documents,
    generalInstructions: generalInstructions ?? this.generalInstructions,
    uploadGuidelines: uploadGuidelines ?? this.uploadGuidelines,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalDocuments: json["total_documents"],
    totalRequired: json["total_required"],
    documents: json["documents"] == null
        ? []
        : List<Document>.from(
            json["documents"]!.map((x) => Document.fromJson(x)),
          ),
    generalInstructions: json["general_instructions"] == null
        ? []
        : List<String>.from(json["general_instructions"]!.map((x) => x)),
    uploadGuidelines: json["upload_guidelines"] == null
        ? []
        : List<String>.from(json["upload_guidelines"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "total_documents": totalDocuments,
    "total_required": totalRequired,
    "documents": documents == null
        ? []
        : List<dynamic>.from(documents!.map((x) => x.toJson())),
    "general_instructions": generalInstructions == null
        ? []
        : List<dynamic>.from(generalInstructions!.map((x) => x)),
    "upload_guidelines": uploadGuidelines == null
        ? []
        : List<dynamic>.from(uploadGuidelines!.map((x) => x)),
  };
}

class Document {
  int? id;
  String? name;
  String? description;
  String? type;
  bool? isRequired;
  String? sortOrder;
  String? maxSize;
  List<String>? acceptedFormats;
  String? instructions;
  String? key;

  Document({
    this.id,
    this.name,
    this.description,
    this.type,
    this.isRequired,
    this.sortOrder,
    this.maxSize,
    this.acceptedFormats,
    this.instructions,
    this.key,
  });

  Document copyWith({
    int? id,
    String? name,
    String? description,
    String? type,
    bool? isRequired,
    String? sortOrder,
    String? maxSize,
    List<String>? acceptedFormats,
    String? instructions,
    String? key,
  }) => Document(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    type: type ?? this.type,
    isRequired: isRequired ?? this.isRequired,
    sortOrder: sortOrder ?? this.sortOrder,
    maxSize: maxSize ?? this.maxSize,
    acceptedFormats: acceptedFormats ?? this.acceptedFormats,
    instructions: instructions ?? this.instructions,
    key: key ?? this.key,
  );

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    type: json["type"],
    isRequired: json["is_required"],
    sortOrder: json["sort_order"],
    maxSize: json["max_size"],
    acceptedFormats: json["accepted_formats"] == null
        ? []
        : List<String>.from(json["accepted_formats"]!.map((x) => x)),
    instructions: json["instructions"],
    key: json["key"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "type": type,
    "is_required": isRequired,
    "sort_order": sortOrder,
    "max_size": maxSize,
    "accepted_formats": acceptedFormats == null
        ? []
        : List<dynamic>.from(acceptedFormats!.map((x) => x)),
    "instructions": instructions,
    "key": key,
  };
}
