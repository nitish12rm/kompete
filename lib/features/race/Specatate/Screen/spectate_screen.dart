import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:redis/redis.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../data/model/Race/race_model.dart';
import '../../../../logic/race/marker_controller.dart';
import '../../../../logic/race/race_model_controller.dart';
import '../../final/screen/final_screen.dart';
import '../../racezone/screens/race_zone_screen.dart';
import '../../racezone/widgets/widgets_race_zone.dart';

class SpectateScreen extends StatefulWidget {
  const SpectateScreen({super.key,required this.polyline,
    required this.destinationLatlng,
    required this.distanceGM,
    required this.lobbyId,
    required this.users, required this.originLatlng});

  final Set<Polyline> polyline;
  final LatLng destinationLatlng;
  final LatLng originLatlng;
  final String distanceGM;
  final String lobbyId;
  final List<String?> users;

  @override
  State<SpectateScreen> createState() => _SpectateScreenState();
}

class _SpectateScreenState extends State<SpectateScreen> {
  ///VARIABLES
late GoogleMapController googleMapController;
final RaceModelModelController raceModelModelController =
   Get.put(RaceModelModelController());
final MarkerController markerController = Get.put(MarkerController());
  dynamic inc;
  RaceModel raceModel = RaceModel();
final RaceZoneController raceZoneController = Get.put(RaceZoneController());
  ///FUNCTIONS

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
    // else if (raceModel.userid == widget.users[2]) {
    //   markerController.markers
    //       .removeWhere((element) => element.mapsId.value == 'origin3');
    //   markerController.markers.add(
    //     Marker(
    //         markerId: MarkerId('origin3'),
    //         position: LatLng(inc["user"]["coord"][0], inc["user"]["coord"][1]),
    //         icon: BitmapDescriptor.defaultMarker,
    //         infoWindow: InfoWindow(title: inc["user"]["name"])),
    //   );
    // }else if (raceModel.userid == widget.users[3]) {
    //   markerController.markers
    //       .removeWhere((element) => element.mapsId.value == 'origin4');
    //   markerController.markers.add(
    //     Marker(
    //         markerId: MarkerId('origin4'),
    //         position: LatLng(inc["user"]["coord"][0], inc["user"]["coord"][1]),
    //         icon: BitmapDescriptor.defaultMarker,
    //         infoWindow: InfoWindow(title: inc["user"]["name"])),
    //   );
    // }

  }
@override
void initState() {
  _initializeRedis();
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
          // Container(height: 5.h,color: Colors.black,child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
          //   Obx(() => Container(
          //     child: Text(raceZoneController.second.value
          //         .toString(),style: TextStyle(fontSize: 20.sp,fontStyle: FontStyle.italic,color: Colors.white,fontWeight: FontWeight.bold),),
          //   ))
          // ],),),
          // Space for Map
          Container(
            height: 57.h,
            color: Colors.black.withOpacity(0.05),
            child:Stack(
              children: [
                Obx(
                      () => GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(target: widget.originLatlng,zoom: 12),
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

            InkWell(
                onTap: () {

                    Get.to(()=>FinalScreen());


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
}
