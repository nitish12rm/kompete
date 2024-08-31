import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../logic/authentication/login.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Container(

      child: Center(
        child: InkWell(
            onTap: () {
              loginController.logout();
            },
            child: Container(
              color: Colors.white,
              height: 20.h,
              width: 50.w,
              child: Center(child: Text("LOGOUT")),
            )),
      ),
    );
  }
}
