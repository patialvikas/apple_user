import 'dart:async';
import 'dart:io';
import 'package:apple_user/Screen/Screens/Appointments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apple_user/Screen/Location/AddLocation.dart';
import 'package:apple_user/Screen/Location/Addtocart.dart';
import 'package:apple_user/Screen/MedicineAndPharmacy/AllPharamacy.dart';
import 'package:apple_user/Screen/AppointmentRelatedScreen/Book_success.dart';
import 'package:apple_user/Screen/AppointmentRelatedScreen/Bookappointment.dart';
import 'package:apple_user/Screen/Doctor/Favoritedoctor.dart';
import 'package:apple_user/FirebaseProviders/auth_provider.dart';
import 'package:apple_user/FirebaseProviders/chat_provider.dart';
import 'package:apple_user/FirebaseProviders/home_provider.dart';
import 'package:apple_user/FirebaseProviders/setting_provider.dart';
import 'package:apple_user/Screen/MedicineAndPharmacy/HealthTips.dart';
import 'package:apple_user/Screen/MedicineAndPharmacy/HealthTipsDetail.dart';
import 'package:apple_user/Screen/MedicineAndPharmacy/MedicineDescription.dart';
import 'package:apple_user/Screen/MedicineAndPharmacy/PharamacyDetail.dart';
import 'package:apple_user/Screen/AppointmentRelatedScreen/Review_Appointment.dart';
import 'package:apple_user/Screen/Authentication/SignIn.dart';
import 'package:apple_user/Screen/Doctor/Specialist.dart';
import 'package:apple_user/Screen/Doctor/Treatment.dart';
import 'package:apple_user/Screen/Doctor/TreatmentSpecialist.dart';
import 'package:apple_user/const/preference.dart';
import 'package:apple_user/Screen/Doctor/doctordetail.dart';
import 'package:apple_user/Screen/Authentication/forgotpassword.dart';
import 'package:apple_user/Screen/Location/Showlocation.dart';
import 'package:apple_user/Screen/Authentication/phoneverification.dart';
import 'package:apple_user/Screen/MedicineAndPharmacy/Myprescription.dart';
import 'package:apple_user/Screen/AppointmentRelatedScreen/Appointment.dart';
import 'package:apple_user/Screen/Setting/ChangeLanguage.dart';
import 'package:apple_user/VideoCall/videocallhistory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:apple_user/Screen/MedicineAndPharmacy/MedicineOrder.dart';
import 'package:apple_user/Screen/MedicineAndPharmacy/MedicineOrderDetail.dart';
import 'package:apple_user/Screen/Payement/MedicinePayment.dart';
import 'package:apple_user/Screen/Payement/StripePaymentScreenMedicine.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screen/Payement/StripePaymentScreen.dart';
import 'Screen/Authentication/signup.dart';
import 'Screen/AppointmentRelatedScreen/appoitment_stripe_service.dart';
import 'Screen/Payement/medicines_stripe_services.dart';
import 'Screen/Screens/Home.dart';
import 'Screen/Screens/Offer.dart';
import 'Screen/Screens/Setting.dart';
import 'Screen/Screens/notifications.dart';
import 'Screen/Screens/profile.dart';
import 'Screen/Setting/AboutUs.dart';
import 'Chat/chatPage.dart';
import 'Screen/Setting/ChangePassword.dart';
import 'Screen/Setting/PrivacyPolicy.dart';
import 'VideoCall/overlay_handler.dart';
import 'api/Retrofit_Api.dart';
import 'api/base_model.dart';
import 'api/network_api.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/prefConstatnt.dart';
import 'localization/language_localization.dart';
import 'localization/localization_constant.dart';
import 'model/detail_setting_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyCyzhwQh5W7m4ivM8IZAXcUZEKpF6qVVP4",
    appId: "1:887088986799:android:921ef78c47578b5ea8325a",
    messagingSenderId: "887088986799-kee9j81h0dfldd0gbgrhcbv1b4eudoqo.apps.googleusercontent.com",
    projectId: "drapple-aea39",
  ));
  await SharedPreferenceHelper.init();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    // description
    importance: Importance.high,
    showBadge: true,
    playSound: true,
    enableVibration: true);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  String? deviceToken = "";

  late SharedPreferences _prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  String msgId = "";
  String msgName = "";
  String msgImage = "";
  String doctorToken = "";

  String token = "";
  bool? router;

  @override
  void initState() {
    super.initState();
    setState(() {
      callApiSetting();
      init();
      Future.delayed(const Duration(seconds: 2), () {
        FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
          if (message != null) {
            Map<String, dynamic> dataValue = message.data;
            msgImage = dataValue['doctorImage'].toString();
            msgName = dataValue['doctorName'].toString();
            msgId = dataValue['doctorId'].toString();
            doctorToken = dataValue['doctorToken'].toString();
            print("message not null");
            if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
              Navigator.of(navigatorKey.currentState!.context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    peerId: msgId,
                    peerAvatar: msgImage,
                    peerNickname: msgName,
                    doctorToken: doctorToken,
                    where: "",
                  ),
                ),
              );
            } else {
              Navigator.of(navigatorKey.currentState!.context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SignIn(),
                ),
              );
            }
          }
        });
      });

      /// Get Notification ///
      var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = new DarwinInitializationSettings();
      var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
      flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onSelectNotification);
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        Map<String, dynamic> dataValue = message.data;
        String screen = dataValue['screen'].toString();
        msgImage = dataValue['doctorImage'].toString();
        msgName = dataValue['doctorName'].toString();
        msgId = dataValue['doctorId'].toString();
        doctorToken = dataValue['doctorToken'].toString();

        print("Screen: " + screen);
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  icon: "@mipmap/ic_launcher",
                ),
              ),
              payload: screen);
        }
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          Navigator.of(navigatorKey.currentState!.context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ChatPage(
                peerId: msgId,
                peerAvatar: msgImage,
                peerNickname: msgName,
                doctorToken: doctorToken,
                where: "",
              ),
            ),
          );
        }
      });
      getToken();
    });
  }

  onSelectNotification(payload) {
    if (payload == "screen") {
      if (msgId.isNotEmpty && msgName.isNotEmpty && msgImage.isNotEmpty && SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
        Navigator.of(navigatorKey.currentState!.context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChatPage(
              peerId: msgId,
              peerAvatar: msgImage,
              peerNickname: msgName,
              doctorToken: doctorToken,
              where: "",
            ),
          ),
        );
      }
    }
  }

  getToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
    if (token.isNotEmpty) {
      print("Notification Token:" + token);
      SharedPreferenceHelper.setString(Preferences.notificationRegisterKey, token);
    }
  }

  Future<SharedPreferences?> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  @override
  void didChangeDependencies() {
    getLocale().then((local) => {
          setState(() {
            this._locale = local;
          })
        });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    if (_locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<StripePayment>(
              create: (context)=>StripePayment(),
          ),
          ChangeNotifierProvider<MedicinesStripePayment>(
              create: (context)=>MedicinesStripePayment(),
          ),
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(
              firebaseAuth: FirebaseAuth.instance,
              googleSignIn: GoogleSignIn(),
              prefs: this._prefs,
              firebaseFirestore: this.firebaseFirestore,
            ),
          ),
          Provider<SettingProvider>(
            create: (_) => SettingProvider(
              prefs: this._prefs,
              firebaseFirestore: this.firebaseFirestore,
              firebaseStorage: this.firebaseStorage,
            ),
          ),
          Provider<HomeProvider>(
            create: (_) => HomeProvider(
              firebaseFirestore: this.firebaseFirestore,
            ),
          ),
          Provider<ChatProvider>(
            create: (_) => ChatProvider(
              prefs: this._prefs,
              firebaseFirestore: this.firebaseFirestore,
              firebaseStorage: this.firebaseStorage,
            ),
          ),
        ],
        child: ChangeNotifierProvider<OverlayHandlerProvider>(
          create: (_) => OverlayHandlerProvider(),
          child: MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Doctro',
            locale: _locale,
            supportedLocales: [
              Locale(ENGLISH, 'US'),
              Locale(SPANISH, 'ES'),
              Locale(ARABIC, 'AE'),
            ],
            localizationsDelegates: [
              LanguageLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (deviceLocal, supportedLocales) {
              for (var local in supportedLocales) {
                if (local.languageCode == deviceLocal!.languageCode && local.countryCode == deviceLocal.countryCode) {
                  return deviceLocal;
                }
              }
              return supportedLocales.first;
            },
            debugShowCheckedModeBanner: false,
            initialRoute: "/",
            theme: ThemeData(
              splashColor: Palette.transparent,
              highlightColor: Palette.transparent,
            ),
            routes: {
              '/': (context) => Home(),
              'SignIn': (context) => SignIn(),
              'SignUp': (context) => SignUp(),
              'ForgotPasswordScreen': (context) => ForgotPasswordScreen(),
              'PhoneVerification': (context) => PhoneVerification(),
              'Home': (context) => Home(),
              'Treatment': (context) => Treatment(),
              'FavoriteDoctorScreen': (context) => FavoriteDoctorScreen(),
              'Specialist': (context) => Specialist(),
              'DoctorDetail': (context) => DoctorDetail(),
              'BookAppointment': (context) => BookAppointment(),
              'Appointment': (context) => Appointment(),
              'AppointmentUi': (context) => AppointmentsUi(),
              'Myprescription': (context) => Myprescription(),
              'HealthTips': (context) => HealthTips(),
              'HealthTipsDetail': (context) => HealthTipsDetail(),
              'Setting': (context) => Setting(),
              'AddToCart': (context) => AddToCart(),
              'Offer': (context) => Offer(),
              'Profile': (context) => Profile(),
              'ShowLocation': (context) => ShowLocation(),
              'AddLocation': (context) => AddLocation(),
              'BookSuccess': (context) => BookSuccess(),
              'Review': (context) => Review(),
              'MedicineDescription': (context) => MedicineDescription(),
              'AllPharamacy': (context) => AllPharamacy(),
              'PharamacyDetail': (context) => PharamacyDetail(),
              'MedicinePayment': (context) => MedicinePayment(),
              'MedicineOrder': (context) => MedicineOrder(),
              'MedicineOrderDetail': (context) => MedicineOrderDetail(),
              'TreatmentSpecialist': (context) => TreatmentSpecialist(),
              'Notifications': (context) => Notifications(),
              'StripePaymentScreen': (context) => StripePaymentScreen(),
              'StripePaymentScreenMedicine': (context) => StripePaymentScreenMedicine(),
              'ChangePassword': (context) => ChangePassword(),
              'PrivacyPolicy': (context) => PrivacyPolicy(),
              'AboutUs': (context) => AboutUs(),
              'ChangeLanguage': (context) => ChangeLanguage(),
              'VideoCallHistory': (context) => VideoCallHistory(),
            },
          ),
        ),
      );
    }
  }

  Future<BaseModel<DetailSetting>> callApiSetting() async {
    DetailSetting response;
    try {
      response = await RestClient(RetroApi2().dioData2()).settingRequest();
      setState(() {
        if (response.success == true) {
          SharedPreferenceHelper.setString(Preferences.patientAppId, response.data!.patientAppId!);
          if (response.data!.patientAppId != null) {
            getOneSingleToken(SharedPreferenceHelper.getString(Preferences.patientAppId));
          }
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  ///one signal
  Future<void> getOneSingleToken(appId) async {
    try {
      OneSignal.shared.consentGranted(true);
      OneSignal.shared.setAppId(appId);
      OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
      await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
      OneSignal.shared.promptLocationPermission();
      await OneSignal.shared.getDeviceState().then((value) {
        print('device token is ${value!.userId}');
        return SharedPreferenceHelper.setString(Preferences.device_token, value.userId!);
      });
    } catch (e) {
      print("error${e.toString()}");
    }

    setState(() {
      deviceToken = SharedPreferenceHelper.getString(Preferences.device_token);
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
