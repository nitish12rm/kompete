import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:http/http.dart';
import 'package:kompete/data/model/Lobby/lobby_model.dart';

import '../../../core/api.dart';

class LobbyRepository {
  Api _api = Api();

  ///LOBBY CREATION
  Future<LobbyModel> createLobby(
      {required String userId,
      required double originLat,
      required double originLng,
      required double destinationLat,
      required double destinationLng,
      required List<List<double>> polyline,
      required String distance}) async {
    try {
      var response = await _api.sendRequest.post('/lobby/create',
          data: jsonEncode({
            'createdBy': userId,
            'role': 'admin',
            "coordinates": [
              {
                "markers": [
                  {
                    "origin": [originLat, originLng],
                    "destination": [destinationLat, destinationLng]
                  }
                ],
                "polyline": polyline
              }
            ],
            "distance": distance
          }));

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if (!apiResponse.success) {
        throw apiResponse.message ?? "Unknown error occurred";
      }
      LobbyModel lobbyModel = LobbyModel.fromJson(apiResponse.data);
      log(lobbyModel.lobbyId.toString());
      return lobbyModel;
    } on DioException catch (dioError) {
      String errorMessage = "An unexpected error occurred";
      if (dioError.response != null) {
// Extract the API error message from the response
        ApiResponse apiResponse = ApiResponse.fromResponse(dioError.response!);
        errorMessage = apiResponse.message ?? errorMessage;
      } else {
// Handle cases where the error has no response (e.g., network issues)
        errorMessage = dioError.message ?? "check your network";
      }
      throw errorMessage;
    } catch (error) {
      throw error.toString();
    }
  }

  ///GETLOBBY
  Future<LobbyModel> getLobby({required String lobbyId}) async {
    try {
      var response = await _api.sendRequest
          .get('/lobby', data: jsonEncode({"lobbyId": lobbyId}));
      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      LobbyModel lobbyModel = LobbyModel.fromJson(apiResponse.data);

      return lobbyModel;
    } on DioException catch (dioError) {
      String errorMessage = "An unexpected error occurred";
      if (dioError.response != null) {
// Extract the API error message from the response
        ApiResponse apiResponse = ApiResponse.fromResponse(dioError.response!);
        errorMessage = apiResponse.message ?? errorMessage;
      } else {
// Handle cases where the error has no response (e.g., network issues)
        errorMessage = dioError.message ?? "check your network";
      }
      throw errorMessage;
    } catch (error) {
      throw error.toString();
    }
  }


///JOIN LOBBY
  Future<LobbyModel> joinLobby(
      {required String lobbyId, required userId}) async {
    try {
      var response = await _api.sendRequest.post('/lobby/join',
          data: jsonEncode({"lobbyId": lobbyId, "userId": userId}));
      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      LobbyModel lobbyModel = LobbyModel.fromJson(apiResponse.data);

      return lobbyModel;
    } on DioException catch (dioError) {
      String errorMessage = "An unexpected error occurred";
      if (dioError.response != null) {
// Extract the API error message from the response
        ApiResponse apiResponse = ApiResponse.fromResponse(dioError.response!);
        errorMessage = apiResponse.message ?? errorMessage;
      } else {
// Handle cases where the error has no response (e.g., network issues)
        errorMessage = dioError.message ?? "check your network";
      }
      throw errorMessage;
    } catch (error) {
      throw error.toString();
    }
  }

  ///JOIN LOBBY
  Future<LobbyModel> removeFromLobby(
      {required String lobbyId, required userId}) async {
    try {
      var response = await _api.sendRequest.post('/lobby/remove',
          data: jsonEncode({"lobbyId": lobbyId, "userId": userId}));
      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      LobbyModel lobbyModel = LobbyModel.fromJson(apiResponse.data);

      return lobbyModel;
    } on DioException catch (dioError) {
      String errorMessage = "An unexpected error occurred";
      if (dioError.response != null) {
// Extract the API error message from the response
        ApiResponse apiResponse = ApiResponse.fromResponse(dioError.response!);
        errorMessage = apiResponse.message ?? errorMessage;
      } else {
// Handle cases where the error has no response (e.g., network issues)
        errorMessage = dioError.message ?? "check your network";
      }
      throw errorMessage;
    } catch (error) {
      throw error.toString();
    }
  }
}
