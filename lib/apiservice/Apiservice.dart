import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../database/DataBaseHelperJalJeevan.dart';
import '../model/GetSourceCategoryModal.dart';
import '../model/Getmasterdatamodal.dart';
import '../model/Villagelistmodal.dart';
import '../utility/ApiExceptionHandler.dart';
import '../view/LoginScreen.dart';

class Apiservice {
     // static String baseurl = "http://10.22.3.161:8086/api/";
    static String baseurl = "https://ejalshakti.gov.in/jjmapp/api/";


  static GetStorage box = GetStorage();
  late DatabaseHelperJalJeevan databaseHelperJalJeevan;

    static Future Loginapi(
        BuildContext context,
        String userid,
        String password,
        String randomsalt,
        ) async {
      // Show loading dialog
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return const Center(
            child: SizedBox(
              height: 40,
              width: 40,
              child: Image(image: AssetImage("images/loading.gif")),
            ),
          );
        },
      );

      // Construct URL and body
      final url = Uri.parse('${baseurl}JJM_Mobile/Login');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final body = {
        "LoginId": userid,
        "Password": password,
        "txtSaltedHash": randomsalt
      };

      // Print request
      print("🔐 Sending Login Request:");
      print("➡️ URL: $url");
      print("➡️ Headers: $headers");
      print("➡️ Body: ${jsonEncode(body)}");

      // Send request
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      // Close dialog
      Get.back();

      // Print response
      print("📥 Received Response:");
      print("⬅️ Status Code: ${response.statusCode}");
      print("⬅️ Body: ${response.body}");

      if (response.statusCode == 200) {
        // Handle successful login if needed
      }

      return jsonDecode(response.body);
    }


  static Future PWSSourceSavetaggingapi(
    BuildContext context,
    String token,
    String UserId,
    String VillageId,
    String AssetTagging,
    String StateId,
    String SchemeId,
    String SourceId,
    String DivisionId,
    String HabitationId,
    String SourceTypeId,
    String SourceCategoryId,
    String Landmark,
    String Latitude,
    String Longitude,
    String Accuracy,
    String Photo,
  ) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset("images/loading.gif")),
            ],
          );
        });

    var response = await http.post(
      Uri.parse('${baseurl}' + "JJM_Mobile/SaveTagWaterSource"),
      headers: {
        'Content-Type': 'application/json',
        'APIKey': token ?? 'DEFAULT_API_KEY'
      },
      body: jsonEncode({
        "UserId": box.read("userid"),
        "VillageId": VillageId,
        "AssetTagging": AssetTagging,
        "StateId": StateId,
        "SchemeId": SchemeId,
        "SourceId": SourceId,
        "DivisionId": DivisionId,
        "HabitationId": HabitationId,
        "SourceTypeId": SourceTypeId,
        "SourceCategoryId": SourceCategoryId,
        "Landmark": Landmark,
        "Latitude": Latitude,
        "Longitude": Longitude,
        "Accuracy": Accuracy,
        "Photo": Photo
      }),
    );
    Get.back();
    if (response.statusCode == 200) {
      var responsede = response.body;
    } else {
      var responsede = response.body;
    }
    return jsonDecode(response.body);
  }

    static Future<Getmasterdatamodal> Getmasterapi(BuildContext context) async {
      try {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.none) {
          throw Exception("No internet connection available");
        }

        String stateId = box.read("stateid") ?? "";
        String userId = box.read("userid") ?? "";

        var uri = Uri.parse("${Apiservice.baseurl}JJM_Mobile/Get_MasterData?&StateId=$stateId&UserId=$userId");

        print("🔗 [GET] Request URL: $uri");

        var response = await http.get(uri).timeout(Duration(seconds: 30));

        print("📡 [RESPONSE] Status Code: ${response.statusCode}");
        print("📥 [RESPONSE] Body: ${response.body}");

        // Use centralized handler
        final responseData = ApiExceptionHandler.handleResponse(context: context, response: response);

// If 200, parse and store data
        if (response.statusCode == 200) {
          var appvaersion = responseData["APKVersion"];
          var appDownloadSize = responseData["DownloadSize"];
          var appAPKVersionMessage = responseData["APKVersionMessage"];
          var appAPKURL = responseData["APKURL"];

          if (appvaersion == null || appvaersion.toString() == "0") {
            // Prevent further processing if version is invalid (already handled in ApiExceptionHandler)
            return Future.error("Invalid APKVersion");
          }

          box.write("appvaersion", appvaersion);
          box.write("appDownloadSize", appDownloadSize);
          box.write("appAPKVersionMessage", appAPKVersionMessage);
          box.write("appAPKURL", appAPKURL);

          return Getmasterdatamodal.fromJson(responseData);
        } else {
          throw Exception("Status Code: ${response.statusCode}");
        }
      } catch (e) {
        print("❌ [ERROR] $e");
        throw Exception("Error occurred: $e");
      }
    }

    static Future SIBSavetaggingapi(
        BuildContext context,
        String token,
        String UserId,
        String VillageId,
        String CapturePointTypeId,
        String StateId,
        String SchemeId,
        String SourceId,
        String DivisionId,
        String HabitationId,
        String Landmark,
        String Latitude,
        String Longitude,
        String Accuracy,
        String Photo,
        ) async {
      try {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset("images/loading.gif"),
                ),
              ],
            );
          },
        );

        final uri = Uri.parse('${baseurl}JJM_Mobile/SaveInformationBoard');

        final headers = {
          'Content-Type': 'application/json',
          'APIKey': token.isNotEmpty ? token : 'DEFAULT_API_KEY',
        };

        final body = {
          "UserId": box.read("userid"),
          "VillageId": VillageId,
          "CapturePointTypeId": CapturePointTypeId,
          "StateId": StateId,
          "SchemeId": SchemeId,
          "SourceId": SourceId,
          "DivisionId": DivisionId,
          "HabitationId": HabitationId,
          "Landmark": Landmark,
          "Latitude": Latitude,
          "Longitude": Longitude,
          "Accuracy": Accuracy,
          "Photo": Photo,
        };

        print("🔗 [POST] Request URL: $uri");
        print("📤 [HEADERS]: $headers");
        print("📤 [BODY]: ${jsonEncode(body)}");

        final response = await http
            .post(uri, headers: headers, body: jsonEncode(body))
            .timeout(Duration(seconds: 30));

        print("📡 [RESPONSE] Status Code: ${response.statusCode}");
        print("📥 [RESPONSE] Body: ${response.body}");

        Get.back();

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          throw Exception("Server error: ${response.statusCode}");
        }
      } catch (e) {
        Get.back(); // Close dialog in case of failure
        print("❌ [ERROR] $e");
        throw Exception("Something went wrong: $e");
      }
    }


    static Future OtherassetSavetaggingapi(
        BuildContext context,
        String token,
        String UserId,
        String VillageId,
        String StateId,
        String SchemeId,
        String SourceId,
        String DivisionId,
        String HabitationId,
        String Landmark,
        String Latitude,
        String Longitude,
        String Accuracy,
        String Photo,
        String assetOtherCategory,
        String WTP_capicity,
        List<int> WTP_selectedSourceIds,
        String WTPTypeId,
        ) async {
      try {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset("images/loading.gif"),
                ),
              ],
            );
          },
        );

        final uri = Uri.parse('${baseurl}JJM_Mobile/SaveTagWater_Others');

        final headers = {
          'Content-Type': 'application/json',
          'APIKey': token.isNotEmpty ? token : 'DEFAULT_API_KEY',
        };

        final body = {
          "UserId": box.read("userid"),
          "VillageId": VillageId,
          "StateId": StateId,
          "SchemeId": SchemeId,
          "SourceId": SourceId,
          "DivisionId": DivisionId,
          "HabitationId": HabitationId,
          "Landmark": Landmark,
          "Latitude": Latitude,
          "Longitude": Longitude,
          "Accuracy": Accuracy,
          "Photo": Photo,
          "AssetOtherCategory": assetOtherCategory,
          "Capicity": WTP_capicity,
          "WTP_SourceId": WTP_selectedSourceIds, // List<int>
          "WTPTypeId": WTPTypeId
        };

        print("🔗 [POST] Request URL: $uri");
        print("📤 [HEADERS]: $headers");
        print("📤 [BODY]: ${jsonEncode(body)}");

        final response = await http
            .post(uri, headers: headers, body: jsonEncode(body))
            .timeout(Duration(seconds: 30));

        print("📡 [RESPONSE] Status Code: ${response.statusCode}");
        print("📥 [RESPONSE] Body: ${response.body}");

        Get.back();

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          throw Exception("Failed with status code: ${response.statusCode}");
        }
      } catch (e) {
        Get.back(); // Ensure dialog closes on error
        print("❌ [ERROR] $e");
        throw Exception("Something went wrong: $e");
      }
    }

    static Future StoragestructureSavetaggingapi(
        BuildContext context,
        String token,
        String UserId,
        String VillageId,
        String StateId,
        String SchemeId,
        String SourceId,
        String DivisionId,
        String HabitationId,
        String Landmark,
        String Latitude,
        String Longitude,
        String Accuracy,
        String Photo,
        String capacityInltr,
        String storageStructureType,
        ) async {
      try {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset("images/loading.gif"),
                ),
              ],
            );
          },
        );

        final uri = Uri.parse('${baseurl}JJM_Mobile/SaveTagWater_StorageStructure');

        final headers = {
          'Content-Type': 'application/json',
          'APIKey': token.isNotEmpty ? token : 'DEFAULT_API_KEY',
        };

        final body = {
          "UserId": box.read("userid"),
          "VillageId": VillageId,
          "StateId": StateId,
          "SchemeId": SchemeId,
          "SourceId": SourceId,
          "DivisionId": DivisionId,
          "HabitationId": HabitationId,
          "Landmark": Landmark,
          "Latitude": Latitude,
          "Longitude": Longitude,
          "Accuracy": Accuracy,
          "Photo": Photo,
          "CapacityInltr": capacityInltr,
          "StorageStructureType": storageStructureType,
        };

        print("🔗 [POST] Request URL: $uri");
        print("📤 [HEADERS]: $headers");
        print("📤 [BODY]: ${jsonEncode(body)}");

        final response = await http
            .post(uri, headers: headers, body: jsonEncode(body))
            .timeout(Duration(seconds: 30));

        print("📡 [RESPONSE] Status Code: ${response.statusCode}");
        print("📥 [RESPONSE] Body: ${response.body}");

        Get.back();

        return jsonDecode(response.body);
      } catch (e) {
        Get.back();
        print("❌ [ERROR] $e");
        throw Exception("Something went wrong: $e");
      }
    }


    static Future SaveOfflinevilaagesApi(
        BuildContext context,
        String token,
        String UserId,
        List Villagelist,
        String StateId,
        ) async {
      try {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset("images/loading.gif"),
                ),
              ],
            );
          },
        );

        final uri = Uri.parse('${baseurl}JJM_Mobile/SaveOfflineVillage');

        final headers = {
          'Content-Type': 'application/json',
          'APIKey': token.isNotEmpty ? token : 'DEFAULT_API_KEY',
        };

        final body = {
          "UserId": box.read("userid"),
          "VillageList": Villagelist,
          "StateId": StateId,
        };

        print("🔗 [POST] Request URL: $uri");
        print("📤 [HEADERS]: $headers");
        print("📤 [BODY]: ${jsonEncode(body)}");

        final response = await http
            .post(uri, headers: headers, body: jsonEncode(body))
            .timeout(Duration(seconds: 30));

        print("📡 [RESPONSE] Status Code: ${response.statusCode}");
        print("📥 [RESPONSE] Body: ${response.body}");

        Get.back();

        return jsonDecode(response.body);
      } catch (e) {
        Get.back(); // Ensure dialog is closed on error
        print("❌ [ERROR] $e");
        throw Exception("Something went wrong: $e");
      }
    }


  Future<void> cleartable_localmasterschemelisttable() async {
    await databaseHelperJalJeevan?.cleardb_localmasterschemelist();
    await databaseHelperJalJeevan!.cleartable_villagelist();
    await databaseHelperJalJeevan!.cleartable_villagedetails();
    await databaseHelperJalJeevan!.cleardb_localhabitaionlisttable();
    await databaseHelperJalJeevan!.cleardb_sourcedetailstable();
    await databaseHelperJalJeevan!.cleardb_sibmasterlist();
  }

  static Future<GetSourceCategoryModal> Getmastersourcecategoryapi() async {
    try {
      var uri = Uri.parse('${baseurl}Master/GetSourceCategorylist?UserId=' +
          box.read("userid"));
      var response = await http
          .get(uri)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        print("responsecat$response");
        Map<String, dynamic> mResposne = jsonDecode(response.body);
        return GetSourceCategoryModal.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Timeout or network error occurred');
    }
  }

  static Future getuserprofile(
    BuildContext context,
    String userid,
    String stateid,
    String token,
  ) async {
    var response = await http.post(
      Uri.parse('${baseurl}' + "JJM_Mobile/User_profile"),
      headers: {
        'Content-Type': 'application/json',
        'APIKey': token ?? 'DEFAULT_API_KEY'
      },
      body: jsonEncode({
        "Userid": userid,
        "StateId": stateid,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<void> fetchData(
    BuildContext context,
    String userid,
    String stateid,
    String villageid,
    String token,
  ) async {
    final String baseUrl =
        'https://ejalshakti.gov.in/krcpwa/api/JJM_Mobile/GetSourceScheme';
    final Map<String, dynamic> queryParams = {
      'UserId': userid,
      'StateId': stateid,
      'villageid': villageid,
    };
    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    try {
      final http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'APIKey': token ?? 'DEFAULT_API_KEY'
        },
      );
      if (response.statusCode == 200) {
      } else {}
    } catch (e) {}
  }

  static Future PWSPendingapprovalAPI(String villageid, String stateid,
      String userid, String token, String status) async {
    var response = await http.get(
      Uri.parse("${baseurl}JJM_Mobile/GetGeotaggedWaterSource?VillageId=" +
          villageid +
          "&StateId=" +
          stateid +
          "&UserId=" +
          userid +
          "&Status=" +
          status),
      headers: {
        'Content-Type': 'application/json',
        'APIKey': token ?? 'DEFAULT_API_KEY'
      },
    );

    if (response.statusCode == 200) {}
  }

  static Future getvillagelistapi(
      String userid, String stateid, String token) async {
    List<Villagelistmodal> list = [];

    try {
      var response = await http.get(
        Uri.parse('${baseurl}' + "JJM_Mobile/GetAssignedVillages?StateId=" + stateid + "&UserId=" + userid),
        headers: {
          'Content-Type': 'application/json',
          'APIKey': token ?? 'DEFAULT_API_KEY'
        },
      );
      if (response.statusCode == 200) {
        var mapResponse = jsonDecode(response.body);
        List<dynamic> ListResponse = mapResponse['Villagelist_Datas'];
      } else {
        var mapResponse = jsonDecode(response.body);

        var status = mapResponse['Status'];
        if (status == "false") {
          Get.off(LoginScreen());
        }
      }
      return jsonDecode(response.body);
    } catch (e) {
      return list;
    }
  }

  static Future getvillagedetailsApi(BuildContext context, String villageid,
      String stateid, String userid, String token) async {
    try {
      var response = await http.get(
        Uri.parse('${baseurl}' + "JJM_Mobile/GetVillageGeoTaggingDetails?VillageId=" + villageid + "&StateId=" + stateid + "&UserId=" + userid),
        headers: {
          'Content-Type': 'application/json',
          'APIKey': token ?? 'DEFAULT_API_KEY'
        },
      );
      if (response.statusCode == 200) {
        var mapResponse = jsonDecode(response.body);
        return mapResponse;
      } else {
        var mapResponse = jsonDecode(response.body);
        var status = mapResponse["Status"];

        if (status == "false") {
          Get.offAll(LoginScreen());
          box.remove("UserToken");
          return jsonDecode(response.body);
        }
        return mapResponse;
      }
    } catch (e) {}
  }

  static Future pandingfor_getpwssource(String villageid, String stateid,
      String userid, String token, String Status) async {
    try {
      var response = await http.get(
        Uri.parse('${baseurl}' + "JJM_Mobile/GetGeotaggedWaterSource?VillageId=" + villageid + "&StateId=" + stateid + "&UserId=" + userid + "&Status=" + Status),
        headers: {
          'Content-Type': 'application/json',
          'APIKey': token ?? 'DEFAULT_API_KEY'
        },
      );
      if (response.statusCode == 200) {
        var mapResponse = jsonDecode(response.body);
        return mapResponse;
      } else {}
      return jsonDecode(response.body);
    } catch (e) {}
  }
}
