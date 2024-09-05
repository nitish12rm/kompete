


import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kompete/logic/authentication/user.dart';
import 'package:redis/redis.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../constants/const.dart';
import '../widgets/widgets_race_zone.dart';

class RaceZoneScreen extends StatefulWidget {
  RaceZoneScreen({super.key});

  @override
  State<RaceZoneScreen> createState() => _RaceZoneScreenState();

}


class _RaceZoneScreenState extends State<RaceZoneScreen> {
  // Player-specific state variables
  Map<String, dynamic> player1Stats = {};
  Map<String, dynamic> player2Stats = {};
  Map<String, dynamic> player3Stats = {};
  Map<String, dynamic> player4Stats = {};
  final double destinationThreshold = 5.0; // Threshold in meters to determine if a player has reached the destination
  List<String> finishedPlayers = []; // Track players who have finished
  Map<String, int> playerRanks = {}; // Store player ranks
  int currentRank = 1; // Current rank to assign to the next player who finishes

  UserController userController = Get.put(UserController());
  final WebSocketChannel channel =
  IOWebSocketChannel.connect('ws://192.168.1.2:8080');
  Timer? _messageTimer;
  Duration _timerInterval = Duration(seconds: 1); // Adjust the interval as needed

  late GoogleMapController googleMapController;

  BitmapDescriptor? bitmapMarkerIcon;

  BitmapDescriptor? person2Icon;

  bool isSearching = false;

  LatLng? originLatlng;

  LatLng? originLatlng2;

  LatLng destinationLatlng = LatLng(28.573225858000086, 77.34857769872204);

  CameraPosition? initialPosition;

  Set<Marker> markers = {};
  Set<String> rank ={};

  Set<Polyline> polylines = {};
  double _totalDistance = 0.0; // Total distance covered in meters
  Position? _previousPosition;
  String distance = "";
  String duration = "";
  String speed = "";
  String calories = "";

  bool isLoading = true;

  List<LatLng> polylineCoordinates = [];

  PolylinePoints polylinePoints = PolylinePoints();

  TextEditingController endController = TextEditingController();
  Stream<Position>? _positionStream;
  StreamSubscription<Position>? _positionSubscription;
  List<String> playa = ["66d43937c1266cdb7d1fdb55", "66d2e811efee23c428ba902f", "dfsfs", "fsdfds"];
  dynamic inc;

  Future<void> _initializeRedis() async {
    Command cmd = await RedisConnection().connect('192.168.1.2', 6379);
    final pubsub = PubSub(cmd);
    pubsub.subscribe(['abcde']);
    final stream = pubsub.getStream();
    var streamWithoutErrors = stream.handleError((e) => print("error $e"));

    await for (final msg in streamWithoutErrors) {
      inc = jsonDecode(msg[2].toString());
      if (inc is! int || inc == null) {
         rank = (inc["rank"] as List<dynamic>).toSet().cast<String>();
        determineMarkers();
        _updatePlayerStats();

      }
    }
  }

  void _updatePlayerStats() {
    if (inc['userid'] == playa[0]) {
      setState(() {
        player1Stats = inc[playa[0]];
      });
    } else if (inc['userid'] == playa[1]) {
      setState(() {
        player2Stats = inc[playa[1]];
      });
    } else if (inc['userid'] == playa[2]) {
      setState(() {
        player3Stats = inc[playa[2]];
      });
    } else if (inc['userid'] == playa[3]) {
      setState(() {
        player4Stats = inc[playa[3]];
      });
    }
  }
  determineMarkers(){
    if(inc["userid"]==playa[0]){
      markers.removeWhere((element) => element.mapsId.value == 'origin');
      markers.add(
        Marker(
          markerId: MarkerId('origin'),
          position: LatLng(inc[playa[0]]["coord"][0], inc[playa[0]]["coord"][1]),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: inc[playa[0]]["name"])
        ),
      );
      setState(() {

      });
    }
   else if(inc["userid"]==playa[1]){
      markers.removeWhere((element) => element.mapsId.value == 'origin2');
      markers.add(
        Marker(
          markerId: MarkerId('origin2'),
          position: LatLng(inc[playa[1]]["coord"][0], inc[playa[1]]["coord"][1]),
          icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: inc[playa[1]]["name"])

        ),
      );
      setState(() {

      });
    }
  }

  void _startMessageTimer() {
    _messageTimer = Timer.periodic(_timerInterval, (timer) {
      if (originLatlng != null) {
        var message = jsonEncode({
          userController.userModel.value.sId: {
            'name': userController.userModel.value.name,
            'coord': [originLatlng!.latitude, originLatlng!.longitude],
            'eta': '',
            'distance': "${(_totalDistance / 1000).toStringAsFixed(2)}",
            'speed': speed,
          },
          'userid': userController.userModel.value.sId,
          'lobbyid': 'abcde',
          "rank":rank.toList()
        });

        channel.sink.add(message);
      }
    });
  }

  bool _isPlayerInCircle(LatLng playerPosition, LatLng destination, double radiusInMeters) {
    // Convert the radius from meters to degrees (rough conversion)
    const double meterToLatLng = 1 / 111320.0;  // Approximation: 1 degree latitude ≈ 111.32 km
    double radiusInDegrees = radiusInMeters * meterToLatLng;

    // Calculate the difference in latitudes and longitudes
    double deltaLat = playerPosition.latitude - destination.latitude;
    double deltaLon = playerPosition.longitude - destination.longitude;

    // Check if the point is inside the circle using the circle formula
    return (deltaLat * deltaLat + deltaLon * deltaLon) <= (radiusInDegrees * radiusInDegrees);
  }
  @override
  void initState() {
    determineLivePosition();
    _initializeRedis();
    _startMessageTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return inc == null|| inc is int ?Center(child: CircularProgressIndicator(),): Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Race Zone",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Space for Map
          Container(
            height: 57.h,
            color: Colors.black.withOpacity(0.05),
            child: initialPosition == null
                ? Center(
              child: CircularProgressIndicator(),
            )
                : Stack(
                  children: [
                    GoogleMap(
                                  mapType: MapType.normal,
                                  initialCameraPosition: initialPosition!,
                                  myLocationEnabled: true,
                                  tiltGesturesEnabled: true,
                                  compassEnabled: true,
                                  scrollGesturesEnabled: true,
                                  zoomGesturesEnabled: true,
                                  markers: markers,
                                  onMapCreated: (controller) {
                    googleMapController = controller;
                                  },
                                ),
                    Container(child: Text(inc["rank"].toString()),)
                  ],
                ),
          ),

          // Player Stats Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Column Titles
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10.h,
                        ),
                        StatTitle(title: "ETA"),
                        StatTitle(title: "DISTANCE"),
                        StatTitle(title: "SPEED"),
                        StatTitle(title: "CALORIES"),
                      ],
                    ),
                    // Player Stats Columns
                    PlayerStatsColumn(
                      playerName: player1Stats['name'] ?? 'Player 1',
                      eta: player1Stats['eta'] ?? '',
                      // eta: player1Stats['coord'][0].toString() ?? '',
                      distance: player1Stats['distance'] ?? '',
                      speed: player1Stats['speed'] ?? '',
                      calories: player1Stats['calories'] ?? '',
                    ),
                    PlayerStatsColumn(
                      playerName: player2Stats['name'] ?? 'Player 2',
                      // eta: player2Stats['coord'][0].toString() ?? '',
                      eta: player2Stats['eta'] ?? '',
                      distance: player2Stats['distance'] ?? '',
                      speed: player2Stats['speed'] ?? '',
                      calories: player2Stats['calories'] ?? '',
                    ),
                    PlayerStatsColumn(
                      playerName: player3Stats['name'] ?? 'Player 3',
                      eta: player3Stats['eta'] ?? '',
                      distance: player3Stats['distance'] ?? '',
                      speed: player3Stats['speed'] ?? '',
                      calories: player3Stats['calories'] ?? '',
                    ),
                    PlayerStatsColumn(
                      playerName: player4Stats['name'] ?? 'Player 4',
                      eta: player4Stats['eta'] ?? '',
                      distance: player4Stats['distance'] ?? '',
                      speed: player4Stats['speed'] ?? '',
                      calories: player4Stats['calories'] ?? '',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  ///LIVE COORDINATES STREAM
  Future<void> determineLivePosition() async {
    final GeolocatorPlatform _geoLocatorPlatform = GeolocatorPlatform.instance;

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await _geoLocatorPlatform.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("Location services are disabled");
    }

    permission = await _geoLocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geoLocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permission is permanently denied, we cannot access location");
    }

    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 1),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
            "Example app will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock: true,
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 4,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
      );
    } else if (kIsWeb) {
      locationSettings = WebSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 4,
        maximumAge: Duration(minutes: 5),
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 4,
      );
    }

    // await getBytesFromAsset("asset/logos_spotify-icon.png", 40).then((value) {
    //   bitmapMarkerIcon = value;
    //   setState(() {});
    // });

    _positionSubscription =_geoLocatorPlatform
        .getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) async {
      if (position != null) {
        if (position.speed > 0.5) {
          speed = "${(position.speed * 3.6).toStringAsFixed(2)}"; // Convert m/s to km/h
        } else {
          speed = "0.0"; // Display as idle if speed is below the threshold
        }

        originLatlng = LatLng(position.latitude, position.longitude);

        // originLatlng2 = LatLng(position.latitude + 0.004, position.longitude);
        // Calculate distance covered
        if (_previousPosition != null) {
          double distance = Geolocator.distanceBetween(
            _previousPosition!.latitude,
            _previousPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          _totalDistance += distance; // Update total distance
          if(_totalDistance>220){
            print("won");
            rank.add(userController.userModel.value.sId.toString());
            speed="0.0";
           _positionSubscription?.cancel();
            setState(() {

            });

          }


        }  _previousPosition = position;

       log(_isPlayerInCircle(originLatlng!, destinationLatlng, 10).toString()) ;
        double distanceToDestination = Geolocator.distanceBetween(originLatlng!.latitude, originLatlng!.longitude, destinationLatlng.latitude, destinationLatlng.longitude);
        log(distanceToDestination.toString());
        if(distanceToDestination<=10){
          log("won");
        }

        initialPosition = CameraPosition(target: originLatlng!, zoom: 12);
        // var message = jsonEncode({
        //   userController.userModel.value.sId : {
        //     'name': userController.userModel.value.name,
        //     'coord': [originLatlng!.latitude, originLatlng!.longitude],
        //     'eta': '8',
        //     'distance': '9',
        //     'speed': '10',
        //     'calories': '120',
        //   },
        //   'userid': userController.userModel.value.sId,
        //   'lobbyid': 'abcde',
        // });
        log(originLatlng!.longitude.toString());
        //   Marker(
        //     markerId: MarkerId('origin'),
        //     position: inc[playa[0]]["coord"][0],
        //     icon: BitmapDescriptor.defaultMarker,
        //   ),
        // markers.removeWhere((element) => element.mapsId.value == 'origin');

        // channel.sink.add(message);
        // markers.removeWhere((element) => element.mapsId.value == 'destination');

        // if (destinationLatlng != null) {
        //   // getPolyline();
        // }


        setState(() {});
      }
    });

  }
        // markers.add(
        // );

// getPolyline() async{
  //   polylineCoordinates.clear();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     googleApiKey: Constants.APIKEY,
  //     request: PolylineRequest(
  //       origin: PointLatLng(originLatlng!.latitude, originLatlng!.longitude),
  //       destination: PointLatLng(destinationLatlng!.latitude, destinationLatlng!.longitude),
  //       mode: TravelMode.driving,
  //     ),
  //   );
  //   // if (result.points.isNotEmpty) {
  //   //   result.points.forEach((PointLatLng point) {
  //   //     polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //   //   });
  //   // }
  //   distance = result.distanceTexts!.first.toString();
  //   duration = result.durationTexts!.first;
  //   int durationValue = result.durationValues!.first;
  //   speed = (result.distanceValues!.first/result.durationValues!.first).toString();
  //   double weight = double.parse(userController.userModel.value.weight.toString()); // Weight in kg
  //   // double met = 8; // MET value for running
  //   //  calories = (met * weight * (durationValue / 3600)).toString();
  //
  //
  //
  //   // polylines.add(Polyline(polylineId: PolylineId("polyline"),color: Colors.blue,width: 6,points: polylineCoordinates));
  //
  //   isLoading = false;
  //   googleMapController.animateCamera(CameraUpdate.newLatLngZoom(originLatlng!, 16));
  //   setState(() {
  //
  //   });
  // }
}


// class _RaceZoneScreenState extends State<RaceZoneScreen> {
//   UserController userController = Get.put(UserController());
//   final WebSocketChannel channel =
//       IOWebSocketChannel.connect('ws://192.168.1.2:8080');
//   Timer? _messageTimer;
//   Duration _timerInterval = Duration(seconds: 1); // Adjust the interval as needed
//
//   late GoogleMapController googleMapController;
//
//   BitmapDescriptor? bitmapMarkerIcon;
//
//   BitmapDescriptor? person2Icon;
//
//   bool isSearching = false;
//
//   LatLng? originLatlng;
//
//   LatLng? originLatlng2;
//
//   LatLng? destinationLatlng;
//
//   CameraPosition? initialPosition;
//
//   Set<Marker> markers = {};
//
//   Set<Polyline> polylines = {};
//
//   String distance = "";
//
//   bool isLoading = true;
//
//   List<LatLng> polylineCoordinates = [];
//
//   PolylinePoints polylinePoints = PolylinePoints();
//
//   TextEditingController endController = TextEditingController();
//
//   List<String> playa = ["66d43937c1266cdb7d1fdb55", "66d2e811efee23c428ba902f", "dfsfs", "fsdfds"];
//   var name;
//   dynamic inc;
//
//   Future<void> _initializeRedis() async {
//     log("first ${inc.runtimeType.toString()}");
//     Command cmd = await RedisConnection().connect('192.168.1.2', 6379);
//     final pubsub = PubSub(cmd);
//     pubsub.subscribe(['abcde']);
//     final stream = pubsub.getStream();
//     var streamWithoutErrors = stream.handleError((e) => print("error $e"));
//
//     await for (final msg in streamWithoutErrors) {
//       // final decoded = jsonDecode(msg[0]);
//       if (msg[2] != 1)
//         // setState(() {
//         //   messages2.add(msg[2].toString());
//         // });
//
//         print(msg[2].toString());
//       inc = jsonDecode(msg[2].toString());
//       log("second ${inc.runtimeType.toString()}");
//       if(inc is! int|| inc ==null){
//
//         determineMarkers();
//
//       }
// setState(() {
//
// });
//
//
//       // print(name??"player");
//     }
//   }
//
//   determineMarkers(){
//     if(inc["userid"]==playa[0]){
//       markers.removeWhere((element) => element.mapsId.value == 'origin');
//       markers.add(
//         Marker(
//           markerId: MarkerId('origin'),
//           position: LatLng(inc[playa[0]]["coord"][0], inc[playa[0]]["coord"][1]),
//           icon: BitmapDescriptor.defaultMarker,
//         ),
//       );
//     }
//
//
//
//   }
//
//   void _startMessageTimer() {
//     _messageTimer = Timer.periodic(_timerInterval, (timer) {
//       if (originLatlng != null) {
//         var message = jsonEncode({
//           userController.userModel.value.sId: {
//             'name': userController.userModel.value.name,
//             'coord': [originLatlng!.latitude, originLatlng!.longitude],
//             'eta': '8',
//             'distance': '9',
//             'speed': '10',
//             'calories': '120',
//           },
//           'userid': userController.userModel.value.sId,
//           'lobbyid': 'abcde',
//         });
//
//         log("Sending message: $message");
//         channel.sink.add(message);
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     determineLivePosition();
//     _initializeRedis();
//     _startMessageTimer();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return inc == null|| inc is int ?Center(child: CircularProgressIndicator(),): Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           "jhg",
//           style: TextStyle(color: Colors.black),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: IconThemeData(color: Colors.black),
//       ),
//       body: Column(
//         children: [
//           // Space for Map
//           Container(
//             height: 57.h,
//             color: Colors.black.withOpacity(0.05),
//             // Placeholder for the map
//             child: initialPosition == null
//                 ? Center(
//                     child: CircularProgressIndicator(),
//                   )
//                 : GoogleMap(
//                     mapType: MapType.normal,
//                     initialCameraPosition: initialPosition!,
//                     myLocationEnabled: true,
//                     tiltGesturesEnabled: true,
//                     compassEnabled: true,
//                     scrollGesturesEnabled: true,
//                     zoomGesturesEnabled: true,
//                     markers: markers,
//                     onMapCreated: (controller) {
//                       googleMapController = controller;
//                     },
//                   ),
//           ),
//
//           // Player Stats Section
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     // Column Titles
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           height: 10.h,
//                         ),
//                         StatTitle(title: "ETA"),
//                         StatTitle(title: "DISTANCE"),
//                         StatTitle(title: "SPEED"),
//                         StatTitle(title: "CALORIES"),
//                       ],
//                     ),
//                     // Player Stats Columns
//
//                     if(inc["userid"]==playa[0])
//                        PlayerStatsColumn(
//                           playerName: inc[playa[0]]["name"], eta: inc[playa[0]]["coord"][0].toString(), distance: inc[playa[0]]["distance"], speed: inc[playa[0]]["speed"], calories: inc[playa[0]]["calories"],)
//                       else
//                          PlayerStatsColumn(playerName: "plaers1", eta: '', distance: '', speed: '', calories: '',),
//
//                     if(inc["userid"]==playa[1])
//                       PlayerStatsColumn(
//                         playerName: inc[playa[1]]["name"], eta: inc[playa[1]]["coord"][1].toString(), distance: inc[playa[1]]["distance"], speed: inc[playa[1]]["speed"], calories: inc[playa[1]]["calories"],)
//                     else
//                       PlayerStatsColumn(playerName: "plaers2", eta: '', distance: '', speed: '', calories: '',),
//
//                     if(inc["userid"]==playa[2])
//                       PlayerStatsColumn(
//                         playerName: inc[playa[2]]["name"], eta: inc[playa[2]]["coord"][2].toString(), distance: inc[playa[2]]["distance"], speed: inc[playa[2]]["speed"], calories: inc[playa[2]]["calories"],)
//                     else
//                       PlayerStatsColumn(playerName: "plaers3", eta: '', distance: '', speed: '', calories: '',),
//
//                     if(inc["userid"]==playa[3])
//                       PlayerStatsColumn(
//                         playerName: inc[playa[3]]["name"], eta: inc[playa[3]]["coord"][3].toString(), distance: inc[playa[3]]["distance"], speed: inc[playa[3]]["speed"], calories: inc[playa[3]]["calories"],)
//                     else
//                       PlayerStatsColumn(playerName: "plaers4", eta: '', distance: '', speed: '', calories: '',),
//
//
//
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   ///LIVE COORDINATES STREAM
//   Future<void> determineLivePosition() async {
//     final GeolocatorPlatform _geoLocatorPlatform = GeolocatorPlatform.instance;
//
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // Test if location services are enabled
//     serviceEnabled = await _geoLocatorPlatform.isLocationServiceEnabled();
//
//     if (!serviceEnabled) {
//       return Future.error("Location services are disabled");
//     }
//
//     permission = await _geoLocatorPlatform.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await _geoLocatorPlatform.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error("Permission denied");
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           "Location permission is permanently denied, we cannot access location");
//     }
//
//     LocationSettings locationSettings;
//
//     if (defaultTargetPlatform == TargetPlatform.android) {
//       locationSettings = AndroidSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 2,
//           forceLocationManager: true,
//           intervalDuration: const Duration(seconds: 1),
//           foregroundNotificationConfig: const ForegroundNotificationConfig(
//             notificationText:
//                 "Example app will continue to receive your location even when you aren't using it",
//             notificationTitle: "Running in Background",
//             enableWakeLock: true,
//           ));
//     } else if (defaultTargetPlatform == TargetPlatform.iOS ||
//         defaultTargetPlatform == TargetPlatform.macOS) {
//       locationSettings = AppleSettings(
//         accuracy: LocationAccuracy.high,
//         activityType: ActivityType.fitness,
//         distanceFilter: 4,
//         pauseLocationUpdatesAutomatically: true,
//         showBackgroundLocationIndicator: false,
//       );
//     } else if (kIsWeb) {
//       locationSettings = WebSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 4,
//         maximumAge: Duration(minutes: 5),
//       );
//     } else {
//       locationSettings = LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 4,
//       );
//     }
//
//     // await getBytesFromAsset("asset/logos_spotify-icon.png", 40).then((value) {
//     //   bitmapMarkerIcon = value;
//     //   setState(() {});
//     // });
//
//     _geoLocatorPlatform
//         .getPositionStream(locationSettings: locationSettings)
//         .listen((Position? position) async {
//       if (position != null) {
//         originLatlng = LatLng(position.latitude, position.longitude);
//         // originLatlng2 = LatLng(position.latitude + 0.004, position.longitude);
//
//         initialPosition = CameraPosition(target: originLatlng!, zoom: 12);
//         var message = jsonEncode({
//          userController.userModel.value.sId : {
//             'name': userController.userModel.value.name,
//             'coord': [originLatlng!.latitude, originLatlng!.longitude],
//             'eta': '8',
//             'distance': '9',
//             'speed': '10',
//             'calories': '120',
//           },
//           'userid': userController.userModel.value.sId,
//           'lobbyid': 'abcde',
//         });
//         log(originLatlng!.longitude.toString());
//         // markers.add(
//         //   Marker(
//         //     markerId: MarkerId('origin'),
//         //     position: inc[playa[0]]["coord"][0],
//         //     icon: BitmapDescriptor.defaultMarker,
//         //   ),
//         // );
//         // markers.removeWhere((element) => element.mapsId.value == 'origin');
//
//         // channel.sink.add(message);
//         // markers.removeWhere((element) => element.mapsId.value == 'destination');
//
//         setState(() {});
//       }
//     });
//   }
// }
