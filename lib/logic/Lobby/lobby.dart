import 'dart:async';

import 'package:get/get.dart';
import 'package:kompete/data/model/Lobby/lobby_model.dart';
import 'package:kompete/features/race/screens/lobby/lobby_screen.dart';
import 'package:kompete/logic/Lobby/controller/lobby_controller.dart';
import 'package:kompete/logic/authentication/user.dart';

import '../../data/repository/Lobby Repository/lobby_repository.dart';
import '../../features/race/controller/lobby_controller.dart';

class LobbyOperationController extends GetxController{
  Timer? _timer;
  final UserController userController = Get.put(UserController());
  final LobbyModelController lobbyModelController = Get.put(LobbyModelController());
  LobbyRepository lobbyRepository = LobbyRepository();

  ///CREATION
  Future<void> createLobby({ required double originLat, required double originLng,required double destinationLat,required double destinationLng  ,required   List<List<double>> polyline,required String distance}) async{

    try{
     LobbyModel lobbyModel = await lobbyRepository.createLobby(userId: userController.userModel.value.sId??"error", originLat: originLat, originLng: originLng, destinationLat: destinationLat, destinationLng: destinationLng, polyline: polyline, distance: distance);
     lobbyModelController.setLobbyModel(lobbyModel);
     Get.to(LobbyScreen());
    }catch(e){
     throw e.toString();
    }
  }

  ///getLobby
  Future<void> getLobby({required lobbyId}) async{
    try{
      LobbyModel lobbyModel = await lobbyRepository.getLobby(lobbyId: lobbyId);
      lobbyModelController.setLobbyModel(lobbyModel);
    }catch(e){

    }
  }


  ///JOIN LOBBY
  Future<void> joinLobby({required lobbyId}) async{
    try{
      LobbyModel lobbyModel = await lobbyRepository.joinLobby(lobbyId: lobbyId, userId: userController.userModel.value.sId);
      lobbyModelController.setLobbyModel(lobbyModel);
    }catch(e){
      throw e.toString();
    }
  }

  ///REMOVE USER FROM LOBBY
  Future<void> removeFromLobby({required lobbyId}) async{
    try{
      LobbyModel lobbyModel = await lobbyRepository.removeFromLobby(lobbyId: lobbyId, userId: userController.userModel.value.sId);
      lobbyModelController.setLobbyModel(lobbyModel);
    }catch(e){
      throw e.toString();
    }
  }




  void startPolling({required lobbyId}) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await getLobby(lobbyId: lobbyId);
    });
  }


  void stopPolling() {
    _timer?.cancel();
  }
}