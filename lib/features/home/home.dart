import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kompete/features/race/screens/mode_select_screen.dart';
import 'package:kompete/logic/authentication/login.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../logic/authentication/user.dart';

class HomeScreen extends StatelessWidget {
  final UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 20.h,
              width: double.infinity,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Races Won!",
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.w500)),
                  Text(
                    "27",
                    style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  )
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 20.h,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Weight",
                              style: TextStyle(
                                  fontSize: 18.sp, fontWeight: FontWeight.w500)),
                          Text(
                            '${userController.userModel.value.weight} kg',
                            style: TextStyle(
                                fontSize: 30.sp,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          )
                        ],
                      ),
                    ),
                  )),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 20.h,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Height",
                              style: TextStyle(
                                  fontSize: 18.sp, fontWeight: FontWeight.w500)),
                          Text(
                            "${userController.userModel.value.height??"00"}cm",
                            style: TextStyle(
                                fontSize: 30.sp,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          )
                        ],
                      ),
                    ),
                  )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 20.h,
              width: double.infinity,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("BMI",
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.w500)),
                  Text(
                    "27",
                    style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  )
                ],
              ),
            ),
          ),

          ///Play
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
              child: InkWell(
                onTap: (){
                  // Get.to(()=>ModeSelectScreen());
                  Get.to(()=>ModeSelectScreen());
                },
                child: Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "LETS GO!",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 20.sp,
                            color: Colors.black),
                      ),
                      Icon(
                        Icons.flag,
                        color: Colors.black,
                        size: 25.sp,
                      )
                    ],
                  ),
                ),
              ),
            ),),
        ],
      ),
    );
  }
}

class NavigationbarController extends GetxController{
  var selectedIndex = 0.obs;
}