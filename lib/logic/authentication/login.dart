import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kompete/data/model/user/user.dart';
import 'package:kompete/data/repository/user%20repository/user_repo.dart';
import 'package:kompete/features/Authentication/screens/signin/sign_in.dart';
import 'package:kompete/features/home/home.dart';
import 'package:kompete/features/race/racezone/screens/race_zone_screen.dart';
import 'package:kompete/logic/authentication/user.dart';
import 'package:kompete/navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final UserController userController = Get.put(UserController());
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _autoLogin();
  }

  Future<void> loginWithEmail() async {
    UserRepository userRepository = UserRepository();
    try {
      UserModel userModel = await userRepository.signin(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      log(userModel.email.toString() ?? "error");

      emailController.clear();
      passwordController.clear();
      userController.setUserModel(userModel);

      // Save the email and password to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', userModel.email.toString() ?? "error");
      await prefs.setString('password', userModel.password.toString() ?? "error");

      Get.offAll(() => NavigationScreen());
    } catch (error) {
      Get.back();
      _showErrorDialog(error.toString());
    }
  }

  Future<void> _autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');

    if (email != null && password != null) {
      // Try to log in with saved credentials
      UserRepository userRepository = UserRepository();
      try {
        UserModel userModel = await userRepository.signin(
          email: email,
          password: password,
        );
        userController.setUserModel(userModel);
       await Future.delayed(Duration(milliseconds: 1000));
        Get.offAll(() => RaceZoneScreen());
      } catch (error) {
        // _showErrorDialog('Auto-login failed: ${error.toString()}');
        // await Future.delayed(Duration(milliseconds: 1000));
        Get.offAll(()=>SignInScreen());
      }
    }
    else{
      await Future.delayed(Duration(milliseconds: 1000));
      Get.offAll(()=>SignInScreen());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          shape: BeveledRectangleBorder(),
          backgroundColor: Colors.white,
          title: Text(
            'Error',
            style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    // Clear the saved email and password
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');

    // Clear the user data and navigate to the login screen
    userController.removeUserModel();
    Get.offAll(() => SignInScreen());
  }
}
