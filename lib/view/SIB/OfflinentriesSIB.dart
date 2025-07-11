import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get_storage/get_storage.dart';

import 'package:get/get.dart';
import '../../addfhtc/HabitationModel.dart';
import '../../apiservice/Apiservice.dart';
import '../../database/DataBaseHelperJalJeevan.dart';
import '../../localdatamodel/LocalSIBsavemodal.dart';
import '../../localdatamodel/Localmasterdatamodal.dart';
import '../../localdatamodel/Localpwspendinglistmodal.dart';
import '../../localdatamodel/Localpwssourcemodal.dart';
import '../../utility/Appcolor.dart';
import '../../utility/Stylefile.dart';
import '../Dashboard.dart';
import '../SS/ZoomImage.dart';

class OfflinentriesSIB extends StatefulWidget {
  String villageid = "";
  String villagename = "";
  String stateid = "";
  String block = "";
  String panchyat = "";
  String district = "";
  String token = "";
  String statusapproved = "";

  OfflinentriesSIB(
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
  State<OfflinentriesSIB> createState() => _PWSPendingapprovalState();
}

class _PWSPendingapprovalState extends State<OfflinentriesSIB> {
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
  List<LocalSIBsavemodal> localsibpendinglist = [];

  List<Result> pwspendinglistresult = [];
  var one = "";
  late Localpwspendinglistmodal localpwspendinglistmodal;
  late LocalPWSSavedData localPWSSavedData;

  @override
  void initState() {
    villagename = widget.villagename;
    getvillageid = widget.villageid;
    getstateid = widget.stateid;
    gettoken = widget.token;
    getstatusapproved = widget.statusapproved;

    databaseHelperJalJeevan = DatabaseHelperJalJeevan();

    setState(() {
      getsibsavedofflineentry_villageidwise(context);
    });
    super.initState();
  }

  Future<void> getsibsavedofflineentry_villageidwise(
      BuildContext context) async {
    setState(() {
      _loading = true;
    });

    await databaseHelperJalJeevan
        ?.getsibsavedofflineentry_villageidwise(widget.villageid)
        .then((value) {
      _loading = false;
      localsibpendinglist = value!.toList();
      bloack = widget.block.toString();
    });
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
              preferredSize: const Size.fromHeight(40.0),
              child: AppBar(
                titleSpacing: 0,
                backgroundColor: const Color(0xFF0D3A98),
                iconTheme: const IconThemeData(
                  color: Appcolor.white,
                ),
                title: const Text("Geo-tagged SIB (Offline Pending)",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
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
                              ? const Center(
                                  child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator()),
                                ))
                              : Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: localsibpendinglist.length == 0
                                      ? const Center(
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

                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  height: 30,
                                                  child: Directionality(
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    child: ElevatedButton.icon(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor: Appcolor.orange,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5.0),
                                                        ),
                                                      ),
                                                      label: const Text(
                                                        'Upload to server',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Appcolor.white),
                                                      ),
                                                      onPressed: () async {
                                                        try {
                                                          final result =
                                                              await InternetAddress
                                                                  .lookup(
                                                                      'example.com');
                                                          if (result.isNotEmpty &&
                                                              result[0]
                                                                  .rawAddress
                                                                  .isNotEmpty) {
                                                            uploadLocalDataAndClear(
                                                                context,
                                                                widget.villageid);
                                                          }
                                                        } on SocketException catch (_) {
                                                          Stylefile
                                                              .showmessageforvalidationfalse(
                                                                  context,
                                                                  "Unable to Connect to the Internet. Please check your network settings.");
                                                        }
                                                      },
                                                      icon: const Icon(
                                                        Icons.upload,
                                                        color: Colors.white,
                                                        size: 30.0,
                                                      ),
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
                                                    const EdgeInsets.all(8.0),
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Village : ${widget.villagename}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                    padding: EdgeInsets.only(
                                                        left: 10, bottom: 5),
                                                    child: SizedBox(
                                                        child: Text(
                                                      "District :",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Appcolor.black,
                                                          fontSize: 16),
                                                    )),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            bottom: 5),
                                                    child: SizedBox(
                                                        child: Text(
                                                      widget.district
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
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
                                                        left: 10, bottom: 5),
                                                    child: SizedBox(
                                                        child: Text(
                                                      "Block :",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Appcolor.black,
                                                          fontSize: 16),
                                                    )),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            bottom: 5),
                                                    child: SizedBox(
                                                        child: Text(
                                                      widget.block.toString(),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
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
                                                        left: 10, bottom: 5),
                                                    child: SizedBox(
                                                        child: Text(
                                                      "Panchayat :",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Appcolor.black,
                                                          fontSize: 16),
                                                    )),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            bottom: 5),
                                                    child: SizedBox(
                                                        child: Text(
                                                      widget.panchyat
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Appcolor.black,
                                                          fontSize: 16),
                                                    )),
                                                  )
                                                ],
                                              ),
                                              Container(
                                                margin: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFFFFF)
                                                      .withOpacity(0.3),
                                                  border: Border.all(
                                                    color: Colors.green,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(
                                                      10.0,
                                                    ),
                                                  ),
                                                ),
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        localsibpendinglist
                                                            .length,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (context, int index) {
                                                      int counter = index + 1;
                                                      return Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          width:
                                                              double.infinity,
                                                          alignment:
                                                              Alignment.center,
                                                        /*  decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),*/
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFFFFFFF)
                                                                .withOpacity(0.3),
                                                            border: Border.all(
                                                              color: Colors.green,
                                                              width: 1,
                                                            ),
                                                            borderRadius:
                                                            const BorderRadius.all(
                                                              Radius.circular(
                                                                10.0,
                                                              ),
                                                            ),
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          child: Material(
                                                            child: InkWell(
                                                              splashColor:
                                                                  Appcolor
                                                                      .lightyello,
                                                              onTap: () {},
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5.0),
                                                                    child: Align(
                                                                        alignment: Alignment.centerLeft,
                                                                        child: Text(
                                                                          "" +
                                                                              counter.toString() +
                                                                              ".",
                                                                          style: const TextStyle(
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold),
                                                                        )),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            bottom:
                                                                                5,
                                                                            top:
                                                                                5),
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
                                                                            left:
                                                                                10,
                                                                            bottom:
                                                                                5,
                                                                            top:
                                                                                5),
                                                                        child: SizedBox(
                                                                            width: 180,
                                                                            child: Text(
                                                                              textAlign: TextAlign.justify,
                                                                              maxLines: 5,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              localsibpendinglist![index].landmark.toString(),
                                                                              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Appcolor.black),
                                                                            )),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            bottom:
                                                                                5,
                                                                            top:
                                                                                5),
                                                                        child: SizedBox(
                                                                            child: Text(
                                                                          "Habitation :",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Appcolor.black,
                                                                              fontSize: 16),
                                                                        )),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            bottom:
                                                                                5,
                                                                            top:
                                                                                5),
                                                                        child: SizedBox(
                                                                            child: Text(
                                                                          textAlign:
                                                                              TextAlign.justify,
                                                                          maxLines:
                                                                              5,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          localsibpendinglist![index]
                                                                              .HabitationName
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: Appcolor.black),
                                                                        )),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            bottom:
                                                                                5,
                                                                            top:
                                                                                5),
                                                                        child: SizedBox(
                                                                            child: Text(
                                                                          "Latitude : ",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Appcolor.black,
                                                                              fontSize: 16),
                                                                        )),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            bottom:
                                                                                5,
                                                                            top:
                                                                                5),
                                                                        child: SizedBox(
                                                                            child: Text(
                                                                          maxLines:
                                                                              10,
                                                                          localsibpendinglist![index]
                                                                              .latitude
                                                                              .toString(),
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
                                                                            left:
                                                                                10,
                                                                            bottom:
                                                                                5,
                                                                            top:
                                                                                5),
                                                                        child: SizedBox(
                                                                            child: Text(
                                                                          "Longitude : ",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 16,
                                                                              color: Appcolor.black),
                                                                        )),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            bottom:
                                                                                5,
                                                                            top:
                                                                                5),
                                                                        child: SizedBox(
                                                                            width: 100,
                                                                            child: Text(
                                                                              maxLines: 10,
                                                                              localsibpendinglist[index].longitude.toString(),
                                                                              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Appcolor.black),
                                                                            )),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            bottom:
                                                                                5,
                                                                            top:
                                                                                5),
                                                                        child: SizedBox(
                                                                            child: Text(
                                                                          "Scheme :",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Appcolor.black,
                                                                              fontSize: 16),
                                                                        )),
                                                                      ),
                                                                      Flexible(
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 10,
                                                                              bottom: 5,
                                                                              top: 5),
                                                                          child:
                                                                              SizedBox(
                                                                            child:
                                                                                Text(
                                                                              maxLines: 5,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              localsibpendinglist[index].SchemeName.toString(),
                                                                              style: const TextStyle(fontWeight: FontWeight.w400, color: Appcolor.black, fontSize: 16),
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
                                                                            left:
                                                                                10,
                                                                            bottom:
                                                                                5,
                                                                            top:
                                                                                5),
                                                                        child: SizedBox(
                                                                            child: Text(
                                                                          "Status : ",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Appcolor.black),
                                                                        )),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            bottom:
                                                                                5,
                                                                            top:
                                                                                5),
                                                                        child: SizedBox(
                                                                            width: 130,
                                                                            child: Text(
                                                                              maxLines: 10,
                                                                              localsibpendinglist[index].Status.toString(),
                                                                              style: const TextStyle(fontWeight: FontWeight.w400, color: Appcolor.red),
                                                                            )),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  const Divider(
                                                                    thickness:
                                                                        1,
                                                                    height: 10,
                                                                    color: Appcolor
                                                                        .lightgrey,
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .end,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                25,
                                                                            child:
                                                                                ElevatedButton.icon(
                                                                              style: ElevatedButton.styleFrom(
                                                                                backgroundColor: Appcolor.lightgrey,
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                ),
                                                                              ),
                                                                              onPressed: () {
                                                                                Get.to(ZoomImage(imgurl: localsibpendinglist[index].photo, lat: localsibpendinglist[index].latitude, long: localsibpendinglist[index].longitude));
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
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                25,
                                                                            child:
                                                                                ElevatedButton.icon(
                                                                              style: ElevatedButton.styleFrom(
                                                                                backgroundColor: Appcolor.pink,
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                ),
                                                                              ),
                                                                              onPressed: () async {
                                                                                _showAlertDialogforuntaggeoloc(localsibpendinglist[index].id.toString(), index);
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

  Future<bool> showuntagedalertbox(String villageid, String stateid,
      String userid, String token, String taggedid, int index) async {
    return await showDialog(
          context: context,
          builder: (context) => Container(
            margin: const EdgeInsets.all(30),
            child: AlertDialog(
              titlePadding: const EdgeInsets.only(top: 20, left: 0, right: 5),
              contentPadding:
                  const EdgeInsets.only(top: 10, left: 0, right: 0, bottom: 20),
              insetPadding: const EdgeInsets.symmetric(horizontal: 10),
              title: const Padding(
                padding: EdgeInsets.only(left: 25, right: 20),
                child: Text(
                  'Alert!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              content: const Padding(
                padding: EdgeInsets.only(left: 25, right: 20),
                child: Text(
                  'Are you sure you want to remove ?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ),
              actions: [
                Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                side: BorderSide(color: Appcolor.btncolor)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Appcolor.btncolor),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Appcolor.btncolor,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  side: BorderSide(color: Appcolor.btncolor))),
                          onPressed: () {},
                          child: const Text('Ok',
                              style: TextStyle(color: Appcolor.white)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ) ??
        false;
  }

  Future<void> uploadLocalDataAndClear(
      BuildContext context, String villageid) async {
    try {
      final List<LocalSIBsavemodal>? localDataList =
          await databaseHelperJalJeevan
              ?.getsibsavedofflineentry_villageidwise(villageid);
      if (localDataList!.isEmpty) {
        return;
      }

      for (final localData in localDataList) {
        final response = await Apiservice.SIBSavetaggingapi(
          context,
          box.read("UserToken").toString(),
          box.read("userid").toString(),
          localData.villageId,
          localData.capturePointTypeId,
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
        ).timeout(const Duration(seconds: 30));

        if (response["Status"].toString() == "true") {
          successfulUploadCount++;
          await databaseHelperJalJeevan
              ?.truncateTableByVillageId_sibsaved(localData.schemeId);
        } else {
          await databaseHelperJalJeevan?.updateStatusInPendingListsib(
              localData.villageId,
              localData.schemeId,
              'This source is already tagged');

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
        Stylefile.showmessageforvalidationfalse(context,
            "Connection timed out. Please check your internet connection.");
      }
    }
  }
  void showAlertDialogforsuccessfulluploadcount(BuildContext context , String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Appcolor.red,
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
          content:  SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                  child: Text(
                    message.toString(),
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
                  onPressed: () {

                    cleartable_localmasterschemelisttable();


                    Navigator.pop(context);
                  },
                  child: const Text('OK',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Appcolor.black))),
            ),
          ],
        );
      },
    );
  }

  Future<void> cleartable_villllagedetails() async {
    await databaseHelperJalJeevan!.cleartable_villagedetails();
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
                  Navigator.of(context).pop();
                  await databaseHelperJalJeevan!
                      .clearRowById_sibsavetabledb(id);

                  Stylefile.showmessageforvalidationtrue(context, "Remove");

                  setState(() {
                    localsibpendinglist.removeAt(index);
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
