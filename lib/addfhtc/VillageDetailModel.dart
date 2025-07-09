// To parse this JSON data, do
//
//     final villageDetailModel = villageDetailModelFromJson(jsonString);

import 'dart:convert';

VillageDetailModel villageDetailModelFromJson(String str) => VillageDetailModel.fromJson(json.decode(str));

String villageDetailModelToJson(VillageDetailModel data) => json.encode(data.toJson());

class VillageDetailModel {
  String message;
  bool status;
  Result result;

  VillageDetailModel({
    required this.message,
    required this.status,
    required this.result,
  });

  factory VillageDetailModel.fromJson(Map<String, dynamic> json) => VillageDetailModel(
    message: json["Message"],
    status: json["Status"],
    result: Result.fromJson(json["Result"]),
  );

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Status": status,
    "Result": result.toJson(),
  };
}

class Result {
  int? villageId;
  String? villageName;
  String? stateName;
  String? districtName;
  String? blockName;
  String? panchayatName;
  int? households;
  int? fhtcProvided;
  int? pendingForApprovalFhtc;
  int? balanceFhtc;
  String? jjmStatus;
  int? isHgj;

  Result({
     this.villageId,
     this.villageName,
     this.stateName,
     this.districtName,
     this.blockName,
     this.panchayatName,
     this.households,
     this.fhtcProvided,
     this.pendingForApprovalFhtc,
     this.balanceFhtc,
     this.jjmStatus,
     this.isHgj,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    villageId: json["VillageId"],
    villageName: json["VillageName"],
    stateName: json["StateName"],
    districtName: json["DistrictName"],
    blockName: json["BlockName"],
    panchayatName: json["PanchayatName"],
    households: json["households"],
    fhtcProvided: json["FHTCProvided"],
    pendingForApprovalFhtc: json["PendingForApprovalFHTC"],
    balanceFhtc: json["BalanceFHTC"],
    jjmStatus: json["JJMStatus"],
    isHgj: json["IsHGJ"],
  );

  Map<String, dynamic> toJson() => {
    "VillageId": villageId,
    "VillageName": villageName,
    "StateName": stateName,
    "DistrictName": districtName,
    "BlockName": blockName,
    "PanchayatName": panchayatName,
    "households": households,
    "FHTCProvided": fhtcProvided,
    "PendingForApprovalFHTC": pendingForApprovalFhtc,
    "BalanceFHTC": balanceFhtc,
    "JJMStatus": jjmStatus,
    "IsHGJ": isHgj,
  };
}
