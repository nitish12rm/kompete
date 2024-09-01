import 'package:get/get.dart';
import 'package:kompete/data/model/Lobby/lobby_model.dart';

class LobbyModelController extends GetxController {
  var lobbyModel = LobbyModel().obs;

  // Load user data, for example, after login or sign-up
  void setLobbyModel(LobbyModel lobby) {
    lobbyModel.value = lobby;
  }

  // Get user data
  LobbyModel get user => lobbyModel.value;


  void removeLobbyModel() {
    lobbyModel.value = LobbyModel(); // Resets to a new UserModel instance
  }
// Additional methods to update other fields as needed
}
