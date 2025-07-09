// To parse this JSON data, do
//
//     final getAadhaarVerificationWithFaceDecryptModel = getAadhaarVerificationWithFaceDecryptModelFromJson(jsonString);

import 'dart:convert';

GetAadhaarVerificationWithFaceDecryptModel getAadhaarVerificationWithFaceDecryptModelFromJson(String str) => GetAadhaarVerificationWithFaceDecryptModel.fromJson(json.decode(str));

String getAadhaarVerificationWithFaceDecryptModelToJson(GetAadhaarVerificationWithFaceDecryptModel data) => json.encode(data.toJson());

class GetAadhaarVerificationWithFaceDecryptModel {
  Response response;
  String statuscode;

  GetAadhaarVerificationWithFaceDecryptModel({
    required this.response,
    required this.statuscode,
  });

  factory GetAadhaarVerificationWithFaceDecryptModel.fromJson(Map<String, dynamic> json) => GetAadhaarVerificationWithFaceDecryptModel(
    response: Response.fromJson(json["response"]),
    statuscode: json["statuscode"],
  );

  Map<String, dynamic> toJson() => {
    "response": response.toJson(),
    "statuscode": statuscode,
  };
}

class Response {
  String name;
  String value;

  Response({
    required this.name,
    required this.value,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
    name: json["name"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "value": value,
  };
}
