


import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:redis/redis.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../widgets/widgets_race_zone.dart';

class RaceZoneScreen extends StatefulWidget {
  RaceZoneScreen({super.key});

  @override
  State<RaceZoneScreen> createState() => _RaceZoneScreenState();
}

class _RaceZoneScreenState extends State<RaceZoneScreen> {
  final WebSocketChannel channel =
      IOWebSocketChannel.connect('ws://192.168.1.2:8080');

  late GoogleMapController googleMapController;

  BitmapDescriptor? bitmapMarkerIcon;

  BitmapDescriptor? person2Icon;

  bool isSearching = false;

  LatLng? originLatlng;

  LatLng? originLatlng2;

  LatLng? destinationLatlng;

  CameraPosition? initialPosition;

  Set<Marker> markers = {};

  Set<Polyline> polylines = {};

  String distance = "";

  bool isLoading = true;

  List<LatLng> polylineCoordinates = [];

  PolylinePoints polylinePoints = PolylinePoints();

  TextEditingController endController = TextEditingController();

  List<String> playa = ["hjgjsdd89e7kl", "dfs", "dfsfs", "fsdfds"];
  var name;
  dynamic inc;

  Future<void> _initializeRedis() async {
    Command cmd = await RedisConnection().connect('192.168.1.2', 6379);
    final pubsub = PubSub(cmd);
    pubsub.subscribe(['abcde']);
    final stream = pubsub.getStream();
    var streamWithoutErrors = stream.handleError((e) => print("error $e"));

    await for (final msg in streamWithoutErrors) {
      // final decoded = jsonDecode(msg[0]);
      if (msg[2] != 1)
        // setState(() {
        //   messages2.add(msg[2].toString());
        // });

        print(msg[2].toString());
      inc = jsonDecode(msg[2].toString());




      // print(name??"player");
    }
  }

//
//
//
// }
  @override
  void initState() {
    // TODO: implement initState
    determineLivePosition();
    _initializeRedis();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return inc == null?Center(child: CircularProgressIndicator(),): Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "jhg",
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
            // Placeholder for the map
            child: initialPosition == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : GoogleMap(
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
                    ...List.generate(playa.length, (index) {
                      if(inc[playa[index]]!=null)
                      return PlayerStatsColumn(
                          playerName: inc[playa[index]]["name"], eta: inc[playa[index]]["coord"][0].toString(), distance: inc[playa[index]]["distance"], speed: inc[playa[index]]["speed"], calories: inc[playa[index]]["calories"],);
                      else
                        return PlayerStatsColumn(playerName: "plaers$index", eta: '', distance: '', speed: '', calories: '',);
                    }),
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

    _geoLocatorPlatform
        .getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) async {
      if (position != null) {
        originLatlng = LatLng(position.latitude, position.longitude);
        // originLatlng2 = LatLng(position.latitude + 0.004, position.longitude);

        initialPosition = CameraPosition(target: originLatlng!, zoom: 12);
        var message = jsonEncode({
          'hjgjsdd89e7kl': {
            'name': 'nitish',
            'coord': [originLatlng!.latitude, originLatlng!.longitude],
            'eta': '8',
            'distance': '9',
            'speed': '10',
            'calories': '120',
          },
          'userid': 'hjgjsdd89e7kl',
          'lobbyid': 'abcde',
        });
        log(originLatlng!.longitude.toString());
        // markers.add(
        //   Marker(
        //     markerId: MarkerId('origin'),
        //     position: inc[playa[0]]["coord"][0],
        //     icon: BitmapDescriptor.defaultMarker,
        //   ),
        // );
        // markers.removeWhere((element) => element.mapsId.value == 'origin');

        channel.sink.add(message);
        // markers.removeWhere((element) => element.mapsId.value == 'destination');

        setState(() {});
      }
    });
  }
}
