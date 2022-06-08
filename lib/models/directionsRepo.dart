import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '.env.dart';
import 'Directions.dart';

class DirectionRepo {
  static const String baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  final Dio _dio;

  DirectionRepo({dio}) : _dio = dio ?? Dio();

  Future<Directions> getDirections({
    required LatLng org,
    required LatLng dest,
  }) async {
    final response = await _dio.get(baseUrl, queryParameters: {
      'origin': '${org.latitude},${org.longitude}',
      'destination': '${dest.latitude},${dest.longitude}',
      'key': googleAPIKey,
    });

    if (response.statusCode == 200) {
      return Directions.fromJson(response.data);
    } else {
      throw Exception('Failed to load directions');
    }
  }
}
