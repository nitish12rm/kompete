import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kompete/features/race/controller/drop_location_controller.dart';
import 'package:kompete/features/race/screens/lobby/lobby_screen.dart';
import 'package:kompete/utils/location_permission.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../constants/const.dart';
import '../../../data/model/place_from_coord.dart';
import '../../../data/model/places_autocomplete.dart';
import '../../../data/repository/api_services.dart';
import '../controller/lobby_controller.dart';
import 'classic_mode.dart';
import 'dropLocationScreen.dart';

class RaceInitialScreen extends StatefulWidget {
  const RaceInitialScreen({super.key});

  @override
  State<RaceInitialScreen> createState() => _RaceInitialScreenState();
}

class _RaceInitialScreenState extends State<RaceInitialScreen> {
  late GoogleMapController mapController;
  late GoogleMapController dropMapController;

  final LatLng _center = LatLng(45.521563, -122.677433);
  late GoogleMapController googleMapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  String distance = "";
  bool isLoading = false;
  bool isReedit = false;
  bool isDropLocation = false;
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  final LobbyController lobbyController = Get.put(LobbyController());
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  bool isSearching = false;
  bool isLoadedinit = false;
  bool isSearchingcurrent = false;

  bool isFocusOnStart = false;
  PlacesFromCoordinate placesFromCoordinate = PlacesFromCoordinate();
  PlacesAutocomplete placesAutocomplete = PlacesAutocomplete();
  LatLng? originlatlng;
  LatLng? currentlatlng;
  LatLng? dropLocation;
  LatLng? endlatlng;
  DropLocationController dropLocationController = Get.put(DropLocationController());

  getCurrentLocation() async {
    isLoadedinit = true;
    setState(() {});
    await determinePosition().then((value) {
      currentlatlng = LatLng(value.latitude, value.longitude);
      originlatlng = currentlatlng;
      dropLocation = currentlatlng;

      setState(() {});
      ApiServices()
          .getPlacesFromCoord(
              value.latitude.toString(), value.longitude.toString())
          .then((value) {
        startController.text = value.results?[0].formattedAddress ?? "";
      });
    });
    isLoadedinit = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        ///APP BAR
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          elevation: 0,
          title: Text(
            "KOMPETE",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ///BODY
        body: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            ///LOCATION SELECTOR BOX
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              height: 15.h,
              width: double.infinity,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onTap: () {
                                isFocusOnStart = true;
                              },
                              onChanged: (value) {
                                ApiServices()
                                    .getPlacesAutocomplete(value.toString())
                                    .then((value) {
                                  setState(() {
                                    placesAutocomplete = value;
                                  });
                                });
                              },
                              controller: startController,
                              decoration: InputDecoration(
                                hintText: "start".toUpperCase(),
                                hintStyle: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15.sp,
                                    color: Colors.white,
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w500),
                                // Change hint text color
                                border: InputBorder.none,
                                // Remove default border
                                fillColor: Colors.transparent,
                                // Background color of the TextField
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                              ),
                              style: TextStyle(
                                  color: Colors.white), // Change text color
                            ),
                          ),
                          isSearchingcurrent
                              ? CircularProgressIndicator()
                              : IconButton(
                                  onPressed: () async {
                                    isSearchingcurrent = true;
                                    setState(() {});
                                    await determinePosition().then((value) {
                                      originlatlng = LatLng(
                                          value.latitude, value.longitude);
                                      setState(() {});
                                      ApiServices()
                                          .getPlacesFromCoord(
                                              value.latitude.toString(),
                                              value.longitude.toString())
                                          .then((value) {
                                        startController.text = value
                                                .results?[0].formattedAddress ??
                                            "";
                                      });
                                    });
                                    isSearchingcurrent = false;
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.location_searching,
                                    color: Colors.white,
                                    size: 20,
                                  )),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 11,
                        ),
                        Container(
                          width: 1,
                          height: 25,
                          color: Colors.white,
                        ),
                        Container(
                          width: 1,
                          height: 25,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Container(
                          width: 70.w,
                          height: 1,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.green),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: dropLocationController.endController,
                              onTap: () {
                                isFocusOnStart = false;
                              },
                              onChanged: (value) {
                                ApiServices()
                                    .getPlacesAutocomplete(value.toString())
                                    .then((value) {
                                  setState(() {
                                    placesAutocomplete = value;
                                  });
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "END".toUpperCase(),
                                hintStyle: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.white,
                                    fontFamily: "Roboto",
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500),
                                // Change hint text color
                                border: InputBorder.none,
                                // Remove default border
                                fillColor: Colors.transparent,
                                // Background color of the TextField
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                              ),
                              style: TextStyle(
                                  color: Colors.white), // Change text color
                            ),
                          ),
                        Obx(
                            ()=>                        dropLocationController.isDropLocation.value?Container():  IconButton(
                                onPressed: () {
                                  endlatlng = null;
                                  dropLocationController.endController.text="";
                                  polylineCoordinates.clear();
                                  markers.clear();
                                  isReedit = false;
                                  setState(() {

                                  });
                                  dropLocationController.isDropLocation.value=true;
                                  dropLocationController.endLat.value = originlatlng!.latitude;
                                  dropLocationController.endLong.value = originlatlng!.longitude;
                                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>DropLocationScreen(currentLatLng: currentlatlng!,)));
                                },
                                icon: Icon(
                                  CupertinoIcons.map_pin,
                                  color: Colors.white,
                                ))

                        )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ///EDIT OR GO
            Obx(()=>dropLocationController.isDropLocation.value? Container(): isReedit
                ? InkWell(
              onTap: () {
                endlatlng = null;
                dropLocationController.endLat.value=0.0;
                dropLocationController.endLong.value=0.0;
                dropLocationController.endController.text="";
                polylineCoordinates.clear();
                markers.clear();
                isReedit = false;
                setState(() {});
              },
              child:Container(
                height: 5.h,
                color: Colors.black,
                child: Center(
                    child: Text(
                      "EDIT!",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    )),
              ),
            )
                : InkWell(
                onTap: () {
                  if (originlatlng == null || dropLocationController.endLat.value==0.0||dropLocationController.endLong.value==0.0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Enter valid address!")));
                  } else {
                    markers.add(Marker(
                        markerId: MarkerId("start"),
                        position: originlatlng!,
                        icon: BitmapDescriptor.defaultMarker));
                    markers.add(Marker(
                        markerId: MarkerId("end"),
                        position: LatLng(dropLocationController.endLat.value,dropLocationController.endLong.value),
                        icon: BitmapDescriptor.defaultMarkerWithHue(90)));
                    getPolyline();
                    isReedit = true;
                    setState(() {});
                  }
                },
                child: Container(
                  height: 5.h,
                  color: Colors.black,
                  child: Center(
                      child: Text(
                        "GO!",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold),
                      )),
                )),),
            ///MAP
            Container(
              height: 60.h,
              child: Obx(
                ()
                {
                  return Stack(
                    children: [
                      dropLocationController.isDropLocation.value
                          ? DropLocationScreen(
                              currentLatLng: currentlatlng!,
                              dropLocationController: dropLocationController,
                            )
                          : isLoadedinit
                              ? Container()
                              : GoogleMap(
                                  mapType: MapType.normal,
                                  initialCameraPosition: CameraPosition(
                                      target: LatLng(
                                          originlatlng?.latitude ??
                                              currentlatlng!.latitude,
                                          originlatlng?.longitude ??
                                              currentlatlng!.longitude),
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

                      isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container(),

                      ///suggestions
                      Visibility(
                        visible: placesAutocomplete.predictions == null
                            ? false
                            : true,
                        child: Container(
                          height: 30.h,
                          color: Colors.black,
                          child: ListView.separated(
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onTap: () {
                                    ApiServices()
                                        .getPlacesFromPlaceId(placesAutocomplete
                                                .predictions?[index].placeId
                                                .toString() ??
                                            "")
                                        .then((value) {
                                      if (isFocusOnStart) {
                                        originlatlng = LatLng(
                                            value.results?[0].geometry?.location
                                                    ?.lat
                                                    ?.toDouble() ??
                                                0.0,
                                            value.results?[0].geometry?.location
                                                    ?.lng
                                                    ?.toDouble() ??
                                                0.0);
                                        startController.text = value
                                                .results?[0].formattedAddress
                                                .toString() ??
                                            "";
                                        placesAutocomplete.predictions = null;
                                      } else {
                                        // endlatlng = LatLng(
                                        //     value.results?[0].geometry?.location
                                        //             ?.lat
                                        //             ?.toDouble() ??
                                        //         0.0,
                                        //     value.results?[0].geometry?.location
                                        //             ?.lng
                                        //             ?.toDouble() ??
                                        //         0.0);
                                        dropLocationController.endLat.value=value.results?[0].geometry?.location
                                            ?.lat
                                            ?.toDouble() ??
                                            0.0;
                                        dropLocationController.endLong.value= value.results?[0].geometry?.location
                                            ?.lng
                                            ?.toDouble() ??
                                            0.0;
                                        dropLocationController.endController.text = value
                                                .results?[0].formattedAddress
                                                .toString() ??
                                            "";
                                      endController.text=dropLocationController.endAddress.value ;
                                        placesAutocomplete.predictions = null;
                                      }
                                      setState(() {});
                                    });
                                  },
                                  leading: Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    placesAutocomplete
                                            .predictions?[index].description
                                            .toString() ??
                                        "",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider();
                              },
                              itemCount:
                                  placesAutocomplete.predictions?.length ?? 0),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ///DISTANCE AND CREATE BUTTON
            Container(
              color: Colors.black,
              height: 10.h, // Use a fixed height here to ensure it fits
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Text(
                            "Distance "+distance,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if(isReedit){
                          // showDialog(
                          //     context: context,
                          //     builder: (BuildContext context) {
                          //       return LobbyPopup(lobbyId: 'ABC123');
                          //     });
                          Get.to(()=>LobbyScreen());
                        }
                        else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Set the address first")));
                        }

                      },
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Text(
                            'CREATE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),


                ],
              ),
            ),
          ],
        ));
  }



  getPolyline() async {
    isLoading = true;
    setState(() {});

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: Constants.APIKEY,
        request: PolylineRequest(
          origin: PointLatLng(originlatlng!.latitude, originlatlng!.longitude),
          destination: PointLatLng(dropLocationController.endLat.value, dropLocationController.endLong.value),
          mode: TravelMode.walking,
        ),
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates.clear();  // Clear previous points if any
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });

        distance = result.distanceTexts!.first.toString();

        polylines.add(Polyline(
            polylineId: PolylineId("polyline"),
            color: Colors.blue,
            width: 7,
            points: polylineCoordinates));

        googleMapController
            .animateCamera(CameraUpdate.newLatLngZoom(originlatlng!, 12));
      } else {
        // If no points were found, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Route not found. Please try again.')),
        );
      }
    } catch (e) {
      // If there's an error in fetching the route, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red,content: Text('Failed to fetch route. Please check your connection or end location and try again.')),
      );

    } finally {
      isLoading = false;
      setState(() {});
    }
  }


// getPolyline() async {
  //   isLoading = true;
  //   setState(() {});
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     googleApiKey: Constants.APIKEY,
  //     request: PolylineRequest(
  //       origin: PointLatLng(originlatlng!.latitude, originlatlng!.longitude),
  //       destination: PointLatLng(dropLocationController.endLat.value, dropLocationController.endLong.value),
  //       mode: TravelMode.walking,
  //     ),
  //   );
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach((PointLatLng point) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     });
  //   }
  //   distance = result.distanceTexts!.first.toString();
  //
  //   polylines.add(Polyline(
  //       polylineId: PolylineId("polyline"),
  //       color: Colors.blue,
  //       width: 7,
  //       points: polylineCoordinates));
  //   isLoading = false;
  //   googleMapController
  //       .animateCamera(CameraUpdate.newLatLngZoom(originlatlng!, 12));
  //   setState(() {});
  // }
}
