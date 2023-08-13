import 'dart:async';

import 'package:apple_user/Screen/AppointmentRelatedScreen/Appointment.dart';
import 'package:apple_user/Screen/Screens/profile_about_doctor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../FirebaseProviders/auth_provider.dart';
import '../../FirebaseProviders/home_provider.dart';
import '../../VideoCall/PhoneScreen.dart';
import '../../VideoCall/videocall.dart';
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
import '../../model/appointments_model.dart';
import '../../model/banner_model.dart';
import '../../model/detail_setting_model.dart';
import '../../model/display_offer_model.dart';
import '../../model/doctors_model.dart';
import '../../model/favorite_doctor_model.dart';
import '../../model/treatments_model.dart';
import '../../model/user_detail_model.dart';
import '../Doctor/TreatmentSpecialist.dart';
import '../Doctor/doctordetail.dart';
import 'Home.dart';


class Bottomone extends StatefulWidget {
  const Bottomone({Key? key}) : super(key: key);

  @override
  State<Bottomone> createState() => _BottomoneState();
}

class _BottomoneState extends State<Bottomone> {

  List<String> Exploreby = [
    "Cardiologist",
    "Eye sp",
    "Neuroscien",
  ];

  List<String> images = [
    AppAssets.Heart,
    AppAssets.eyesp,
    AppAssets.brain,
  ];

  List<String> popular = [
    AppAssets.doctor1,
    AppAssets.doctor3,
  ];

  List<String> upcoming = [
    AppAssets.doctor3,
    AppAssets.doctor1,
  ];
  List<Add> banner = [];
  // int _selectedIndex = 0;
  //
  // chanegindex(int value) {
  //   _selectedIndex = value;
  //   setState(() {});
  // }
  //
  // int _selectedIndex1 = 0;
  //
  // chanegindex1(int value) {
  //   _selectedIndex1 = value;
  //   setState(() {});
  // }
  // Search //
  List<UpcomingAppointment> upcomingAppointment = [];
  List<OfferModel> offerList = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _search = TextEditingController();
  List<DoctorModel> _searchResult = [];

  List<DoctorModel> doctorList = [];
  List<TreatmentData> treatmentList = [];
  AuthProvider? authProvider;
  List<bool> favoriteDoctor = [];
  int? doctorID = 0;
  String? _lat = "";
  String? _lang = "";bool loading = false;
  late HomeProvider homeProvider;
  late LocationData _locationData;
  Location location = new Location();
  String? name = "";
  String? email = "";
  String? phoneNo = "";
  String? image = "";
  String? _address = "";
  String userPhoneNo = "";
  String userEmail = "";
  String userName = "";
  int current = 0;
  List<String?> imgList = [];
  @override
  void initState() {
    super.initState();
    getLocation();
    callApiSetting();
    getLiveLocation();
    homeProvider = context.read<HomeProvider>();
    if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
      callApiForUserDetail();
      Future.delayed(
        const Duration(seconds: 0),
            () {
          //print("UID ${FirebaseAuth.instance.currentUser!.uid}");
          homeProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, FirebaseAuth.instance.currentUser!.uid, {'pushToken': SharedPreferenceHelper.getString(Preferences.notificationRegisterKey)!});
          print("Message TOKEN ${SharedPreferenceHelper.getString(Preferences.notificationRegisterKey)}");
        },
      );
    }
    if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
      callApiAppointment();
      Timer.periodic(Duration(minutes: 10), (Timer t) => callApiAppointment());
    }
    if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
      getOneSingleToken();
    }
    callApiBanner();
  }

  Future<void> getLocation() async {
    await Permission.location.request();
    await Permission.storage.request();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? checkLat = prefs.getString('lat');
    if (checkLat != "" && checkLat != null) {
      _getAddress();
    } else {
      _locationData = await location.getLocation();
      setState(
            () {
          prefs.setString('lat', _locationData.latitude.toString());
          prefs.setString('lang', _locationData.longitude.toString());
          print("${_locationData.latitude.toString()}  ${_locationData.longitude.toString()}");
        },
      );
      _getAddress();
    }
  }

  getLiveLocation() async {
    _locationData = await location.getLocation();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('latLive', _locationData.latitude.toString());
    prefs.setString('langLive', _locationData.longitude.toString());
    print("Live Location Lat & Long ==   ${_locationData.latitude.toString()}  ${_locationData.longitude.toString()}");
  }

  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
          () {
        _address = prefs.getString('Address');
        _lat = prefs.getString('lat');
        _lang = prefs.getString('lang');
        callApiDoctorList();
        callApiTreatment();
        callApIDisplayOffer();
      },
    );
  }

  _passDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userPhoneNo = '$phoneNo';
      userEmail = '$email';
      userName = '$name';
    });
    prefs.setString('phone_no', userPhoneNo);
    prefs.setString('email', userEmail);
    prefs.setString('name', userName);
  }

  _passIsWhere() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('isWhere', "Home");
  }

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: getTranslated(context, exit_app).toString(),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {

    authProvider = Provider.of<AuthProvider>(context);
    double width;
    double height;

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Column(
          children: [
            SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                ? DrawerHeader(
              margin: EdgeInsets.zero,
              child: Container(
                width: width * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      alignment: AlignmentDirectional.center,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Palette.dark_blue,width: 1),

                      ),
                      child: CachedNetworkImage(
                        alignment: Alignment.center,
                        imageUrl: image!,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 50,
                          backgroundColor: Palette.white,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: imageProvider,
                          ),
                        ),
                        placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                        errorWidget: (context, url, error) => ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/NoImage.png",
                            fit: BoxFit.fitHeight,
                            width: 70,
                            height: 70,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: width * 0.4,
                      height: height * 0.08,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$name',
                              style: TextStyle(
                                fontSize: 18,
                                color: Palette.dark_blue,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '$email',
                              style: TextStyle(
                                fontSize: 12,
                                color: Palette.dark_blue,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '$phoneNo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Palette.dark_blue,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, 'Profile');
                        },
                        child: SvgPicture.asset(
                          'assets/icons/edit.svg',
                          height: 20,
                          width: 20,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
                : DrawerHeader(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, 'SignIn');
                    },
                    child: Container(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.06),
                        ),
                        color: Palette.white,
                        shadowColor: Palette.grey,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Text(
                            getTranslated(context, home_signIn_button).toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.dark_blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, 'SignUp');
                    },
                    child: Container(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.06),
                        ),
                        color: Palette.white,
                        shadowColor: Palette.grey,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Text(
                            getTranslated(context, home_signUp_button).toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.dark_blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, 'Specialist');
                      },
                      title: Text(
                        getTranslated(context, home_book_appointment).toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Palette.dark_blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Column(
                        children: [
                          DottedLine(
                            direction: Axis.horizontal,
                            lineLength: double.infinity,
                            lineThickness: 1.0,
                            dashLength: 3.0,
                            dashColor: Colors.black54,
                            dashRadius: 0.0,
                            dashGapLength: 1.0,
                            dashGapColor: Palette.transparent,
                            dashGapRadius: 0.0,
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                            ? Navigator.popAndPushNamed(context, 'AppointmentUi')
                            : FormHelper.showMessage(
                          context,
                          getTranslated(context, home_medicineOrder_alert_title).toString(),
                          getTranslated(context, home_medicineOrder_alert_text).toString(),
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
                      title: Text(
                        getTranslated(context, home_appointments).toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Palette.dark_blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Column(
                        children: [
                          DottedLine(
                            direction: Axis.horizontal,
                            lineLength: double.infinity,
                            lineThickness: 1.0,
                            dashLength: 3.0,
                            dashColor: Colors.black54,
                            dashRadius: 0.0,
                            dashGapLength: 1.0,
                            dashGapColor: Palette.transparent,
                            dashGapRadius: 0.0,
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                            ? Navigator.popAndPushNamed(context, 'FavoriteDoctorScreen')
                            : FormHelper.showMessage(
                          context,
                          getTranslated(context, home_favoriteDoctor_alert_title).toString(),
                          getTranslated(context, home_favoriteDoctor_alert_text).toString(),
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
                      title: Text(
                        getTranslated(context, home_favoritesDoctor).toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Palette.dark_blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Column(
                        children: [
                          DottedLine(
                            direction: Axis.horizontal,
                            lineLength: double.infinity,
                            lineThickness: 1.0,
                            dashLength: 3.0,
                            dashColor: Colors.black54,
                            dashRadius: 0.0,
                            dashGapLength: 1.0,
                            dashGapColor: Palette.transparent,
                            dashGapRadius: 0.0,
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                            ? Navigator.popAndPushNamed(context, 'VideoCallHistory')
                            : FormHelper.showMessage(
                          context,
                          getTranslated(context, home_favoriteDoctor_alert_title).toString(),
                          getTranslated(context, home_favoriteDoctor_alert_text).toString(),
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
                      title: Text(
                        getTranslated(context, call_history).toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Palette.dark_blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Column(
                        children: [
                          DottedLine(
                            direction: Axis.horizontal,
                            lineLength: double.infinity,
                            lineThickness: 1.0,
                            dashLength: 3.0,
                            dashColor: Colors.black54,
                            dashRadius: 0.0,
                            dashGapLength: 1.0,
                            dashGapColor: Palette.transparent,
                            dashGapRadius: 0.0,
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, 'AllPharamacy');
                      },
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getTranslated(context, home_medicineBuy).toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.dark_blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, 'AddToCart');
                            },
                            icon: Icon(
                              Icons.shopping_cart_outlined,
                              color: Color(0xff1C208F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Column(
                        children: [
                          DottedLine(
                            direction: Axis.horizontal,
                            lineLength: double.infinity,
                            lineThickness: 1.0,
                            dashLength: 3.0,
                            dashColor: Colors.black54,
                            dashRadius: 0.0,
                            dashGapLength: 1.0,
                            dashGapColor: Palette.transparent,
                            dashGapRadius: 0.0,
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                            ? Navigator.popAndPushNamed(context, 'MedicineOrder')
                            : FormHelper.showMessage(
                          context,
                          getTranslated(context, home_medicineBuy_alert_title).toString(),
                          getTranslated(context, home_medicineBuy_alert_text).toString(),
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
                      title: Text(
                        getTranslated(context, home_orderHistory).toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Palette.dark_blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Column(
                        children: [
                          DottedLine(
                            direction: Axis.horizontal,
                            lineLength: double.infinity,
                            lineThickness: 1.0,
                            dashLength: 3.0,
                            dashColor: Colors.black54,
                            dashRadius: 0.0,
                            dashGapLength: 1.0,
                            dashGapColor: Palette.transparent,
                            dashGapRadius: 0.0,
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.popAndPushNamed(context, 'HealthTips');
                      },
                      title: Text(
                        getTranslated(context, home_healthTips).toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Palette.dark_blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Column(
                        children: [
                          DottedLine(
                            direction: Axis.horizontal,
                            lineLength: double.infinity,
                            lineThickness: 1.0,
                            dashLength: 3.0,
                            dashColor: Colors.black54,
                            dashRadius: 0.0,
                            dashGapLength: 1.0,
                            dashGapColor: Palette.transparent,
                            dashGapRadius: 0.0,
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.popAndPushNamed(context, 'Offer');
                      },
                      title: Text(
                        getTranslated(context, home_offers).toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Palette.dark_blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Column(
                        children: [
                          DottedLine(
                            direction: Axis.horizontal,
                            lineLength: double.infinity,
                            lineThickness: 1.0,
                            dashLength: 3.0,
                            dashColor: Colors.black54,
                            dashRadius: 0.0,
                            dashGapLength: 1.0,
                            dashGapColor: Palette.transparent,
                            dashGapRadius: 0.0,
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                            ? Navigator.popAndPushNamed(context, 'Notifications')
                            : FormHelper.showMessage(
                          context,
                          getTranslated(context, home_notification_alert_title).toString(),
                          getTranslated(context, home_notification_alert_text).toString(),
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
                      title: Text(
                        getTranslated(context, home_notification).toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Palette.dark_blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Column(
                        children: [
                          DottedLine(
                            direction: Axis.horizontal,
                            lineLength: double.infinity,
                            lineThickness: 1.0,
                            dashLength: 3.0,
                            dashColor: Colors.black54,
                            dashRadius: 0.0,
                            dashGapLength: 1.0,
                            dashGapColor: Palette.transparent,
                            dashGapRadius: 0.0,
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.popAndPushNamed(context, 'Setting');
                      },
                      title: Text(
                        getTranslated(context, home_settings).toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Palette.dark_blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Column(
                        children: [
                          DottedLine(
                            direction: Axis.horizontal,
                            lineLength: double.infinity,
                            lineThickness: 1.0,
                            dashLength: 3.0,
                            dashColor: Colors.black54,
                            dashRadius: 0.0,
                            dashGapLength: 1.0,
                            dashGapColor: Palette.transparent,
                            dashGapRadius: 0.0,
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      title: SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                          ? GestureDetector(
                        onTap: () {
                          FormHelper.showMessage(
                            context,
                            getTranslated(context, home_logout_alert_title).toString(),
                            getTranslated(context, home_logout_alert_text).toString(),
                            getTranslated(context, cancel).toString(),
                                () {
                              Navigator.of(context).pop();
                            },
                            buttonText2: getTranslated(context, home_logout_alert_title).toString(),
                            isConfirmationDialog: true,
                            onPressed2: () {
                              Preferences.checkNetwork().then((value) => value == true ? logoutUser() : print('No int'));
                            },
                          );
                        },
                        child: Text(
                          getTranslated(context, home_logout).toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Palette.dark_blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                          : Text(
                        '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Palette.dark_blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
        body: RefreshIndicator(
        onRefresh: refresh,
        child: GestureDetector(
        onTap: () {
      FocusScope.of(context).requestFocus(new FocusNode());
    },
    child:SingleChildScrollView(
            child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(top: 50, left: 10),
                      child: Text(
                        "Find your",
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5, left: 10),
                      child: Text(
                        "Specialist",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 30),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 150,
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  padding: EdgeInsets.only(right: 10, left: 10),
                  child: IconButton(
                    onPressed: () {
                      _scaffoldKey.currentState!.openDrawer();
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/menu.svg',
                      height: 15,
                      width: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 40),
          width: 335,
          height: 52,
          child: TextField(
            textCapitalization: TextCapitalization.words,
            textAlignVertical: TextAlignVertical.center,
            onChanged: onSearchTextChanged,
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.search, color: Color(0xff1C208F)),
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
              hintText: 'Search doctor...',
            ),
          ),
        ),
        //treatments
        Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: width * 0.05,
                      right: width * 0.05,
                    ),
                    alignment: AlignmentDirectional.topStart,
                    child: Row(
                      children: [
                        Text(
                          getTranslated(context, home_treatments).toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Palette.dark_blue,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'Treatment');
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: width * 0.04, left: width * 0.04),
                      child: Text("View all",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xff1C208F),
                          )),
                    ),
                  ),
                ],
              ),
            ),
            treatmentList.length != 0
                ? Container(
              height: 125,
              width: width,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  ListView.builder(
                    itemCount: 4 <= treatmentList.length ? 4 : treatmentList.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TreatmentSpecialist(
                                id: treatmentList[index].id,
                              ),
                            ),
                          );
                        },
                        child:Container(
                          height: 100,
                          width: 120,
                          margin: EdgeInsets.only(left: 5,right: 5,bottom: 10),
                          decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(5, 6))
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: /*Image(
                                      image: AssetImage(images[index]),
                                      width: 50,
                                    ),*/CachedNetworkImage(
                                      alignment: Alignment.center,
                                      imageUrl: treatmentList[index].fullImage!,
                                      fit: BoxFit.fill,
                                      placeholder: (context, url) =>Image(
                                        image: AssetImage(index%2==0?images[0]:images[1]),
                                        width: 50,
                                      ),
                                      // CircularProgressIndicator(),
                                      /*SpinKitFadingCircle(
                                        color: Palette.blue,
                                      ),*/
                                      errorWidget: (context, url, error) => Image(
                                        image: AssetImage(index%2==0?images[0]:images[1]),
                                        width: 50,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Center(
                                    child: Text( treatmentList[index].name!,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14)),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
                : Center(
              child: Container(
                height: 125,
                width: width,
                alignment: AlignmentDirectional.center,
                child: Text(
                  getTranslated(context, home_notAvailable).toString(),
                  style: TextStyle(fontSize: width * 0.05, color: Palette.grey, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        /*Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(
                  3,
                  (index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 5),
                        child:
                        GestureDetector(
                          onTap: (){
                            if(index==0){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  OldHome()),
                              );
                            }
                          },
                          child: Container(
                            height: 100,
                            width: 120,
                            decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(5, 6))
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: Image(
                                        image: AssetImage(images[index]),
                                        width: 50,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Center(
                                      child: Text(Exploreby[index],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14)),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
            ),
          ),
        ),*/
        //pop doc
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("Popular Doctor",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                )),
            const SizedBox(
              width: 110,
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'Specialist');
              },
              child: const Text("View all",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xff1C208F),
                  )),
            ),
          ],
        ),
        /*Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(
                  2,
                  (index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 5),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Profileabout()),
                            );
                          },
                          child: Container(
                              height: 120,
                              width: 280,
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(5, 6),
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          maxRadius: 30,
                                          backgroundImage:
                                              AssetImage(popular[index]),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: Text("Dr Gourav Solanaki",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14)),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: const [
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 10),
                                                  child: Text("Dermatology",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14)),
                                                ),
                                                SizedBox(
                                                  width: 70,
                                                ),
                                                Icon(
                                                  Icons.message_outlined,
                                                  size: 20,
                                                  color: Color(0xff1C208F),
                                                )
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: const [
                                                  Icon(Icons.star,
                                                      color: Color(0xff36C8FF)),
                                                  Text("4.8 (110 Reviews)",
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
                                  )
                                ],
                              )),
                        ),
                      )),
            ),
          ),
        ),*/
        Container(
          height: 150,
          width: width * 1,
          margin: EdgeInsets.symmetric(horizontal: width * 0.03),
          child: _searchResult.length > 0 || _search.text.isNotEmpty
              ? ListView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            children: [
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _searchResult.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  favoriteDoctor.clear();
                  for (int i = 0; i < _searchResult.length; i++) {
                    _searchResult[i].isFaviroute == false ? favoriteDoctor.add(false) : favoriteDoctor.add(true);
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorDetail(
                            id: _searchResult[index].id,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 150,
                      width: 280,
                      margin: EdgeInsets.only(left: 5,right:5 ,top:10 ,bottom:10 ),
                      decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(5, 6),
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child:
                         /*Column(
                          children: [
                            Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(width * 0.02),
                                      width: width * 0.35,
                                      height: height * 0.15,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        child: CachedNetworkImage(
                                          alignment: Alignment.center,
                                          imageUrl: _searchResult[index].fullImage!,
                                          fit: BoxFit.fill,
                                          placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                          errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 0,
                                      child: Container(
                                        child: SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                            ? IconButton(
                                          onPressed: () {
                                            setState(
                                                  () {
                                                favoriteDoctor[index] == false ? favoriteDoctor[index] = true : favoriteDoctor[index] = false;
                                                doctorID = _searchResult[index].id;
                                                callApiFavoriteDoctor();
                                              },
                                            );
                                          },
                                          icon: Icon(
                                            Icons.favorite_outlined,
                                            size: 25,
                                            color: favoriteDoctor[index] == false ? Palette.white : Palette.red,
                                          ),
                                        )
                                            : IconButton(
                                          onPressed: () {
                                            setState(
                                                  () {
                                                Fluttertoast.showToast(
                                                  msg: getTranslated(context, home_pleaseLogin_toast).toString(),
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor: Palette.blue,
                                                  textColor: Palette.white,
                                                );
                                              },
                                            );
                                          },
                                          icon: Icon(
                                            Icons.favorite_outlined,
                                            size: 25,
                                            color: favoriteDoctor[index] == false ? Palette.white : Palette.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              width: width * 0.4,
                              margin: EdgeInsets.only(top: width * 0.02),
                              child: Column(
                                children: [
                                  Text(
                                    _searchResult[index].name!,
                                    style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: width * 0.4,
                              child: Column(
                                children: [
                                  _searchResult[index].treatment != null
                                      ? Text(
                                    _searchResult[index].treatment!.name.toString(),
                                    style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                      : Text(
                                    getTranslated(context, home_notAvailable).toString(),
                                    style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),*/
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  maxRadius: 30,
                                  backgroundImage:
                                  AssetImage("assets/images/doctor2.png"),
                                ),
                                Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                      EdgeInsets.only(left: 10),
                                      child: Text(_searchResult[index].name!,
                                          style: TextStyle(
                                              fontWeight:
                                              FontWeight.w600,
                                              fontSize: 14)),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children:  [
                                        Padding(
                                          padding:
                                          EdgeInsets.only(left: 10),
                                          child: Text(_searchResult[index].treatment != null
                                              ?_searchResult[index].treatment!.name.toString():
                                          getTranslated(context, home_notAvailable).toString(),
                                              style: TextStyle(
                                                  fontWeight:
                                                  FontWeight.w400,
                                                  fontSize: 14)),
                                        ),
                                        SizedBox(
                                          width: 70,
                                        ),
                                        /*Icon(
                                          Icons.message_outlined,
                                          size: 20,
                                          color: Color(0xff1C208F),
                                        )*/
                                        Container(
                                          width: 24,height:24,
                                          child: SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                              ? IconButton(
                                            onPressed: () {
                                              setState(
                                                    () {
                                                  favoriteDoctor[index] == false ? favoriteDoctor[index] = true : favoriteDoctor[index] = false;
                                                  doctorID = doctorList[index].id;
                                                  callApiFavoriteDoctor();
                                                },
                                              );
                                            },
                                            icon: Icon(
                                              Icons.favorite_outlined,
                                              size: 20,
                                              color: favoriteDoctor[index] == false ? Palette.black : Palette.red,
                                            ),
                                          )
                                              : IconButton(
                                            onPressed: () {
                                              setState(
                                                    () {
                                                  Fluttertoast.showToast(
                                                    msg: getTranslated(context, home_pleaseLogin_toast).toString(),
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.BOTTOM,
                                                    backgroundColor: Palette.blue,
                                                    textColor: Palette.white,
                                                  );
                                                },
                                              );
                                            },
                                            icon: Icon(
                                              Icons.favorite_outlined,
                                              size: 20,
                                              color: favoriteDoctor[index] == false ? Palette.black : Palette.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceEvenly,
                                        children: const [
                                          Icon(Icons.star,
                                              color: Color(0xff36C8FF)),
                                          Text("4.8 (110 Reviews)",
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
                          )
                        ],
                      ),

                    ),
                  );
                },
              )
            ],
          )
              : doctorList.length > 0
              ? ListView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            children: [
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 3 <= doctorList.length ? 3 : doctorList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  favoriteDoctor.clear();
                  for (int i = 0; i < doctorList.length; i++) {
                    doctorList[i].isFaviroute == false ? favoriteDoctor.add(false) : favoriteDoctor.add(true);
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorDetail(
                            id: doctorList[index].id,
                          ),
                        ),
                      );
                    },
                    child: Container(
                        height: 150,
                        width: 280,
                      margin: EdgeInsets.only(left: 5,right:5 ,top:10 ,bottom:10 ),
                      decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(5, 6),
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                     // width: width * 0.4,

                        child: /*Column(
                          children: [
                            Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(width * 0.02),
                                      width: width * 0.35,
                                      height: height * 0.15,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        child: CachedNetworkImage(
                                          alignment: Alignment.center,
                                          imageUrl: doctorList[index].fullImage!,
                                          fit: BoxFit.fill,
                                          placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                          errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 0,
                                      child: Container(
                                        child: SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                            ? IconButton(
                                          onPressed: () {
                                            setState(
                                                  () {
                                                favoriteDoctor[index] == false ? favoriteDoctor[index] = true : favoriteDoctor[index] = false;
                                                doctorID = doctorList[index].id;
                                                callApiFavoriteDoctor();
                                              },
                                            );
                                          },
                                          icon: Icon(
                                            Icons.favorite_outlined,
                                            size: 25,
                                            color: favoriteDoctor[index] == false ? Palette.white : Palette.red,
                                          ),
                                        )
                                            : IconButton(
                                          onPressed: () {
                                            setState(
                                                  () {
                                                Fluttertoast.showToast(
                                                  msg: getTranslated(context, home_pleaseLogin_toast).toString(),
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor: Palette.blue,
                                                  textColor: Palette.white,
                                                );
                                              },
                                            );
                                          },
                                          icon: Icon(
                                            Icons.favorite_outlined,
                                            size: 25,
                                            color: favoriteDoctor[index] == false ? Palette.white : Palette.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              width: width * 0.4,
                              margin: EdgeInsets.only(top: width * 0.02),
                              child: Column(
                                children: [
                                  Text(
                                    doctorList[index].name!,
                                    style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: width * 0.4,
                              child: Column(
                                children: [
                                  doctorList[index].treatment != null
                                      ? Text(
                                    doctorList[index].treatment!.name.toString(),
                                    style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                      : Text(
                                    getTranslated(context, home_notAvailable).toString(),
                                    style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),*/
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    maxRadius: 30,
                                    backgroundImage:
                                    AssetImage("assets/images/doctor1.png"),
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                       Padding(
                                        padding:
                                        EdgeInsets.only(left: 10),
                                        child: Text(doctorList[index].name!,
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight.w600,
                                                fontSize: 14)),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children:  [
                                          Padding(
                                            padding:
                                            EdgeInsets.only(left: 10),
                                            child: Text(doctorList[index].treatment != null
                                                ?doctorList[index].treatment!.name.toString():
                                            getTranslated(context, home_notAvailable).toString(),
                                                style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.w400,
                                                    fontSize: 14)),
                                          ),
                                          SizedBox(
                                            width: 70,
                                          ),
                                          /*Icon(
                                            Icons.message_outlined,
                                            size: 20,
                                            color: Color(0xff1C208F),
                                          )*/
                                          Container(
                                            width: 24,height:24,
                                            child: SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                                ? IconButton(
                                              onPressed: () {
                                                setState(
                                                      () {
                                                    favoriteDoctor[index] == false ? favoriteDoctor[index] = true : favoriteDoctor[index] = false;
                                                    doctorID = doctorList[index].id;
                                                    callApiFavoriteDoctor();
                                                  },
                                                );
                                              },
                                              icon: Icon(
                                                Icons.favorite_outlined,
                                                size: 20,
                                                color: favoriteDoctor[index] == false ? Palette.black : Palette.red,
                                              ),
                                            )
                                                : IconButton(
                                              onPressed: () {
                                                setState(
                                                      () {
                                                    Fluttertoast.showToast(
                                                      msg: getTranslated(context, home_pleaseLogin_toast).toString(),
                                                      toastLength: Toast.LENGTH_SHORT,
                                                      gravity: ToastGravity.BOTTOM,
                                                      backgroundColor: Palette.blue,
                                                      textColor: Palette.white,
                                                    );
                                                  },
                                                );
                                              },
                                              icon: Icon(
                                                Icons.favorite_outlined,
                                                size: 20,
                                                color: favoriteDoctor[index] == false ? Palette.black : Palette.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceEvenly,
                                          children: const [
                                            Icon(Icons.star,
                                                color: Color(0xff36C8FF)),
                                            Text("4.8 (110 Reviews)",
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
                            )
                          ],
                        ),

                    ),
                  );
                },
              )
            ],
          )
              : Center(
            child: Container(
              child: Text(
                getTranslated(context, home_notAvailable).toString(),
                style: TextStyle(fontSize: width * 0.05, color: Palette.grey, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        /*Container(margin: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text("Upcoming Appointment",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    )),
              ),
            ],
          ),
        ),*/
        /*Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(
                  2,
                  (index) =>

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 5),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Appointment()),
                            );
                          },
                          child: Container(
                              height: 140,
                              width: 287,
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 10,
                                        offset: Offset(5, 6)),
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          maxRadius: 25,
                                          backgroundImage:
                                              AssetImage(upcoming[index]),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Row(
                                                children: const [
                                                  Text("Dr Tania Alam",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black,
                                                          fontSize: 14)),
                                                  SizedBox(
                                                    width: 60,
                                                  ),
                                                  Icon(
                                                    Icons.more_vert,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: Text("Cosmetologist",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 20, right: 80),
                                    width: 161,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        color: const Color(0xffEEEEFF),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.access_time, size: 18),
                                        Text(" Thu, Dec at 10:00 am",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      )
              ),
            ),
          ),
        ),*/
        upcomingAppointment.length != 0
            ? Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                  alignment: AlignmentDirectional.topStart,
                  child: Column(
                    children: [
                      Text(
                        getTranslated(context, home_upcomingAppointment).toString(),
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color: Palette.dark_blue,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, 'Appointment');
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 15, left: 20, right: 20),
                    alignment: AlignmentDirectional.topStart,
                    child: Column(
                      children: [
                        Text(
                          getTranslated(context, home_viewAll).toString(),
                          style: TextStyle(fontSize: width * 0.035, color: Palette.blue),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
                child: Stack(
                  children: <Widget>[
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 170,
                        viewportFraction: 1.0,
                        onPageChanged: (index, index1) {
                          setState(
                                () {
                              current = index;
                            },
                          );
                        },
                      ),
                      items: upcomingAppointment.map((appointmentData) {
                        var statusColor = Palette.green.withOpacity(0.5);
                        if (appointmentData.appointmentStatus!.toUpperCase() == getTranslated(context, home_pending).toString()) {
                          statusColor = Palette.dark_blue;
                        } else if (appointmentData.appointmentStatus!.toUpperCase() == getTranslated(context, home_cancel).toString()) {
                          statusColor = Palette.red;
                        } else if (appointmentData.appointmentStatus!.toUpperCase() == getTranslated(context, home_approve).toString()) {
                          statusColor = Palette.green.withOpacity(0.5);
                        }
                        return Builder(
                          builder: (BuildContext context) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 2,
                                color: Palette.white,
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 10, left: 12, right: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  getTranslated(context, home_bookingId).toString(),
                                                  style: TextStyle(fontSize: 14, color: Palette.blue, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Text(
                                                appointmentData.appointmentId!,
                                                style: TextStyle(fontSize: 14, color: Palette.black, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            child: Text(
                                              appointmentData.appointmentStatus!.toUpperCase(),
                                              style: TextStyle(fontSize: 14, color: statusColor, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 10,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: width * 0.15,
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: new BoxDecoration(shape: BoxShape.circle, boxShadow: [
                                                    new BoxShadow(
                                                      color: Palette.blue,
                                                      blurRadius: 1.0,
                                                    ),
                                                  ]),
                                                  child: CachedNetworkImage(
                                                    alignment: Alignment.center,
                                                    imageUrl: appointmentData.doctor!.fullImage!,
                                                    imageBuilder: (context, imageProvider) => CircleAvatar(
                                                      radius: 50,
                                                      backgroundColor: Palette.white,
                                                      child: CircleAvatar(
                                                        radius: 18,
                                                        backgroundImage: imageProvider,
                                                      ),
                                                    ),
                                                    placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                    errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: width * 0.75,
                                            // color: Colors.red,
                                            child: Column(
                                              children: [
                                                Container(
                                                  alignment: AlignmentDirectional.topStart,
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        appointmentData.doctor!.name!,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Palette.dark_blue,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                appointmentData.hospital != null
                                                    ? Column(
                                                  children: [
                                                    Container(
                                                      alignment: AlignmentDirectional.topStart,
                                                      margin: EdgeInsets.only(top: 3),
                                                      child: Column(
                                                        children: [Text(appointmentData.hospital!.name!, style: TextStyle(fontSize: 12, color: Palette.grey), overflow: TextOverflow.ellipsis)],
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment: AlignmentDirectional.topStart,
                                                      margin: EdgeInsets.only(top: 3),
                                                      child: Column(
                                                        children: [Text(appointmentData.hospital!.address!, style: TextStyle(fontSize: 12, color: Palette.grey), overflow: TextOverflow.ellipsis)],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                                    : SizedBox(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: Column(
                                        children: [
                                          Divider(
                                            height: 2,
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
                                                  getTranslated(context, home_dateTime).toString(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Palette.grey,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  getTranslated(context, home_patientName).toString(),
                                                  style: TextStyle(
                                                    fontSize: 12,
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
                                                  appointmentData.date! + '  ' + appointmentData.time!,
                                                  style: TextStyle(fontSize: 12, color: Palette.dark_blue),
                                                ),
                                              ),
                                              Container(
                                                child: Text(
                                                  appointmentData.patientName!,
                                                  style: TextStyle(fontSize: 12, color: Palette.dark_blue),
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
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
            : SizedBox(),

        Column (
          children: [
            Container(
              alignment: AlignmentDirectional.topStart,
              margin: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  Text(
                    getTranslated(context, home_lookingFor).toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Palette.dark_blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            //banners
            Container(
              height: 210,

              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
                child: Stack(
                  children: <Widget>[
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 200,
                        viewportFraction: 1.0,
                        autoPlay: true,
                        onPageChanged: (index, index1) {
                          setState(
                                () {
                              current = index;
                            },
                          );
                        },
                      ),
                      items: banner.map((bannerData) {
                        return Builder(
                          builder: (BuildContext context) {
                            return InkWell(
                              onTap: () async {
                                // await launch(bannerData.link!);
                                Uri _url = Uri.parse(bannerData.link!);
                                launchUrl(_url);
                              },
                              child: Container(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: CachedNetworkImage(
                                      imageUrl: bannerData.fullImage!,
                                      fit: BoxFit.fitHeight,
                                      placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                      errorWidget: (context, url, error) => Image.asset(
                                        "assets/images/no_image.jpg",
                                        width: width,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        SizedBox(
          height: 10,
        ),
        /// Offer ///
        offerList.length != 0
            ? Column(
          children: [
            Container(
              alignment: AlignmentDirectional.topStart,
              margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
              child: Column(
                children: [
                  Text(
                    getTranslated(context, home_offers).toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Palette.dark_blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              width: width * 1,
              child: ListView.builder(
                itemCount: offerList.length,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Container(
                      height: 160,
                      width: 175,
                      child: Card(
                        color: index % 2 == 0 ? Palette.light_blue.withOpacity(0.9) : Palette.offer_card.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                              child: Container(
                                height: 40,
                                margin: EdgeInsets.symmetric(vertical: 5),
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Text(
                                      offerList[index].name!,
                                      style: TextStyle(fontSize: 16, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                              child: Column(
                                children: [
                                  DottedLine(
                                    direction: Axis.horizontal,
                                    lineLength: double.infinity,
                                    lineThickness: 1.0,
                                    dashLength: 3.0,
                                    dashColor: index % 2 == 0 ? Palette.light_blue.withOpacity(0.9) : Palette.offer_card.withOpacity(0.9),
                                    dashRadius: 0.0,
                                    dashGapLength: 1.0,
                                    dashGapColor: Palette.transparent,
                                    dashGapRadius: 0.0,
                                  )
                                ],
                              ),
                            ),
                            if (offerList[index].discountType == "amount" && offerList[index].isFlat == 0)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: Text(
                                  getTranslated(context, home_flat).toString() + ' ' + SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + offerList[index].discount.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Palette.dark_blue,
                                  ),
                                ),
                              ),
                            if (offerList[index].discountType == "percentage" && offerList[index].isFlat == 0)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                // alignment: Alignment.topLeft,
                                child: Text(
                                  offerList[index].discount.toString() + getTranslated(context, home_discount).toString(),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Palette.dark_blue,
                                  ),
                                ),
                              ),
                            if (offerList[index].discountType == "amount" && offerList[index].isFlat == 1)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: Text(
                                  getTranslated(context, home_flat).toString() + SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + offerList[index].flatDiscount.toString(),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Palette.dark_blue,
                                  ),
                                ),
                              ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Palette.white, borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: SelectableText(
                                  offerList[index].offerCode!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        )
            : Container(),

      ],
    )
        ),),),
    );
  }
  Future logoutUser() async {
    setState(() {
      SharedPreferenceHelper.clearPref();
      authProvider!.handleSignOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Home()),
        ModalRoute.withName('SplashScreen'),
      );
    });
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

  Future<BaseModel<FavoriteDoctor>> callApiFavoriteDoctor() async {
    FavoriteDoctor response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).favoriteDoctorRequest(doctorID);
      setState(() {
        loading = false;
        Fluttertoast.showToast(
          msg: '${response.msg}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Palette.blue,
          textColor: Palette.white,
        );
        doctorList.clear();
        callApiDoctorList();
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
        loading = false;
        doctorList.clear();
        doctorList.addAll(response.data!.reversed);
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

  Future<BaseModel<DetailSetting>> callApiSetting() async {
    DetailSetting response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).settingRequest();
      setState(() {
        loading = false;
        if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
          if (response.data!.paypalClientId.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.paypal_Client_Id, response.data!.paypalClientId.toString());
          }
          if (response.data!.paypalSecretKey.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.paypal_Secret_key, response.data!.paypalSecretKey.toString());
          }
          if (response.data!.patientAppId! != "null") {
            SharedPreferenceHelper.setString(Preferences.patientAppId, response.data!.patientAppId!);
            // SharedPreferenceHelper.setString(Preferences.patientAppId, response.data!.doctorAppId!);
          }
          if (response.data!.currencySymbol! != "null") {
            SharedPreferenceHelper.setString(Preferences.currency_symbol, response.data!.currencySymbol!);
          }
          if (response.data!.currencyCode! != "null") {
            SharedPreferenceHelper.setString(Preferences.currency_code, response.data!.currencyCode!);
          }
          if (response.data!.cod.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.cod, response.data!.cod.toString());
          }
          if (response.data!.stripe.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.stripe, response.data!.stripe.toString());
          }
          if (response.data!.paypal.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.paypal, response.data!.paypal.toString());
          }
          if (response.data!.razor.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.razor, response.data!.razor.toString());
          }
          if (response.data!.flutterwave.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.flutterWave, response.data!.flutterwave.toString());
          }
          if (response.data!.paystack.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.payStack, response.data!.paystack.toString());
          }
          if (response.data!.stripePublicKey! != "null") {
            SharedPreferenceHelper.setString(Preferences.stripe_public_key, response.data!.stripePublicKey!);
          }
          if (response.data!.stripeSecretKey! != "null") {
            SharedPreferenceHelper.setString(Preferences.stripe_secret_key, response.data!.stripeSecretKey!);
          }
          if (response.data!.paypalSandboxKey != null) {
            SharedPreferenceHelper.setString(Preferences.paypal_sandbox_key, response.data!.paypalSandboxKey!);
          }
          if (response.data!.paypalProducationKey!=null) {
            SharedPreferenceHelper.setString(Preferences.paypal_production_key, response.data!.paypalProducationKey!);
          }
          if (response.data!.razorKey! != "null") {
            SharedPreferenceHelper.setString(Preferences.razor_key, response.data!.razorKey!);
          }
          if (response.data!.flutterwaveKey! != "null") {
            SharedPreferenceHelper.setString(Preferences.flutterWave_key, response.data!.flutterwaveKey!);
          }
          if (response.data!.flutterwaveEncryptionKey!=null) {
            SharedPreferenceHelper.setString(Preferences.flutterWave_encryption_key, response.data!.flutterwaveEncryptionKey!);
          }
          if (response.data!.paystackPublicKey! != "null") {
            SharedPreferenceHelper.setString(Preferences.payStack_public_key, response.data!.paystackPublicKey!);
          }
          if (response.data!.agoraAppId! != "null") {
            SharedPreferenceHelper.setString(Preferences.agoraAppId, response.data!.agoraAppId!);
          }
        } else {
          if (response.data!.patientAppId! != "null") {
            SharedPreferenceHelper.setString(Preferences.patientAppId, response.data!.patientAppId!);
            // SharedPreferenceHelper.setString(Preferences.patientAppId, response.data!.doctorAppId!);
          }
          if (response.data!.currencySymbol! != "null") {
            SharedPreferenceHelper.setString(Preferences.currency_symbol, response.data!.currencySymbol!);
          }
          if (response.data!.currencyCode! != "null") {
            SharedPreferenceHelper.setString(Preferences.currency_code, response.data!.currencyCode!);
          }
          if (response.data!.cod.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.cod, response.data!.cod.toString());
          }
          if (response.data!.stripe.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.stripe, response.data!.stripe.toString());
          }
          if (response.data!.paypal.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.paypal, response.data!.paypal.toString());
          }
          if (response.data!.razor.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.razor, response.data!.razor.toString());
          }
          if (response.data!.flutterwave.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.flutterWave, response.data!.flutterwave.toString());
          }
          if (response.data!.paystack.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.payStack, response.data!.paystack.toString());
          }
          if (response.data!.isLiveKey.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.isLiveKey, response.data!.isLiveKey.toString());
          }
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

  Future<BaseModel<UserDetail>> callApiForUserDetail() async {
    UserDetail response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).userDetailRequest();
      setState(() {
        loading = false;
        name = response.name;
        email = response.email;
        phoneNo = response.phone;
        image = response.fullImage;
        _passDetail();
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

  Future<BaseModel<DisplayOffer>> callApIDisplayOffer() async {
    DisplayOffer response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).displayOfferRequest();
      setState(() {
        loading = false;
        offerList.addAll(response.data!);
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

  Future<BaseModel<Appointments>> callApiAppointment() async {
    Appointments response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).appointmentsRequest();
      setState(() {
        loading = false;
        upcomingAppointment.addAll(response.data!.upcomingAppointment!);
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
  Future<BaseModel<Treatments>> callApiTreatment() async {
    Treatments response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).treatmentsRequest();
      setState(() {
        loading = false;
        if (response.success == true) {
          setState(() {
            treatmentList.addAll(response.data!);
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
  Future<void> getOneSingleToken() async {
    try {
      OneSignal.shared.setNotificationOpenedHandler((event) async {
        if (event.action!.actionId == "") {
        }
        else if (event.action!.actionId == "decline") {
          setState(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoCall(
                  doctorId: event.notification.additionalData!["id"],
                  flag: "Cut",
                ),
              ),
            );
          });
          setState(() {});
        }
        else if (event.action!.actionId == "accept") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCall(
                doctorId: event.notification.additionalData!["id"],
                flag: "InComming",
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PhoneScreen(event.notification.additionalData)),
          );
        }
      });
    } catch (e) {}
  }
  Future<void> refresh() async {
    setState(() {
      callApiDoctorList();
    });
  }
  Future<BaseModel<Banners>> callApiBanner() async {
    Banners response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).bannerRequest();
      setState(() {
        loading = false;
        if (response.data!.length != 0) {
          imgList.clear();
          for (int i = 0; i < response.data!.length; i++) {
            imgList.add(response.data![i].fullImage);
          }
        }
        banner.addAll(response.data!);
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
}
