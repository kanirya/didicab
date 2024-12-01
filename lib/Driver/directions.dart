import 'package:didiauth2/Driver/directions_model.dart';
import 'package:didiauth2/Global_variables.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionRepo {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json?';
  final Dio _dio;

  DirectionRepo({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final response = await _dio.get(_baseUrl, queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': googleMapKey,
      });

      if (response.statusCode == 200) {
        return Directions.fromMap(response.data);
      } else {
        print('Failed to fetch directions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception occurred while fetching directions: $e');
      return null;
    }
  }
}
