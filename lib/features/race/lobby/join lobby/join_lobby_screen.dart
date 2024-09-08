import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kompete/app.dart';
import 'package:kompete/features/race/Specatate/Screen/spectate_screen.dart';
import 'package:kompete/features/race/screens/lobby/lobby_screen.dart';
import 'package:kompete/logic/Lobby/controller/lobby_controller.dart';
import 'package:kompete/logic/Lobby/lobby.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
class JoinLobbyScreen extends StatefulWidget {
   JoinLobbyScreen({super.key});

  @override
  State<JoinLobbyScreen> createState() => _JoinLobbyScreenState();
}

class _JoinLobbyScreenState extends State<JoinLobbyScreen> {
TextEditingController lobbyIdController = TextEditingController();

LobbyOperationController lobbyOperationController = Get.put(LobbyOperationController());
final LobbyModelController lobbyModelController = Get.put(LobbyModelController());

   List<LatLng> polylineCoordinates=[];
   Set<Polyline> polylines={};
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      appBar:  AppBar(foregroundColor: Colors.black,backgroundColor: Colors.white,title: Text("Join Lobby",style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),),
      body:isLoading?Center(child: CircularProgressIndicator(),): Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 25.h,),
              Center(
                child: Container(
                  width: 50.w,
                  child: TextField(
                    controller: lobbyIdController,
                    decoration: InputDecoration(
                      hintText: "LobbyId",
                      hintStyle: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black))
                    ),
                    style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),

                  ),
                ),
              ),
          SizedBox(height: 2.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async{
                  if(lobbyIdController.text.isNotEmpty){
                    try{
                      await lobbyOperationController.joinLobby(lobbyId: lobbyIdController.text.toString());
                      Get.to(LobbyScreen());
                    }catch(e){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.black,content: Text(e.toString())));
                    }
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.black,content: Text("Enter lobby id")));

                  }

                },
                child: Container(color: Colors.black,child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 15),
                  child: Text("JOIN",style:TextStyle(color: Colors.white,fontSize: 16.sp,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold)),
                ),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(child: Text("or",style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),),
              ),
              InkWell(
                onTap: () async{
                  if(lobbyIdController.text.isNotEmpty){

                    try{
                      isLoading = true;
                      setState(() {});
                      await lobbyOperationController.getLobby(lobbyId: lobbyIdController.text.toString());
                   polylineCoordinates=parsePolylineData(lobbyModelController.lobbyModel.value.coordinates![0].polyline!);

                     getPolyline();
                      Get.to(SpectateScreen(polyline:polylines , destinationLatlng: LatLng(
                          lobbyModelController.lobbyModel.value
                              .coordinates?[0].markers?[0].destination?[0] ??
                              0.0,
                          lobbyModelController.lobbyModel.value
                              .coordinates?[0].markers?[0].destination?[1] ??
                              0.0), distanceGM: lobbyModelController.lobbyModel.value.distance!, lobbyId: lobbyIdController.text, users: lobbyModelController.lobbyModel.value.users!.map((user) => user.userId).toList(), originLatlng: LatLng(
                          lobbyModelController.lobbyModel.value
                              .coordinates?[0].markers?[0].origin?[0] ??
                              0.0,
                          lobbyModelController.lobbyModel.value
                              .coordinates?[0].markers?[0].origin?[1] ??
                              0.0)));
                      isLoading = true;
                      setState(() {});
                    }catch(e){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.black,content: Text(e.toString())));
                    }
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.black,content: Text("Enter lobby id")));

                  }

                },
                child: Container(color: Colors.black,child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 15),
                  child: Text("SPECTATE",style:TextStyle(color: Colors.white,fontSize: 16.sp,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold)),
                ),),
              ),
            ],
          ),
        ],
      ),
    );
  }

   List<LatLng> parsePolylineData(List<dynamic> polylineData) {
     return polylineData.map((coord) => LatLng(coord[0], coord[1])).toList();
   }

   getPolyline() async {


     try {


       if (polylineCoordinates.isNotEmpty) {

         polylines.add(Polyline(
             polylineId: PolylineId("polyline"),
             color: Colors.blue,
             width: 7,
             points: polylineCoordinates));

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
     }
   }
}
