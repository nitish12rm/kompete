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
import 'package:kompete/logic/race/marker_controller.dart';
import 'package:redis/redis.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../constants/const.dart';
import '../../../../data/model/Race/race_model.dart';
import '../../../../logic/race/race_model_controller.dart';
import '../../../../utils/latlng_list.dart';
import '../widgets/widgets_race_zone.dart';

class RaceZoneScreen extends StatefulWidget {
  RaceZoneScreen({super.key, required this.polyline, required this.destinationLatlng, required this.distanceGM});
  final   Set<Polyline> polyline;
  final LatLng destinationLatlng;
  final String distanceGM;
  @override
  State<RaceZoneScreen> createState() => _RaceZoneScreenState();

}


class _RaceZoneScreenState extends State<RaceZoneScreen> {
  final RaceModelModelController raceModelModelController = Get.put(RaceModelModelController());
 final MarkerController markerController = Get.put(MarkerController());
 final RaceZoneController raceZoneController = Get.put(RaceZoneController());

  final double destinationThreshold = 5.0; // Threshold in meters to determine if a player has reached the destination
  List<String> finishedPlayers = []; // Track players who have finished
  Map<String, int> playerRanks = {}; // Store player ranks
  int currentRank = 1; // Current rank to assign to the next player who finishes

  UserController userController = Get.put(UserController());
  final WebSocketChannel channel =
  IOWebSocketChannel.connect('ws://192.168.1.12:8080');
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
  RaceModel raceModel = RaceModel();

  Future<void> _initializeRedis() async {
    Command cmd = await RedisConnection().connect('192.168.1.12', 6379);
    final pubsub = PubSub(cmd);
    pubsub.subscribe(['abcde']);
    final stream = pubsub.getStream();
    var streamWithoutErrors = stream.handleError((e) => print("error $e"));

    await for (final msg in streamWithoutErrors) {
      // inc = jsonDecode(msg[2].toString());
      // if (inc is! int || inc == null) {
      //   rank = (inc["rank"] as List<dynamic>).toSet().cast<String>();
      //   determineMarkers();
      //   _updatePlayerStats();
      //
      // }
      inc = jsonDecode(msg[2].toString());
      // log(inc);
      if (inc is! int || inc == null) {
        raceModel = RaceModel.fromJson(inc);
        log(raceModel.user!.name!);
        log("recieved redis");
        // rank = (raceModel.rank as List<dynamic>).toSet().cast<String>();
        determineMarkers();
        _updatePlayerStats();

      }
      setState(() {

      });
    }
  }
  void _updatePlayerStats() {
    if (raceModel.userid == playa[0]) {

      raceModelModelController.setRaceModel1(raceModel);

    } else if (raceModel.userid == playa[1]) {
      raceModelModelController.setRaceModel2(raceModel);

    } else if (raceModel.userid == playa[2]) {
      raceModelModelController.setRaceModel3(raceModel);

    } else if (raceModel.userid== playa[3]) {
      raceModelModelController.setRaceModel4(raceModel);

    }
  }
  determineMarkers(){
    if(raceModel.userid==playa[0]){
      markerController.markers.removeWhere((element) => element.mapsId.value == 'origin');
      markerController.markers.add(
        Marker(
            markerId: MarkerId('origin'),
            position: LatLng(inc["user"]["coord"][0], inc["user"]["coord"][1]),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: inc["user"]["name"])
        ),
      );

    }
    else if(raceModel.userid==playa[1]){
      markerController.markers.removeWhere((element) => element.mapsId.value == 'origin2');
      markerController.markers.add(
        Marker(
            markerId: MarkerId('origin2'),
            position: LatLng(inc["user"]["coord"][0], inc["user"]["coord"][1]),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: inc["user"]["name"])
        ),
      );

    }
  }

  void _startMessageTimer() {
    _messageTimer = Timer.periodic(_timerInterval, (timer) {
      if (originLatlng != null) {
        var message = jsonEncode({
          "user": {
            "id": userController.userModel.value.sId,
            "name": userController.userModel.value.name,
            "coord": [originLatlng!.latitude, originLatlng!.longitude],
            "eta": "",
            "distance": "${(_totalDistance / 1000).toStringAsFixed(2)}",
            "speed": speed
          },
          "userid": userController.userModel.value.sId,
          "lobbyid": "abcde",
          "rank": rank.toList()
        });

        channel.sink.add(message);
      }
    });
  }
  List<LatLng> coordinates=[];
///INIT
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
                Obx(
                      () => GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: initialPosition!,
                        myLocationEnabled: true,
                        tiltGesturesEnabled: true,
                        compassEnabled: true,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        polylines: widget.polyline,
                        markers:Set<Marker>.of(markerController.markers),
                        onMapCreated: (controller) {
                          googleMapController = controller;
                        },
                      ),
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
                    Obx(
                          ()=> PlayerStatsColumn(
                        playerName: raceModelModelController.raceModel1.value.user?.name??"",
                        eta: raceModelModelController.raceModel1.value.user?.coord?[0].toString()??"",
                        distance: raceModelModelController.raceModel1.value.user?.distance ?? "",
                        speed: raceModelModelController.raceModel1.value.user?.speed ?? "",

                      ),
                    ),
                    Obx(
                          ()=> PlayerStatsColumn(
                        playerName: raceModelModelController.raceModel2.value.user?.name??"",
                        eta: raceModelModelController.raceModel2.value.user?.eta??"",
                        distance: raceModelModelController.raceModel2.value.user?.distance ?? "",
                        speed: raceModelModelController.raceModel2.value.user?.speed ?? "",
                      ),
                    ),
                    Obx(
                          ()=> PlayerStatsColumn(
                        playerName: raceModelModelController.raceModel4.value.user?.name??"",
                        eta: raceModelModelController.raceModel4.value.user?.eta??"",
                        distance: raceModelModelController.raceModel4.value.user?.distance ?? "",
                        speed: raceModelModelController.raceModel4.value.user?.speed ?? "",
                      ),
                    ),
                    Obx(
                          ()=> PlayerStatsColumn(
                        playerName: raceModelModelController.raceModel3.value.user?.name??"",
                        eta: raceModelModelController.raceModel3.value.user?.eta??"",
                        distance: raceModelModelController.raceModel3.value.user?.distance ?? "",
                        speed: raceModelModelController.raceModel3.value.user?.speed ?? "",
                      ),
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


        // Calculate distance covered
        if (_previousPosition != null) {
          double distance = Geolocator.distanceBetween(
            _previousPosition!.latitude,
            _previousPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          _totalDistance += distance; // Update total distance

        }  _previousPosition = position;

        double distanceToDestination = Geolocator.distanceBetween(originLatlng!.latitude, originLatlng!.longitude, widget.destinationLatlng.latitude, widget.destinationLatlng.longitude);
        // log(distanceToDestination.toString());
        if(distanceToDestination<=25){
          log("won $distanceToDestination");
          raceZoneController.won.value = true;
          rank.add(userController.user.sId!);
        }
        else{
          log("not yet $distanceToDestination");
        }

        initialPosition = CameraPosition(target: originLatlng!, zoom: 12);

        log(originLatlng!.longitude.toString());


        setState(() {});
      }
    });

  }


  // getPolyline() async {
  //   isLoading = true;
  //   setState(() {});
  //
  //   try {
  //
  //
  //     if (polylineCoordinates.isNotEmpty) {
  //
  //       polylines.add(Polyline(
  //           polylineId: PolylineId("polyline"),
  //           color: Colors.blue,
  //           width: 7,
  //           points: polylineCoordinates));
  //
  //       googleMapController
  //           .animateCamera(CameraUpdate.newLatLngZoom(originLatlng!, 10));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Route not found. Please try again.')),
  //       );
  //     }
  //   } catch (e) {
  //     // If there's an error in fetching the route, show an error message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           backgroundColor: Colors.red,
  //           content: Text(
  //               'Failed to fetch route. Please check your connection or end location and try again.')),
  //     );
  //   } finally {
  //     isLoading = false;
  //     setState(() {});
  //   }
  // }
@override
  void dispose() {
    // TODO: implement dispose

  _positionSubscription!.cancel();
  _messageTimer!.cancel();
    super.dispose();
  }
}

class RaceZoneController extends GetxController{
  var won = false.obs;


}