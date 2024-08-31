import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kompete/app.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../classic_mode.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("LOBBY", style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic),
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
                              fontStyle: FontStyle.italic),
                        ),
                        Spacer(),
                        Text(
                          "315678",
                          style: TextStyle(
                              fontSize: 18.sp,

                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: "lobbyId"));
                              final snackBar = SnackBar(
                                content: Text('Lobby ID copied to clipboard!'),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            },
                            icon: Icon(
                              Icons.copy_sharp,
                              color: Colors.black,
                              size: 18.sp,
                            ))
                      ],
                    ),
                    Divider(),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Text(
                          "TOTAL DISTANCE",
                          style: TextStyle(
                            fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ),
                        Spacer(),
                        Text(
                          "20 KM",
                          style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ),
                        SizedBox(
                          width: 30.sp,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ///Players
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Players(),
                          Players(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Players(),
                          Players(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
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
                          fontSize: 20.sp),
                    ),
                    Icon(Icons.arrow_right_alt_outlined,size: 25.sp,)
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
