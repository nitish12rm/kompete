import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  void signIn() async {
    isLoading(true);
    // Mocking a sign-in process
    await Future.delayed(Duration(seconds: 2));

    // Perform sign-in logic here
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields");
    } else {
      Get.snackbar("Success", "Signed in as $email");
    }

    isLoading(false);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
