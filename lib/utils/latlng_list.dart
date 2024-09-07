import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

List<LatLng> generateCoordinates(LatLng center, double radius, int numberOfPoints) {
  List<LatLng> coordinates = [];
  const double earthRadius = 6371000; // Earth's radius in meters

  for (int i = 0; i < numberOfPoints; i++) {
    // Generate random angle
    double angle = Random().nextDouble() * 2 * pi;

    // Calculate the latitude and longitude offsets
    double latOffset = (radius / earthRadius) * (180 / pi) * cos(angle);
    double lonOffset = (radius / earthRadius) * (180 / pi) * sin(angle) / cos(center.latitude * pi / 180);

    // Calculate the new latitude and longitude
    double newLat = center.latitude + latOffset;
    double newLon = center.longitude + lonOffset;

    coordinates.add(LatLng(newLat, newLon));
  }
  print(coordinates.toString());

  return coordinates;
}
