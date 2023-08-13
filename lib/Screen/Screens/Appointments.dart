import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../api/Retrofit_Api.dart';
import '../../api/base_model.dart';
import '../../api/network_api.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_asset.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import '../../model/appointments_model.dart';
import '../../model/common_response.dart';
import '../../model/detail_setting_model.dart';
import '../MedicineAndPharmacy/Myprescription.dart';


class AppointmentsUi extends StatefulWidget {
  const AppointmentsUi({Key? key}) : super(key: key);

  @override
  State<AppointmentsUi> createState() => AppointmentsState();
}

class AppointmentsState extends State<AppointmentsUi> with SingleTickerProviderStateMixin {

  List<String> upcoming = [
    AppAssets.doctor3,
    AppAssets.doctor1,
    AppAssets.doctor2,
  ];

  List title = [
    "Dr Albert Flores",
    "Dr Gourav Solanaki",
    "Dr Kathryn Murphy",
  ];

  List subtitle = [
    "Cosmetologist",
    "Endocrinology",
    "Cosmetologist",
  ];
  bool loading = false;

  List<UpcomingAppointment> upcomingAppointment = [];
  List<PastAppointment> pastAppointment = [];
  List<PendingAppointment> pendingAppointment = [];

  List<String> cancelReason = [];
  String reason = "";

  int? id = 0;
  int value = 0;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    callApiAppointment();
    callApiSetting();
    _tabController = TabController(length: 3, vsync: this);
  }
  late double width;
  late double height;
  @override
  Widget build(BuildContext context) {

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          toolbarHeight: 70,
          titleSpacing: -2,
          leading: InkWell(
              onTap: () {
               Navigator.of(context).pop();
              },
              child:
                  const Icon(Icons.arrow_back_outlined, color: Colors.black)),
          title: const Text("Appointments",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _tabSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabSection(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 52,
            width: 335,
            decoration: BoxDecoration(
                color: const Color(0xffEEEEFF),
                borderRadius: BorderRadius.circular(16)),
            child: TabBar(
                controller: _tabController,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                unselectedLabelColor: const Color(0xff8E90C7),
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white),
                tabs:  [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(getTranslated(context, appointment_title_tab1).toString(),
                          style: TextStyle(
                            color: Color(0xff8E90C7),
                          )),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(getTranslated(context, appointment_title_tab2).toString(),
                          style: TextStyle(
                            color: Color(0xff8E90C7),
                          )),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(getTranslated(context, appointment_title_tab3).toString(),
                          style: TextStyle(
                            color: Color(0xff8E90C7),
                          )),
                    ),
                  ),
                ]),
          ),
          SizedBox(
            height: 850,
            child: TabBarView(
              controller: _tabController,
              children: [

                /*Column(
                  children: List.generate(
                      3,
                      (index) => Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: Container(
                                height: 254,
                                width: 335,
                                decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                          offset: Offset(8, 6)),
                                    ],
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                            ),
                                            child: CircleAvatar(
                                              maxRadius: 35,
                                              backgroundImage:
                                                  AssetImage(upcoming[index]),
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, bottom: 5),
                                                child: Text(title[index],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                        fontSize: 18)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Text(subtitle[index],
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(Icons.star,
                                                        color:
                                                            Color(0xff36C8FF),
                                                        size: 20),
                                                    Text("4.8",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Divider(
                                          color: Colors.grey,
                                          endIndent: 20,
                                          indent: 20),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.calendar_month_sharp,
                                            color: Colors.grey, size: 20),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("10 Dec 2022",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                                fontSize: 12)),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Icon(Icons.access_time,
                                            color: Colors.grey, size: 20),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("10:30 AM",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                                fontSize: 12)),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Icon(Icons.circle,
                                            color: Colors.green, size: 20),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("Confirmed",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                                fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 140,
                                          height: 44,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: const Color(0xff1C208F),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: const Center(
                                            child: Text("Cancel",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12)),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            // Get.to(const VideoCall(),transition: Transition.rightToLeft);
                                          },
                                          child: Container(
                                            width: 140,
                                            height: 44,
                                            decoration: BoxDecoration(
                                                color: const Color(0xff1C208F),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: const Center(
                                              child: Text("Reschedule",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                          )),
                ),*/
                // first tab pending
                pendingAppointment.length != 0
                    ? RefreshIndicator(
                  onRefresh: callApiAppointment,
                  child: Container(
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: pendingAppointment.length,
                      itemBuilder: (context, index) {
                        var statusColor = Palette.green;
                        if (pendingAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, appointment_pending).toString()) {
                          statusColor = Palette.dark_blue.withOpacity(0.6);
                        } else if (pendingAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, appointment_cancel).toString()) {
                          statusColor = Palette.red;
                        } else if (pendingAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, appointment_approve).toString()) {
                          statusColor = Palette.green;
                        }
                        return pendingAppointment.length != 0
                            ?
                        /*Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              child: Container(
                                width: width * 1,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  elevation: 2,
                                  color: Palette.white,
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: width * 0.02, left: width * 0.03, right: width * 0.03),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: Text(
                                                    getTranslated(context, appointment_bookingID).toString(),
                                                    style: TextStyle(fontSize: width * 0.035, color: Palette.blue, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                Text(
                                                  pendingAppointment[index].appointmentId!,
                                                  style: TextStyle(fontSize: width * 0.035, color: Palette.black, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              child: Text(
                                                pendingAppointment[index].appointmentStatus!.toUpperCase(),
                                                style: TextStyle(fontSize: width * 0.035, color: statusColor, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: width * 0.02,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: width * 0.15,
                                              margin: EdgeInsets.only(left: width * 0.028),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: width * 0.15,
                                                    height: height * 0.07,
                                                    decoration: new BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        new BoxShadow(
                                                          color: Palette.blue,
                                                          blurRadius: 1.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: CachedNetworkImage(
                                                      alignment: Alignment.center,
                                                      imageUrl: pendingAppointment[index].doctor!.fullImage!,
                                                      imageBuilder: (context, imageProvider) => CircleAvatar(
                                                        radius: 50,
                                                        backgroundColor: Palette.white,
                                                        child: CircleAvatar(
                                                          radius: 25,
                                                          backgroundImage: imageProvider,
                                                        ),
                                                      ),
                                                      placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                      errorWidget: (context, url, error) => ClipRRect(
                                                        borderRadius: BorderRadius.circular(30),
                                                        child: Image.asset("assets/images/no_image.jpg"),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: width * 0.6,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    alignment: AlignmentDirectional.topStart,
                                                    margin: EdgeInsets.only(
                                                      left: width * 0.02,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          pendingAppointment[index].doctor!.name!,
                                                          style: TextStyle(
                                                            fontSize: width * 0.04,
                                                            color: Palette.dark_blue,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  pendingAppointment[index].hospital != null
                                                      ? Column(
                                                    children: [
                                                      Container(
                                                        alignment: AlignmentDirectional.topStart,
                                                        margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02, top: width * 0.005),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              pendingAppointment[index].hospital!.name!,
                                                              style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                                              overflow: TextOverflow.ellipsis,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        alignment: AlignmentDirectional.topStart,
                                                        margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02, top: width * 0.005),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              pendingAppointment[index].hospital!.address!,
                                                              style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                                              overflow: TextOverflow.ellipsis,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                      : SizedBox(),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              child: Column(
                                                children: [
                                                  PopupMenuButton(
                                                    itemBuilder: (context) => [
                                                      PopupMenuItem(
                                                        child: Text(
                                                          getTranslated(context, appointment_cancelAppointment).toString(),
                                                          style: TextStyle(
                                                            fontSize: width * 0.04,
                                                            color: Palette.blue,
                                                          ),
                                                        ),
                                                        value: 1,
                                                      )
                                                    ],
                                                    onSelected: (dynamic values) {
                                                      if (values == 1) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return StatefulBuilder(
                                                              builder: (context, setState) {
                                                                return AlertDialog(
                                                                  insetPadding: EdgeInsets.all(20),
                                                                  title: Text(
                                                                    getTranslated(context, appointment_whyCancelAppointment).toString(),
                                                                  ),
                                                                  content: Container(
                                                                    height: 250,
                                                                    width: 280,
                                                                    child: ListView.builder(
                                                                      itemCount: cancelReason.length,
                                                                      itemBuilder: (context, index) {
                                                                        return RadioListTile(
                                                                          value: index,
                                                                          groupValue: value,
                                                                          onChanged: (int? reason) {
                                                                            setState(() {
                                                                              value = reason!.toInt();
                                                                            });
                                                                          },
                                                                          title: Text(cancelReason[index]),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                  actions: <Widget>[
                                                                    OutlinedButton(
                                                                      child: Text(
                                                                        getTranslated(context, bookAppointment_no).toString(),
                                                                      ),
                                                                      onPressed: () {
                                                                        setState(
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        );
                                                                      },
                                                                    ),
                                                                    OutlinedButton(
                                                                      child: Text(
                                                                        getTranslated(context, bookAppointment_yes).toString(),
                                                                      ),
                                                                      onPressed: () {
                                                                        setState(
                                                                              () {
                                                                            id = pendingAppointment[index].id;
                                                                            reason = cancelReason[value];
                                                                            Navigator.of(context).pop();
                                                                            callApiCancelAppointment();
                                                                          },
                                                                        );
                                                                      },
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      }
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: width * 0.03),
                                        child: Column(
                                          children: [
                                            Divider(
                                              height: width * 0.004,
                                              color: Palette.dark_grey,
                                              thickness: width * 0.001,
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  child: Text(
                                                    getTranslated(context, appointment_dateTime).toString(),
                                                    style: TextStyle(
                                                      fontSize: width * 0.03,
                                                      color: Palette.grey,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    getTranslated(context, appointment_patientName).toString(),
                                                    style: TextStyle(
                                                      fontSize: width * 0.03,
                                                      color: Palette.grey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  child: Text(
                                                    pendingAppointment[index].date! + '  ' + pendingAppointment[index].time!,
                                                    style: TextStyle(fontSize: width * 0.03, color: Palette.dark_blue),
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    pendingAppointment[index].patientName!,
                                                    style: TextStyle(fontSize: width * 0.03, color: Palette.dark_blue),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )*/
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Container(
                              height: 254,
                              width: 335,
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                        offset: Offset(8, 6)),
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child:
                                          Container(
                                            width: 80,
                                            height: 80,
                                            alignment: AlignmentDirectional.center,
                                            child: CachedNetworkImage(
                                              alignment: Alignment.center,
                                              imageUrl: pendingAppointment[index].doctor!.fullImage!,
                                              imageBuilder: (context, imageProvider) => Container(
                                                width: 80.0,
                                                height: 80.0,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: imageProvider, fit: BoxFit.cover),
                                                ),
                                              ),
                                              fit: BoxFit.fill,
                                              placeholder: (context, url) =>
                                                  Image(
                                                    image: AssetImage("assets/images/doctor3.png"),
                                                    //width: 50,
                                                  ),
                                              errorWidget: (context, url, error) => Image.asset("assets/images/NoImage.png"),
                                            ),
                                          ),
                                          /*CircleAvatar(
                                            maxRadius: 35,
                                            backgroundImage:
                                            AssetImage(upcoming[index]),
                                          ),*/
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, bottom: 5),
                                              child: Text(pendingAppointment[index].doctor!.name!,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      color: Colors.black,
                                                      fontSize: 18)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text(pendingAppointment[index].doctor!.treatment!.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      fontSize: 14)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5, top: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: const [
                                                  Icon(Icons.star,
                                                      color:
                                                      Color(0xff36C8FF),
                                                      size: 20),
                                                  Text("4.8",
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.w500,
                                                          fontSize: 14)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Divider(
                                        color: Colors.grey,
                                        endIndent: 20,
                                        indent: 20),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children:  [
                                      Icon(Icons.calendar_month_sharp,
                                          color: Colors.grey, size: 20),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                          //"10 Dec 2022",
                                          pendingAppointment[index].date!.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                              fontSize: 12)),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Icon(Icons.access_time,
                                          color: Colors.grey, size: 20),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                          //"10:30 AM",
                                          pendingAppointment[index].time!.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                              fontSize: 12)),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Icon(Icons.circle,
                                          color: Colors.green, size: 20),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                          pendingAppointment[index].appointmentStatus!.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                              fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 140,
                                        height: 44,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: const Color(0xff1C208F),
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(10)),
                                        child: const Center(
                                          child: Text("Cancel",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12)),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          // Get.to(const VideoCall(),transition: Transition.rightToLeft);
                                        },
                                        child: Container(
                                          width: 140,
                                          height: 44,
                                          decoration: BoxDecoration(
                                              color: const Color(0xff1C208F),
                                              borderRadius:
                                              BorderRadius.circular(10)),
                                          child: const Center(
                                            child: Text("Reschedule",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    fontSize: 12)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                        )
                            : Center(
                          child: Text(
                            getTranslated(context, appointment_appointmentNotAvailable).toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Palette.grey,
                            ),
                          ),
                        );

                      },
                    ),
                  ),
                )
                    : Container(
                  height: height * 0.9,
                  child: Center(
                    child: Text(
                      getTranslated(context, appointment_appointmentNotAvailable).toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Palette.grey,
                      ),
                    ),
                  ),
                ),
                // 2 tab upcoming app
                /*Column(
                  children: List.generate(
                      3,
                      (index) => Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: Container(
                                height: 254,
                                width: 335,
                                decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                          offset: Offset(8, 6)),
                                    ],
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                            ),
                                            child: CircleAvatar(
                                              maxRadius: 35,
                                              backgroundImage:
                                                  AssetImage(upcoming[index]),
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, bottom: 5),
                                                child: Text(title[index],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                        fontSize: 18)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Text(subtitle[index],
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(Icons.star,
                                                        color:
                                                            Color(0xff36C8FF),
                                                        size: 20),
                                                    Text("4.8",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Divider(
                                          color: Colors.grey,
                                          endIndent: 20,
                                          indent: 20),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.calendar_month_sharp,
                                            color: Colors.grey, size: 20),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("10 Dec 2022",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                                fontSize: 12)),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Icon(Icons.access_time,
                                            color: Colors.grey, size: 20),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("10:30 AM",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                                fontSize: 12)),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Icon(Icons.circle,
                                            color: Colors.green, size: 20),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("Confirmed",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                                fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 140,
                                          height: 44,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: const Color(0xff1C208F),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: const Center(
                                            child: Text("Cancel",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12)),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            // Get.to(const VideoCall(),transition: Transition.rightToLeft);
                                          },
                                          child: Container(
                                            width: 140,
                                            height: 44,
                                            decoration: BoxDecoration(
                                                color: const Color(0xff1C208F),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: const Center(
                                              child: Text("Reschedule",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                          )),
                ),*/

                upcomingAppointment.length != 0
                    ? RefreshIndicator(
                  onRefresh: callApiAppointment,
                  child: Container(
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: upcomingAppointment.length,
                      itemBuilder: (context, index) {
                        var statusColor = Palette.green;
                        if (upcomingAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, appointment_pending).toString()) {
                          statusColor = Palette.dark_blue.withOpacity(0.6);
                        } else if (upcomingAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, appointment_cancel).toString()) {
                          statusColor = Palette.red;
                        } else if (upcomingAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, appointment_approve).toString()) {
                          statusColor = Palette.green;
                        }
                        String upcomingStatus = "";
                        if (upcomingAppointment[index].appointmentStatus!.toUpperCase() == "APPROVE") {
                          upcomingStatus = "APPROVED";
                        }
                        return upcomingAppointment.length != 0
                            ?
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Container(
                              height: 254,
                              width: 335,
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                        offset: Offset(8, 6)),
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child:
                                          Container(
                                            width: 80,
                                            height: 80,
                                            alignment: AlignmentDirectional.center,
                                            child: CachedNetworkImage(
                                              alignment: Alignment.center,
                                              imageUrl: upcomingAppointment[index].doctor!.fullImage!,
                                              imageBuilder: (context, imageProvider) => Container(
                                                width: 80.0,
                                                height: 80.0,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: imageProvider, fit: BoxFit.cover),
                                                ),
                                              ),
                                              fit: BoxFit.fill,
                                              placeholder: (context, url) =>
                                                  Image(
                                                    image: AssetImage("assets/images/doctor3.png"),
                                                    //width: 50,
                                                  ),
                                              errorWidget: (context, url, error) => Image.asset("assets/images/NoImage.png"),
                                            ),
                                          ),
                                          /*CircleAvatar(
                                            maxRadius: 35,
                                            backgroundImage:
                                            AssetImage(upcoming[index]),
                                          ),*/
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, bottom: 5),
                                              child: Text(upcomingAppointment[index].doctor!.name!,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      color: Colors.black,
                                                      fontSize: 18)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text(upcomingAppointment[index].doctor!.treatment!.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      fontSize: 14)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5, top: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: const [
                                                  Icon(Icons.star,
                                                      color:
                                                      Color(0xff36C8FF),
                                                      size: 20),
                                                  Text("4.8",
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.w500,
                                                          fontSize: 14)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Divider(
                                        color: Colors.grey,
                                        endIndent: 20,
                                        indent: 20),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children:  [
                                      Icon(Icons.calendar_month_sharp,
                                          color: Colors.grey, size: 20),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        //"10 Dec 2022",
                                          upcomingAppointment[index].date!.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                              fontSize: 12)),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Icon(Icons.access_time,
                                          color: Colors.grey, size: 20),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        //"10:30 AM",
                                          upcomingAppointment[index].time!.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                              fontSize: 12)),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Icon(Icons.circle,
                                          color: Colors.green, size: 20),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                          upcomingAppointment[index].appointmentStatus!.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                              fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 140,
                                        height: 44,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: const Color(0xff1C208F),
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(10)),
                                        child: const Center(
                                          child: Text("Cancel",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12)),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          // Get.to(const VideoCall(),transition: Transition.rightToLeft);
                                        },
                                        child: Container(
                                          width: 140,
                                          height: 44,
                                          decoration: BoxDecoration(
                                              color: const Color(0xff1C208F),
                                              borderRadius:
                                              BorderRadius.circular(10)),
                                          child: const Center(
                                            child: Text("Reschedule",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    fontSize: 12)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                        )
                            : Center(
                          child: Text(
                            getTranslated(context, appointment_appointmentNotAvailable).toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Palette.dark_blue,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
                    : Container(
                  height: height * 0.9,
                  child: Center(
                    child: Text(
                      getTranslated(context, appointment_appointmentNotAvailable).toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Palette.grey,
                      ),
                    ),
                  ),
                ),

                // 3rd past
                /*Column(
                  children: List.generate(
                      3,
                          (index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Container(
                            height: 254,
                            width: 335,
                            decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                      offset: Offset(8, 6)),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 20,
                                        ),
                                        child: CircleAvatar(
                                          maxRadius: 35,
                                          backgroundImage:
                                          AssetImage(upcoming[index]),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, bottom: 5),
                                            child: Text(title[index],
                                                style: const TextStyle(
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    color: Colors.black,
                                                    fontSize: 18)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10),
                                            child: Text(subtitle[index],
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                    FontWeight.w400,
                                                    fontSize: 14)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, top: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.star,
                                                    color:
                                                    Color(0xff36C8FF),
                                                    size: 20),
                                                Text("4.8",
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        fontSize: 14)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Divider(
                                      color: Colors.grey,
                                      endIndent: 20,
                                      indent: 20),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.calendar_month_sharp,
                                        color: Colors.grey, size: 20),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("10 Dec 2022",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                            fontSize: 12)),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Icon(Icons.access_time,
                                        color: Colors.grey, size: 20),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("10:30 AM",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                            fontSize: 12)),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Icon(Icons.circle,
                                        color: Colors.green, size: 20),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("Confirmed",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                            fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 140,
                                      height: 44,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: const Color(0xff1C208F),
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                      child: const Center(
                                        child: Text("Cancel",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12)),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        // Get.to(const VideoCall(),transition: Transition.rightToLeft);
                                      },
                                      child: Container(
                                        width: 140,
                                        height: 44,
                                        decoration: BoxDecoration(
                                            color: const Color(0xff1C208F),
                                            borderRadius:
                                            BorderRadius.circular(10)),
                                        child: const Center(
                                          child: Text("Reschedule",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      )),
                ),*/

                pastAppointment.length != 0
                    ? RefreshIndicator(
                  onRefresh: callApiAppointment,
                  child: Container(
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: pastAppointment.length,
                      itemBuilder: (context, index) {
                        var statusColor = Palette.green;
                        if (pastAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, appointment_pending).toString()) {
                          statusColor = Palette.dark_blue.withOpacity(0.6);
                        } else if (pastAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, appointment_cancel).toString()) {
                          statusColor = Palette.red;
                        } else if (pastAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, appointment_approve).toString()) {
                          statusColor = Palette.green;
                        }
                        String pastStatus = "";
                        if (pastAppointment[index].appointmentStatus!.toUpperCase() == "CANCEL") {
                          pastStatus = "CANCELED";
                        } else if (pastAppointment[index].appointmentStatus!.toUpperCase() == "COMPLETE") {
                          pastStatus = "COMPLETED";
                        } else if (pastAppointment[index].appointmentStatus!.toUpperCase() == "APPROVE") {
                          pastStatus = "APPROVED";
                        } else if (pastAppointment[index].appointmentStatus!.toUpperCase() == "PENDING") {
                          pastStatus = "PENDING";
                        }
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (pastAppointment[index].appointmentStatus!.toUpperCase() == "COMPLETE") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Myprescription(
                                        doctorImage: pastAppointment[index].doctor!.fullImage,
                                        doctorName: pastAppointment[index].doctor!.name,
                                        doctorTreatmentName: pastAppointment[index].doctor!.treatment!.name,
                                        doctorAddress: pastAppointment[index].hospital!.address ?? "",
                                        appointmentDate: pastAppointment[index].date,
                                        appointmentTime: pastAppointment[index].time,
                                        patientName: pastAppointment[index].patientName,
                                        appointmentIdPrescription: pastAppointment[index].prescription == true ? pastAppointment[index].id : 0,
                                        appointmentId: pastAppointment[index].id,
                                        userRating: pastAppointment[index].rate,
                                      ),
                                    ),
                                  );
                                } else {
                                  Fluttertoast.showToast(msg: "No Detail Available");
                                }
                              },
                              child:

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Container(
                                    height: 254,
                                    width: 335,
                                    decoration: BoxDecoration(
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                              offset: Offset(8, 6)),
                                        ],
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 30),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 20,
                                                ),
                                                child:
                                                Container(
                                                  width: 80,
                                                  height: 80,
                                                  alignment: AlignmentDirectional.center,
                                                  child: CachedNetworkImage(
                                                    alignment: Alignment.center,
                                                    imageUrl: pastAppointment[index].doctor!.fullImage!,
                                                    imageBuilder: (context, imageProvider) => Container(
                                                      width: 80.0,
                                                      height: 80.0,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                            image: imageProvider, fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                    fit: BoxFit.fill,
                                                    placeholder: (context, url) =>
                                                        Image(
                                                          image: AssetImage("assets/images/doctor3.png"),
                                                          //width: 50,
                                                        ),
                                                    errorWidget: (context, url, error) => Image.asset("assets/images/NoImage.png"),
                                                  ),
                                                ),
                                                /*CircleAvatar(
                                            maxRadius: 35,
                                            backgroundImage:
                                            AssetImage(upcoming[index]),
                                          ),*/
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 10, bottom: 5),
                                                    child: Text(pastAppointment[index].doctor!.name!,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                            FontWeight.w600,
                                                            color: Colors.black,
                                                            fontSize: 18)),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 10),
                                                    child: Text(pastAppointment[index].doctor!.treatment!.toString(),
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                            FontWeight.w400,
                                                            fontSize: 14)),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 5, top: 5),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                      children: const [
                                                        Icon(Icons.star,
                                                            color:
                                                            Color(0xff36C8FF),
                                                            size: 20),
                                                        Text("4.8",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                FontWeight.w500,
                                                                fontSize: 14)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(top: 20),
                                          child: Divider(
                                              color: Colors.grey,
                                              endIndent: 20,
                                              indent: 20),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children:  [
                                            Icon(Icons.calendar_month_sharp,
                                                color: Colors.grey, size: 20),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              //"10 Dec 2022",
                                                pastAppointment[index].date!.toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Icon(Icons.access_time,
                                                color: Colors.grey, size: 20),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              //"10:30 AM",
                                                pastAppointment[index].time!.toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Icon(Icons.circle,
                                                color: Colors.green, size: 20),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                                pastAppointment[index].appointmentStatus!.toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 140,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 1,
                                                    color: const Color(0xff1C208F),
                                                  ),
                                                  borderRadius:
                                                  BorderRadius.circular(10)),
                                              child: const Center(
                                                child: Text("Cancel",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 12)),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                // Get.to(const VideoCall(),transition: Transition.rightToLeft);
                                              },
                                              child: Container(
                                                width: 140,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                    color: const Color(0xff1C208F),
                                                    borderRadius:
                                                    BorderRadius.circular(10)),
                                                child: const Center(
                                                  child: Text("Reschedule",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                          FontWeight.w600,
                                                          fontSize: 12)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                              )
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                )
                    : Container(
                  height: height * 0.9,
                  child: Center(
                    child: Text(
                      getTranslated(context, appointment_appointmentNotAvailable).toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Palette.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<BaseModel<Appointments>> callApiAppointment() async {
    Appointments response;
    setState(
          () {
        loading = true;
      },
    );
    try {
      response = (await RestClient(RetroApi().dioData()).appointmentsRequest());
      if (response.success == true) {
        setState(
              () {
            pendingAppointment.clear();
            upcomingAppointment.clear();
            pastAppointment.clear();
            loading = false;
            upcomingAppointment.addAll(response.data!.upcomingAppointment!);
            pastAppointment.addAll(response.data!.pastAppointment!);
            pendingAppointment.addAll(response.data!.pendingAppointment!);
          },
        );
      } else {
        loading = false;
      }
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommonResponse>> callApiCancelAppointment() async {
    CommonResponse response;
    Map<String, dynamic> body = {
      "appointment_id": id,
      "cancel_reason": reason,
    };
    try {
      response = await RestClient(RetroApi().dioData()).cancelAppointmentRequest(body);
      if (response.success == true) {
        setState(() {
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );

          pendingAppointment.clear();
          upcomingAppointment.clear();
          pastAppointment.clear();
          callApiAppointment();
        });
      } else {
        Fluttertoast.showToast(
          msg: '${response.msg}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<DetailSetting>> callApiSetting() async {
    DetailSetting response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).settingRequest();
      loading = false;
      if (response.success == true) {
        var convertCancelReason = json.decode(response.data!.cancelReason!);
        cancelReason.clear();
        for (int i = 0; i < convertCancelReason.length; i++) {
          cancelReason.add(convertCancelReason[i]);
        }
      }
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
