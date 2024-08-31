import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kompete/features/race/controller/drop_location_controller.dart';

import '../../../data/model/place_from_coord.dart';
import '../../../data/repository/api_services.dart';

class DropLocationScreen extends StatefulWidget {
  final LatLng currentLatLng;
  final DropLocationController dropLocationController;
  const DropLocationScreen({super.key, required this.currentLatLng, required this.dropLocationController});

  @override
  State<DropLocationScreen> createState() => _DropLocationScreenState();
}

class _DropLocationScreenState extends State<DropLocationScreen> {
  late GoogleMapController mapController;
  double defaultLat = 0.0;
  double defaultLong = 0.0;
  bool isLoading = true;
  PlacesFromCoordinate placesFromCoordinate = PlacesFromCoordinate();

  getAddress(){
    ApiServices().getPlacesFromCoord(widget.currentLatLng.latitude.toString(), widget.currentLatLng.longitude.toString()).then((value){

      setState(() {
        defaultLat = value.results?[0].geometry?.location?.lat??0.0;
        defaultLong = value.results?[0].geometry?.location?.lng??0.0;
        placesFromCoordinate = value;
        isLoading=false;
      });
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAddress();

  }


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:isLoading? Center(child: CircularProgressIndicator(),): Column(
        children: [
          InkWell(
            onTap: (){
              widget.dropLocationController.endLat.value= defaultLat;
              widget.dropLocationController.endLong.value= defaultLong;
              widget.dropLocationController.endController.text= placesFromCoordinate.results?[0].formattedAddress ?? "";

              widget.dropLocationController.isDropLocation.value = false;
              widget.dropLocationController.isReedit.value = true;

            },
            child: Container(width: double.infinity,color: Colors.black,child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(child: Text("SET!",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),)),
            ),),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  myLocationEnabled: true,
                  tiltGesturesEnabled: true,
                  compassEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(defaultLat, defaultLong),
                    zoom: 12,
                  ),
                  onCameraIdle: (){
                    ApiServices().getPlacesFromCoord(defaultLat.toString(), defaultLong.toString()).then((value){
                      setState(() {
                        placesFromCoordinate = value;

                      });
                    });
                  },
                  onCameraMove: (posn){
                    setState(() {
                      defaultLat = posn.target.latitude;
                      defaultLong = posn.target.longitude;
                    });
                  },
                ),
                Center(child: Icon(CupertinoIcons.map_pin,size: 50,color: Colors.green,),),
                // Positioned(bottom: 120,right:10 ,child: InkWell(
                //   onTap: (){
                //     widget.dropLocationController.endLat.value= defaultLat;
                //     widget.dropLocationController.endLong.value= defaultLong;
                //     widget.dropLocationController.endController.text= placesFromCoordinate.results?[0].formattedAddress ?? "";
                //
                //     widget.dropLocationController.isDropLocation.value = false;
                //     widget.dropLocationController.isReedit.value = true;
                //
                //   },
                //   child: Container(color: Colors.black,child: Padding(
                //     padding: const EdgeInsets.all(20.0),
                //     child: Text("SET!",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),),
                //   ),),
                // ))
              ],

            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.black,
        padding:EdgeInsets.symmetric(vertical: 20,horizontal: 20) ,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
          Icon(Icons.location_on,size: 30,color: Colors.green,),
          Expanded(child: Text(placesFromCoordinate.results?[0].formattedAddress??"Loading",style: TextStyle(fontSize: 15,color: Colors.white),)),
        ],),
      ),
    );
  }
}
