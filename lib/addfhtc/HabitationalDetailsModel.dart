// To parse this JSON data, do
//
//     final habitationalDetailsModel = habitationalDetailsModelFromJson(jsonString);

import 'dart:convert';

HabitationalDetailsModel habitationalDetailsModelFromJson(String str) => HabitationalDetailsModel.fromJson(json.decode(str));

String habitationalDetailsModelToJson(HabitationalDetailsModel data) => json.encode(data.toJson());

class HabitationalDetailsModel {
  String message;
  bool status;
  int habitationId;
  String habitationName;
  int villageId;
  String villageName;
  int noHh;
  int noFhtcProvidedtillDate;
  int householdleft;
  int fhtcPecentage;
  int totalprovided;
  int pendingapproval;
  int balanceFhtc;
  int isHgj;
  dynamic districtName;
  dynamic blockName;
  dynamic panchayatName;

  HabitationalDetailsModel({
    required this.message,
    required this.status,
    required this.habitationId,
    required this.habitationName,
    required this.villageId,
    required this.villageName,
    required this.noHh,
    required this.noFhtcProvidedtillDate,
    required this.householdleft,
    required this.fhtcPecentage,
    required this.totalprovided,
    required this.pendingapproval,
    required this.balanceFhtc,
    required this.isHgj,
    required this.districtName,
    required this.blockName,
    required this.panchayatName,
  });

  factory HabitationalDetailsModel.fromJson(Map<String, dynamic> json) => HabitationalDetailsModel(
    message: json["Message"],
    status: json["Status"],
    habitationId: json["HabitationId"],
    habitationName: json["HabitationName"],
    villageId: json["VillageId"],
    villageName: json["VillageName"],
    noHh: json["NoHH"],
    noFhtcProvidedtillDate: json["No_FHTCProvidedtillDate"],
    householdleft: json["Householdleft"],
    fhtcPecentage: json["FHTC_Pecentage"],
    totalprovided: json["totalprovided"],
    pendingapproval: json["pendingapproval"],
    balanceFhtc: json["balanceFHTC"],
    isHgj: json["IsHGJ"],
    districtName: json["DistrictName"],
    blockName: json["BlockName"],
    panchayatName: json["PanchayatName"],
  );

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Status": status,
    "HabitationId": habitationId,
    "HabitationName": habitationName,
    "VillageId": villageId,
    "VillageName": villageName,
    "NoHH": noHh,
    "No_FHTCProvidedtillDate": noFhtcProvidedtillDate,
    "Householdleft": householdleft,
    "FHTC_Pecentage": fhtcPecentage,
    "totalprovided": totalprovided,
    "pendingapproval": pendingapproval,
    "balanceFHTC": balanceFhtc,
    "IsHGJ": isHgj,
    "DistrictName": districtName,
    "BlockName": blockName,
    "PanchayatName": panchayatName,
  };
}
