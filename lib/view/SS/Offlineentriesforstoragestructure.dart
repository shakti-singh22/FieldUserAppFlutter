import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../apiservice/Apiservice.dart';
import '../../database/DataBaseHelperJalJeevan.dart';
import '../../localdatamodel/Localmasterdatamodal.dart';
import '../../localdatamodel/Localpwspendinglistmodal.dart';
import '../../localdatamodel/Localpwssourcemodal.dart';
import '../../model/LocalStoragestructureofflinesavemodal.dart';
import '../../model/PWSPendingapprovalmodal.dart';
import '../../utility/Appcolor.dart';
import '../../utility/Stylefile.dart';
import '../Dashboard.dart';
import '../LoginScreen.dart';
import '../SS/ZoomImage.dart';

class Offlineentriesforstoragestructure extends StatefulWidget {
  String villageid = "";
  String villagename = "";
  String stateid = "";
  String block = "";
  String panchyat = "";
  String district = "";
  String token = "";
  String statusapproved = "";

  Offlineentriesforstoragestructure(
      {required this.villageid,
      required this.villagename,
      required this.stateid,
      required this.block,
      required this.panchyat,
      required this.district,
      required this.token,
      required this.statusapproved,
      super.key});

  @override
  State<Offlineentriesforstoragestructure> createState() =>
      _PWSPendingapprovalState();
}

class _PWSPendingapprovalState
    extends State<Offlineentriesforstoragestructure> {
  DatabaseHelperJalJeevan? databaseHelperJalJeevan;
  GetStorage box = GetStorage();
  var statusforapproveornot;
  var statusforapproveornot_message;
  var village = "";
  var message = "";
  var Headingmessage;
  var Panchayat;
  var Block;
  var district;
  var getvillageid;
  var getstateid;
  var messageres;
  var gettoken;
  var getstatusapproved;
  String bloack = "";
  var villagename;
  int successfulUploadCount = 0;
  bool _loading = false;
  bool offflinevisibility = false;
  bool onlinevisibility = true;
  List<LocalStoragestructureofflinesavemodal> localstoragestructureofflinelist =
      [];

  late LocalStoragestructureofflinesavemodal
      localStoragestructureofflinesavemodal;
  List<Result> pwspendinglistresult = [];
  var one = "";
  late Localpwspendinglistmodal localpwspendinglistmodal;
  late LocalPWSSavedData localPWSSavedData;

  Future<void> cleartable_villllagedetails() async {
    await databaseHelperJalJeevan!.cleartable_villagedetails();
  }

  @override
  void initState() {
    villagename = widget.villagename;
    getvillageid = widget.villageid;
    getstateid = widget.stateid;
    gettoken = widget.token;
    getstatusapproved = widget.statusapproved;

    databaseHelperJalJeevan = DatabaseHelperJalJeevan();

    setState(() {
      getallstoragestructurestructureofflineentry_villageidwise(context);
    });

    if (box.read("UserToken").toString() == "null") {
      Get.off(LoginScreen());
      cleartable_localmasterschemelisttable();

      Stylefile.showmessageforvalidationfalse(
          context, "Please do login your token has been expired!.");
    }

    super.initState();
  }

  Future<void> getallstoragestructurestructureofflineentry_villageidwise(
      BuildContext context) async {
    setState(() {
      _loading = true;
    });

    await databaseHelperJalJeevan
        ?.getallstoragestructurestructureofflineentry_villageidwise(
            widget.villageid)
        .then((value) {
      _loading = false;
      localstoragestructureofflinelist = value!.toList();

      bloack = widget.block.toString();
    });
  }

  double calculateWidth(String schemeName) {
    const double minWidth = 100;
    const double maxWidth = 300;

    double estimatedWidth = schemeName.length * 10.0;
    return estimatedWidth.clamp(minWidth, maxWidth);
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onVisibilityGained: () {
        setState(() {});
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(40.0),
              child: AppBar(
                titleSpacing: 0,
                backgroundColor: const Color(0xFF0D3A98),
                iconTheme: const IconThemeData(
                  color: Appcolor.white,
                ),
                title: const Text("Geo-tagged storage-structure (Offline)",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
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
            body: Stack(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('images/header_bg.png'),
                          fit: BoxFit.cover),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _loading == true
                              ? Center(
                                  child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator()),
                                ))
                              : Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.all(10),
                                  child:
                                      localstoragestructureofflinelist.length ==
                                              0
                                          ? Center(
                                              child: SizedBox(
                                                  child: Text(
                                              "No data found",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            )))
                                          : SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 30,
                                                    child: Directionality(
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      child:
                                                          ElevatedButton.icon(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor: Appcolor.orange,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                          ),
                                                        ),
                                                        label: Text(
                                                          'Upload to server',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Appcolor
                                                                  .white),
                                                        ),
                                                        onPressed: () async {
                                                          try {
                                                            final result =
                                                                await InternetAddress
                                                                    .lookup(
                                                                        'example.com');
                                                            if (result
                                                                    .isNotEmpty &&
                                                                result[0]
                                                                    .rawAddress
                                                                    .isNotEmpty) {
                                                              uploadLocalDataAndClearss(
                                                                  context,
                                                                  widget
                                                                      .villageid);
                                                            }
                                                          } on SocketException catch (_) {
                                                            Stylefile
                                                                .showmessageforvalidationfalse(
                                                                    context,
                                                                    "Unable to Connect to the Internet. Please check your network settings.");
                                                          }
                                                        },
                                                        icon: Icon(
                                                          Icons.upload,
                                                          color: Colors.white,
                                                          size: 30.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const Divider(
                                                    thickness: 1,
                                                    height: 10,
                                                    color: Appcolor.lightgrey,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Village : ${widget.villagename}',
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 16,
                                                              color: Appcolor
                                                                  .headingcolor),
                                                        )),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                bottom: 5),
                                                        child: SizedBox(
                                                            child: Text(
                                                          "District :",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Appcolor
                                                                  .black,
                                                              fontSize: 16),
                                                        )),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                bottom: 5),
                                                        child: SizedBox(
                                                            child: Text(
                                                          widget.district
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Appcolor
                                                                  .black,
                                                              fontSize: 16),
                                                        )),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                bottom: 5),
                                                        child: SizedBox(
                                                            child: Text(
                                                          "Block :",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Appcolor
                                                                  .black,
                                                              fontSize: 16),
                                                        )),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                bottom: 5),
                                                        child: SizedBox(
                                                            child: Text(
                                                          widget.block
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Appcolor
                                                                  .black,
                                                              fontSize: 16),
                                                        )),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                bottom: 5),
                                                        child: SizedBox(
                                                            child: Text(
                                                          "Panchayat :",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Appcolor
                                                                  .black,
                                                              fontSize: 16),
                                                        )),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                bottom: 5),
                                                        child: SizedBox(
                                                            child: Text(
                                                          widget.panchyat
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Appcolor
                                                                  .black,
                                                              fontSize: 16),
                                                        )),
                                                      )
                                                    ],
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                              0xFFFFFFFF)
                                                          .withOpacity(0.3),
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
                                                    child: ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            localstoragestructureofflinelist
                                                                .length,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        itemBuilder: (context,
                                                            int index) {
                                                          int counter =
                                                              index + 1;
                                                          return Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              width:
                                                                  double
                                                                      .infinity,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration: BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                          width:
                                                                              1,
                                                                          color: Appcolor
                                                                              .greenmessagecolor),
                                                                  color:
                                                                      Appcolor
                                                                          .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: InkWell(
                                                                splashColor:
                                                                    Appcolor
                                                                        .lightyello,
                                                                onTap: () {},
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          5.0),
                                                                      child: Align(
                                                                          alignment: Alignment.centerLeft,
                                                                          child: Text(
                                                                            "" +
                                                                                counter.toString() +
                                                                                ".",
                                                                            style:
                                                                                TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                          )),
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              left: 10,
                                                                              bottom: 5,
                                                                              top: 5),
                                                                          child:
                                                                              SizedBox(
                                                                            child:
                                                                                Text(
                                                                              "Scheme:",
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Appcolor.black,
                                                                                fontSize: 16,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Flexible(
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsets.only(
                                                                                left: 10,
                                                                                bottom: 5,
                                                                                top: 5),
                                                                            child:
                                                                                Text(
                                                                              maxLines: 4,
                                                                              localstoragestructureofflinelist[index].SchemeName.toString(),
                                                                              style: const TextStyle(
                                                                                fontWeight: FontWeight.w400,
                                                                                fontSize: 16,
                                                                                color: Appcolor.black,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              left: 10,
                                                                              bottom: 5,
                                                                              top: 5),
                                                                          child: SizedBox(
                                                                              child: Text(
                                                                            "Habitation : ",
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Appcolor.black,
                                                                                fontSize: 16),
                                                                          )),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 10,
                                                                              bottom: 5,
                                                                              top: 5),
                                                                          child: SizedBox(
                                                                              child: Text(
                                                                            textAlign:
                                                                                TextAlign.justify,
                                                                            maxLines:
                                                                                5,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            localstoragestructureofflinelist![index].HabitationName.toString(),
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
                                                                          padding: EdgeInsets.only(
                                                                              left: 10,
                                                                              bottom: 5,
                                                                              top: 5),
                                                                          child: SizedBox(
                                                                              child: Text(
                                                                            "Location :",
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Appcolor.black,
                                                                                fontSize: 16),
                                                                          )),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 10,
                                                                              bottom: 5,
                                                                              top: 5),
                                                                          child: SizedBox(
                                                                              width: 180,
                                                                              child: Text(
                                                                                textAlign: TextAlign.justify,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                maxLines: 10,
                                                                                localstoragestructureofflinelist![index].landmark.toString(),
                                                                                style: const TextStyle(fontWeight: FontWeight.w400, color: Appcolor.black, fontSize: 16),
                                                                              )),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              left: 10,
                                                                              bottom: 5,
                                                                              top: 5),
                                                                          child: SizedBox(
                                                                              child: Text(
                                                                            textAlign:
                                                                                TextAlign.justify,
                                                                            maxLines:
                                                                                5,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            "Capacity :",
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Appcolor.black,
                                                                                fontSize: 16),
                                                                          )),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 10,
                                                                              bottom: 5,
                                                                              top: 5),
                                                                          child: SizedBox(
                                                                              child: Text(
                                                                            textAlign:
                                                                                TextAlign.justify,
                                                                            maxLines:
                                                                                5,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            localstoragestructureofflinelist![index].Storagecapacity.toString() +
                                                                                " " +
                                                                                "Liter",
                                                                            style: const TextStyle(
                                                                                fontWeight: FontWeight.w400,
                                                                                fontSize: 16,
                                                                                color: Appcolor.black),
                                                                          )),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              left: 10,
                                                                              bottom: 5,
                                                                              top: 5),
                                                                          child: SizedBox(
                                                                              child: Text(
                                                                            "Latitude :",
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Appcolor.black,
                                                                                fontSize: 16),
                                                                          )),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 10,
                                                                              bottom: 5,
                                                                              top: 5),
                                                                          child: SizedBox(
                                                                              width: 180,
                                                                              child: Text(
                                                                                textAlign: TextAlign.justify,
                                                                                maxLines: 5,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                localstoragestructureofflinelist![index].latitude.toString(),
                                                                                style: const TextStyle(fontWeight: FontWeight.w400, color: Appcolor.black, fontSize: 16),
                                                                              )),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              left: 10,
                                                                              bottom: 5,
                                                                              top: 5),
                                                                          child: SizedBox(
                                                                              child: Text(
                                                                            "Longitude : ",
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Appcolor.black,
                                                                                fontSize: 16),
                                                                          )),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 10,
                                                                              bottom: 5,
                                                                              top: 5),
                                                                          child: SizedBox(
                                                                              width: 180,
                                                                              child: Text(
                                                                                textAlign: TextAlign.justify,
                                                                                maxLines: 5,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                localstoragestructureofflinelist![index].longitude.toString().toString(),
                                                                                style: const TextStyle(fontWeight: FontWeight.w400, color: Appcolor.black),
                                                                              )),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              left: 10,
                                                                              bottom: 5,
                                                                              top: 5),
                                                                          child: SizedBox(
                                                                              child: Text(
                                                                            "Status : ",
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Appcolor.black,
                                                                                fontSize: 16),
                                                                          )),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 10,
                                                                              bottom: 5,
                                                                              top: 5),
                                                                          child: SizedBox(
                                                                              width: 130,
                                                                              child: Text(
                                                                                maxLines: 10,
                                                                                localstoragestructureofflinelist![index].Status.toString(),
                                                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Appcolor.red),
                                                                              )),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    const Divider(
                                                                      thickness:
                                                                          1,
                                                                      height:
                                                                          10,
                                                                      color: Appcolor
                                                                          .lightgrey,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment
                                                                              .end,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: [
                                                                            SizedBox(
                                                                              height: 25,
                                                                              child: ElevatedButton.icon(
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Appcolor.lightgrey,
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                                  ),
                                                                                ),
                                                                                onPressed: () {
                                                                                  Get.to(ZoomImage(
                                                                                    imgurl: localstoragestructureofflinelist![index].photo,
                                                                                    lat: localstoragestructureofflinelist[index].latitude,
                                                                                    long: localstoragestructureofflinelist[index].longitude,
                                                                                  ));
                                                                                },
                                                                                icon: const Icon(
                                                                                  Icons.remove_red_eye_outlined,
                                                                                  size: 18,
                                                                                  color: Appcolor.white,
                                                                                ),
                                                                                label: const Text(
                                                                                  "View",
                                                                                  style: TextStyle(color: Appcolor.white, fontSize: 12, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            SizedBox(
                                                                              height: 25,
                                                                              child: ElevatedButton.icon(
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Appcolor.pink,
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                                  ),
                                                                                ),
                                                                                onPressed: () async {
                                                                                  _showAlertDialogforuntaggeoloc(localstoragestructureofflinelist[index].id.toString(), index);
                                                                                },
                                                                                icon: const Icon(
                                                                                  size: 18.0,
                                                                                  Icons.delete_outline_outlined,
                                                                                  color: Appcolor.white,
                                                                                ),
                                                                                label: const Text(
                                                                                  "Remove",
                                                                                  style: TextStyle(color: Appcolor.white, fontSize: 12, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ]),
                                                                    )
                                                                  ],
                                                                ),
                                                              ));
                                                        }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                )
                        ],
                      ),
                    )),
              ],
            )),
      ),
    );
  }

  Future<void> uploadLocalDataAndClearss(
      BuildContext context, String villageid) async {
    try {
      final List<LocalStoragestructureofflinesavemodal>? localDataList =
          await databaseHelperJalJeevan
              ?.getallstoragestructure_villagewise(villageid);
      if (localDataList!.isEmpty) {
        return;
      }
      for (final localData in localDataList) {
        final response = await Apiservice.StoragestructureSavetaggingapi(
          context,
          box.read("UserToken").toString(),
          box.read("userid").toString(),
          localData.villageId,
          localData.stateId,
          localData.schemeId,
          localData.sourceId,
          box.read("DivisionId").toString(),
          localData.habitationId,
          localData.landmark,
          localData.latitude,
          localData.longitude,
          localData.accuracy,
          localData.photo,
          localData.Storagecapacity,
          localData.Selectstoragecategory,

        ).timeout(const Duration(seconds: 30));

        if (response["Status"].toString() == "true") {
          successfulUploadCount++;
          await databaseHelperJalJeevan
              ?.truncateTableByVillageId_sssaved(localData.schemeId);
        } else {
          await databaseHelperJalJeevan
              ?.updateStatusInPendingListstoragestructure(localData.villageId,
                  localData.schemeId, 'This source is already tagged');

          Stylefile.showmessageforvalidationfalse(
              context, "This source is already tagged");
        }
      }

      if (successfulUploadCount > 0) {
        Stylefile.showmessageforvalidationtrue(context,
            "$successfulUploadCount record(s) has been uploaded successfully.");
      }

      cleartable_localmasterschemelisttable();
    } catch (e) {
      if (e is TimeoutException) {
        Stylefile.showmessageforvalidationfalse(context, """
Connection timed out. Please check your internet connection.""");
      }
    }
  }

  Future<void> cleartable_localmasterschemelisttable() async {
    await databaseHelperJalJeevan!.cleardb_localmasterschemelist();
    await databaseHelperJalJeevan!.cleartable_villagelist();
    await databaseHelperJalJeevan!.cleartable_villagedetails();
    await databaseHelperJalJeevan!.cleardb_localhabitaionlisttable();
    await databaseHelperJalJeevan!.cleardb_sourcedetailstable();

    await databaseHelperJalJeevan!.truncatetable_ssmasterdeatils();

    Apiservice.Getmasterapi(context).then((value) {
      for (int i = 0; i < value.villagelist!.length; i++) {
        var userid = value.villagelist![i]!.userId;

        var villageId = value.villagelist![i]!.villageId;
        var stateId = value.villagelist![i]!.stateId;
        var villageName = value.villagelist![i]!.VillageName;
        databaseHelperJalJeevan
            ?.insertMastervillagelistdata(Localmasterdatanodal(
                UserId: userid.toString(),
                villageId: villageId.toString(),
                StateId: stateId.toString(),
                villageName: villageName.toString()))
            .then((value) {});
      }
      databaseHelperJalJeevan!.removeDuplicateEntries();

      for (int i = 0; i < value.villageDetails!.length; i++) {
        var stateName = "";

        var districtName = value.villageDetails![i]!.districtName;
        var stateid = value.villageDetails![i]!.stateId;
        var blockName = value.villageDetails![i]!.blockName;
        var panchayatName = value.villageDetails![i]!.panchayatName;
        var stateidnew = value.villageDetails![i]!.stateId;
        var userId = value.villageDetails![i]!.userId;
        var villageIddetails = value.villageDetails![i]!.villageId;
        var villageName = value.villageDetails![i]!.villageName;
        var totalNoOfScheme = value.villageDetails![i]!.totalNoOfScheme;
        var totalNoOfWaterSource = value.villageDetails![i]!.totalNoOfWaterSource;
        var totalWsGeoTagged = value.villageDetails![i]!.totalWsGeoTagged;
        var pendingWsTotal = value.villageDetails![i]!.pendingWsTotal;
        var balanceWsTotal = value.villageDetails![i]!.balanceWsTotal;
        var totalSsGeoTagged = value.villageDetails![i]!.totalSsGeoTagged;
        var pendingApprovalSsTotal =
            value.villageDetails![i]!.pendingApprovalSsTotal;
        var totalIbRequiredGeoTagged =
            value.villageDetails![i]!.totalIbRequiredGeoTagged;
        var totalIbGeoTagged = value.villageDetails![i]!.totalIbGeoTagged;
        var pendingIbTotal = value.villageDetails![i]!.pendingIbTotal;
        var balanceIbTotal = value.villageDetails![i]!.balanceIbTotal;
        var totalOaGeoTagged = value.villageDetails![i]!.totalOaGeoTagged;
        var balanceOaTotal = value.villageDetails![i]!.balanceOaTotal;
        var totalNoOfSchoolScheme =
            value.villageDetails![i]!.totalNoOfSchoolScheme;
        var totalNoOfPwsScheme = value.villageDetails![i]!.totalNoOfPwsScheme;

        databaseHelperJalJeevan
            ?.insertMastervillagedetails(Localmasterdatamodal_VillageDetails(
          status: "0",
          stateName: stateName,
          districtName: districtName,
          blockName: blockName,
          panchayatName: panchayatName,
          stateId: stateidnew.toString(),
          userId: userId.toString(),
          villageId: villageIddetails.toString(),
          villageName: villageName,
          totalNoOfScheme: totalNoOfScheme.toString(),
          totalNoOfWaterSource: totalNoOfWaterSource.toString(),
          totalWsGeoTagged: totalWsGeoTagged.toString(),
          pendingWsTotal: pendingWsTotal.toString(),
          balanceWsTotal: balanceWsTotal.toString(),
          totalSsGeoTagged: totalSsGeoTagged.toString(),
          pendingApprovalSsTotal: pendingApprovalSsTotal.toString(),
          totalIbRequiredGeoTagged: totalIbRequiredGeoTagged.toString(),
          totalIbGeoTagged: totalIbGeoTagged.toString(),
          pendingIbTotal: pendingIbTotal.toString(),
          balanceIbTotal: balanceIbTotal.toString(),
          totalOaGeoTagged: totalOaGeoTagged.toString(),
          balanceOaTotal: balanceOaTotal.toString(),
          totalNoOfSchoolScheme: totalNoOfSchoolScheme.toString(),
          totalNoOfPwsScheme: totalNoOfPwsScheme.toString(),
        ));
      }

      for (int i = 0; i < value.schmelist!.length; i++) {
        var source_type = value.schmelist![i]!.source_type;
        var schemeidnew = value.schmelist![i]!.schemeid;
        var villageid = value.schmelist![i]!.villageId;
        var schemenamenew = value.schmelist![i]!.schemename;
        var schemenacategorynew = value.schmelist![i]!.category;
        var SourceTypeCategoryId = value.schmelist![i]!.SourceTypeCategoryId;
        var source_typeCategory = value.schmelist![i]!.source_typeCategory;
        databaseHelperJalJeevan
            ?.insertMasterSchmelist(Localmasterdatamoda_Scheme(
          source_type: source_type.toString(),    schemeid: schemeidnew.toString(),
          villageId: villageid.toString(),
          schemename: schemenamenew.toString(),
          category: schemenacategorynew.toString(),
          SourceTypeCategoryId: SourceTypeCategoryId.toString(),
          source_typeCategory: source_typeCategory.toString(),
        ));
      }

      for (int i = 0; i < value.sourcelist!.length; i++) {
        var sourceId = value.sourcelist![i]!.sourceId;
        var SchemeId = value.sourcelist![i]!.schemeId;
        var stateid = value.sourcelist![i]!.stateid;
        var Schemename = value.sourcelist![i]!.schemeName;
        var villageid = value.sourcelist![i]!.villageId;
        var sourceTypeId = value.sourcelist![i]!.sourceTypeId;
        var statename = value.sourcelist![i]!.stateName;
        var sourceTypeCategoryId = value.sourcelist![i]!.sourceTypeCategoryId;
        var habitationId = value.sourcelist![i]!.habitationId;
        var villageName = value.sourcelist![i]!.villageName;
        var existTagWaterSourceId = value.sourcelist![i]!.existTagWaterSourceId;
        var isApprovedState = value.sourcelist![i]!.isApprovedState;
        var landmark = value.sourcelist![i]!.landmark;
        var latitude = value.sourcelist![i]!.latitude;
        var longitude = value.sourcelist![i]!.longitude;
        var habitationName = value.sourcelist![i]!.habitationName;
        var location = value.sourcelist![i]!.location;
        var sourceTypeCategory = value.sourcelist![i]!.sourceTypeCategory;
        var sourceType = value.sourcelist![i]!.sourceType;
        var districtName = value.sourcelist![i]!.districtName;
        var districtId = value.sourcelist![i]!.districtId;
        var panchayatNamenew = value.sourcelist![i]!.panchayatName;
        var blocknamenew = value.sourcelist![i]!.blockName;

        databaseHelperJalJeevan
            ?.insertMasterSourcedetails(LocalSourcelistdetailsModal(
          schemeId: SchemeId.toString(),
          sourceId: sourceId.toString(),
          villageId: villageid.toString(),
          schemeName: Schemename,
          sourceTypeId: sourceTypeId.toString(),
          sourceTypeCategoryId: sourceTypeCategoryId.toString(),
          habitationId: habitationId.toString(),
          existTagWaterSourceId: existTagWaterSourceId.toString(),
          isApprovedState: isApprovedState.toString(),
          landmark: landmark,
          latitude: latitude.toString(),
          longitude: longitude.toString(),
          habitationName: habitationName,
          location: location,
          sourceTypeCategory: sourceTypeCategory,
          sourceType: sourceType,
          stateName: statename,
          districtName: districtName,
          blockName: blocknamenew,
          panchayatName: panchayatNamenew,
          districtId: districtId.toString(),
          villageName: villageName,
          stateId: stateid.toString(),
        ));
      }

      for (int i = 0; i < value.habitationlist!.length; i++) {
        var villafgeid = value.habitationlist![i]!.villageId;
        var habitationId = value.habitationlist![i]!.habitationId;
        var habitationName = value.habitationlist![i]!.habitationName;

        databaseHelperJalJeevan?.insertMasterhabitaionlist(
            LocalHabitaionlistModal(
                villageId: villafgeid.toString(),
                HabitationId: habitationId.toString(),
                HabitationName: habitationName.toString()));
      }
      for (int i = 0; i < value.informationBoardList!.length; i++) {
        databaseHelperJalJeevan?.insertmastersibdetails(
            LocalmasterInformationBoardItemModal(
                userId: value.informationBoardList![i]!.userId.toString(),
                villageId: value.informationBoardList![i]!.villageId.toString(),
                stateId: value.informationBoardList![i]!.stateId.toString(),
                schemeId: value.informationBoardList![i]!.schemeId.toString(),
                districtName: value.informationBoardList![i]!.districtName,
                blockName: value.informationBoardList![i]!.blockName,
                panchayatName: value.informationBoardList![i]!.panchayatName,
                villageName: value.informationBoardList![i]!.villageName,
                habitationName: value.informationBoardList![i]!.habitationName,
                latitude: value.informationBoardList![i]!.latitude.toString(),
                longitude: value.informationBoardList![i]!.longitude.toString(),
                sourceName: value.informationBoardList![i]!.sourceName,
                schemeName: value.informationBoardList![i]!.schemeName,
                message: value.informationBoardList![i]!.message,
                status: value.informationBoardList![i]!.status.toString()));
      }
    });
    Get.back();
    setState(() {});
  }

  Future<void> _showAlertDialogforuntaggeoloc(id, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Appcolor.white,
          titlePadding: EdgeInsets.only(top: 0, left: 0, right: 00),
          buttonPadding: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                5.0,
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          title: Container(
            color: Appcolor.red,
            child: Padding(
              padding: EdgeInsets.only(left: 30, top: 5, bottom: 5),
              child: const Text(
                'Alert! ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Appcolor.white),
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    "Are you sure you want to remove it?",
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
                border: Border.all(
                  color: Appcolor.red,
                  width: 1,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(
                    30.0,
                  ),
                ),
              ),
              child: TextButton(
                child: const Text(
                  'No',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Appcolor.red),
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
                border: Border.all(
                  color: Appcolor.red,
                  width: 1,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(
                    30.0,
                  ),
                ),
              ),
              child: TextButton(
                child: const Text(
                  'Yes',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Appcolor.red),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();

                  await databaseHelperJalJeevan!.clearRowByIdss(id);
                  Stylefile.showmessageforvalidationtrue(context, "Removed");
                  setState(() {
                    localstoragestructureofflinelist.removeAt(index);
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
