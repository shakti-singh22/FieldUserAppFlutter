import 'dart:convert';
import 'dart:io';

import 'package:fielduserappnew/addfhtc/village_detials.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;
import '../apiservice/Apiservice.dart';
import '../database/DataBaseHelperJalJeevan.dart';
import '../localdatamodel/Villagelistdatalocaldata.dart';
import '../model/Villagelistforsend.dart';
import '../utility/Appcolor.dart';
import '../utility/InternetAllow.dart';
import '../utility/Stylefile.dart';
import '../view/LoginScreen.dart';

class FHTCAssignedVillage extends StatefulWidget {
  var userid;
  var usertoken;
  var stateid;

  FHTCAssignedVillage(
      {required this.userid,
      required this.usertoken,
      required this.stateid,
      Key? key})
      : super(key: key);

  @override
  State<FHTCAssignedVillage> createState() => _AssignedVillageState();
}

class _AssignedVillageState extends State<FHTCAssignedVillage> {
  List<dynamic> ListResponse = [];
  GetStorage box = GetStorage();
  TextEditingController searchController = TextEditingController();
  String searchString = "";
  String gettotalvillage = "";
  String PanchayatName = "";
  String OfflineStatus = "";
  String BlockName = "";
  String DistrictName = "";
  late Future<List<Villagelistlocaldata>> villagelistlocal;
  List<Villagelistforsend> listofvill = [];
  String sss = "";
  List list = [];
  DatabaseHelperJalJeevan? databaseHelperJalJeevan;
  var VillageId;
  var VillageName;
  bool checkedValue = false;
  String checkedboxvalueselet = "";
  List<bool> isCheckedList = [];
  var message;
  bool loader = false;

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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    setState(() {
      sss.isEmpty;
    });
  }

  Future getvillagelist() async {
    setState(() {
      loader = true;
    });
    var url = "${'${Apiservice.baseurl}'
            "JJM_Mobile/GetAssignedVillages?StateId=" + box.read("stateid")}&UserId=" +
        box.read("userid");
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'APIKey': box.read("UserToken")
      },
    );
    setState(() {
      loader = false;
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> mResposne = jsonDecode(response.body);
      message = mResposne["Message"];

      if (mResposne["Message"] == "Village list") {
        List<dynamic> data = mResposne["Villagelist_Datas"];
        listofvill.clear();
        for (int i = 0; i < data.length; i++) {
          var VillageId = data[i]["VillageId"].toString();
          var VillageName = data[i]["VillageName"].toString();
          OfflineStatus = data[i]["OfflineStatus"].toString();
          PanchayatName = data[i]["PanchayatName"].toString();
          BlockName = data[i]["BlockName"].toString();
          DistrictName = data[i]["DistrictName"].toString();

          listofvill.add(Villagelistforsend(VillageName, VillageId,
              OfflineStatus, PanchayatName, BlockName, DistrictName));

          if (listofvill[i].OfflineStatus == '1') {
            listofvill[i].isChecked = true;

            listofvill[i].villageid.toString();
          } else {
            listofvill[i].isChecked = false;
          }
        }
      } else if (mResposne["Message"] == "Record not found") {
        Stylefile.showmessageforvalidationfalse(context, mResposne["Message"]);
      } else {
        if (mResposne["Status"].toString() == "false") {
          Get.offAll(LoginScreen());
          box.remove("UserToken");
          cleartable_localmasterschemelisttable();
          Stylefile.showmessageforvalidationfalse(
              context, "Please login, your token has been expired!");
        }
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    databaseHelperJalJeevan = DatabaseHelperJalJeevan();

    if (box.read("UserToken").toString() == "null") {
      Get.offAll( LoginScreen());
      cleartable_localmasterschemelisttable();
      Stylefile.showmessageforvalidationfalse(
          context, "Please login, your token has been expired!");
    } else {
      setState(() {
        Apicallforvilages();
      });
    }

    /* Apiservice.fetchData(
        context, widget.userid, widget.stateid, "194431", widget.usertoken);*/
  }

  Apicallforvilages() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        getvillagelist();
        FocusScope.of(context).unfocus();
      }
    } on SocketException catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // Filter the list based on the search string
    List filteredList = listofvill.where((village) {
      return village.villagename
          .toLowerCase()
          .contains(searchString.toUpperCase().toLowerCase().toString());
    }).toList();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0), //
        child: AppBar(
          backgroundColor: const Color(0xFF0D3A98),
          iconTheme: const IconThemeData(
            color: Appcolor.white,
          ),
          title: const Text("FHTC Assigned Village",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          actions: const <Widget>[],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Visibility(
                      visible: Provider.of<InternetConnectionStatus>(context) ==
                          InternetConnectionStatus.disconnected,
                      child:
                           SizedBox(height: 40, child: InternetAllow())),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('images/header_bg.png'),
                          fit: BoxFit.cover),
                    ),
                    child: loader == true
                        ? const Center(
                            child: SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator()))
                        : SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              'images/bharat.png',
                                              width: 60,
                                              height: 60,
                                            ),
                                            const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Jal Jeevan Mission',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () {
                                            showDialog<void>(
                                              context: context,
                                              barrierDismissible: true,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                      Appcolor.white,
                                                  titlePadding:
                                                      const EdgeInsets.only(
                                                          top: 0,
                                                          left: 0,
                                                          right: 00),
                                                  buttonPadding:
                                                      const EdgeInsets.all(10),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
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
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          "Jal jeevan mission",
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Appcolor
                                                                  .white),
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
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Text(
                                                            "Are you sure want to sign out from this application ?",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Appcolor
                                                                    .black),
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
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: TextButton(
                                                        child: const Text(
                                                          'No',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Appcolor
                                                                  .black),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
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
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: TextButton(
                                                        child: const Text(
                                                          'Yes',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Appcolor
                                                                  .black),
                                                        ),
                                                        onPressed: () async {
                                                          box.remove(
                                                              "UserToken");
                                                          box.remove(
                                                              'loginBool');
                                                          cleartable_localmasterschemelisttable();
                                                          Get.offAll(
                                                               LoginScreen());
                                                          Stylefile
                                                              .showmessageapisuccess(
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
                                            borderRadius:
                                                BorderRadius.circular(20.0),
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
                                    height: 30,
                                  ),
                                  Container(
                                    height: 40,
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF0B2E7C),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Geo-tag water assets',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: TextField(
                                      autofocus: false,
                                      controller: searchController,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Appcolor.black,
                                          fontWeight: FontWeight.bold),
                                      onChanged: (value) {
                                        setState(() {
                                          searchString = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        suffixIcon: const Icon(
                                          Icons.search,
                                          color: Appcolor.bgcolor,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: 'Search Villages...',
                                        contentPadding: const EdgeInsets.only(
                                            left: 14.0, bottom: 8.0, top: 8.0),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Appcolor.btncolor,
                                              width: 3),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Provider.of<InternetConnectionStatus>(
                                              context) ==
                                          InternetConnectionStatus.disconnected
                                      ?  InternetAllowwithimage()
                                      : Container(
                                          color: Appcolor.white,
                                          margin: const EdgeInsets.all(10),
                                          child: Material(
                                            child: InkWell(
                                              onTap: () {},
                                              child: Column(
                                               children: [
                                                  message == "Record not found"
                                                      ? const SizedBox(
                                                          child: Center(
                                                              child: Text(
                                                          "Record not found",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )))
                                                      : loader == true
                                                          ? const CircularProgressIndicator()
                                                          : filteredList.isEmpty
                                                              ? Center(
                                                                  child:
                                                                      Container(
                                                                    color: Appcolor
                                                                        .white,
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height /
                                                                        2,
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        const SizedBox(
                                                                          height:
                                                                              20,
                                                                        ),
                                                                        Image.asset(
                                                                            "images/noresult.gif"),
                                                                        const SizedBox(
                                                                          height:
                                                                              50,
                                                                        ),
                                                                        const Padding(
                                                                          padding:
                                                                              EdgeInsets.all(8.0),
                                                                          child:
                                                                              Text(
                                                                            'No result found for the village\nplease check spelling and try again.',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  child: Column(
                                                                    children: [
                                                                      const Align(
                                                                          alignment: Alignment
                                                                              .centerLeft,
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsets.only(
                                                                                left: 10,
                                                                                right: 10,
                                                                                bottom: 5,
                                                                                top: 10),
                                                                            child:
                                                                                Text(
                                                                              'Village List',
                                                                              style: TextStyle(fontWeight: FontWeight.w500, color: Appcolor.btncolor, fontSize: 18),
                                                                            ),
                                                                          )),
                                                                      const Align(
                                                                          alignment: Alignment
                                                                              .centerLeft,
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsets.only(
                                                                                left: 10,
                                                                                right: 10,
                                                                                bottom: 5,
                                                                                top: 0),
                                                                            child:
                                                                                Text(
                                                                              'Select village for FHTC',
                                                                              style: TextStyle(fontWeight: FontWeight.w500, color: Appcolor.grey, fontSize: 12),
                                                                            ),
                                                                          )),
                                                                      const Divider(
                                                                        thickness:
                                                                            1,
                                                                        height:
                                                                            10,
                                                                        color: Appcolor
                                                                            .lightgrey,
                                                                      ),
                                                                      ListView
                                                                          .builder(
                                                                        physics:
                                                                            const NeverScrollableScrollPhysics(),
                                                                        itemCount:
                                                                            listofvill.length,
                                                                        shrinkWrap:
                                                                            true,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          return listofvill[index].villagename.toString().toUpperCase().toLowerCase().contains(searchString.toLowerCase().toString())
                                                                              ? Container(
                                                                                  padding: const EdgeInsets.all(5),
                                                                                  child: Material(
                                                                                    elevation: 2.0,
                                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                                    child: InkWell(
                                                                                      splashColor: Appcolor.splashcolor,
                                                                                      customBorder: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(10.0),
                                                                                      ),
                                                                                      onTap: () {
                                                                                        Navigator.push(
                                                                                            context,
                                                                                            MaterialPageRoute(
                                                                                                builder: (context) => Village_details(
                                                                                                      villageid: listofvill[index].villageid.toString(),
                                                                                                      villagenamesend: listofvill[index].villagename.toString(),
                                                                                                    )));
                                                                                      },
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: <Widget>[
                                                                                          Container(
                                                                                            margin: const EdgeInsets.all(10),
                                                                                            child: Column(
                                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    const Padding(
                                                                                                      padding: EdgeInsets.all(2.0),
                                                                                                      child: Text(
                                                                                                        "Village:",
                                                                                                        style: TextStyle(fontWeight: FontWeight.w500, color: Appcolor.grey, fontSize: 14),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.all(2.0),
                                                                                                      child: Text(
                                                                                                        maxLines: 4,
                                                                                                        listofvill[index].villagename.toString(),
                                                                                                        // "listofvill[index].villagename.toString() listofvill[index].villagename.toString()",
                                                                                                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                                Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    const Padding(
                                                                                                      padding: EdgeInsets.all(2.0),
                                                                                                      child: Text(
                                                                                                        "(Block :",
                                                                                                        style: TextStyle(fontWeight: FontWeight.bold, color: Appcolor.grey, fontSize: 14),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.all(2.0),
                                                                                                      child: Text(
                                                                                                        listofvill[index].BlockName.toString(),
                                                                                                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                                                                                      ),
                                                                                                    ),
                                                                                                    const SizedBox(
                                                                                                      width: 10,
                                                                                                    ),
                                                                                                    const Padding(
                                                                                                      padding: EdgeInsets.all(2.0),
                                                                                                      child: Text(
                                                                                                        ", GP :",
                                                                                                        style: TextStyle(fontWeight: FontWeight.bold, color: Appcolor.grey, fontSize: 14),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Padding(
                                                                                                      padding: const EdgeInsets.all(2.0),
                                                                                                      child: Text(
                                                                                                        "${listofvill[index].PanchayatName})",
                                                                                                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          IconButton(
                                                                                            color: Colors.black,
                                                                                            onPressed: () {
                                                                                              Navigator.push(
                                                                                                  context,
                                                                                                  MaterialPageRoute(
                                                                                                      builder: (context) => Village_details(
                                                                                                            villageid: listofvill[index].villageid.toString(),
                                                                                                            villagenamesend: listofvill[index].villagename.toString(),
                                                                                                          )));
                                                                                            },
                                                                                            icon: const Icon(
                                                                                              Icons.double_arrow_outlined,
                                                                                              size: 20,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : const SizedBox();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                  const SizedBox(
                                                    height: 20,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                  const SizedBox(
                                    height: 40,
                                  )
                                ],
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
    );
  }
}
