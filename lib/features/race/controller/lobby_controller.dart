import 'package:get/get.dart';

class LobbyController extends GetxController {
  var isCreateClicked = false.obs; // Observable to track button click

  void toggleCreateClicked() {
    isCreateClicked.value = !isCreateClicked.value;
  }
}
