import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kompete/data/model/user/user.dart';
import 'package:kompete/data/repository/user%20repository/user_repo.dart';
import 'package:kompete/features/race/screens/race_initial_screen.dart';
import 'package:kompete/logic/authentication/user.dart';
import 'package:kompete/navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/home.dart';

class SignupController extends GetxController {
  final UserController userController = Get.put(UserController());

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  Future<void> signup() async {
    UserRepository userRepository = UserRepository();
    try {
      UserModel userModel =await userRepository.signup(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        weight: weightController.text,
        height: heightController.text,
      );

      nameController.clear();
      emailController.clear();
      passwordController.clear();
      weightController.clear();
      heightController.clear();

      userController.setUserModel(userModel);
      // Save the email and password to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', userModel.email.toString() ?? "error");
      await prefs.setString('password', userModel.password.toString() ?? "error");

      Get.offAll(()=>NavigationScreen()); // Navigate to the next screen after signup
    } catch (error) {
      Get.back();
      _showErrorDialog(error.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          shape: BeveledRectangleBorder(),
          backgroundColor: Colors.white,
          title: Text('Error',style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic),),
          content: Text(message,style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic)),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK',style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic)),
            ),
          ],
        );
      },
    );
  }
}
