import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:kompete/core/api.dart';
import 'package:kompete/data/model/user/user.dart';

class UserRepository {
  final Api _api = Api();

  Future<UserModel> signin({
    required String email,
    required String password,
  }) async {
    try {
      var response = await _api.sendRequest.post(
        "auth/login",
        data: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if (!apiResponse.success) {
        throw apiResponse.message ?? "Unknown error occurred";
      }
      UserModel userModel = UserModel.fromJson(apiResponse.data);
      log(userModel.email.toString());
      return userModel;
    } on DioException catch (dioError) {
      String errorMessage = "An unexpected error occurred";
      if (dioError.response != null) {
        // Extract the API error message from the response
        ApiResponse apiResponse =
        ApiResponse.fromResponse(dioError.response!);
        errorMessage = apiResponse.message ?? errorMessage;
      } else {
        // Handle cases where the error has no response (e.g., network issues)
        errorMessage = dioError.message??"check your network";
      }
      throw errorMessage;
    } catch (error) {
      throw error.toString();
    }
  }

  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
    required String weight,
    required String height,
  }) async {
    try {
      var response = await _api.sendRequest.post(
        "auth/signup",
        data: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'weight': weight,
          'height': height,
        }),
      );

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if (!apiResponse.success) {
        throw apiResponse.message ?? "Unknown error occurred";
      }
      return UserModel.fromJson(apiResponse.data);
    } on DioException catch (dioError) {
      String errorMessage = "An unexpected error occurred";
      if (dioError.response != null) {
        ApiResponse apiResponse =
        ApiResponse.fromResponse(dioError.response!);
        errorMessage = apiResponse.message ?? errorMessage;
      } else {
        errorMessage = dioError.message??"network issue";
      }
      throw errorMessage;
    } catch (error) {
      throw error.toString();
    }
  }
}
