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
        required String name,
      required double originLng,
      required double destinationLat,
      required double destinationLng,
      required List<List<double>> polyline,
      required String distance}) async {
    try {
      var response = await _api.sendRequest.post('/lobby/create',
          data: jsonEncode({
"name":name,
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
      {required String lobbyId, required userId, required name}) async {
    try {
      var response = await _api.sendRequest.post('/lobby/join',
          data: jsonEncode({"lobbyId": lobbyId, "userId": userId, "name":name}));
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

  ///REMOVE LOBBY
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


  ///ADD READY
  Future<LobbyModel> addReady(
      {required String lobbyId, required userId}) async {
    try {
      var response = await _api.sendRequest.post('/lobby/ready/add',
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

  ///REMOVE READY
  Future<LobbyModel> removeReady(
      {required String lobbyId, required userId}) async {
    try {
      var response = await _api.sendRequest.post('/lobby/ready/remove',
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

  Future<LobbyModel> addRank(
      {required String lobbyId, required userId, required int duration}) async {
    try {
      var response = await _api.sendRequest.post('/lobby/rank',
          data: jsonEncode({"lobbyId": lobbyId, "userId": userId,"duration": duration}));
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
