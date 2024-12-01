import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;
  final String startAddress;
  final String endAddress;

  const Directions({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
    required this.startAddress,
    required this.endAddress,
  });

  factory Directions.fromMap(Map<String, dynamic> map) {
    if ((map['routes'] as List).isEmpty) {
      return Directions(
        bounds: LatLngBounds(northeast: LatLng(0, 0), southwest: LatLng(0, 0)),
        polylinePoints: [],
        totalDistance: '',
        totalDuration: '',
        startAddress: '',
        endAddress: '',
      );
    }

    final data = Map<String, dynamic>.from(map['routes'][0]);
    final boundsData = data['bounds'];
    final northeast = boundsData['northeast'];
    final southwest = boundsData['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );
    String distance = '';
    String duration = '';
    String startAddress = '';
    String endAddress = '';
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
      startAddress = leg['start_address'];
      endAddress = leg['end_address'];
    }

    return Directions(
      bounds: bounds,
      polylinePoints: PolylinePoints().decodePolyline(data['overview_polyline']['points']),
      totalDistance: distance,
      totalDuration: duration,
      startAddress: startAddress,
      endAddress: endAddress,
    );
  }
}
