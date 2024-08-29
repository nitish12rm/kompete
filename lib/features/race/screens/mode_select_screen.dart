import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'classic_mode.dart';
class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(child: GestureDetector(onTap: (){Navigator.push(context, MaterialPageRoute(builder: (_)=>ClassicModeScreen()));},child: Container(color: Colors.black,child: Center(child: Text('Classic Mode', style: TextStyle(color: Colors.white,fontSize: 20.sp,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),))))),
          Expanded(child: GestureDetector(child: Center(child: Text('Free Mode',style: TextStyle(color: Colors.black,fontSize: 20.sp,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),)))),
        ],
      )
    );
  }
}
