import 'package:google_maps_flutter/google_maps_flutter.dart';

class OriginDestinationModel {
  final String? oName;
  final String? oAddress;
  final LatLng? oLatLng;
  final String? dName;
  final String? dAddress;
  final LatLng? dLatLng;
  final int? userNameId;

  OriginDestinationModel({
    this.userNameId,
    this.dAddress,
    this.dLatLng,
    this.dName,
    this.oAddress,
    this.oLatLng,
    this.oName,
  });

  OriginDestinationModel copyWith({
    String? dAddress,
    LatLng? dLatLng,
    String? dName,
    String? oAddress,
    int? userNameId,
    LatLng? oLatLng,
    String? oName,
  }) {
    return OriginDestinationModel(
      dLatLng: dLatLng ?? this.dLatLng,
      userNameId: userNameId ?? this.userNameId,
      dAddress: dAddress ?? this.dAddress,
      oLatLng: oLatLng ?? this.oLatLng,
      oAddress: oAddress ?? this.oAddress,
      dName: dName ?? this.dName,
      oName: oName ?? this.oName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "oName": oName,
      "oAddress": oAddress,
      "oLatLng": oLatLng,
      "dName": dName,
      "dAddress": dAddress,
      "dLatLng": dLatLng,
      "userNameId": userNameId,
    };
  }
}
