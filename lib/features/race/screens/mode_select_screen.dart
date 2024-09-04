import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kompete/features/race/lobby/join%20lobby/join_lobby_screen.dart';
import 'package:kompete/features/race/screens/race_initial_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'classic_mode.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
        ),
        body: Column(
          children: [
            Expanded(
                child: Row(
              children: [
                Expanded(
                  child: Container(
                      color: Colors.black,
                      child: Center(
                          child: Text(
                        'Classic Mode',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ))),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: (){
                                    Get.to(()=>RaceInitialScreen());

                          },
                          child: Container(
                              color: Colors.black,
                              child: Center(
                                  child: Text(
                                'Create',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              ))),
                        ),
                      ),
                      Container(width: double.infinity,height: 1,color: Colors.white,),
                      Expanded(
                        child: InkWell(
                          onTap: (){
                            Get.to(()=>JoinLobbyScreen());

                          },
                          child: Container(
                              color: Colors.black,
                              child: Center(
                                  child: Text(
                                'Join',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              ))),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
            Expanded(
                child: GestureDetector(
                    child: Center(
                        child: Text(
              'Free Mode',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            )))),
          ],
        ));
  }
}
