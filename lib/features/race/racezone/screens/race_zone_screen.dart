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
import 'package:kompete/features/home/home.dart';
import 'package:kompete/features/race/controller/lobby_controller.dart';
import 'package:kompete/logic/authentication/user.dart';
import 'package:kompete/logic/race/marker_controller.dart';
import 'package:redis/redis.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../constants/const.dart';
import '../../../../data/model/Race/race_model.dart';
import '../../../../logic/Lobby/lobby.dart';
import '../../../../logic/race/race_model_controller.dart';
import '../../../../utils/latlng_list.dart';
import '../../final/screen/final_screen.dart';
import '../widgets/widgets_race_zone.dart';

class RaceZoneScreen extends StatefulWidget {
  RaceZoneScreen(
      {super.key,
      required this.polyline,
      required this.destinationLatlng,
      required this.distanceGM,
      required this.lobbyId,
        required this.users, required this.originLatlng
      }
      );

  final Set<Polyline> polyline;
  final LatLng destinationLatlng;
  final LatLng originLatlng;
  final String distanceGM;
  final String lobbyId;
  final List<String?> users;

  @override
  State<RaceZoneScreen> createState() => _RaceZoneScreenState();
}

class _RaceZoneScreenState extends State<RaceZoneScreen> {
  Timer? _timer;

  final RaceModelModelController raceModelModelController =
      Get.put(RaceModelModelController());
  final MarkerController markerController = Get.put(MarkerController());
  final RaceZoneController raceZoneController = Get.put(RaceZoneController());
  final LobbyOperationController lobbyOperationController =
      Get.put(LobbyOperationController());

  final double destinationThreshold =
      5.0; // Threshold in meters to determine if a player has reached the destination
  List<String> finishedPlayers = []; // Track players who have finished
  Map<String, int> playerRanks = {}; // Store player ranks
  int currentRank = 1; // Current rank to assign to the next player who finishes
  double distanceToDestination = 0;
  UserController userController = Get.put(UserController());
  final WebSocketChannel channel =
      IOWebSocketChannel.connect('ws://192.168.1.7:8080');
  Timer? _messageTimer;
  Duration _timerInterval =
      Duration(seconds: 1); // Adjust the interval as needed

  late GoogleMapController googleMapController;

  BitmapDescriptor? bitmapMarkerIcon;

  BitmapDescriptor? person2Icon;

  bool isSearching = false;

  LatLng? originLatlng;

  LatLng? originLatlng2;

  CameraPosition? initialPosition;

  Set<Marker> markers = {};
  Set<String> rank = {};

  Set<Polyline> polylines = {};
  double _totalDistance = 0.0; // Total distance covered in meters
  Position? _previousPosition;
  String distance = "";
  String duration = "";
  String speed = "";


  bool isLoading = true;

  List<LatLng> polylineCoordinates = [];

  PolylinePoints polylinePoints = PolylinePoints();

  TextEditingController endController = TextEditingController();
  Stream<Position>? _positionStream;
  StreamSubscription<Position>? _positionSubscription;

  dynamic inc;
  RaceModel raceModel = RaceModel();

  Future<void> _initializeRedis() async {
    Command cmd = await RedisConnection().connect('192.168.1.7', 6379);
    final pubsub = PubSub(cmd);
    pubsub.subscribe([widget.lobbyId]);
    final stream = pubsub.getStream();
    var streamWithoutErrors = stream.handleError((e) => print("error $e"));

    await for (final msg in streamWithoutErrors) {
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
      setState(() {});
    }
  }

  void _updatePlayerStats() {
    if (raceModel.userid == widget.users[0]) {
      raceModelModelController.setRaceModel1(raceModel);
    } else if (raceModel.userid == widget.users[1]) {
      raceModelModelController.setRaceModel2(raceModel);
    } else if (raceModel.userid == widget.users[2]) {
      raceModelModelController.setRaceModel3(raceModel);
    } else if (raceModel.userid == widget.users[3]) {
      raceModelModelController.setRaceModel4(raceModel);
    }
  }

  determineMarkers() {
    if (raceModel.userid == widget.users[0]) {
      markerController.markers
          .removeWhere((element) => element.mapsId.value == 'origin');
      markerController.markers.add(
        Marker(
            markerId: MarkerId('origin'),
            position: LatLng(inc["user"]["coord"][0], inc["user"]["coord"][1]),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: inc["user"]["name"])),
      );
    } else if (raceModel.userid == widget.users[1]) {
      markerController.markers
          .removeWhere((element) => element.mapsId.value == 'origin2');
      markerController.markers.add(
        Marker(
            markerId: MarkerId('origin2'),
            position: LatLng(inc["user"]["coord"][0], inc["user"]["coord"][1]),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: inc["user"]["name"])),
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
          "lobbyid": widget.lobbyId,
          "rank": rank.toList()
        });

        channel.sink.add(message);
      }
    });
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      raceZoneController.second.value++;
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _positionSubscription!.cancel();
    speed = "0.0";
  }

  List<LatLng> coordinates = [];
  double? kilometers;
  double? metersDistance;

  ///INIT
  @override
  void initState() {

    determineLivePosition();
    _initializeRedis();
    _startMessageTimer();
    startTimer();
    kilometers = double.parse(widget.distanceGM.split(" ")[0]);

    // Convert kilometers to meters
    metersDistance = kilometers! * 1000;
    markerController.markers
        .removeWhere((element) => element.mapsId.value == 'start');
    markerController.markers.add(
      Marker(
          markerId: MarkerId('start'),
          position: widget.originLatlng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: "START")),
    );
    markerController.markers
        .removeWhere((element) => element.mapsId.value == 'end');
    markerController.markers.add(
      Marker(
          markerId: MarkerId('end'),
          position: widget.destinationLatlng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: "END")),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return inc == null || inc is int
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                "Race zone",
                style: TextStyle(fontSize: 20.sp,fontStyle: FontStyle.italic,color: Colors.white,fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            body: Column(
              children: [
                Container(height: 5.h,color: Colors.black,child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                  Obx(() => Container(
                    child: Text(raceZoneController.second.value
                        .toString(),style: TextStyle(fontSize: 20.sp,fontStyle: FontStyle.italic,color: Colors.white,fontWeight: FontWeight.bold),),
                  ))
                ],),),
                // Space for Map
                Container(
                  height: 52.h,
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
                                markers:
                                    Set<Marker>.of(markerController.markers),
                                onMapCreated: (controller) {
                                  googleMapController = controller;
                                },
                              ),
                            ),

                            // Container(child: Text(inc["rank"].toString()),),

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
                            ],
                          ),
                          // Player Stats Columns
                          Obx(
                            () => PlayerStatsColumn(
                              playerName: raceModelModelController
                                      .raceModel1.value.user?.name ??
                                  "",
                              eta: raceModelModelController
                                      .raceModel1.value.user?.coord?[0]
                                      .toString() ??
                                  "",
                              distance: raceModelModelController
                                      .raceModel1.value.user?.distance ??
                                  "",
                              speed: raceModelModelController
                                      .raceModel1.value.user?.speed ??
                                  "",
                            ),
                          ),
                          Obx(
                            () => PlayerStatsColumn(
                              playerName: raceModelModelController
                                      .raceModel2.value.user?.name ??
                                  "",
                              eta: raceModelModelController
                                      .raceModel2.value.user?.eta ??
                                  "",
                              distance: raceModelModelController
                                      .raceModel2.value.user?.distance ??
                                  "",
                              speed: raceModelModelController
                                      .raceModel2.value.user?.speed ??
                                  "",
                            ),
                          ),
                          Obx(
                            () => PlayerStatsColumn(
                              playerName: raceModelModelController
                                      .raceModel4.value.user?.name ??
                                  "",
                              eta: raceModelModelController
                                      .raceModel4.value.user?.eta ??
                                  "",
                              distance: raceModelModelController
                                      .raceModel4.value.user?.distance ??
                                  "",
                              speed: raceModelModelController
                                      .raceModel4.value.user?.speed ??
                                  "",
                            ),
                          ),
                          Obx(
                            () => PlayerStatsColumn(
                              playerName: raceModelModelController
                                      .raceModel3.value.user?.name ??
                                  "",
                              eta: raceModelModelController
                                      .raceModel3.value.user?.eta ??
                                  "",
                              distance: raceModelModelController
                                      .raceModel3.value.user?.distance ??
                                  "",
                              speed: raceModelModelController
                                      .raceModel3.value.user?.speed ??
                                  "",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (distanceToDestination < metersDistance! * 0.2)
                  InkWell(
                      onTap: () {
                        if(raceZoneController.won.value){
                          Get.to(()=>FinalScreen());
                        }else{
                          log("won $distanceToDestination");
                          raceZoneController.won.value = true;
                          rank.add(userController.user.sId!);
                          lobbyOperationController.addRank(lobbyId:widget.lobbyId , duration: raceZoneController.second.value);
                          stopTimer();
                          Get.to(()=>FinalScreen());
                        }
                        
                      },
                      child: Container(
                        width: double.infinity,
                        height: 6.h,
                        color: Colors.black,
                        child: Center(
                            child: Text(
                          "FINISH!",
                          style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              fontSize: 19.sp),
                        )),
                      ))
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

    _positionSubscription = _geoLocatorPlatform
        .getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) async {
      if (position != null) {
        if (position.speed > 0.5) {
          speed =
              "${(position.speed * 3.6).toStringAsFixed(2)}"; // Convert m/s to km/h
        } else {
          speed = "0.0";
          setState(() {}); // Display as idle if speed is below the threshold
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
        }
        _previousPosition = position;

        distanceToDestination = Geolocator.distanceBetween(
            originLatlng!.latitude,
            originLatlng!.longitude,
            widget.destinationLatlng.latitude,
            widget.destinationLatlng.longitude);
        // log(distanceToDestination.toString());

        if (distanceToDestination <= 20) {
          log("won $distanceToDestination");
          raceZoneController.won.value = true;
          rank.add(userController.user.sId!);
          lobbyOperationController.addRank(
              lobbyId: widget.lobbyId,
              duration: raceZoneController.second.value);
          stopTimer();
        } else {
          log("not yet $distanceToDestination");
        }

        initialPosition = CameraPosition(target: originLatlng!, zoom: 12);

        log(originLatlng!.longitude.toString());

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _positionSubscription!.cancel();
    _messageTimer!.cancel();
    super.dispose();
  }
}

class RaceZoneController extends GetxController {
  var won = false.obs;
  var second = 0.obs;
}
