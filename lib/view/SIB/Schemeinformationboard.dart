import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:provider/provider.dart';
import '../../apiservice/Apiservice.dart';
import '../../database/DataBaseHelperJalJeevan.dart';
import '../../localdatamodel/Localmasterdatamodal.dart';
import '../../model/SIBGeotagmodal.dart';
import '../../utility/Appcolor.dart';
import '../../utility/Stylefile.dart';
import '../Dashboard.dart';
import '../LoginScreen.dart';
import '../SS/ZoomImage.dart';

class Schemeinformationboard extends StatefulWidget {
  String send_district;
  String send_block = "";
  String send_panchayat = "";
  String villageid;
  String VillageName;
  String stateid;
  String token;
  String statusapproved;

  Schemeinformationboard(
      {required this.send_district,
      required this.send_block,
      required this.send_panchayat,
      required this.villageid,
      required this.VillageName,
      required this.stateid,
      required this.token,
      required this.statusapproved,
      super.key});

  @override
  State<Schemeinformationboard> createState() => _SchemeinformationboardState();
}

class _SchemeinformationboardState extends State<Schemeinformationboard> {
  String getstateid = "";
  String getvillageid = "";
  String getstatusapproved = "";
  GetStorage box = GetStorage();
  String statusforapproveornot = "";
  String statusforapproveornot_message = "";
  String village = "";
  String message = "";
  String Panchayat = "";
  String villagename = "";
  String Block = "";
  String district = "";
  String gettoken = "";
  bool _loading = false;
  late SibGeotagmodal sibGeotagmodal;
  List<Result> sibgeotaglist = [];

  DatabaseHelperJalJeevan? databaseHelperJalJeevan;

  Future<void> cleartable_villllagedetails() async {
    await databaseHelperJalJeevan!.cleartable_villagedetails();
  }

  @override
  void initState() {
    villagename = widget.VillageName.toString();
    getvillageid = widget.villageid;
    getstateid = widget.stateid;
    gettoken = widget.token;
    getstatusapproved = widget.statusapproved;
    databaseHelperJalJeevan = DatabaseHelperJalJeevan();
    sibGeotagmodal = SibGeotagmodal(
        status: true,
        message: "ff",
        district: "",
        block: "",
        panchayat: "",
        headingMessage: "",
        result: []);

    setState(() {
      SIBPendingapprovalAPI(getvillageid, getstateid, box.read("userid"),
          getstatusapproved, gettoken);
    });

    super.initState();
  }

  Future SIBPendingapprovalAPI(String villageid, String stateid, String userid,
      String status, String token) async {
    setState(() {
      _loading = true;
    });
    var response = await http.get(
      Uri.parse(
          "${Apiservice.baseurl}JJM_Mobile/GetGeotaggedInformationBoard?VillageId=$villageid&StateId=$stateid&UserId=$userid&Status=$status"),
      headers: {
        'Content-Type': 'application/json',
        'APIKey': token ?? 'DEFAULT_API_KEY'
      },
    );
    try {
      if (response.statusCode == 200) {
        try {
          if (response.statusCode == 200) {
            Map<String, dynamic> mResposne = jsonDecode(response.body);
            message = mResposne["Message"];

            if (message == "Token is wrong or expire") {
              setState(() {
                Get.off(LoginScreen());
                box.remove("UserToken").toString();
                cleartable_localmastertables();
              });
              Stylefile.showmessageforvalidationfalse(
                  context, "Please login, your token has been expired!");
            } else {
              setState(() {
                district = mResposne["District"];
                Block = mResposne["Block"];
                Panchayat = mResposne["Panchayat"];
                sibgeotaglist = (mResposne["Result"] as List<dynamic>)
                    .map((item) => Result.fromJson(item))
                    .toList();
              });
            }
          }
        } catch (e) {}
      }
    } finally {
      _loading = false;
    }
  }

  Future<void> cleartable_localmastertables() async {
    await databaseHelperJalJeevan!.truncateTable_localmasterschemelist();
    await databaseHelperJalJeevan!.cleardb_localmasterschemelist();
    await databaseHelperJalJeevan!.cleartable_villagelist();
    await databaseHelperJalJeevan!.cleartable_villagedetails();
    await databaseHelperJalJeevan!.cleardb_localhabitaionlisttable();
    await databaseHelperJalJeevan!.cleardb_sourcedetailstable();
    await databaseHelperJalJeevan!.cleardb_sibmasterlist();
  }

  Future RemovegeotaggedSIBAPI(String villageid, String stateid, String userid,
      String token, String taggedid, int index) async {
    var response = await http.get(
      Uri.parse(
          "${Apiservice.baseurl}JJM_Mobile/RemoveGeoTaggedInformationBoard?VillageId=$villageid&StateId=$stateid&UserId=$userid&TaggedId=$taggedid"),
      headers: {'Content-Type': 'application/json', 'APIKey': token},
    );
    try {
      if (response.statusCode == 200) {
        var responseof = jsonDecode(response.body);
        var message = responseof["Message"].toString();
        var Status = responseof["Status"].toString();
        if (Status == "true") {
          Stylefile.showmessageforvalidationtrue(context, "$message");
        }
      }
    } catch (e) {
      e.printError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: AppBar(
            leadingWidth: 30,
            backgroundColor: const Color(0xFF0D3A98),
            iconTheme: const IconThemeData(
              color: Appcolor.white,
            ),
            title: getstatusapproved == "1"
                ? const Text("Geo-tagged Scheme Information(Approved)",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold))
                : const Text("Geo-tagged Scheme Information(Pending)",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
            actions: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                onPressed: () async {
                  Get.offAll(Dashboard(
                      stateid: box.read("stateid"),
                      userid: box.read("userid"),
                      usertoken: box.read("UserToken")));
                },
              )
            ],
          ),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/header_bg.png'), fit: BoxFit.cover),
            ),
            child: _loading == true
                ? Provider.of<InternetConnectionStatus>(context) ==
                        InternetConnectionStatus.disconnected
                    ? Center(
                        child: Container(
                            width: 200,
                            child: const Text(
                                "No internet connection available please connect to the internet")),
                      )
                    : Center(
                        child: SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset("images/loading.gif")),
                      )
                : sibgeotaglist.length == 0
                    ? Center(
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: const Center(
                                child: Text(
                              "No data found",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Appcolor.black,
                                  fontSize: 16),
                            ))),
                      )
                    : SingleChildScrollView(
                        child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              10.0,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Village : ${widget.VillageName}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Appcolor.headingcolor),
                                  )),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              thickness: 1,
                              height: 10,
                              color: Appcolor.lightgrey,
                            ),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 10, bottom: 5),
                                  child: SizedBox(
                                      child: Text(
                                    "District:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Appcolor.black),
                                  )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 5),
                                  child: SizedBox(
                                      child: Text(
                                    widget.send_district.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Appcolor.black,
                                        fontSize: 16),
                                  )),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 10, bottom: 5),
                                  child: SizedBox(
                                      child: Text(
                                    "Block:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Appcolor.black),
                                  )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 5),
                                  child: SizedBox(
                                      child: Text(
                                    widget.send_block.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Appcolor.black,
                                        fontSize: 16),
                                  )),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 10, bottom: 5),
                                  child: SizedBox(
                                      child: Text(
                                    "Panchayat:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Appcolor.black),
                                  )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 5),
                                  child: SizedBox(
                                      child: Text(
                                    widget.send_panchayat.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Appcolor.black,
                                        fontSize: 16),
                                  )),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFFFFFFF).withOpacity(0.3),
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 1,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(
                                      10.0,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    sibgeotaglist.length == 0
                                        ? const Center(
                                            child: SizedBox(
                                            child: Text(
                                              "No data found",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          ))
                                        : Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: sibgeotaglist.length,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemBuilder:
                                                    (context, int index) {
                                                  statusforapproveornot =
                                                      sibgeotaglist[index]
                                                          .status
                                                          .toString();
                                                  statusforapproveornot_message =
                                                      sibgeotaglist[index]
                                                          .message
                                                          .toString();
                                                  int counter = index + 1;
                                                  return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5,
                                                              bottom: 5,
                                                              top: 5),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                        border: Border.all(
                                                          color: Colors.green,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                          Radius.circular(
                                                            10.0,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            child: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  "" +
                                                                      counter
                                                                          .toString() +
                                                                      ".",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10,
                                                                        bottom:
                                                                            5,
                                                                        top: 5),
                                                                child: SizedBox(
                                                                    child: Text(
                                                                  "Scheme :",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Appcolor
                                                                          .black,
                                                                      fontSize:
                                                                          16),
                                                                )),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        bottom:
                                                                            5,
                                                                        top: 5),
                                                                child: SizedBox(
                                                                    width: 140,
                                                                    child: Text(
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      maxLines:
                                                                          5,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      sibgeotaglist[
                                                                              index]
                                                                          .schemeName
                                                                          .toString(),
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Appcolor.black),
                                                                    )),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10,
                                                                        bottom:
                                                                            5,
                                                                        top: 5),
                                                                child: SizedBox(
                                                                    child: Text(
                                                                  "Habitation :",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Appcolor
                                                                          .black,
                                                                      fontSize:
                                                                          16),
                                                                )),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        bottom:
                                                                            5,
                                                                        top: 5),
                                                                child: SizedBox(
                                                                    child: Text(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  maxLines: 5,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  sibgeotaglist[
                                                                          index]
                                                                      .habitationName
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Appcolor
                                                                          .black),
                                                                )),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10,
                                                                        bottom:
                                                                            5,
                                                                        top: 5),
                                                                child: SizedBox(
                                                                    child: Text(
                                                                  "Location : ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Appcolor
                                                                          .black,
                                                                      fontSize:
                                                                          16),
                                                                )),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        bottom:
                                                                            5,
                                                                        top: 5),
                                                                child: SizedBox(
                                                                    width: 100,
                                                                    child: Text(
                                                                      maxLines:
                                                                          10,
                                                                      "${sibgeotaglist[index].sourceName}",
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color: Appcolor
                                                                              .black,
                                                                          fontSize:
                                                                              16),
                                                                    )),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10,
                                                                        bottom:
                                                                            5,
                                                                        top: 5),
                                                                child: SizedBox(
                                                                    child: Text(
                                                                  "Latitude : ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Appcolor
                                                                          .black,
                                                                      fontSize:
                                                                          16),
                                                                )),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        bottom:
                                                                            5,
                                                                        top: 5),
                                                                child: SizedBox(
                                                                    width: 180,
                                                                    child: Text(
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          10,
                                                                      sibgeotaglist[
                                                                              index]
                                                                          .latitude
                                                                          .toString()
                                                                          .toString(),
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color: Appcolor
                                                                              .black,
                                                                          fontSize:
                                                                              16),
                                                                    )),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10,
                                                                        bottom:
                                                                            5,
                                                                        top: 5),
                                                                child: SizedBox(
                                                                    child: Text(
                                                                  "Longitude : ",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Appcolor
                                                                          .black),
                                                                )),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        bottom:
                                                                            5,
                                                                        top: 5),
                                                                child: SizedBox(
                                                                    width: 180,
                                                                    child: Text(
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      maxLines:
                                                                          5,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      sibgeotaglist[
                                                                              index]
                                                                          .longitude
                                                                          .toString()
                                                                          .toString(),
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color: Appcolor
                                                                              .black,
                                                                          fontSize:
                                                                              16),
                                                                    )),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10,
                                                                        bottom:
                                                                            5,
                                                                        top: 5),
                                                                child: SizedBox(
                                                                    child: Text(
                                                                  "Status :",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Appcolor
                                                                          .black,
                                                                      fontSize:
                                                                          16),
                                                                )),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        bottom:
                                                                            5,
                                                                        top: 5),
                                                                child: SizedBox(
                                                                    child: Text(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  maxLines: 5,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  sibgeotaglist[
                                                                          index]
                                                                      .message
                                                                      .toString()
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Appcolor
                                                                          .red,
                                                                      fontSize:
                                                                          16),
                                                                )),
                                                              )
                                                            ],
                                                          ),
                                                          const Divider(
                                                            thickness: 1,
                                                            height: 10,
                                                            color: Appcolor
                                                                .lightgrey,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Container(
                                                                    height: 25,
                                                                    child:
                                                                        ElevatedButton
                                                                            .icon(
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor: Appcolor.lightgrey,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5.0),
                                                                        ),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        Get.to(
                                                                            ZoomImage(
                                                                          imgurl:
                                                                              sibgeotaglist[index].imageUrl.toString(),
                                                                          lat: sibgeotaglist[index]
                                                                              .latitude.toString(),
                                                                          long:
                                                                              sibgeotaglist[index].longitude.toString(),
                                                                        ));
                                                                      },
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .remove_red_eye_outlined,
                                                                        size:
                                                                            18,
                                                                        color: Appcolor
                                                                            .white,
                                                                      ),
                                                                      label:
                                                                          const Text(
                                                                        "View",
                                                                        style: TextStyle(
                                                                            color: Appcolor
                                                                                .white,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  getstatusapproved ==
                                                                          "1"
                                                                      ? const SizedBox()
                                                                      : Container(
                                                                          height:
                                                                              25,
                                                                          child:
                                                                              ElevatedButton.icon(
                                                                            style:
                                                                                ElevatedButton.styleFrom(
                                                                              backgroundColor: Appcolor.pink,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                              ),
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              showuntagedalertbox(sibgeotaglist[index].villageId.toString(), sibgeotaglist[index].stateId.toString(), box.read("userid").toString(), gettoken, sibgeotaglist[index].taggedId.toString(), index).then((value) {
                                                                                setState(() {});
                                                                              });
                                                                            },
                                                                            icon:
                                                                                const Icon(
                                                                              size: 18.0,
                                                                              Icons.delete_outline_outlined,
                                                                              color: Appcolor.white,
                                                                            ),
                                                                            label:
                                                                                const Text(
                                                                              "Remove",
                                                                              style: TextStyle(color: Appcolor.white, fontSize: 12, fontWeight: FontWeight.w400),
                                                                            ),
                                                                          ),
                                                                        )
                                                                ]),
                                                          )
                                                        ],
                                                      ));
                                                }),
                                          ),
                                  ],
                                )),
                          ],
                        ),
                      ))));
  }

  Future<void> showuntagedalertbox(String villageid, String stateid,
      String userid, String token, String taggedid, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Appcolor.white,
          titlePadding: const EdgeInsets.only(top: 0, left: 0, right: 00),
          buttonPadding: const EdgeInsets.all(10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                5.0,
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          title: Container(
            color: Appcolor.red,
            child: const Padding(
              padding: EdgeInsets.only(left: 25, top: 10, bottom: 10),
              child: Text(
                'Alert! ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Appcolor.white),
              ),
            ),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                  child: Text(
                    " Are you sure you want to remove it?",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Appcolor.black),
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                child: const Text(
                  'No',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                child: const Text(
                  'Yes',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Appcolor.black),
                ),
                onPressed: () async {
                  RemovegeotaggedSIBAPI(
                          villageid, stateid, userid, token, taggedid, index)
                      .then((value) {
                    sibgeotaglist.removeAt(index);

                    Navigator.of(context).pop(false);

                    cleartable_localmasterschemelisttable();
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> cleartable_localmasterschemelisttable() async {
    await databaseHelperJalJeevan!.cleardb_localmasterschemelist();
    await databaseHelperJalJeevan!.cleartable_villagelist();
    await databaseHelperJalJeevan!.cleartable_villagedetails();
    await databaseHelperJalJeevan!.cleardb_localhabitaionlisttable();
    await databaseHelperJalJeevan!.cleardb_sourcedetailstable();
    await databaseHelperJalJeevan!.truncatetable_sibmasterdeatils();

    // Fetch new data from API and update local database
    Apiservice.Getmasterapi(context).then((value) async {
      // Update Village List
      for (int i = 0; i < value.villagelist!.length; i++) {
        var villageData = value.villagelist![i]!;
        await databaseHelperJalJeevan?.insertMastervillagelistdata(
          Localmasterdatanodal(
            UserId: villageData.userId.toString(),
            villageId: villageData.villageId.toString(),
            StateId: villageData.stateId.toString(),
            villageName: villageData.VillageName.toString(),
          ),
        );
      }
      await databaseHelperJalJeevan!.removeDuplicateEntries();

      // Update Village Details
      for (int i = 0; i < value.villageDetails!.length; i++) {
        var villageDetails = value.villageDetails![i]!;
        await databaseHelperJalJeevan?.insertMastervillagedetails(
          Localmasterdatamodal_VillageDetails(
            status: "0",
            stateName: "Assam",
            districtName: villageDetails.districtName,
            blockName: villageDetails.blockName,
            panchayatName: villageDetails.panchayatName,
            stateId: villageDetails.stateId.toString(),
            userId: villageDetails.userId.toString(),
            villageId: villageDetails.villageId.toString(),
            villageName: villageDetails.villageName,
            totalNoOfScheme: villageDetails.totalNoOfScheme.toString(),
            totalNoOfWaterSource: villageDetails.totalNoOfWaterSource.toString(),
            totalWsGeoTagged: villageDetails.totalWsGeoTagged.toString(),
            pendingWsTotal: villageDetails.pendingWsTotal.toString(),
            balanceWsTotal: villageDetails.balanceWsTotal.toString(),
            totalSsGeoTagged: villageDetails.totalSsGeoTagged.toString(),
            pendingApprovalSsTotal: villageDetails.pendingApprovalSsTotal.toString(),
            totalIbRequiredGeoTagged: villageDetails.totalIbRequiredGeoTagged.toString(),
            totalIbGeoTagged: villageDetails.totalIbGeoTagged.toString(),
            pendingIbTotal: villageDetails.pendingIbTotal.toString(),
            balanceIbTotal: villageDetails.balanceIbTotal.toString(),
            totalOaGeoTagged: villageDetails.totalOaGeoTagged.toString(),
            balanceOaTotal: villageDetails.balanceOaTotal.toString(),
            totalNoOfSchoolScheme: villageDetails.totalNoOfSchoolScheme.toString(),
            totalNoOfPwsScheme: villageDetails.totalNoOfPwsScheme.toString(),
          ),
        );
      }

      // Update Scheme List
      for (int i = 0; i < value.schmelist!.length; i++) {
        var scheme = value.schmelist![i]!;
        await databaseHelperJalJeevan?.insertMasterSchmelist(
          Localmasterdatamoda_Scheme(
            source_type: scheme.source_type.toString(),
            schemeid: scheme.schemeid.toString(),
            villageId: scheme.villageId.toString(),
            schemename: scheme.schemename.toString(),
            category: scheme.category.toString(),
            SourceTypeCategoryId: scheme.SourceTypeCategoryId.toString(),
            source_typeCategory: scheme.source_typeCategory.toString(),
          ),
        );
      }

      // Update Source List
      for (int i = 0; i < value.sourcelist!.length; i++) {
        var source = value.sourcelist![i]!;
        await databaseHelperJalJeevan?.insertMasterSourcedetails(
          LocalSourcelistdetailsModal(
            schemeId: source.schemeId.toString(),
            sourceId: source.sourceId.toString(),
            villageId: source.villageId.toString(),
            schemeName: source.schemeName,
            sourceTypeId: source.sourceTypeId.toString(),
            sourceTypeCategoryId: source.sourceTypeCategoryId.toString(),
            habitationId: source.habitationId.toString(),
            existTagWaterSourceId: source.existTagWaterSourceId.toString(),
            isApprovedState: source.isApprovedState.toString(),
            landmark: source.landmark,
            latitude: source.latitude.toString(),
            longitude: source.longitude.toString(),
            habitationName: source.habitationName,
            location: source.location,
            sourceTypeCategory: source.sourceTypeCategory,
            sourceType: source.sourceType,
            stateName: source.stateName,
            districtName: source.districtName,
            blockName: source.blockName,
            panchayatName: source.panchayatName,
            districtId: source.districtId.toString(),
            villageName: source.villageName,
            stateId: source.stateid.toString(),
            IsWTP: source.IsWTP.toString(),
          ),
        );
      }

      // Update Habitation List
      for (int i = 0; i < value.habitationlist!.length; i++) {
        var habitation = value.habitationlist![i]!;
        await databaseHelperJalJeevan?.insertMasterhabitaionlist(
          LocalHabitaionlistModal(
            villageId: habitation.villageId.toString(),
            HabitationId: habitation.habitationId.toString(),
            HabitationName: habitation.habitationName.toString(),
          ),
        );
      }

      // Update Information Board List
      for (int i = 0; i < value.informationBoardList!.length; i++) {
        var infoBoard = value.informationBoardList![i]!;
        await databaseHelperJalJeevan?.insertmastersibdetails(
          LocalmasterInformationBoardItemModal(
            userId: infoBoard.userId.toString(),
            villageId: infoBoard.villageId.toString(),
            stateId: infoBoard.stateId.toString(),
            schemeId: infoBoard.schemeId.toString(),
            districtName: infoBoard.districtName,
            blockName: infoBoard.blockName,
            panchayatName: infoBoard.panchayatName,
            villageName: infoBoard.villageName,
            habitationName: infoBoard.habitationName,
            latitude: infoBoard.latitude.toString(),
            longitude: infoBoard.longitude.toString(),
            sourceName: infoBoard.sourceName,
            schemeName: infoBoard.schemeName,
            message: infoBoard.message,
            status: infoBoard.status.toString(),
          ),
        );
      }
    });

    // Handle API timeout or errors
    try {
      var value = await Apiservice.Getmasterapi(context).timeout(Duration(seconds: 30));
      // Data processing logic if needed
    } catch (e) {
      if (e is TimeoutException) {
        print("API call timed out");
        Stylefile.showmessageforvalidationfalse(context, "Request timed out. Please try again.");
      } else {
        print("Error: $e");
        Stylefile.showmessageforvalidationfalse(context, "An error occurred.");
      }
    }
  }
}
