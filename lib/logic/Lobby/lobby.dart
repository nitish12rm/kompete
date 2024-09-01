import 'package:get/get.dart';
import 'package:kompete/data/model/Lobby/lobby_model.dart';
import 'package:kompete/features/race/screens/lobby/lobby_screen.dart';
import 'package:kompete/logic/Lobby/controller/lobby_controller.dart';
import 'package:kompete/logic/authentication/user.dart';

import '../../data/repository/Lobby Repository/lobby_repository.dart';
import '../../features/race/controller/lobby_controller.dart';

class LobbyOperationController extends GetxController{
  final UserController userController = Get.put(UserController());
  final LobbyModelController lobbyModelController = Get.put(LobbyModelController());

  ///CREATION
  Future<void> createLobby({ required double originLat, required double originLng,required double destinationLat,required double destinationLng  ,required   List<List<double>> polyline,required String distance}) async{
    LobbyRepository lobbyRepository = LobbyRepository();

    try{
     LobbyModel lobbyModel = await lobbyRepository.createLobby(userId: userController.userModel.value.sId??"error", originLat: originLat, originLng: originLng, destinationLat: destinationLat, destinationLng: destinationLng, polyline: polyline, distance: distance);
     lobbyModelController.setLobbyModel(lobbyModel);
     Get.to(LobbyScreen());
    }catch(e){

    }
  }
}