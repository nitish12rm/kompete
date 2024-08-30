import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../constants/const.dart';
import '../model/place_from_coord.dart';
import '../model/placeid.dart';
import '../model/places_autocomplete.dart';

class ApiServices{
  Future<PlacesFromCoordinate> getPlacesFromCoord(String lat, String long) async{
    Uri url = Uri.parse("https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=${Constants.APIKEY}");
    var response = await http.get(url);

    if(response.statusCode==200){
      return PlacesFromCoordinate.fromJson(jsonDecode(response.body));
    }
    else{
      throw Exception("Api ERROR: PlacesFromCoordinate");
    }
  }

  Future<PlacesAutocomplete> getPlacesAutocomplete(String placeInput) async{
    Uri url = Uri.parse("https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeInput&key=${Constants.APIKEY}");
    var response = await http.get(url);

    if(response.statusCode==200){
      return PlacesAutocomplete.fromJson(jsonDecode(response.body));
    }
    else{
      throw Exception("Api ERROR: PlacesAutocomplete");
    }
  }

  Future<PlaceId> getPlacesFromPlaceId(String placeId) async{
    Uri url = Uri.parse("https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=${Constants.APIKEY}");
    var response = await http.get(url);

    if(response.statusCode==200){
      return PlaceId.fromJson(jsonDecode(response.body));
    }
    else{
      throw Exception("Api ERROR: PlacesAutocomplete");
    }
  }
}