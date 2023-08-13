import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/Retrofit_Api.dart';
import '../../api/base_model.dart';
import '../../api/network_api.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../const/prefConstatnt.dart';
import '../../const/preference.dart';
import '../../localization/localization_constant.dart';
import '../../model/Pharamacies_details_model.dart';
import '../../model/vitamins_model.dart';
import '../MedicineAndPharmacy/MedicineDescription.dart';


class Vitamins extends StatefulWidget {
  final int? id;

  Vitamins({this.id});

  @override
  State<Vitamins> createState() => _VitaminsState();
}

class _VitaminsState extends State<Vitamins> {
  int? id = 0;
  bool loading = false;
  String? pharamacyImage = "";
  String? pharamacyName = "";
  String? pharamacyPhone = "";
  String? pharamacyEmail = "";
  String? pharamacyDescription = "";
  String? pharamacyStartTime = "";
  String? pharamacyEndTime = "";
  String? pharamacyAddress = "";
  int? isShipping;
  String? pharmacyLat = "";
  String? pharmacyLang = "";

  List<String?> minValue = [];
  List<String?> maxValue = [];
  List<String?> charges = [];

  List<Medicine> medicines = [];

  int? pharamacyId;
  void initState() {
    id = widget.id;
    callApiPharamacyDetail();

    super.initState();
    _passPharamacyId();
  }
  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F9),
      body:

    ModalProgressHUD(
    inAsyncCall: loading,
    opacity: 0.5,
    progressIndicator: SpinKitFadingCircle(
    color: Palette.blue,
    size: 50.0,
    ),
    child:SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 25),
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
                  padding: EdgeInsets.only(top: 50, left: 10),
                  child: Text("Vitamins",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ],
            ),
            medicines.length != 0
                ?
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 250),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                itemCount: medicines.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xffFFFFFF),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MedicineDescription(id: medicines[index].id),
                              ),
                            );

                          },
                          child:
                          Container(
                            margin: const EdgeInsets.only(
                                right: 10, left: 10, top: 10, bottom: 10),
                            height: 146,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: const Color(0xffF2F4F7),
                                borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              children: [
                                Icon(
                                   Icons.favorite_border,
                                  color:  const Color(0xff292D32),
                                  size: 20,
                                ).paddingOnly(top: 10, left: 90),
                                Center(
                                  child: CachedNetworkImage(
                                    alignment: Alignment.center,
                                    height: 100,
                                    //width: 35,
                                    fit: BoxFit.fill,
                                    imageUrl: medicines[index].fullImage!,
                                    placeholder: (context, url) =>
                                        Image(
                                          image: AssetImage("assets/images/doctor3.png"),
                                          //width: 50,
                                        ),
                                    errorWidget: (context, url, error) => ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                      child: Image.asset(
                                        "assets/images/NoImage.png",
                                        height: 100,

                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          maxLines: 1,
                          medicines[index].name!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ).marginOnly(left: 15),
                        Text(
                          maxLines: 2,
                  "",
                          style: const TextStyle(
                            fontSize: 12,

                            fontWeight: FontWeight.w500,
                          ),
                        ).marginOnly(left: 15, top: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + medicines[index].pricePrStrip.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ).marginOnly(top: 5),
                            const SizedBox(
                              width: 45,
                            ),
                            const CircleAvatar(
                              backgroundColor: Color(0xff1C208F),
                              maxRadius: 15,
                              child: Icon(Icons.add, color: Colors.white),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ):
            Container(
              alignment: Alignment.center,
              child: Text(
                getTranslated(
                    context, allPharamacy_pharmacyNotFound)
                    .toString(),
                style: TextStyle(
                    fontSize: width * 0.04,
                    color: Palette.grey,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),),
    );
  }

  Future<BaseModel<PharamaciesDetails>> callApiPharamacyDetail() async {
    PharamaciesDetails response;

    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).pharmacyDetailRequest(id);
      setState(() {
        loading = false;
        if (response.success == true) {
          setState(
                () {
              loading = false;
              pharamacyImage = response.data!.fullImage;
              pharamacyName = response.data!.name;
              pharamacyPhone = response.data!.phone;
              pharamacyEmail = response.data!.email;
              pharamacyDescription = response.data!.description;
              pharamacyStartTime = response.data!.startTime;
              pharamacyEndTime = response.data!.endTime;
              pharamacyAddress = response.data!.address;
              medicines.addAll(response.data!.medicine!);
              isShipping = response.data!.isShipping;
              pharmacyLat = response.data!.lat;
              pharmacyLang = response.data!.lang;

              if ('$isShipping' == 1.toString()) {
                var convertCharges = json.decode(response.data!.deliveryCharges!);
                minValue.clear();
                maxValue.clear();
                charges.clear();
                for (int i = 0; i < convertCharges.length; i++) {
                  minValue.add(convertCharges[i]['min_value']);
                  maxValue.add(convertCharges[i]['max_value']);
                  charges.add(convertCharges[i]['charges']);
                  _passShippingStatus();
                }
                _passShippingStatus();
              }
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
  _passPharamacyId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pharamacyId = id;
      prefs.setInt('pharamacyId', pharamacyId!);
    });
  }

  _passShippingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setInt('ShippingStatus', isShipping!);
      prefs.setString('pharmacyLat', pharmacyLat!);
      prefs.setString('pharmacyLang', pharmacyLang!);
      prefs.setStringList('minValue', minValue as List<String>);
      prefs.setStringList('maxValue', maxValue as List<String>);
      prefs.setStringList('charges', charges as List<String>);
    });
  }
}
