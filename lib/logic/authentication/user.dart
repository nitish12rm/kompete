import 'package:get/get.dart';
import 'package:kompete/data/model/user/user.dart';

class UserController extends GetxController {
  var userModel = UserModel().obs;

  // Load user data, for example, after login or sign-up
  void setUserModel(UserModel user) {
    userModel.value = user;
  }

  // Get user data
  UserModel get user => userModel.value;

  // Example of updating specific fields
  void updateUserName(String name) {
    userModel.update((user) {
      user?.name = name;
    });


  }
  void removeUserModel() {
    userModel.value = UserModel(); // Resets to a new UserModel instance
  }
// Additional methods to update other fields as needed
}
