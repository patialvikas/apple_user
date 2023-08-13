import 'package:apple_user/Screen/Screens/profile_about_doctor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/Retrofit_Api.dart';
import '../../api/base_model.dart';
import '../../api/network_api.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_asset.dart';
import '../../const/app_string.dart';
import '../../const/prefConstatnt.dart';
import '../../const/preference.dart';
import '../../database/form_helper.dart';
import '../../localization/localization_constant.dart';
import '../../model/doctors_model.dart';
import '../../model/favorite_doctor_model.dart';
import '../AppointmentRelatedScreen/Bookappointment.dart';


class Searchresult extends StatefulWidget {
  const Searchresult({Key? key}) : super(key: key);

  @override
  State<Searchresult> createState() => _SearchresultState();
}

class _SearchresultState extends State<Searchresult> {

  List<String> upcoming = [
    AppAssets.doctor3,
    AppAssets.doctor1,
    AppAssets.doctor2,
  ];

  List title = [
    "Dr. Gourav Solanaki",
    "Dr. Jane Smith",
    "Dr. Marvin McKinney",
  ];
  bool loading = false;
  String? _address = "";
  String? _lat = "";
  String? _lang = "";

  List<DoctorModel> doctorList = [];

  List<bool> favoriteDoctor = [];
  List<bool> searchFavoriteDoctor = [];
  int? doctorID = 0;

  TextEditingController _search = TextEditingController();
  List<DoctorModel> _searchResult = [];

  @override
  void initState() {
    super.initState();
    //_tabController = TabController(vsync: this, length: 2);
    _getAddress();
  }
  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
          () {
        _address = (prefs.getString('Address'));
        _lat = (prefs.getString('lat'));
        _lang = (prefs.getString('lang'));
      },
    );
    callApiDoctorList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60, left: 15),
                  child: InkWell(
                    onTap: () {
                     Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back_outlined,
                      size: 25,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 60, left: 10),
                  child: Text("Search result",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 15),
              width: 335,
              height: 52,
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.words,
                textAlignVertical: TextAlignVertical.center,
                onChanged: onSearchTextChanged,
                decoration: InputDecoration(
                  suffixIcon:
                      const Icon(Icons.search, color: Color(0xff1C208F)),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xff1C208F), width: 1.0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xffD0D5DD), width: 1.0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  hintText: 'Cardiologist',
                ),
              ),
            ),
             Padding(
              padding: EdgeInsets.only(top: 20, right: 170),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                        text: doctorList.length.toString(),
                        style: TextStyle(
                          color: Color(0xff1C208F),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
                    TextSpan(
                      text: ' Available Doctors',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            _searchResult.length > 0 || _search.text.isNotEmpty
                ? _searchResult.length != 0
                ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _searchResult.length,
                itemBuilder: (BuildContext context, int index) =>
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
                                          imageUrl: _searchResult[index].fullImage!,
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
                                          child: Text(_searchResult[index].name!,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                  fontSize: 18)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(_searchResult[index].treatment!.name.toString(),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
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
                                                  color: Color(0xff36C8FF),
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
                              const SizedBox(height: 30,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Fee Starts\nfrom",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12)),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Text("\Rs. 300",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24)),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      //Get.to(const Profileabout(),transition: Transition.rightToLeft);
                                      /*Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const Profileabout()),
                                      );*/
                                      SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                          ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookAppointment(id: doctorList[index].id),
                                        ),
                                      )
                                          : FormHelper.showMessage(
                                        context,
                                        getTranslated(context, doctorDetail_appointmentBook_alert_title).toString(),
                                        getTranslated(context, doctorDetail_appointmentBook_alert_text).toString(),
                                        getTranslated(context, cancel).toString(),
                                            () {
                                          Navigator.of(context).pop();
                                        },
                                        buttonText2: getTranslated(context, login).toString(),
                                        isConfirmationDialog: true,
                                        onPressed2: () {
                                          Navigator.pushNamed(context, 'SignIn');
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 140,
                                      height: 44,
                                      decoration: BoxDecoration(
                                          color: const Color(0xff1C208F),
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                      child: const Center(
                                        child: Text("Book Now",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    )

            )
                : Container(
              alignment: AlignmentDirectional.center,
              child: Text(
                getTranslated(context, specialist_doctorNotFound).toString(),
                style: TextStyle(fontSize: 18, color: Palette.grey, fontWeight: FontWeight.bold),
              ),
            )
                :doctorList.length>0?
            ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: doctorList.length,
                  itemBuilder: (BuildContext context, int index) =>
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
                                            imageUrl: doctorList[index].fullImage!,
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
                                            child: Text(doctorList[index].name!,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                    fontSize: 18)),
                                          ),
                                           Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text(doctorList[index].treatment!.name.toString(),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,
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
                                                    color: Color(0xff36C8FF),
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
                                const SizedBox(height: 30,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Fee Starts\nfrom",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12)),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                     Text("\Rs. 300",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 24)),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        //Get.to(const Profileabout(),transition: Transition.rightToLeft);
                                        /*Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const Profileabout()),
                                        );*/
                                        SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                            ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BookAppointment(id: doctorList[index].id),
                                          ),
                                        )
                                            : FormHelper.showMessage(
                                          context,
                                          getTranslated(context, doctorDetail_appointmentBook_alert_title).toString(),
                                          getTranslated(context, doctorDetail_appointmentBook_alert_text).toString(),
                                          getTranslated(context, cancel).toString(),
                                              () {
                                            Navigator.of(context).pop();
                                          },
                                          buttonText2: getTranslated(context, login).toString(),
                                          isConfirmationDialog: true,
                                          onPressed2: () {
                                            Navigator.pushNamed(context, 'SignIn');
                                          },
                                        );
                                      },
                                      child: Container(
                                        width: 140,
                                        height: 44,
                                        decoration: BoxDecoration(
                                            color: const Color(0xff1C208F),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: const Center(
                                          child: Text("Book Now",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      )

              ):
            Container(height: 140,width:120,child: Center(child: Text("No Data Available."),),),

          ],
        ),
      ),
    );
  }


  Future<BaseModel<Doctors>> callApiDoctorList() async {
    Doctors response;
    Map<String, dynamic> body = {
      "lat": _lat,
      "lang": _lang,
    };
    setState(() {
      loading = true;
    });
    try {
      SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true ? response = await RestClient(RetroApi().dioData()).doctorList(body) : response = await RestClient(RetroApi2().dioData2()).doctorList(body);
      setState(() {
        if (response.success == true) {
          setState(() {
            doctorList.clear();
            loading = false;
            doctorList.addAll(response.data!);
          });
        }
      });
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<FavoriteDoctor>> callApiFavoriteDoctor() async {
    FavoriteDoctor response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).favoriteDoctorRequest(doctorID);
      setState(() {
        loading = false;
        if (response.success == true) {
          setState(
                () {
              Fluttertoast.showToast(
                msg: '${response.msg}',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor:Color(0xff1C208F),
                textColor: Palette.white,
              );
              doctorList.clear();
              callApiDoctorList();
            },
          );
        }
      });
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    doctorList.forEach((appointmentData) {
      if (appointmentData.name!.toLowerCase().contains(text.toLowerCase())) _searchResult.add(appointmentData);
    });

    setState(() {});
  }
}
