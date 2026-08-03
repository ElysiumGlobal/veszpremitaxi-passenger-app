import 'dart:convert';
import 'dart:math' as math;

import 'package:e_taxi/core/debug/passenger_flow_debug.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class GoogleRouteResult {
  const GoogleRouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.source,
    required this.alternativeCount,
    required this.straightLineMeters,
  });

  final List<LatLng> points;
  final int distanceMeters;
  final int durationSeconds;
  final String source;
  final int alternativeCount;
  final double straightLineMeters;

  double get detourRatio => straightLineMeters <= 0
      ? 0
      : distanceMeters / straightLineMeters;
}

class GoogleRouteService {
  static const Duration _requestTimeout = Duration(seconds: 12);

  static Future<GoogleRouteResult> bestDrivingRoute({
    required String apiKey,
    required LatLng origin,
    required LatLng destination,
  }) async {
    final String normalizedKey = apiKey.trim();
    if (normalizedKey.isEmpty) {
      throw ArgumentError('Hiányzik a Google Maps API-kulcs.');
    }

    final double straight = Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );
    final List<GoogleRouteResult> candidates = <GoogleRouteResult>[];

    await _loadRoutesV2Candidates(
      apiKey: normalizedKey,
      origin: origin,
      destination: destination,
      straight: straight,
      output: candidates,
    );

    // A Routes API nem minden Google-projektben engedélyezett. Emellett egy
    // körülményesen kerülő első eredménynél külön lekérjük a Directions API
    // alternatíváit is, majd a ténylegesen legrövidebb autós útvonalat választjuk.
    final bool needsDirectionsFallback = candidates.isEmpty ||
        candidates
            .map((GoogleRouteResult route) => route.detourRatio)
            .reduce((double a, double b) => math.min(a, b).toDouble()) >
            2.0;
    if (needsDirectionsFallback) {
      await _loadDirectionsCandidates(
        apiKey: normalizedKey,
        origin: origin,
        destination: destination,
        straight: straight,
        output: candidates,
      );
    }

    if (candidates.isEmpty) {
      await _loadLegacyCandidate(
        apiKey: normalizedKey,
        origin: origin,
        destination: destination,
        straight: straight,
        output: candidates,
      );
    }

    if (candidates.isEmpty) {
      throw StateError('Nem érkezett használható autós útvonal a Google-től.');
    }

    candidates.sort(
      (GoogleRouteResult a, GoogleRouteResult b) =>
          a.distanceMeters.compareTo(b.distanceMeters),
    );

    final double maxReasonable = math.max(
      straight * 2.6,
      straight + 2500.0,
    );
    final GoogleRouteResult selected = candidates.firstWhere(
      (GoogleRouteResult route) =>
          route.distanceMeters >= straight * .90 &&
          route.distanceMeters <= maxReasonable,
      orElse: () => candidates.first,
    );

    PassengerFlowDebug.send('google_route_selected', data: <String, dynamic>{
      'source': selected.source,
      'alternative_count': candidates.length,
      'distance_meters': selected.distanceMeters,
      'duration_seconds': selected.durationSeconds,
      'straight_line_meters': straight.round(),
      'detour_ratio': double.parse(selected.detourRatio.toStringAsFixed(3)),
      'all_routes': candidates
          .map(
            (GoogleRouteResult route) => <String, dynamic>{
              'source': route.source,
              'distance_meters': route.distanceMeters,
              'duration_seconds': route.durationSeconds,
              'detour_ratio':
                  double.parse(route.detourRatio.toStringAsFixed(3)),
            },
          )
          .toList(),
    });
    return selected;
  }

  static Future<void> _loadRoutesV2Candidates({
    required String apiKey,
    required LatLng origin,
    required LatLng destination,
    required double straight,
    required List<GoogleRouteResult> output,
  }) async {
    try {
      final http.Response response = await http
          .post(
            Uri.parse(
              'https://routes.googleapis.com/directions/v2:computeRoutes',
            ),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': apiKey,
              'X-Goog-FieldMask':
                  'routes.distanceMeters,routes.duration,'
                  'routes.polyline.encodedPolyline',
            },
            body: jsonEncode(<String, dynamic>{
              'origin': <String, dynamic>{
                'location': <String, dynamic>{
                  'latLng': <String, double>{
                    'latitude': origin.latitude,
                    'longitude': origin.longitude,
                  },
                },
              },
              'destination': <String, dynamic>{
                'location': <String, dynamic>{
                  'latLng': <String, double>{
                    'latitude': destination.latitude,
                    'longitude': destination.longitude,
                  },
                },
              },
              'travelMode': 'DRIVE',
              'routingPreference': 'TRAFFIC_UNAWARE',
              'computeAlternativeRoutes': true,
              'languageCode': 'hu-HU',
              'units': 'METRIC',
            }),
          )
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        PassengerFlowDebug.send(
          'google_route_v2_http_error',
          data: <String, dynamic>{
            'status_code': response.statusCode,
            'body_length': response.body.length,
          },
        );
        return;
      }

      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> routes = decoded is Map && decoded['routes'] is List
          ? List<dynamic>.from(decoded['routes'] as List)
          : <dynamic>[];
      for (final dynamic rawRoute in routes) {
        if (rawRoute is! Map) continue;
        final dynamic rawPolyline = rawRoute['polyline'];
        final String encoded = rawPolyline is Map
            ? (rawPolyline['encodedPolyline'] ?? '').toString()
            : '';
        final int distance =
            (rawRoute['distanceMeters'] as num?)?.round() ?? 0;
        final int duration = _durationSeconds(rawRoute['duration']);
        final List<LatLng> points = _decodePolyline(encoded);
        if (points.length < 2 || distance <= 0) continue;
        output.add(
          GoogleRouteResult(
            points: points,
            distanceMeters: distance,
            durationSeconds: duration,
            source: 'routes_v2',
            alternativeCount: routes.length,
            straightLineMeters: straight,
          ),
        );
      }
    } catch (error, stack) {
      PassengerFlowDebug.runtimeError('google_route_v2', error, stack);
    }
  }

  static Future<void> _loadDirectionsCandidates({
    required String apiKey,
    required LatLng origin,
    required LatLng destination,
    required double straight,
    required List<GoogleRouteResult> output,
  }) async {
    try {
      final Uri uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/directions/json',
        <String, String>{
          'origin': '${origin.latitude},${origin.longitude}',
          'destination':
              '${destination.latitude},${destination.longitude}',
          'mode': 'driving',
          'alternatives': 'true',
          'language': 'hu',
          'units': 'metric',
          'key': apiKey,
        },
      );
      final http.Response response =
          await http.get(uri).timeout(_requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        PassengerFlowDebug.send(
          'google_directions_http_error',
          data: <String, dynamic>{
            'status_code': response.statusCode,
            'body_length': response.body.length,
          },
        );
        return;
      }

      final dynamic decoded = jsonDecode(response.body);
      final String status = decoded is Map
          ? (decoded['status'] ?? '').toString()
          : '';
      if (status != 'OK') {
        PassengerFlowDebug.send(
          'google_directions_api_error',
          data: <String, dynamic>{
            'status': status,
            'error_message': decoded is Map
                ? (decoded['error_message'] ?? '').toString()
                : '',
          },
        );
        return;
      }

      final List<dynamic> routes = decoded is Map && decoded['routes'] is List
          ? List<dynamic>.from(decoded['routes'] as List)
          : <dynamic>[];
      for (final dynamic rawRoute in routes) {
        if (rawRoute is! Map) continue;
        final dynamic overview = rawRoute['overview_polyline'];
        final String encoded = overview is Map
            ? (overview['points'] ?? '').toString()
            : '';
        final List<dynamic> legs = rawRoute['legs'] is List
            ? List<dynamic>.from(rawRoute['legs'] as List)
            : <dynamic>[];
        int distance = 0;
        int duration = 0;
        for (final dynamic rawLeg in legs) {
          if (rawLeg is! Map) continue;
          final dynamic distanceMap = rawLeg['distance'];
          final dynamic durationMap = rawLeg['duration'];
          if (distanceMap is Map) {
            distance += (distanceMap['value'] as num?)?.round() ?? 0;
          }
          if (durationMap is Map) {
            duration += (durationMap['value'] as num?)?.round() ?? 0;
          }
        }
        final List<LatLng> points = _decodePolyline(encoded);
        if (points.length < 2 || distance <= 0) continue;
        output.add(
          GoogleRouteResult(
            points: points,
            distanceMeters: distance,
            durationSeconds: duration,
            source: 'directions_rest',
            alternativeCount: routes.length,
            straightLineMeters: straight,
          ),
        );
      }
    } catch (error, stack) {
      PassengerFlowDebug.runtimeError('google_directions_rest', error, stack);
    }
  }

  static Future<void> _loadLegacyCandidate({
    required String apiKey,
    required LatLng origin,
    required LatLng destination,
    required double straight,
    required List<GoogleRouteResult> output,
  }) async {
    try {
      final PolylineResult result =
          await PolylinePoints(apiKey: apiKey).getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(
            destination.latitude,
            destination.longitude,
          ),
          mode: TravelMode.driving,
        ),
      );
      final List<LatLng> points = result.points
          .map((PointLatLng point) => LatLng(point.latitude, point.longitude))
          .toList();
      if (points.length < 2) return;
      final int geometryDistance = _geometryDistance(points).round();
      output.add(
        GoogleRouteResult(
          points: points,
          distanceMeters: geometryDistance,
          durationSeconds:
              math.max(60, ((geometryDistance / 1000) / 35 * 3600).round()),
          source: 'legacy_fallback',
          alternativeCount: 1,
          straightLineMeters: straight,
        ),
      );
    } catch (error, stack) {
      PassengerFlowDebug.runtimeError('google_route_legacy', error, stack);
    }
  }

  static int _durationSeconds(dynamic raw) {
    final String value = raw?.toString() ?? '';
    final double seconds =
        double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    return seconds.round();
  }

  static double _geometryDistance(List<LatLng> points) {
    double total = 0;
    for (int index = 1; index < points.length; index++) {
      total += Geolocator.distanceBetween(
        points[index - 1].latitude,
        points[index - 1].longitude,
        points[index].latitude,
        points[index].longitude,
      );
    }
    return total;
  }

  static List<LatLng> _decodePolyline(String encoded) {
    if (encoded.isEmpty) return <LatLng>[];
    final List<LatLng> points = <LatLng>[];
    int index = 0;
    int latitude = 0;
    int longitude = 0;

    try {
      while (index < encoded.length) {
        final _DecodedValue latValue = _decodeValue(encoded, index);
        index = latValue.nextIndex;
        latitude += latValue.value;
        if (index >= encoded.length) break;

        final _DecodedValue lngValue = _decodeValue(encoded, index);
        index = lngValue.nextIndex;
        longitude += lngValue.value;
        points.add(LatLng(latitude / 1e5, longitude / 1e5));
      }
    } catch (error, stack) {
      PassengerFlowDebug.runtimeError('google_polyline_decode', error, stack);
      return <LatLng>[];
    }
    return points;
  }

  static _DecodedValue _decodeValue(String encoded, int startIndex) {
    int index = startIndex;
    int result = 0;
    int shift = 0;
    int byte;
    do {
      if (index >= encoded.length) {
        throw const FormatException('Csonka kódolt Google polyline.');
      }
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    final int value = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
    return _DecodedValue(value: value, nextIndex: index);
  }
}

class _DecodedValue {
  const _DecodedValue({required this.value, required this.nextIndex});

  final int value;
  final int nextIndex;
}
