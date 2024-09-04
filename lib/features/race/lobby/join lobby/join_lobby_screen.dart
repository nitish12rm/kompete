import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kompete/app.dart';
import 'package:kompete/features/race/screens/lobby/lobby_screen.dart';
import 'package:kompete/logic/Lobby/lobby.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
class JoinLobbyScreen extends StatelessWidget {
   JoinLobbyScreen({super.key});
TextEditingController lobbyIdController = TextEditingController();
LobbyOperationController lobbyOperationController = Get.put(LobbyOperationController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      appBar:  AppBar(foregroundColor: Colors.black,backgroundColor: Colors.white,title: Text("Join Lobby",style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),),
      body: Column(
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
        ],
      ),
    );
  }
}
