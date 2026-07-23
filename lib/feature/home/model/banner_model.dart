import 'dart:convert';

BannerModel bannerModelFromJson(String str) =>
    BannerModel.fromJson(json.decode(str));

String bannerModelToJson(BannerModel data) => json.encode(data.toJson());

class BannerModel {
  bool? success;
  Data? data;
  Meta? meta;

  BannerModel({this.success, this.data, this.meta});

  BannerModel copyWith({bool? success, Data? data, Meta? meta}) => BannerModel(
    success: success ?? this.success,
    data: data ?? this.data,
    meta: meta ?? this.meta,
  );

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
    "meta": meta?.toJson(),
  };
}

class Data {
  List<Row>? firstRow;
  List<Row>? secondRow;

  Data({this.firstRow, this.secondRow});

  Data copyWith({List<Row>? firstRow, List<Row>? secondRow}) => Data(
    firstRow: firstRow ?? this.firstRow,
    secondRow: secondRow ?? this.secondRow,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    firstRow: json["first_row"] == null
        ? []
        : List<Row>.from(json["first_row"]!.map((x) => Row.fromJson(x))),
    secondRow: json["second_row"] == null
        ? []
        : List<Row>.from(json["second_row"]!.map((x) => Row.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "first_row": firstRow == null
        ? []
        : List<dynamic>.from(firstRow!.map((x) => x.toJson())),
    "second_row": secondRow == null
        ? []
        : List<dynamic>.from(secondRow!.map((x) => x.toJson())),
  };
}

class Row {
  int? id;
  String? title;
  String? description;
  String? imageUrl;
  String? imagePath;
  String? fileName;
  String? fileType;
  int? fileSize;
  String? formattedSize;
  String? dimensions;
  int? width;
  int? height;
  String? rowPosition;
  int? sortOrder;
  bool? isActive;
  City? city;
  Link? link;
  List<dynamic>? metadata;
  String? createdAt;
  String? updatedAt;

  Row({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.imagePath,
    this.fileName,
    this.fileType,
    this.fileSize,
    this.formattedSize,
    this.dimensions,
    this.width,
    this.height,
    this.rowPosition,
    this.sortOrder,
    this.isActive,
    this.city,
    this.link,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  Row copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    String? imagePath,
    String? fileName,
    String? fileType,
    int? fileSize,
    String? formattedSize,
    String? dimensions,
    int? width,
    int? height,
    String? rowPosition,
    int? sortOrder,
    bool? isActive,
    City? city,
    Link? link,
    List<dynamic>? metadata,
    String? createdAt,
    String? updatedAt,
  }) => Row(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    imagePath: imagePath ?? this.imagePath,
    fileName: fileName ?? this.fileName,
    fileType: fileType ?? this.fileType,
    fileSize: fileSize ?? this.fileSize,
    formattedSize: formattedSize ?? this.formattedSize,
    dimensions: dimensions ?? this.dimensions,
    width: width ?? this.width,
    height: height ?? this.height,
    rowPosition: rowPosition ?? this.rowPosition,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
    city: city ?? this.city,
    link: link ?? this.link,
    metadata: metadata ?? this.metadata,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Row.fromJson(Map<String, dynamic> json) => Row(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    imageUrl: json["image_url"],
    imagePath: json["image_path"],
    fileName: json["file_name"],
    fileType: json["file_type"],
    fileSize: json["file_size"],
    formattedSize: json["formatted_size"],
    dimensions: json["dimensions"],
    width: json["width"],
    height: json["height"],
    rowPosition: json["row_position"],
    sortOrder: json["sort_order"],
    isActive: json["is_active"],
    city: City.parse(
      json["city"] ?? json["city_name"] ?? json["city_data"],
      cityId: json["city_id"],
    ),
    link: json["link"] == null ? null : Link.fromJson(json["link"]),
    metadata: json["metadata"] == null
        ? []
        : List<dynamic>.from(json["metadata"]!.map((x) => x)),
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "image_url": imageUrl,
    "image_path": imagePath,
    "file_name": fileName,
    "file_type": fileType,
    "file_size": fileSize,
    "formatted_size": formattedSize,
    "dimensions": dimensions,
    "width": width,
    "height": height,
    "row_position": rowPosition,
    "sort_order": sortOrder,
    "is_active": isActive,
    "city": city?.toJson(),
    "link": link?.toJson(),
    "metadata": metadata == null
        ? []
        : List<dynamic>.from(metadata!.map((x) => x)),
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class City {
  int? id;
  String? name;
  String? state;
  String? country;
  String? fullName;

  City({this.id, this.name, this.state, this.country, this.fullName});

  City copyWith({
    int? id,
    String? name,
    String? state,
    String? country,
    String? fullName,
  }) => City(
    id: id ?? this.id,
    name: name ?? this.name,
    state: state ?? this.state,
    country: country ?? this.country,
    fullName: fullName ?? this.fullName,
  );

  static City? parse(dynamic value, {dynamic cityId}) {
    City? parsed;
    if (value != null) {
      if (value is String && value.trim().isNotEmpty) {
        parsed = City(name: value.trim());
      } else if (value is Map<String, dynamic>) {
        parsed = City.fromJson(value);
      }
    }

    final resolvedId = parsed?.id ?? _parseCityId(cityId);
    if (parsed == null && resolvedId == null) return null;

    if (parsed != null && resolvedId != null && parsed.id == null) {
      return parsed.copyWith(id: resolvedId);
    }
    if (parsed != null) return parsed;

    return City(id: resolvedId);
  }

  static int? _parseCityId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse('$value');
  }

  factory City.fromJson(Map<String, dynamic> json) => City(
    id: json["id"],
    name: json["name"],
    state: json["state"],
    country: json["country"],
    fullName: json["full_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "state": state,
    "country": country,
    "full_name": fullName,
  };
}

class Link {
  String? url;
  String? text;
  bool? hasLink;

  Link({this.url, this.text, this.hasLink});

  Link copyWith({String? url, String? text, bool? hasLink}) => Link(
    url: url ?? this.url,
    text: text ?? this.text,
    hasLink: hasLink ?? this.hasLink,
  );

  factory Link.fromJson(Map<String, dynamic> json) =>
      Link(url: json["url"], text: json["text"], hasLink: json["has_link"]);

  Map<String, dynamic> toJson() => {
    "url": url,
    "text": text,
    "has_link": hasLink,
  };
}

class Meta {
  int? totalFirstRow;
  int? totalSecondRow;
  int? totalBanners;

  Meta({this.totalFirstRow, this.totalSecondRow, this.totalBanners});

  Meta copyWith({int? totalFirstRow, int? totalSecondRow, int? totalBanners}) =>
      Meta(
        totalFirstRow: totalFirstRow ?? this.totalFirstRow,
        totalSecondRow: totalSecondRow ?? this.totalSecondRow,
        totalBanners: totalBanners ?? this.totalBanners,
      );

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    totalFirstRow: json["total_first_row"],
    totalSecondRow: json["total_second_row"],
    totalBanners: json["total_banners"],
  );

  Map<String, dynamic> toJson() => {
    "total_first_row": totalFirstRow,
    "total_second_row": totalSecondRow,
    "total_banners": totalBanners,
  };
}
