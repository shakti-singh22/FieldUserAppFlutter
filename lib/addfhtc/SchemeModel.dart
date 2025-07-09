// To parse this JSON data, do
//
//     final schemeModel = schemeModelFromJson(jsonString);

import 'dart:convert';

SchemeModel schemeModelFromJson(String str) => SchemeModel.fromJson(json.decode(str));

String schemeModelToJson(SchemeModel data) => json.encode(data.toJson());

class SchemeModel {
  String? message;
  bool? status;
  List<Schmelist>? schmelist;

  SchemeModel({
     this.message,
     this.status,
     this.schmelist,
  });

  factory SchemeModel.fromJson(Map<String, dynamic> json) => SchemeModel(
    message: json["Message"],
    status: json["Status"],
    schmelist: List<Schmelist>.from(json["schmelist"].map((x) => Schmelist.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Status": status,
    "schmelist": List<dynamic>.from(schmelist!.map((x) => x.toJson())),
  };
}

class Schmelist {
  int? schemeid;
  String? schemename;
  String? category;

  Schmelist({
     this.schemeid,
     this.schemename,
     this.category,
  });

  factory Schmelist.fromJson(Map<String, dynamic> json) => Schmelist(
    schemeid: json["Schemeid"],
    schemename: json["Schemename"],
    category: json["Category"],
  );

  Map<String, dynamic> toJson() => {
    "Schemeid": schemeid,
    "Schemename": schemename,
    "Category": category,
  };
}
