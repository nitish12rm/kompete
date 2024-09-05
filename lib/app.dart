
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kompete/features/Authentication/screens/signup/sign_up.dart';
import 'package:kompete/features/Splash/splash_screen.dart';
import 'package:kompete/features/home/home.dart';
import 'package:kompete/features/race/screens/race_initial_screen.dart';
import 'package:kompete/navigation_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'features/Authentication/screens/signin/sign_in.dart';
import 'features/race/racezone/screens/race_zone_screen.dart';
import 'features/race/screens/classic_mode.dart';
import 'features/race/screens/mode_select_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType){
      return GetMaterialApp(

        theme: ThemeData(
          fontFamily: "Roboto"
        ),
        home: NavigationScreen()
      );
    });
  }
}

