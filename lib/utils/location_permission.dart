import 'package:geolocator/geolocator.dart';

Future<Position> determinePosition() async{
  final GeolocatorPlatform _geoLocatorPlatform = GeolocatorPlatform.instance;

  bool serviceEnabled;
  LocationPermission permission;

  ///Test if location services are enabled
  serviceEnabled = await _geoLocatorPlatform.isLocationServiceEnabled();

  if(!serviceEnabled){
    return Future.error("Location services are disabled");
  }

  permission = await _geoLocatorPlatform.checkPermission();
  if(permission == LocationPermission.denied){
    permission = await _geoLocatorPlatform.requestPermission();
    if(permission == LocationPermission.denied){
      return Future.error("Permission denied");
    }
  }

  if(permission == LocationPermission.deniedForever){
    return Future.error("Location commissioner currently tonight we cannot access location");
  }

  return await _geoLocatorPlatform.getCurrentPosition();
}
