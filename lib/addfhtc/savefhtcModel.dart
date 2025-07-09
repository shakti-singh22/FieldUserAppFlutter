// To parse this JSON data, do
//
//     final saveFhtcModel = saveFhtcModelFromJson(jsonString);

import 'dart:convert';

SaveFhtcModel saveFhtcModelFromJson(String str) => SaveFhtcModel.fromJson(json.decode(str));

String saveFhtcModelToJson(SaveFhtcModel data) => json.encode(data.toJson());

class SaveFhtcModel {
  bool status;
  String message;

  SaveFhtcModel({
    required this.status,
    required this.message,
  });

  factory SaveFhtcModel.fromJson(Map<String, dynamic> json) => SaveFhtcModel(
    status: json["Status"],
    message: json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "Status": status,
    "Message": message,
  };
}
