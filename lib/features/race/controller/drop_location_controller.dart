import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DropLocationController extends GetxController {
  var isDropLocation = false.obs; // Observable to track button click
  var isReedit = false.obs; // Observable to track button click
  var endAddress = ''.obs;
  var endLat = 0.0.obs;
  var endLong = 0.0.obs;
  final endController = TextEditingController();

  @override
  void onClose() {
    // Dispose the TextEditingController when the controller is disposed
    endController.dispose();
    super.onClose();
  }

  void toggleCreateClicked() {
    isDropLocation.value = !isDropLocation.value;
  }
}
