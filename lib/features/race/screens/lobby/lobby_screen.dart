import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kompete/features/race/racezone/screens/race_zone_screen.dart';
import 'package:kompete/logic/Lobby/lobby.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:kompete/logic/Lobby/controller/lobby_controller.dart';

import '../../../../constants/const.dart';

class LobbyScreen extends StatefulWidget {
  LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  bool isLoadedinit = false;
  bool isLoading = false;
 // Text for countdown display
  late GoogleMapController googleMapController;
  final LobbyModelController lobbyModelController =
  Get.put(LobbyModelController());
  final LobbyOperationController lobbyOperationController =
  Get.put(LobbyOperationController());
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
   bool isReadyClicked = false;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};


  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    isLoadedinit=true;
    markers.add(Marker(
        markerId: MarkerId("start"),
        position: LatLng(
            lobbyModelController.lobbyModel.value
                .coordinates?[0].markers?[0].origin?[0] ??
                0.0,
            lobbyModelController.lobbyModel.value
                .coordinates?[0].markers?[0].origin?[1] ??
                0.0),
        icon: BitmapDescriptor.defaultMarker));
    markers.add(Marker(
        markerId: MarkerId("end"),
        position: LatLng(
            lobbyModelController.lobbyModel.value
                .coordinates?[0].markers?[0].destination?[0] ??
                0.0,
            lobbyModelController.lobbyModel.value
                .coordinates?[0].markers?[0].destination?[1] ??
                0.0),
        icon: BitmapDescriptor.defaultMarkerWithHue(90)));
    polylineCoordinates=parsePolylineData(lobbyModelController.lobbyModel.value.coordinates![0].polyline!);
    getPolyline();
    isLoadedinit=false;

    lobbyOperationController.startPolling(
        lobbyId: lobbyModelController.lobbyModel.value.lobbyId);
  }

  @override
  void dispose() {
    lobbyOperationController.stopPolling();
    lobbyOperationController.removeFromLobby(
        lobbyId: lobbyModelController.lobbyModel.value.lobbyId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "LOBBY",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [

          ///lobby id and distance
          Obx(

            ()=> Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.white,
                child:Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "LOBBY ID",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Spacer(),
                          Text(
                            lobbyModelController.lobbyModel.value.lobbyId ??
                                "error",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: lobbyModelController
                                      .lobbyModel.value.lobbyId ??
                                      "error"));
                              final snackBar = SnackBar(
                                content: Text('Lobby ID copied to clipboard!'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                            icon: Icon(
                              Icons.copy_sharp,
                              color: Colors.black,
                              size: 18.sp,
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            "TOTAL DISTANCE",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Spacer(),
                          Text(
                            lobbyModelController.lobbyModel.value.distance ??
                                "error",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(width: 30.sp),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),

          // Players
          Container(
            height: 21.h,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text("KOMPETERS",style: TextStyle(fontSize: 17.sp,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),),
                    ),
                    Expanded(
                      child: Obx(
                            () =>
                            ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                              lobbyModelController.lobbyModel.value.users?.length ??
                                  0,
                              // Total number of items
                              itemBuilder: (context, index) {
                                return Players(playerName: "Player $index");
                              },
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          ///maps
          Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Container(
                      color: Colors.white,
                      child: isLoadedinit
                          ? Container()
                          : GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(
                                lobbyModelController.lobbyModel.value
                                    .coordinates?[0].markers?[0].origin?[0] ??
                                    0.0,
                                lobbyModelController.lobbyModel.value
                                    .coordinates?[0].markers?[0].origin?[1] ??
                                    0.0),
                            zoom: 12),
                        myLocationEnabled: true,
                        tiltGesturesEnabled: true,
                        compassEnabled: true,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        onMapCreated: (controller) {
                          googleMapController = controller;
                        },
                        markers: markers,
                        polylines: polylines,
                      ),
                    ),
                    isLoading
                        ? Center(
                      child: CircularProgressIndicator(),
                    )
                        : Container(),
                  ],
                ),
              )),

          SizedBox(height: 10),
          Obx(
                () => lobbyModelController.lobbyModel.value.users!.length >= 2
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
              onTap:() {
                Get.to(()=>RaceZoneScreen(polyline: polylines, destinationLatlng:LatLng(
                    lobbyModelController.lobbyModel.value
                        .coordinates?[0].markers?[0].destination?[0] ??
                        0.0,
                    lobbyModelController.lobbyModel.value
                        .coordinates?[0].markers?[0].destination?[1] ??
                        0.0), distanceGM: lobbyModelController.lobbyModel.value.distance! ,));
                lobbyOperationController.stopPolling();

              },
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Start",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 20.sp,
                          ),
                        ),
                        Icon(Icons.arrow_right_alt_outlined, size: 25.sp),
                      ],
                    ),
                  ),
                ),
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Center(
                    child: Text(
                      "Waiting...",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  getPolyline() async {
    isLoading = true;
    setState(() {});

    try {


      if (polylineCoordinates.isNotEmpty) {

        polylines.add(Polyline(
            polylineId: PolylineId("polyline"),
            color: Colors.blue,
            width: 7,
            points: polylineCoordinates));

        googleMapController
            .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lobbyModelController.lobbyModel.value.coordinates?[0].markers?[0]
            .origin?[0] ?? 0.0, lobbyModelController.lobbyModel.value.coordinates?[0].markers?[0]
            .origin?[1] ?? 0.0,), 10));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Route not found. Please try again.')),
        );
      }
    } catch (e) {
      // If there's an error in fetching the route, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text(
                'Failed to fetch route. Please check your connection or end location and try again.')),
      );
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

//to parse polylineData list to polylines(latlng)

// Function to parse polyline data from backend
  List<LatLng> parsePolylineData(List<dynamic> polylineData) {
    return polylineData.map((coord) => LatLng(coord[0], coord[1])).toList();
  }
}

class Players extends StatelessWidget {
  final String playerName;

  const Players({
    Key? key,
    required this.playerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Icon(
                Icons.person,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            playerName,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
