import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:kompete/data/model/Race/race_model.dart';

class RaceModelModelController extends GetxController {
  var raceModel1 = RaceModel().obs;
  var raceModel2 = RaceModel().obs;
  var raceModel3 = RaceModel().obs;
  var raceModel4 = RaceModel().obs;

  void setRaceModel1(RaceModel race) {
    raceModel1.value = race;
  }
  void setRaceModel2(RaceModel race) {
    raceModel2.value = race;
  }
  void setRaceModel3(RaceModel race) {
    raceModel2.value = race;
  }
  void setRaceModel4(RaceModel race) {
    raceModel2.value = race;
  }




}