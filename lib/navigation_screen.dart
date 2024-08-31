import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:kompete/features/home/home.dart';
import 'package:kompete/features/profile/profile.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'logic/authentication/login.dart';
import 'logic/authentication/user.dart';

class NavigationScreen extends StatelessWidget {
   NavigationScreen({super.key});
  final UserController userController = Get.put(UserController());

  final NavigationbarController navigationbarController = Get.put(NavigationbarController());

  List screens = [
    HomeScreen(),
    Container(color: Colors.blue,),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            "Welcome, ${userController.userModel.value.name ?? "Name"}",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
        ),
        body:screens[navigationbarController.selectedIndex.value] ,
        bottomNavigationBar: Obx(
              ()=> NavigationBar(
              backgroundColor: Colors.white,
              indicatorColor: Colors.black,
              selectedIndex:navigationbarController.selectedIndex.value ,
              onDestinationSelected: (index){
                navigationbarController.selectedIndex.value=index;

              },
              destinations: [
                NavigationDestination(icon: Icon(Icons.home,color:navigationbarController.selectedIndex.value==0? Colors.white:Colors.grey,), label: "Home"),
                NavigationDestination(icon: Icon(Icons.receipt,color:navigationbarController.selectedIndex.value==1? Colors.white:Colors.grey,), label: "Recents"),
                NavigationDestination(icon: Icon(Icons.person,color:navigationbarController.selectedIndex.value==2? Colors.white:Colors.grey,), label: "Profile"),

              ]),
        ),
      ),
    );
  }
}
class NavigationbarController extends GetxController{
  var selectedIndex = 0.obs;
}