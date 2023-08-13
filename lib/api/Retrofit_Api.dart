import 'package:dio/dio.dart';
import 'package:apple_user/const/prefConstatnt.dart';
import 'package:apple_user/const/preference.dart';

class RetroApi {
  Dio dioData() {
    final dio = Dio();
    String? token = SharedPreferenceHelper.getString(Preferences.auth_token);
    dio.options.headers["Accept"] = "application/json"; // config your dio headers globally
    dio.options.followRedirects = false;
    dio.options.connectTimeout = 750000; //5s
    dio.options.receiveTimeout = 30000;
    if (token != "N/A") {
      dio.options.headers["Authorization"] = "Bearer " + token!;
    }
    return dio;
  }
}

class RetroApi2 {
  Dio dioData2() {
    final dio = Dio();
    dio.options.headers["Accept"] = "application/json"; // config your dio headers globally
    dio.options.followRedirects = false;
    dio.options.connectTimeout = 75000; //5s
    dio.options.receiveTimeout = 35000;//35 s
    return dio;
  }
}
