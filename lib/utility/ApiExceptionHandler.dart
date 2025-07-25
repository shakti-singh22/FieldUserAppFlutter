import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'ExceptionScreen.dart';

class ApiExceptionHandler {
  static dynamic handleResponse({
    required BuildContext context,
    required response,
  }) {
    final statusCode = response.statusCode;
    final body = response.body;

    print("🔎 API Status Code: $statusCode");
    print("📥 API Response Body: $body");

    dynamic responseJson;
    try {
      responseJson = jsonDecode(body);
    } catch (e) {
      responseJson = {'message': 'Invalid response from server. Please try again later.'};
    }

    // 📌 1. Handle known error codes
    if (statusCode >= 400) {
      String errorMessage = "Something went wrong. Please try again later.";

      switch (statusCode) {
        case 400:
          errorMessage = "Request was invalid. Please try again later.";
          break;
        case 401:
          errorMessage = "Your session has expired. Please login again.";
          break;
        case 403:
          errorMessage = "Access denied. Please try again later.";
          break;
        case 404:
          errorMessage = "Data not found. Please try again later.";
          break;
        case 500:
          errorMessage = "Server is not responding. Please try again later.";
          break;
      }

      _showExceptionDialog(context, errorMessage, statusCode.toString());
    }

    // 📌 2. Handle 200 but invalid data (e.g. APKVersion = 0)
    if (statusCode == 200 &&
        responseJson is Map<String, dynamic> &&
        (responseJson["APKVersion"]?.toString() ?? "0") == "0") {
      _showExceptionDialog(context, "Invalid application version. Please try again later.", "500");
    }

    return responseJson;
  }

  static void _showExceptionDialog(
      BuildContext context, String message, String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: ExceptionScreen(
          errorMessage: message,
          errorCode: code,
          shouldExit: true, // 👈 new flag to exit app
        ),
      ),
    );
  }
}
