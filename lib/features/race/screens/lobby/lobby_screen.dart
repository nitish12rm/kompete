import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kompete/data/model/Lobby/lobby_model.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:kompete/logic/Lobby/controller/lobby_controller.dart';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:kompete/logic/Lobby/controller/lobby_controller.dart';





class LobbyScreen extends StatelessWidget {
  LobbyScreen({super.key});
  final LobbyModelController lobbyModelController = Get.put(LobbyModelController());

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.white,
              child: Padding(
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
                          lobbyModelController.lobbyModel.value.lobbyId ?? "error",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: lobbyModelController.lobbyModel.value.lobbyId??"error"));
                            final snackBar = SnackBar(
                              content: Text('Lobby ID copied to clipboard!'),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                          lobbyModelController.lobbyModel.value.distance ?? "error",
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
          SizedBox(height: 10),

          // Players
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                color: Colors.white,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 4.0, // Spacing between columns
                    mainAxisSpacing: 4.0, // Spacing between rows
                    childAspectRatio: 1.0, // Aspect ratio of each grid item
                  ),
                  itemCount: lobbyModelController.lobbyModel.value.users?.length ?? 0, // Total number of items
                  itemBuilder: (context, index) {
                    return Players(playerName: "Player $index");
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "START",
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
        ],
      ),
    );
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Icon(
            Icons.person,
            size: 50.sp,
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
    );
  }
}
