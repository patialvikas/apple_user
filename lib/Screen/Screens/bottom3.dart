import 'package:apple_user/Screen/Screens/vitamins..dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import '../../api/Retrofit_Api.dart';
import '../../api/base_model.dart';
import '../../api/network_api.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_asset.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import '../../model/pharamacies_model.dart' as md;
import '../../model/pharamacies_model.dart';

class Bottomthree extends StatefulWidget {
  const Bottomthree({Key? key}) : super(key: key);

  @override
  State<Bottomthree> createState() => _BottomthreeState();
}

class _BottomthreeState extends State<Bottomthree> {
  List<String> Exploreby = [
    "  Covid\nEssential",
    "    Skin\ndesieses",
    "Sexual",
    "General",
    "Vitamin",
    "Essential",
  ];

  List images = [
    AppAssets.medicine1,
    AppAssets.medicine2,
    AppAssets.medicine3,
    AppAssets.medicine4,
    AppAssets.medicine5,
    AppAssets.medicine6,
  ];
  bool loading = false;
  String? address = "";

  List<md.Data> pharamacy = [];

  TextEditingController _search = TextEditingController();
  List<md.Data> _searchResult = [];

  @override
  void initState() {
    super.initState();
    //_getAddress();
    callApiPharamacy();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.only(top: 50, left: 20),
                  child: Text(
                    "Medicine",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
                  ),
                ),
              ],
            ),

            Container(
              margin: const EdgeInsets.only(top: 20),
              width: 335,
              height: 52,
              child: TextField(
                // keyboardType: TextInputType.emailAddress,
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
                  hintText: getTranslated(context, allPharamacy_searchPharamacy)
                      .toString(),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 20),
                  child: Text("Medicine/Pharmacy categories",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      )),
                ),
              ],
            ),

            //GridView
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child:

                  /* GridView.builder(
                shrinkWrap: true,
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisExtent: 150),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                     // Get.to(const Vitamins(),transition: Transition.rightToLeft);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Vitamins()),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 104,
                          width: 104,
                          decoration: BoxDecoration(
                              color: const Color(0xffF2F4F7),
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Image(
                              image: AssetImage(images[index].toString()),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Center(
                          child: Text(Exploreby[index],
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14)),
                        ),
                      ],
                    ),
                  );
                },
              ),*/

                  _searchResult.length > 0 || _search.text.isNotEmpty
                      ? _searchResult.length != 0
                          ? Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: GridView.builder(
                                shrinkWrap: true,
                                itemCount: _searchResult.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3, mainAxisExtent: 150),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      // Get.to(const Vitamins(),transition: Transition.rightToLeft);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                 Vitamins(id: _searchResult[index].id,)),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 104,
                                          width: 104,
                                          decoration: BoxDecoration(
                                              color:  Color(0xff1C208F),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 6,right: 6,bottom: 6,top: 6),
                                            child: CachedNetworkImage(
                                              alignment: Alignment.center,
                                              height: 104,
                                              width: 104,
                                              fit: BoxFit.fill,
                                              imageUrl: _searchResult[index].fullImage!,
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
                                                  width: 100,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Center(
                                          child: Text(_searchResult[index].name!,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          )
                          : Container(
                              alignment: AlignmentDirectional.center,
                              child: Text(
                                getTranslated(
                                        context, allPharamacy_pharmacyNotFound)
                                    .toString(),
                                style: TextStyle(
                                    fontSize: width * 0.04,
                                    color: Palette.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                      : pharamacy.length != 0
                          ? Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: GridView.builder(
                                shrinkWrap: true,
                                itemCount: pharamacy.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3, mainAxisExtent: 150),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      // Get.to(const Vitamins(),transition: Transition.rightToLeft);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                 Vitamins(id: pharamacy[index].id)),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 104,
                                          width: 104,
                                          decoration: BoxDecoration(
                                              //color: const Color(0xffF2F4F7),
                                            color:  Color(0xff1C208F),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 6,top: 6,right: 6,bottom: 6),
                                            child:
                                            /*Image(
                                              image: AssetImage(
                                                  images[index].toString()),
                                            ),*/
                                            CachedNetworkImage(
                                              alignment: Alignment.center,
                                              height: 80,
                                              width: 80,
                                              fit: BoxFit.fill,
                                              imageUrl: pharamacy[index].fullImage!,
                                              placeholder: (context, url) =>
                                              /* SpinKitFadingCircle(
                                                  color: Palette.blue,
                                                ),*/
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
                                                  height: 80,
                                                  width: 80,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Center(
                                          child: Text(pharamacy[index].name!,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          )
                          : Container(
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
            ),

            Container(
              height: 250.49,
              width: 335,
              decoration: BoxDecoration(
                  color: const Color(0xff1C208F),
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Get the Best \nMedical Service",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20)),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                                "Lorem Ipsum is simply dummy \ntext of the printing",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Image(
                            image: AssetImage(AppAssets.medicinedoctor),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<BaseModel<Pharamacy>> callApiPharamacy() async {
    Pharamacy response;

    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).pharamacyRequest();
      setState(() {
        if (response.success == true) {
          loading = false;
          pharamacy.addAll(response.data!);
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

    pharamacy.forEach((appointmentData) {
      if (appointmentData.name!.toLowerCase().contains(text.toLowerCase()))
        _searchResult.add(appointmentData);
    });

    setState(() {});
  }
}
