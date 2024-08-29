
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
        home: Scaffold(
          body: ClassicModeScreen()
        ),
      );
    });
  }
}

