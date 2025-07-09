import 'dart:convert';
import 'dart:io';
import 'package:fielduserappnew/addfhtc/savefhtcModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../apiservice/Apiservice.dart';
import '../database/DataBaseHelperJalJeevan.dart';
import '../utility/Appcolor.dart';
import '../utility/Stylefile.dart';
import '../view/LoginScreen.dart';
import 'Aesen.dart';
import 'HabitationModel.dart';
import 'SchemeModel.dart';
import 'getAadhaarVerificationWithFaceDecryptModel.dart';

class face_auth extends StatefulWidget {
  late int? IsHGJ;
  String? villagenamesend;
  late String getvillageid;

  face_auth(this.IsHGJ, this.villagenamesend, this.getvillageid, {super.key});

  @override
  _face_auth createState() => _face_auth();
}
/*enum SelectGender {Male, Female, Transgender}
enum SelectCategory {GEN, SC, ST}*/

class _face_auth extends State<face_auth> {
  String? radioButtonItem;
  String? groupValue;
  int id = 1;
  final int _selectedIndex = 0;
  String random = "";
  final formKey = GlobalKey<FormState>();
  final formKeyanother = GlobalKey<FormState>();
  String name = "";
  bool passwordVisible = false;
  bool fhtcdetailsVisible = false;
  bool beneficiarydetailsVisible = false;
  bool beneficiaryInformation = false;
  int Geo_tagPWS = 1;
  int Geo_tagSIB = 2;
  int Geo_tagSS = 3;
  int Geo_tagOA = 4;

  List SchemeResponse = [];

  List ListResponse = [];

  String? Habitation;

  String? Selectscheme;

  bool schemeSource = false;

  String dropdownvalue2 = 'Item 1';

  String? _gender;
  String? _category;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    BeneficiaryName.clear();
    Aadhaarno.clear();
  }

  var items2 = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
  ];

  var BalanceWsTotal;
  var PendingWsTotal;
  var TotalWsGeoTagged;
  bool isLoadingMasterData = false;
  bool isLoadingSaveFHTC = false;
  bool _loading = false;
  bool _fhtcloading = false;
  bool loadingverify = false;

  String selectedGender = '';

  var UidToken;

  var AdhaarUidtoken;

  var Messageresponse;

  GetStorage box = GetStorage();

  var Total_household = 0;

  var Total_Provided = 0;

  var Pending_approval = 0;

  var Balance_HHs = 0;

  var pidresult;
  final FocusNode _unUsedFocusNode = FocusNode();
  String? gender;

  String? category;

  var pidjsonResponse;
  static const platform = MethodChannel('AdhaarDemo');
  DatabaseHelperJalJeevan? databaseHelperJalJeevan;

  Future<void> cleartable_localmasterschemelisttable() async {
    await databaseHelperJalJeevan!.cleardb_localmasterschemelist();
    await databaseHelperJalJeevan!.cleartable_villagelist();
    await databaseHelperJalJeevan!.cleartable_villagedetails();
    await databaseHelperJalJeevan!.cleardb_sourcetypecategorytable();
    await databaseHelperJalJeevan!.cleardb_sourcassettypetable();
    await databaseHelperJalJeevan!.cleardb_localhabitaionlisttable();
    await databaseHelperJalJeevan!.cleardb_sourcedetailstable();
    await databaseHelperJalJeevan!.truncatetable_dashboardtable();
    await databaseHelperJalJeevan!.cleardb_sibmasterlist();
  }

  Future<void> _openFaceCapture() async {
    const pidOptXml =
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<PidOptions ver=\"1.0\" env=\"PP\">\n<Opts pidVer=\"2.0\" otp=\"\" wadh=\"\"/>\n<CustOpts>\n<Param name=\"txnId\" value=\"yourTransactionId\"/>\n</CustOpts>\n<BioData/>\n</PidOptions>";

    try {
      final String result = await platform
          .invokeMethod('openFaceCapture', {'request': pidOptXml});
      // The result here will be "Face capture started"
      print('Result from openFaceCapture: $result');
      Stylefile.showmessageforvalidationtrue(context, "Result from openFaceCapture: $result");
    } on PlatformException catch (e) {
      // Handle errors here
      print("Error: $e");
    }
  }

  TextEditingController BeneficiaryName = TextEditingController();

  TextEditingController Aadhaarno = TextEditingController();

  TextEditingController HusbandName = TextEditingController();

  TextEditingController MobileNumber = TextEditingController();

  TextEditingController BeneficiaryId = TextEditingController();

  Future<List<HabitationModel>> getHabitationList() async {
    setState(() {
      _loading = true;
    });

    List<HabitationModel> list = [];

    try {
      var url =
          "${"${'${Apiservice.baseurl}' "JJM_Mobile/GetHabitationlist?UserId=" + box.read("userid")}&StateId=" + box.read("stateid")}&VillageId=${widget.getvillageid}";
      // Append parameters to the URL

      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'APIKey': box.read("UserToken"),
        },
      );
      setState(() {
        _loading = false;
      });
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['Status'] == true) {
          var result = jsonResponse['Result'];
          print("result: $result");
          setState(() {
            ListResponse = jsonResponse['Result'];
          });
          print("Habitation List: $list");
        } else {
          print(
              "Request was successful, but the server returned an error: ${jsonResponse['Message']}");
        }
      } else {
        print("Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
    return list;
  }

  Future<void> getHabitationDetails(String habitationId) async {
    setState(() {
      _fhtcloading = true;
    });
    try {
      var url =
          "${"${'${Apiservice.baseurl}' "JJM_Mobile/GetHabitationDetails?UserId=" + box.read("userid")}&StateId=" + box.read("stateid")}&VillageId=${widget.getvillageid}&HabitationId=$habitationId";
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'APIKey': box.read("UserToken"),
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print("Habitaional details: $jsonResponse");

        if (jsonResponse != null && jsonResponse['Status'] == true) {
          setState(() {
            Total_household = jsonResponse['NoHH'];
            Total_Provided = jsonResponse['totalprovided'];
            Pending_approval = jsonResponse['pendingapproval'];
            Balance_HHs = jsonResponse['Householdleft'];
          });
        } else {
          print("Request was successful, but the server returned an error: ${jsonResponse['Message']}");
        }
      } else {
        print("Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _fhtcloading = false;
      });
    }
  }

  Future<List<SchemeModel>> getSchemeList() async {
    setState(() {
      // _loading=true;
    });

    List<SchemeModel> list = [];

    try {
      var url =
          "${"${'${Apiservice.baseurl}' "JJM_Mobile/GetSourceScheme?UserId=" + box.read("userid")}&StateId=" + box.read("stateid")}&VillageId=${widget.getvillageid}";
      // Append parameters to the URL

      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'APIKey': box.read("UserToken"),
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['Status'] == true) {

          setState(() {
            SchemeResponse = jsonResponse['schmelist'];
          });

        }
      } else {
        print("Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
    setState(() {
      // _loading=false;
    });
    return list;
  }

  Future<List<SchemeModel>> getaadhaarvalidation(Aadhaarno, Familyhead) async {
    /* showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:  [
              //CircularProgressIndicator()
              SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset("images/loading.gif")),

            ],
          );
        });*/
    setState(() {
      loadingverify = true;
    });

    List<SchemeModel> list = [];
    Map<String, String> requestBody = {
      "Userid": box.read("userid"),
      "AdharNumber": Aadhaarno,
      "FaimlyHeadName": Familyhead
    };

    try {
      var url = '${Apiservice.baseurl}' "JJM_Mobile/AadharVerification";
      // Append parameters to the URL

      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'APIKey': box.read("UserToken"),
        },
        body: jsonEncode(
            requestBody), // Encode the map as a JSON string6000265012
      );
      //   Get.back();
      setState(() {
        loadingverify = false;
      });
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print("response: $jsonResponse");
        if (jsonResponse['Status'] == true) {
          setState(() {
            UidToken = jsonResponse["UIDToken"];
          });
          _openFaceCapture();
          Stylefile.showmessageforvalidationtrue(context, "Aadhaar number is valid");

    /*      Fluttertoast.showToast(
              msg: "Aadhaar number is valid",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);*/

        }
      } else {
      }
    } catch (e) {
    }

    return list;
  }

  Future<List<GetAadhaarVerificationWithFaceDecryptModel>>
      getAadhaarVerificationWithFaceDecrypt(urlaadhaar, pidvalue) async {
    List<GetAadhaarVerificationWithFaceDecryptModel> list = [];

    Map map = {"aadhaar": urlaadhaar, "pid": pidvalue};

    try {
      var url =
          "https://sbm.gov.in/FaceAuthenticationWebService/RestServiceImpl.svc/GetAadhaarVerificationWithFaceDecrypt";
      // Append parameters to the URL

      var response = await http.post(Uri.parse(url), body: map);

      if (response.statusCode == 200) {
        pidjsonResponse = jsonDecode(response.body);
        Stylefile.showmessageforvalidationtrue(context, "$pidjsonResponse");
        setState(() {
          var listreponse = pidjsonResponse["response"]["IsAadhaarVerified"];

          if (listreponse == 'Y') {
            beneficiaryInformation = true;
            AdhaarUidtoken = pidjsonResponse["response"]["UIDToken"];
          }

          print("response: $pidjsonResponse");
        });
      } else {
        print("Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }

    return list;
  }

  var savejsonResponse;

  Future<List<SaveFhtcModel>> getSaveFHTC(
      Aadhaar,
      Uidtoken,
      Habitationid,
      Schemeid,
      Familyheadname,
      Beneficiaryid,
      Husbandname,
      Adhaarfaceuidtoken,
      IsHGJ,
      Gender,
      Category) async {
    List<SaveFhtcModel> list = [];
    isLoadingSaveFHTC = true;
    Map<String, String> requestBody = {
      "UserId": box.read("userid"),
      "DivisionId": box.read("DivisionId"),
      "StateId": box.read("stateid"),
      "SchemeId": Schemeid,
      "VillageId": widget.getvillageid,
      "HabitationId": Habitationid,
      "AdharNumber": Aadhaar,
      "FaimlyHeadName": Familyheadname,
      "UIDToken": Uidtoken,
      "BeneficiaryIdMIS": Beneficiaryid,
      "SubCategory": Category,
      "Father_HusbandName": Husbandname,
      "Gender": Gender,
      "AadharFaceUIDToken": Adhaarfaceuidtoken,
      "IsHGJ": box.read("Ishgj")
    };

    try {
      var url = '${Apiservice.baseurl}' "JJM_Mobile/SaveFHTC";
      // Append parameters to the URL

      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'APIKey': box.read("UserToken"),
        },
        body: jsonEncode(
            requestBody), // Encode the map as a JSON string6000265012
      );

      if (response.statusCode == 200) {
        isLoadingSaveFHTC = false;

        setState(() {
          savejsonResponse = jsonDecode(response.body);
          Messageresponse = savejsonResponse['Message'];
          /*isLoadingSaveFHTC= false;*/
          print("save_response $Messageresponse");
        });
        /*if (jsonResponse['Status'] == true) {
          _openFaceCapture();
          isLoadingMasterData = false;
          Fluttertoast.showToast(
              msg: "FHTC save",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }*/
      } else {
        print("Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }

    return list;
  }

  String pidValue = '';
  String key = "8080808080808080";
  String encryptedText = " ";
  String decryptedUname = " ";
  String pidvalueurlEncodedText = " ";
  String aadhaarurlEncodedText = " ";
  String villageid = " ";

  @override
  void initState() {
    super.initState();
    databaseHelperJalJeevan = DatabaseHelperJalJeevan();
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onFaceCaptureResult') {
        setState(() {
          pidValue = call.arguments as String;
          String pidvalue = pidValue.toString();
          Stylefile.showmessageforvalidationtrue(context, "$pidvalue");
          Uint8List keyBytes = Uint8List.fromList(utf8.encode(key));
          Uint8List iv = Uint8List.fromList(utf8.encode(key));
          Uint8List encryptedBytes = encryptAES(pidvalue, keyBytes, iv);
          encryptedText = base64.encode(encryptedBytes);
          pidvalueurlEncodedText = Uri.encodeComponent(encryptedText);
          print('pidvalue $pidvalueurlEncodedText');

          getAadhaarVerificationWithFaceDecrypt(
              aadhaarurlEncodedText, pidvalueurlEncodedText);
        });
      }
      return null; // Return a Future that completes with null
    });

    getHabitationList();
    getSchemeList();
    villageid = widget.getvillageid;

/*    if (widget.token != null) {
      setState(() {
        String userIdString = widget.userId.toString();
        String stateIdString = widget.stateid.toString();
        String VillageIdString = widget.villageid.toString();
        getVillageList(userIdString, stateIdString, VillageIdString, widget.token!);
      });
      // If token is not null, call your API function with the non-null token value
      print('userid ${widget.userId}');
      print('stateid ${widget.stateid}');
      print('token ${widget.token}');
    }
    else {
      // Handle the case where token is null, for example, show an error message
      print('Token is null. Cannot make API request.');
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/header_bg.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0), //
          child: AppBar(
            backgroundColor: const Color(0xFF0D3A98),
            iconTheme: const IconThemeData(
              color: Appcolor.white,
            ),
            title: const Text("Face Authenticaiton",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            actions: const <Widget>[],
          ),
        ),
        body: GestureDetector(
          /* onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());

          },*/
          //keyboard pop-down
          onTapDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                            top: 15, left: 2, right: 2, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        child: Image.asset(
                                          'images/bharat.png',
                                          // Replace with your logo file path
                                          width: 60,
                                          // Adjust width and height as needed
                                          height: 60,
                                        ),
                                      ),
                                      Container(
                                        child: const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Jal Jeevan Mission',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Department of Drinking Water and Sanitation',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              'Ministry of Jal Shakti',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showDialog<void>(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: Appcolor.white,
                                            titlePadding: const EdgeInsets.only(
                                                top: 0, left: 0, right: 00),
                                            buttonPadding:
                                                const EdgeInsets.all(10),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                  5.0,
                                                ),
                                              ),
                                            ),
                                            actionsAlignment:
                                                MainAxisAlignment.center,
                                            title: Container(
                                              color: Appcolor.red,
                                              child: const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Jal jeevan mission",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Appcolor.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            content:
                                                const SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text(
                                                      "Are you sure want to sign out from this application ?",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Appcolor.black),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              Container(
                                                height: 40,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Appcolor.red,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: TextButton(
                                                  child: const Text(
                                                    'No',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Appcolor.black),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ),
                                              Container(
                                                height: 40,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Appcolor.red,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: TextButton(
                                                  child: const Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Appcolor.black),
                                                  ),
                                                  onPressed: () async {
                                                    box.remove("UserToken");
                                                    box.remove('loginBool');
                                                    cleartable_localmasterschemelisttable();
                                                    Get.offAll(
                                                         LoginScreen());
                                                    Stylefile.showmessageapisuccess(
                                                        context,
                                                        "Sign out successfully");
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius:BorderRadius.circular(20.0),
                                      child: const Icon(
                                        Icons.logout,
                                        size: 35,
                                        color: Appcolor.btncolor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                'Village :${widget.villagenamesend}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Appcolor.headingcolor),
                              ),
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Appcolor.grey),
                                      borderRadius: BorderRadius.circular(5)),
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                            
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                          child: Container(
                                        margin: const EdgeInsets.all(3),
                            
                            
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Select Habitation',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  _loading == true
                                                      ? const Center(
                                                          child: SizedBox(
                                                              height: 40,
                                                              width: 40,
                                                              child: CircularProgressIndicator()),
                                                        )
                                                      : Container(
                                            height: 55,
                            
                                            width: double.infinity,
                                            padding: const EdgeInsets.only(
                                                left: 5.0, right: 3.0),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                border: Border.all(
                                                    color: Appcolor.grey, width: .5),
                                                borderRadius: BorderRadius.circular(6)),
                                            child: Container(
                                                height: 50,
                            
                                                width: double.infinity,
                                                alignment: Alignment.centerLeft,
                                                decoration: const BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color:Appcolor.lightgrey ,  width: 1))),
                                                          child: DropdownButton<
                                                                  String>(
                                                              itemHeight: 60,
                                                              alignment: Alignment.center,
                                                              elevation: 10,
                                                              dropdownColor: Appcolor.white,
                                                              underline: const SizedBox(),
                                                              isExpanded: true,
                                                              hint: const Center(
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                      '--Select Habitation--'),
                                                                ),
                                                              ),
                                                              value: Habitation,
                                                              // The currently selected value, set this if you want to preselect an item
                                                              onChanged: (String? newValue) {
                                                                setState(() {
                                                                  Habitation = newValue ?? ''; // Use null-aware operator to handle null values
                                                                  print("hid $Habitation");
                                                                  getHabitationDetails(Habitation!);
                                                                  fhtcdetailsVisible =
                                                                      true;
                                                                  beneficiarydetailsVisible =
                                                                      true;
                                                                  schemeSource =
                                                                      true;
                                                                  BeneficiaryName
                                                                      .clear();
                                                                  Aadhaarno
                                                                      .clear();
                                                                });
                                                              },
                                                              items: ListResponse.map<DropdownMenuItem<String>>((item) {
                                                                return DropdownMenuItem<String>(

                                                                  value: item[
                                                                          'HabitationId']
                                                                      .toString(),
                                                                  alignment:
                                                                      AlignmentDirectional
                                                                          .centerStart,
                                                                  child: Container(
                                                                    width: double.infinity,
                                                                    alignment:
                                                                    Alignment.centerLeft,
                                                                    decoration: const BoxDecoration(
                                                                        border: Border(
                                                                            bottom: BorderSide(
                                                                                color:
                                                                                Colors.grey,
                                                                                width: .3))),
                                                                    child: Text(
                                                                      item[
                                                                          'HabitationName'],
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                );
                                                              }).toList()
                                                              // Use null-aware operator to handle null ListResponse
                                                              )),
                                                  )  ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                      const SizedBox(
                                        height: 5,
                                      ),

                                    ],
                                  ),
                                )),
                            Visibility(
                              visible: fhtcdetailsVisible,
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5)),
                                padding: const EdgeInsets.all(5.0),


                                child: _fhtcloading == true
                                    ? const Center(
                                    child:
                                    CircularProgressIndicator())
                                    : Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    const SizedBox(height: 10,),
                                    const Align(
                                        alignment: Alignment
                                            .centerLeft,
                                        child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
                                            'FHTC Details of Habitation',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                fontSize:
                                                16),
                                          ),
                                        )),
                                    const SizedBox(
                                      height: 10,
                                    ),





                                    SizedBox(
                                      width: double.infinity,

                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Container(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xffb3c53c2)),
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(5)),
                                                    margin:
                                                    const EdgeInsets.only(
                                                        left: 2,
                                                        right: 5,
                                                        bottom: 10,
                                                        top: 0),
                                                    child:
                                                    Total_household != "0"
                                                        ? Material(
                                                      elevation: 2.0,
                                                      color: Appcolor
                                                          .greeenlight,
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          10.0),
                                                      child: InkWell(
                                                        splashColor:
                                                        Appcolor
                                                            .splashcolor,
                                                        customBorder:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                            10.0,
                                                          ),
                                                        ),

                                                        child: Ink(
                                                          child:
                                                          Column(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                            /*  Container(
                                                                width: MediaQuery.of(context)
                                                                    .size
                                                                    .width,
                                                                padding: const EdgeInsets
                                                                    .all(
                                                                    5),
                                                                child: const Center(
                                                                    child: Text(
                                                                      '\nTotal\nhouseholds',
                                                                      style:
                                                                      TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                                                    )),
                                                              ),*/
                                                              Container(
                                                                width: MediaQuery.of(
                                                                    context)
                                                                    .size
                                                                    .width,
                                                                padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                                child: const Center(
                                                                    child: Text(
                                                                      textAlign: TextAlign.center,
                                                                      '\n Total\nhouseholds',
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                          fontSize: 16),
                                                                    )),
                                                              ),
                                                              const Divider(
                                                                thickness:
                                                                1,
                                                                height:
                                                                10,
                                                                color:
                                                                Appcolor.lightgrey,
                                                              ),
                                                              Center(
                                                                  child:
                                                                  Text(
                                                                    Total_household.toString(),
                                                                    style: const TextStyle(
                                                                        fontSize: 18,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Appcolor.btncolor),
                                                                  ))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                        : Material(
                                                      elevation: 2.0,
                                                      color: Appcolor
                                                          .greeenlight,
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          5.0),
                                                      child: InkWell(
                                                        splashColor:
                                                        Appcolor
                                                            .splashcolor,
                                                        customBorder:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                            5.0,
                                                          ),
                                                        ),
                                                        child: Ink(
                                                          child:
                                                          Column(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Container(
                                                                width: MediaQuery.of(context)
                                                                    .size
                                                                    .width,
                                                                padding: const EdgeInsets
                                                                    .all(
                                                                    5),
                                                                child: const Center(
                                                                    child: Text(
                                                                      textAlign: TextAlign.center,
                                                                      '\nTotal\nhouseholds',
                                                                      style:
                                                                      TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                                                    )),
                                                              ),
                                                              const Divider(
                                                                thickness:
                                                                1,
                                                                height:
                                                                10,
                                                                color:
                                                                Appcolor.lightgrey,
                                                              ),
                                                              Center(
                                                                  child:
                                                                  Text(
                                                                    Total_household
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        fontSize: 18,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Appcolor.btncolor),
                                                                  ))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child:
                                                  Pending_approval
                                                      .toString() !=
                                                      "0"
                                                      ? Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: const Color(0xffb3c53c2)),
                                                        borderRadius:
                                                        BorderRadius.circular(5)),
                                                    margin: const EdgeInsets.only(left: 0, right: 0, bottom: 10, top: 0),
                                                    child: Material(
                                                      elevation: 2.0,
                                                      color: Appcolor
                                                          .lightyello,
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          5.0),
                                                      child: InkWell(
                                                          splashColor:
                                                          Appcolor
                                                              .splashcolor,
                                                          customBorder:
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                              10.0,
                                                            ),
                                                          ),
                                                          onTap:
                                                              ()  {
                                                          },
                                                          child: Ink(
                                                            child:
                                                            Column(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.start,
                                                               crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                              children: [
                                                                Container(
                                                                  width:
                                                                  MediaQuery.of(context).size.width,
                                                                  padding:
                                                                  const EdgeInsets.all(5),
                                                                  child: const Center(
                                                                      child: Text(

                                                                        textAlign: TextAlign.center,
                                                                        '\nTotal\nprovided',
                                                                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                                                      )),
                                                                ),
                                                                const Divider(
                                                                  thickness: 1,
                                                                  height: 10,
                                                                  color: Appcolor.lightgrey,
                                                                ),
                                                                Center(
                                                                    child: Text(
                                                                      Total_Provided.toString(),
                                                                      style: const TextStyle(
                                                                          fontSize: 18,
                                                                          fontWeight: FontWeight.bold,
                                                                          color: Appcolor.btncolor),
                                                                    ))
                                                              ],
                                                            ),
                                                          )),
                                                    ),
                                                  )
                                                      : Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xffb3c53c2)),
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            5)),
                                                    margin:
                                                    const EdgeInsets
                                                        .only(
                                                        left: 2,
                                                        right: 2,
                                                        bottom:
                                                        10,
                                                        top: 0),
                                                    child: Material(
                                                      elevation: 2.0,
                                                      color: Appcolor
                                                          .lightyello,
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          5.0),
                                                      child: InkWell(
                                                        splashColor:
                                                        Appcolor
                                                            .splashcolor,
                                                        customBorder:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                            10.0,
                                                          ),
                                                        ),
                                                        child: Ink(
                                                          child:
                                                          Column(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Container(
                                                                width: MediaQuery.of(context)
                                                                    .size
                                                                    .width,
                                                                padding: const EdgeInsets
                                                                    .all(
                                                                    5),
                                                                child: const Center(
                                                                    child: Text(
                                                                      textAlign: TextAlign.center,
                                                                      '\nTotal\nprovided',
                                                                      style:
                                                                      TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                                                    )),
                                                              ),
                                                              const Divider(
                                                                thickness:
                                                                1,
                                                                height:
                                                                10,
                                                                color:
                                                                Appcolor.lightgrey,
                                                              ),
                                                              Center(
                                                                  child:
                                                                  Text(
                                                                    Total_Provided
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        fontSize: 18,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Appcolor.btncolor),
                                                                  ))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 2,
                                                      right: 5,
                                                      bottom: 5,
                                                      top: 0),
                                                  decoration: BoxDecoration(
                                                      color: Appcolor.pinklight,
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          5)),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xffb3c53c2)),
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(5)),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                              context)
                                                              .size
                                                              .width,
                                                          padding:
                                                          const EdgeInsets
                                                              .all(5),
                                                          child: const Center(
                                                              child: Text(
                                                                'Pending\n    for\napproval ',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                    fontSize: 16),
                                                              )),
                                                        ),
                                                        const Divider(
                                                          thickness: 1,
                                                          height: 10,
                                                          color: Appcolor
                                                              .lightgrey,
                                                        ),
                                                        Pending_approval == "0"
                                                            ? Center(
                                                            child: Text(
                                                              Pending_approval
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                  18,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  color: Appcolor
                                                                      .btncolor),
                                                            ))
                                                            : GestureDetector(
                                                            onTap: () {},
                                                            child: Center(
                                                                child: Text(
                                                                  Pending_approval
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      18,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      color: Appcolor
                                                                          .btncolor),
                                                                ))),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {

                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xffb3c53c2)),
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(5)),
                                                    margin:
                                                    const EdgeInsets.only(
                                                        left: 2,
                                                        right: 2,
                                                        bottom: 5 ,
                                                        top: 0),
                                                    child: Material(
                                                      elevation: 2.0,
                                                      color:
                                                      Appcolor.greylightsec,
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                      child: InkWell(
                                                        customBorder:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                            5.0,
                                                          ),
                                                        ),
                                                        child: Ink(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {

                                                                },
                                                                child:
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                      context)
                                                                      .size
                                                                      .width,
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      5),
                                                                  child:
                                                                  const Center(
                                                                      child:
                                                                      Text(
                                                                        '\nBalance HHs\n',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                            fontSize:
                                                                            16),
                                                                      )),
                                                                ),
                                                              ),
                                                              const Divider(
                                                                thickness: 1,
                                                                height: 10,
                                                                color: Appcolor
                                                                    .lightgrey,
                                                              ),
                                                              Center(
                                                                  child: Text(
                                                                    Balance_HHs
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                        18,
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color: Appcolor
                                                                            .btncolor),
                                                                  ))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),



                                        ],
                                      ),
                                    ),







                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: schemeSource,
                              child: Card(
                                elevation: 5,
                                child: SizedBox(
                                    child: Container(
                                  decoration: BoxDecoration(
                                      color: Appcolor.white,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5)),
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(3.0),
                                          child: Text(
                                            'Select Scheme',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          height: 75,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin: const EdgeInsets.only(
                                              bottom: 10.0, right: 5, left: 3),
                                          padding: const EdgeInsets.only(
                                              left: 5.0, right: 5.0),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              border: Border.all(
                                                  color: Appcolor.grey,
                                                  width: .5),
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: DropdownButton<String>(
                                              itemHeight: 100,
                                              alignment: Alignment.center,
                                              elevation: 10,
                                              dropdownColor: Appcolor.white,
                                              underline: const SizedBox(),
                                              isExpanded: true,

                                              // Adjusted for larger dropdown box size
                                              icon: const Icon(
                                                  Icons.arrow_drop_down),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                              ),
                                              hint: Container(
                                                width: double.infinity,
                                                alignment: Alignment.centerLeft,
                                                decoration: const BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color: Colors.grey,
                                                            width: 1))),
                                                child: const Text(
                                                    '--Select Scheme--',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Appcolor.black)),
                                              ),
                                              value: Selectscheme,
                                              onChanged: (String? newValue) {
                                                print("ddddddd  $newValue");
                                                setState(() {
                                                  if (SchemeResponse[0] ==
                                                      "--Select Scheme--") {
                                                    Stylefile
                                                        .showmessageforvalidationfalse(
                                                            context,
                                                            "Select scheme.");
                                                  } else {
                                                    Selectscheme =
                                                        newValue ?? '';
                                                    print(
                                                        "schemeid_id  $Selectscheme");
                                                  }
                                                });
                                              },
                                              items: SchemeResponse.map<
                                                      DropdownMenuItem<String>>(
                                                  (item) {
                                                return DropdownMenuItem<String>(
                                                  value: item['Schemeid']
                                                      .toString(),
                                                  child: Container(
                                                    width: double.infinity,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    decoration: const BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color:
                                                                    Colors.grey,
                                                                width: 1))),
                                                    child: Text(
                                                      item['Schemename'],
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList()),
                                        )
                                      ]),
                                )),
                              ),
                            ),
                            Visibility(
                              visible: beneficiarydetailsVisible,
                              child: Card(
                                elevation: 5,
                                child: SizedBox(
                                    child: Container(
                                  decoration: BoxDecoration(
                                      color: Appcolor.white,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5)),
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          'Beneficiary details',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(

                                                width: double.infinity,
                                                padding: const EdgeInsets.only(
                                                    left: 5.0, right: 5.0),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: TextFormField(
                                                        maxLength: 40,
                                                        controller:
                                                            BeneficiaryName,
                                                        decoration:
                                                            InputDecoration(
                                                          counterText: "",
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                          // Set the background color of the entire TextFormField
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          hintText:
                                                              "Beneficiary name",
                                                          prefixIcon:
                                                              const Icon(
                                                                  Icons.person),
                                                          // Add your prefix icon here
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(
                                                                  16.0), // Set the internal padding
                                                        ),
                                                        keyboardType:
                                                            TextInputType.text,
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return "Beneficiary Name";
                                                          } else {
                                                            // Regular expression for alphabets only
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: TextFormField(
                                                        controller: Aadhaarno,
                                                        onTapOutside:
                                                            (PointerDownEvent
                                                                event) {
                                                          FocusScope.of(context)
                                                              .requestFocus(
                                                                  _unUsedFocusNode);
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          filled: true,
                                                          counterText: "",
                                                          fillColor:
                                                              Colors.white,
                                                          // Set the background color  of the entire TextFormField
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          hintText:
                                                              "Aadhaar Number",
                                                          prefixIcon:
                                                              const Icon(Icons
                                                                  .fingerprint_outlined),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(
                                                                  16.0), // Set the internal padding
                                                        ),
                                                        keyboardType:
                                                            const TextInputType
                                                                .numberWithOptions(
                                                                decimal: true),
                                                        inputFormatters: <TextInputFormatter>[
                                                          FilteringTextInputFormatter
                                                              .digitsOnly
                                                        ],
                                                        maxLength: 12,
                                                        textInputAction:
                                                            TextInputAction
                                                                .done,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return "Enter Aadhaar Number";
                                                          } else {
                                                            RegExp
                                                                aadhaarRegex =
                                                                RegExp(
                                                                    r'^\d{12}$');

                                                            if (!aadhaarRegex
                                                                .hasMatch(
                                                                    value)) {
                                                              return "Enter a valid 12-digit Aadhaar Number";
                                                            } else {
                                                              return null;
                                                            }
                                                          }
                                                        },
                                                        onChanged: (aadhaar) {
                                                          setState(() {
                                                            String Aadhaar =
                                                                aadhaar.toString() ??
                                                                    '';
                                                            Uint8List keyBytes =
                                                                Uint8List.fromList(
                                                                    utf8.encode(
                                                                        key));
                                                            Uint8List iv =
                                                                Uint8List.fromList(
                                                                    utf8.encode(
                                                                        key));
                                                            Uint8List
                                                                encryptedBytes =
                                                                encryptAES(
                                                                    Aadhaar,
                                                                    keyBytes,
                                                                    iv);
                                                            encryptedText = base64.encode(encryptedBytes);
                                                            aadhaarurlEncodedText = Uri.encodeComponent(encryptedText);
                                                            print('aadhaarurlencoded $aadhaarurlEncodedText');
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        if (SchemeResponse[0]
                                                                .toString() ==
                                                            "--Select Scheme--") {
                                                          Stylefile
                                                              .showmessageforvalidationfalse(
                                                                  context,
                                                                  "Select scheme.");
                                                        } else if (BeneficiaryName
                                                                .text
                                                                .toString() ==
                                                            "") {
                                                          Stylefile
                                                              .showmessageforvalidationfalse(
                                                                  context,
                                                                  "Enter beneficiary name.");
                                                        } else if (Aadhaarno
                                                                .text
                                                                .toString() ==
                                                            "") {
                                                          Stylefile
                                                              .showmessageforvalidationfalse(
                                                                  context,
                                                                  "Enter aadhar number.");
                                                        } else if (Aadhaarno
                                                                .text.length <
                                                            12) {
                                                          Stylefile
                                                              .showmessageforvalidationfalse(
                                                                  context,
                                                                  "Enter 12-digits aadhar number.");
                                                        } else {
                                                          try {
                                                            final result = await InternetAddress.lookup('example.com');
                                                            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                                              getaadhaarvalidation(Aadhaarno.text.toString()
                                                                      .trimLeft()
                                                                      .trimRight(),
                                                                  BeneficiaryName
                                                                      .text
                                                                      .toString());
                                                              print(
                                                                  "ddddff${Aadhaarno.text}");
                                                            }
                                                          } on SocketException catch (_) {
                                                            Stylefile
                                                                .showmessageforvalidationfalse(
                                                                    context,
                                                                    "Unable to Connect to the Internet. Please check your network settings.");
                                                          }
                                                        }
                                                      },
                                                      child: loadingverify ==
                                                              true
                                                          ? Container(
                                                              height: 50,
                                                              width: 50,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Appcolor.btncolor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                              ),
                                                              child:
                                                                  const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            5.0),
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation(
                                                                          Colors
                                                                              .white),
                                                                ),
                                                              ))
                                                          : Container(
                                                              height: 40,
                                                              width: double
                                                                  .infinity,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Appcolor.btncolor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child:
                                                                  const Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    'Verify Aadhaar ',
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          18.0,
                                                                    ),
                                                                  ),
                                                                  // Conditional loader for master data
                                                                  //  isLoadingMasterData ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),) : Container(),
                                                                ],
                                                              ),
                                                            ),
                                                    ),
                                                  ],
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                              ),
                            ),
                            Visibility(
                              visible: beneficiaryInformation,
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Appcolor.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
                                            'Select Gender',
                                            style: TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                fontSize: 16),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                            margin: const EdgeInsets.all(4),
                                            decoration:
                                                BoxDecoration(
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          8),
                                              border: Border.all(
                                                  color: Colors
                                                      .black54),
                                            ),
                                            child:
                                            Column(
                                              children: [
                                                RadioListTile(
                                            contentPadding: EdgeInsets.zero,
                                                    visualDensity: const VisualDensity(
                                                      horizontal: VisualDensity.minimumDensity,
                                                      vertical: VisualDensity.minimumDensity),
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  title: const Text("Male"),
                                                  value: "male",
                                                  groupValue: gender,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      gender =
                                                          value.toString();
                                                    });
                                                  },
                                                ),
                                                RadioListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    visualDensity: const VisualDensity(
                                                      horizontal: VisualDensity.minimumDensity,
                                                      vertical: VisualDensity.minimumDensity),
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  title: const Text("Female"),
                                                  value: "female",
                                                  groupValue:
                                                      gender,
                                                  onChanged:
                                                      (value) {
                                                    setState(
                                                        () {
                                                      gender =
                                                          value.toString();
                                                    });
                                                  },
                                                ),
                                                RadioListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    visualDensity: const VisualDensity(
                                                      horizontal: VisualDensity.minimumDensity,
                                                      vertical: VisualDensity.minimumDensity),
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  title: const Text("Other"),
                                                  value: "other",
                                                  groupValue: gender,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      gender = value.toString();
                                                    });
                                                  },
                                                )
                                              ],
                                            )),
                                        const SizedBox(height: 15),
                                        Container(
                                          margin: const EdgeInsets.only(left:5 ,right:5 , bottom:5),  width: double.infinity,
                                          child: TextFormField(
                                            controller:
                                                MobileNumber,
                                            decoration:
                                                InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  Colors.white,
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                                              ),
                                              hintText: "Mobile Number",
                                              prefixIcon: const Icon(Icons.phone),
                                              contentPadding: const EdgeInsets.all(16.0),
                                            ),
                                            keyboardType:
                                                TextInputType
                                                    .visiblePassword,
                                            // This might be incorrect for mobile numbers
                                            textInputAction:
                                                TextInputAction
                                                    .done,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Enter Mobile Number";
                                              } else {
                                                // Regular expression for Aadhaar number validation
                                                RegExp mobileRegex =
                                                    RegExp(
                                                        r'^[6789]\d{9}$'); // Regular expression for a 10-digit mobile number

                                                if (!mobileRegex
                                                    .hasMatch(
                                                        value)) {
                                                  return "Enter a valid 10-digit Mobile Number starting with 6, 7, 8, or 9";
                                                } else {
                                                  return null;
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Container(
                                            margin: const EdgeInsets.only(left:5 ,right:5 , bottom:5),
                                          width: double.infinity,
                                          child: TextFormField(
                                            controller:
                                                BeneficiaryId,
                                            decoration:
                                                InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  Colors.white,
                                              border:
                                                  OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                            10),
                                              ),
                                              hintText:
                                                  "Beneficiary Id of state",
                                              prefixIcon:
                                                  const Icon(
                                                      Icons.person),
                                              contentPadding:
                                                  const EdgeInsets
                                                      .all(16.0),
                                            ),
                                            keyboardType:
                                                TextInputType
                                                    .visiblePassword,
                                            // This might be incorrect for beneficiary ID
                                            textInputAction:
                                                TextInputAction
                                                    .done,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Enter valid Beneficiary Id of state";
                                              } else {
                                                // Regular expression for beneficiary ID validation
                                                RegExp
                                                    beneficiaryIdRegex =
                                                    RegExp(
                                                        r'^\d{10}$'); // Regular expression for a 10-digit beneficiary ID

                                                if (!beneficiaryIdRegex
                                                    .hasMatch(
                                                        value)) {
                                                  return "Enter a valid 10-digit Beneficiary ID";
                                                } else {
                                                  return null;
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Container(
                                            margin: const EdgeInsets.only(left:5 ,right:5 , bottom:5),
                                          width: double.infinity,
                                          child: TextFormField(
                                            controller: HusbandName,
                                            decoration:
                                                InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  Colors.white,
                                              border:
                                                  OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                            10),
                                              ),
                                              hintText:
                                                  "Father/Husband Name",
                                              prefixIcon:
                                                  const Icon(
                                                      Icons.person),
                                              contentPadding:
                                                  const EdgeInsets
                                                      .all(16.0),
                                            ),
                                            keyboardType:
                                                TextInputType
                                                    .visiblePassword,
                                            textInputAction:
                                                TextInputAction
                                                    .done,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Enter Father/Husband Name";
                                              } else {
                                                // Regular expression for alphabets only
                                                RegExp
                                                    alphabetRegex =
                                                    RegExp(
                                                        r'^[a-zA-Z]+$');
                                                if (!alphabetRegex
                                                    .hasMatch(
                                                        value)) {
                                                  return "Enter only alphabets for Father/Husband Name";
                                                }
                                              }
                                              return null; // Return null if validation passes
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                                      
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              const SizedBox(height: 5,),
                                              const Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Text(
                                                  'Select Category',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight
                                                              .bold,
                                                      fontSize: 16),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                      margin: const EdgeInsets.only(left:5 ,right:5 , bottom:5),
                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.black54),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      RadioListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                        visualDensity: const VisualDensity(
                                                            horizontal: VisualDensity.minimumDensity,
                                                            vertical: VisualDensity.minimumDensity),
                                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                        title: const Text("GEN"),
                                                        value: "GEN",
                                                        groupValue:
                                                            category,
                                                        onChanged:
                                                            (value) {
                                                          setState(
                                                              () {
                                                            category =
                                                                value.toString();
                                                          });
                                                        },
                                                      ),
                                                      RadioListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                        visualDensity: const VisualDensity(
                                                            horizontal: VisualDensity.minimumDensity,
                                                            vertical: VisualDensity.minimumDensity),
                                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                        title:
                                                            const Text("SC"),
                                                        value: "SC",
                                                        groupValue:
                                                            category,
                                                        onChanged:
                                                            (value) {
                                                          setState(
                                                              () {
                                                            category =
                                                                value.toString();
                                                          });
                                                        },
                                                      ),
                                                      RadioListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                        visualDensity: const VisualDensity(
                                                            horizontal: VisualDensity.minimumDensity,
                                                            vertical: VisualDensity.minimumDensity),
                                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                        title:
                                                            const Text("ST"),
                                                        value: "ST",
                                                        groupValue:
                                                            category,
                                                        onChanged:
                                                            (value) {
                                                          setState(
                                                              () {
                                                            category =
                                                                value.toString();
                                                          });
                                                        },
                                                      )
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height:20),
                                        GestureDetector(
                                          onTap: () {
                                            getSaveFHTC(
                                                Aadhaarno.text,
                                                UidToken,
                                                Habitation,
                                                Selectscheme,
                                                BeneficiaryName.text,
                                                BeneficiaryId.text,
                                                HusbandName.text,
                                                AdhaarUidtoken,
                                                widget.IsHGJ,
                                                gender,
                                                category);
                                          },
                                          child: Container(
                                            height: 40,
                                            margin: const EdgeInsets.all(5),
                                            width: double.infinity,
                                            alignment:
                                                Alignment.center,
                                            decoration:
                                                BoxDecoration(
                                              color:Appcolor.btncolor,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(8),
                                            ),
                                            child: Stack(
                                              alignment:
                                                  Alignment.center,
                                              children: [
                                                const Text(
                                                  'Save',
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight
                                                            .w500,
                                                    color: Colors
                                                        .white,
                                                    fontSize: 18.0,
                                                  ),
                                                ),
                                                // Conditional loader for master data
                                                isLoadingSaveFHTC
                                                    ? const CircularProgressIndicator(
                                                        valueColor: AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors
                                                                .white),
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Text("pidresponse $pidjsonResponse"),
                                        Text("save_response$savejsonResponse"),
                                        Text(Aadhaarno.text),
                                        Text("UidToken$UidToken"),
                                        Text("Habitation$Habitation"),
                                        Text("Selectscheme$Selectscheme"),
                                        Text(BeneficiaryName.text),
                                        Text(BeneficiaryId.text),
                                        Text("_category$category"),
                                        Text(HusbandName.text),
                                        Text("_gender$gender"),
                                        Text("AdhaarUidtoken$AdhaarUidtoken"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
