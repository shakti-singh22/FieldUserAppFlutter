// To parse this JSON data, do
//
//     final habitationModel = habitationModelFromJson(jsonString);

import 'dart:convert';

HabitationModel habitationModelFromJson(String str) => HabitationModel.fromJson(json.decode(str));

String habitationModelToJson(HabitationModel data) => json.encode(data.toJson());

class HabitationModel {
  String message;
  bool status;
  List<Result> result;

  HabitationModel({
    required this.message,
    required this.status,
    required this.result,
  });

  factory HabitationModel.fromJson(Map<String, dynamic> json) => HabitationModel(
    message: json["Message"],
    status: json["Status"],
    result: List<Result>.from(json["Result"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Status": status,
    "Result": List<dynamic>.from(result.map((x) => x.toJson())),
  };
}

class Result {
  int habitationId;
  String habitationName;

  Result({
    required this.habitationId,
    required this.habitationName,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    habitationId: json["HabitationId"],
    habitationName: json["HabitationName"],
  );

  Map<String, dynamic> toJson() => {
    "HabitationId": habitationId,
    "HabitationName": habitationName,
  };
}
