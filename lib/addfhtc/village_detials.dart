import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../apiservice/Apiservice.dart';
import '../utility/Appcolor.dart';
import '../utility/Stylefile.dart';
import '../view/LoginScreen.dart';
import 'VillageDetailModel.dart';
import 'jjm_facerd.dart';


class Village_details extends StatefulWidget {



String villageid="";
String villagenamesend="";

Village_details(
    {required this.villageid,required this.villagenamesend,

      Key? key})
    : super(key: key);
  @override
  _Village_details createState() => _Village_details();
}
class _Village_details extends State<Village_details> {
  String? radioButtonItem;
  String?groupValue;
  int id = 1;
  final int _selectedIndex = 0;
  String random = "";
  final formKey = GlobalKey<FormState>();
  String name = "";
  bool passwordVisible=false;

  int Geo_tagPWS =  1;
  int Geo_tagSIB =  2;
  int Geo_tagSS =  3;
  int Geo_tagOA =  4;

  bool extrafhtc = false;
  bool jjmstatus = true;

GetStorage box = GetStorage();
  late List ListResponse;

  dynamic message;
  bool? status;
  var villageName = '';
  var stateName;
  var districtName = '';
  var msg = '';
  var getvillageid = '';
  var blockName = '';
  var panchayatName = '';
  var totalhhs = 0;
  var total_provider = 0;
  var pending_approval = 0;
  var balance = 0;
  var Ishgj = 0;
  var jjm_village_status = "";
  bool _loading = false;


  Future<List<VillageDetailModel>> getVillageList() async {
    setState(() {
      _loading = true;
    });


    List<VillageDetailModel> list = [];

    try {
      var url = "${"${'${Apiservice.baseurl}'"JJM_Mobile/GetVillageStatus_FHTC?UserId="+box.read("userid")}&StateId="+box.read("stateid")}&VillageId=${widget.villageid}";
      var response = await http.get(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          "APIKey": box.read("UserToken")
        },
      );



      if (response.statusCode == 200) {

        var mapResponse = jsonDecode(response.body);
        print('response $mapResponse'); // Default message if Token is null
        setState(() {
          _loading = false;
        });

        setState(() {
          msg = mapResponse["Message"];
          villageName = mapResponse['Result']['VillageName'] ; // Default message if Token is null
          districtName = mapResponse['Result']['DistrictName']; // Default message if Token is null
          blockName = mapResponse['Result']['BlockName']; // Default message if Token is null
          panchayatName = mapResponse['Result']['PanchayatName']; // Default message if Token is null
          totalhhs = mapResponse['Result']['households']; // Default message if Token is null
          total_provider = mapResponse['Result']['FHTCProvided'];
          pending_approval = mapResponse['Result']['PendingForApprovalFHTC'];
          balance = mapResponse['Result']['BalanceFHTC'];
          Ishgj = mapResponse['Result']['IsHGJ'];
          jjm_village_status = mapResponse['Result']['JJMStatus'];

          if( Ishgj == 2 || Ishgj == 3 || Ishgj == 4)
            {
              extrafhtc = true;
              jjmstatus = false;
            }


          box.write("Ishgj", Ishgj);
        }
        );


        // Do something with mapResponse here...
        print(mapResponse);
      } else {
        print("Failed");
      }
    } catch (e) {
      print(e.toString());
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    getvillageid= widget.villageid;

  /*  if (widget.token != null) {
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

    getVillageList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/header_bg.png'), fit: BoxFit.cover),
      ),

      child: WillPopScope(
        onWillPop: () async {
          // You can do some work here.
          // Returning true allows the pop to happen, returning false prevents it.
          // Navigate back to the previous screen here
/*
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => Assigned_village(widget.userId, widget.stateid, widget.token)));
*/
          return true; // Return true to allow the pop to happen
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,

          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40.0), //
            child: AppBar(
              backgroundColor: const Color(0xFF0D3A98),
              iconTheme: const IconThemeData(
                color: Appcolor.white,
              ),
              title: const Text("Village details",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              actions: const <Widget>[

              ],
            ),
          ),

          body: Stack(
            children: [

              Form(
                key: formKey,
                child: _loading == true
                    ? const Center(
                  child: SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator()),
                ) : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 15, left: 5, right: 5, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        child: Image.asset('images/bharat.png', // Replace with your logo file path
                                          width: 60, // Adjust width and height as needed
                                          height: 60,
                                        ),
                                      ),

                                      Container(
                                        child: const Column(crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Jal Jeevan Mission', style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.bold),),
                                            Text('Department of Drinking Water and Sanitation', style: TextStyle(color: Colors.black, fontSize: 12,),),
                                            Text('Ministry of Jal Shakti',style: TextStyle(color: Colors.black, fontSize: 12),),
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
                                              //      cleartable_localmasterschemelisttable();
                                                    Get.offAll( LoginScreen());
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
                                      borderRadius: BorderRadius.circular(20.0),
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
                            const SizedBox(height: 20,),

                            const Align(
                                alignment:Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text('Geo-tag water assets',style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Appcolor.btncolor ),),
                                )),



                            Container(

                              margin: const EdgeInsets.all(5),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC2C2C2).withOpacity(0.3),
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
                              child: SizedBox(
                                  width: double.infinity,
                                  child: Container(

                                    padding: const EdgeInsets.all(7.0),
                                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Village : $villageName',style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Appcolor.headingcolor),),
                                        const SizedBox(height: 10,),
                                        SizedBox(
                                          child: Container(
                                              padding: const EdgeInsets.only(left: 10, top: 5.0, right: 5.0, bottom: 5.0),
                                              decoration: BoxDecoration(
                                                  color: Appcolor.white,

                                                  borderRadius: BorderRadius.circular(5)),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Text('District : ',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                                                      const SizedBox(width: 10,),
                                                      Text('$districtName ',style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color:Appcolor.btncolor,),),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10,),
                                                  Row(
                                                    children: [
                                                      const Text('Block : ',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                                                      const SizedBox(width: 10,),
                                                      Text(blockName,style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color:Appcolor.btncolor,),),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10,),
                                                  Row(
                                                    children: [
                                                      const Text('Panchayat : ',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                                                      const SizedBox(width: 10,),
                                                      Text('$panchayatName ',style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color:Appcolor.btncolor),),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10,),
                                                  Row(
                                                    children: [
                                                      const Text('Total HHs: ',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                                                      const SizedBox(width: 10,),
                                                      Text('$totalhhs ',style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color:Appcolor.btncolor),),
                                                    ],
                                                  ),

                                                ],
                                              )
                                          ),
                                        ),

                                        const SizedBox(height: 15,),
                                        const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: EdgeInsets.all(0.0),
                                              child: Text('Current Status of FHTC',  style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  color: Appcolor.headingcolor), ),
                                            )),
                                        const SizedBox(height: 10,),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Appcolor.white,
                                            border: Border.all(
                                              color: Appcolor.lightgrey,
                                              width: 1,
                                            ),
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(
                                                10.0,
                                              ),
                                            ),
                                          ),
                                          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 5,),
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
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 10,
                                                            top: 0),
                                                        child:
                                                        total_provider != "0"
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
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                        .size
                                                                        .width,
                                                                    padding: const EdgeInsets
                                                                        .all(
                                                                        5),
                                                                    child: const Center(
                                                                        child: Text(
                                                                          '\nTotal\nProvided',
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
                                                                        total_provider.toString(),
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
                                                                          ' Total\nProvided',
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
                                                                        total_provider
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
                                                      pending_approval
                                                          .toString() !=
                                                          "0"
                                                          ? Container(
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
                                                            right: 5,
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
                                                                            'Pending \n     for \napproval',
                                                                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
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
                                                                        child: Text(
                                                                          pending_approval.toString(),
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
                                                            right: 5,
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
                                                                          'Pending \n     for \napproval',
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
                                                                        pending_approval
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
                                                          left: 5,
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
                                                                    ' \n Balance     \n',
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
                                                            balance == "0"
                                                                ? Center(
                                                                child: Text(
                                                                  balance
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
                                                                      balance
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
                                                            right: 5,
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
                                                                            'Entries \n  to be\nuploaded',
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
                                                                        "0"
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

                                        const SizedBox(height: 20,),

                                        Visibility(
                                          visible: jjmstatus,
                                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [

                                              Container(
                                                margin: const EdgeInsets.all(5),
                                                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('JJM Status:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                                                    Text(jjm_village_status, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,color: Colors.orange),),
                                                  ],
                                                ),
                                              ),

                                              const SizedBox(height: 10,),

                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => face_auth(Ishgj,widget.villagenamesend ,  getvillageid)));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Appcolor.btncolor, // Background color
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                                  ),
                                                  elevation: 3, // Elevation (shadow)
                                                ),
                                                child: const Text('Next',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                                              ),

                                            ],
                                          ),
                                        ),

                                        Visibility(
                                          visible: extrafhtc,
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(5.0),
                                            decoration: BoxDecoration(
                                                border: Border.all(color: Colors.orange),
                                                 color: const Color(0xFFE1DEDE).withOpacity(0.3),
                                                borderRadius: BorderRadius.circular(5)),
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(msg, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),

                                                const SizedBox(height: 10,),

                                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => face_auth(Ishgj, widget.villagenamesend , getvillageid)));
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.green, // Background color
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                                        ),
                                                        elevation: 3, // Elevation (shadow)
                                                      ),
                                                      child: const Text('Yes', style: TextStyle(color: Appcolor.white , fontSize: 16)),
                                                    ),

                                                    const SizedBox(width: 15,),

                                                    ElevatedButton(
                                                      onPressed: () {

                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red, // Background color
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                                        ),
                                                        elevation: 3, // Elevation (shadow)
                                                      ),
                                                      child: const Text('No' , style: TextStyle(color: Appcolor.white , fontSize: 16),),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
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
