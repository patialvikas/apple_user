import 'package:flutter/material.dart';

import '../../const/app_asset.dart';
import '../../widgets/intro_button.dart';


class Profileabout extends StatefulWidget {
  const Profileabout({Key? key}) : super(key: key);

  @override
  State<Profileabout> createState() => _ProfileaboutState();
}

class _ProfileaboutState extends State<Profileabout> {
  List<String> Exploreby = [
    "I recently had the pleasure of seeing Dr. John Doe for a routine check-up and was extremely impressed with the level of care and attention he provided.",
    "I've been a patient of Dr. Jane Smith for several years now and have always had a positive experience. She is knowledgea",
  ];

  List<String> images = [
    AppAssets.doctor1,
    AppAssets.doctor2,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 15),
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
                  child: Text("Profile",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                maxRadius: 50,
                backgroundImage: AssetImage(AppAssets.doctor1),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text("Dr. Jane Smith",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(
              height: 5,
            ),
            const Text("Cardiologist",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Patients",
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 14)),
                    SizedBox(
                      height: 5,
                    ),
                    Text("120+",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18)),
                  ],
                ),
                Container(color: Colors.grey, height: 40, width: 1),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Exp",
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 14)),
                    SizedBox(
                      height: 5,
                    ),
                    Text("10 Yrs",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18)),
                  ],
                ),
                Container(color: Colors.grey, height: 40, width: 1),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Rating",
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 14)),
                    SizedBox(
                      height: 5,
                    ),
                    Text("4.7",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Color(0xff36C8FF))),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            _tabSection(context),
          ],
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
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                unselectedLabelColor: const Color(0xff8E90C7),
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white),
                tabs: const [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("About",
                          style: TextStyle(
                            color: Color(0xff8E90C7),
                            fontWeight: FontWeight.w400,
                          )),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Address",
                        style: TextStyle(
                          color: Color(0xff8E90C7),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Ratings",
                          style: TextStyle(
                            color: Color(0xff8E90C7),
                            fontWeight: FontWeight.w400,
                          )),
                    ),
                  ),
                ]),
          ),
          Container(
            // height: double.maxFinite,
            height: 400,
            child: TabBarView(
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const ListTile(
                      title: Text("Biography",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                            "Dr. Jane Smith is a highly skilled and respected physician who has been practicing medicine for over 20 years. She received her medical degree from the University of California, Los Angeles and completed her residency at the Mayo Clinic."),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 100,
                      width: 336,
                      decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(5, 6))
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: ListTile(
                          leading: Container(
                              decoration: BoxDecoration(
                                  color: const Color(0xffC3EFFF),
                                  borderRadius: BorderRadius.circular(20)),
                              height: 56,
                              width: 56,
                              child: const Icon(Icons.access_time,
                                  color: Color(0xff31B4E6))),
                          title: const Text("Availability",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400)),
                          subtitle: const Text("6 PM - 9 PM",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 96,
                      width: 375,
                      color: const Color(0xffC3EFFF),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("Patients",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14)),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("120+",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18)),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("\$20",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24)),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 56,
                                  width: 168,
                                  decoration: BoxDecoration(
                                      color: const Color(0xff1C208F),
                                      borderRadius: BorderRadius.circular(16)),
                                  child: const Center(
                                    child: Text("Book Now",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                )
                              ],
                            ),
                          ]),
                    )
                  ],
                ),
                Column(
                  children: [
                    const ListTile(
                      title: Text("Practice Place",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      subtitle: Text("Dhanmondi 32, Dhaka, Bangladesh",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ),
                    ListTile(
                      title: const Text("Location Map",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Image(image: AssetImage(AppAssets.Location)),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    InkWell(
                      onTap: () {
                       /* Get.to(const Bookappointment(),
                            transition: Transition.rightToLeft);*/
                      },
                      child: IntroButton(
                          title: 'Book Offline Visit', height: 56, width: 335),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("4.7",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 24)),
                            const SizedBox(
                              height: 10,
                            ),
                            Image(image: AssetImage(AppAssets.Stargrp)),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text("(110 Reviews)",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 12)),
                          ],
                        ),
                        Container(color: Colors.grey, height: 100, width: 1),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Image(image: AssetImage(AppAssets.Stargrp)),
                                const Text(" 12",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16)),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Image(image: AssetImage(AppAssets.Stargroup03)),
                                const Text(" 03",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16)),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Image(image: AssetImage(AppAssets.Stargroup02)),
                                const Text(" 02",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16)),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Image(image: AssetImage(AppAssets.Stargroup01)),
                                const Text(" 01",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const ListTile(
                      title: Text(" Ratings",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      trailing: Text("View all",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xff1C208F))),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: List.generate(
                              2,
                              (index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 5),
                                    child: Container(
                                      height: 166,
                                      width: 267,
                                      decoration: BoxDecoration(
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 10,
                                                offset: Offset(5, 6))
                                          ],
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ListTile(
                                            leading: Container(
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          AppAssets.videocall1),
                                                      fit: BoxFit.fill),
                                                  color:
                                                      const Color(0xffC3EFFF),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              height: 56,
                                              width: 56,
                                            ),
                                            title: const Text("Shahin Alam",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            subtitle: const Text("1 Day",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                            trailing: const Icon(
                                              Icons.star,
                                              color: Color(0xffC3EFFF),
                                            ),
                                          ),
                                          ListTile(
                                            subtitle: Text(Exploreby[index]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
