import 'package:apple_user/Screen/Screens/Appointments.dart';
import 'package:apple_user/Screen/Screens/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../const/app_asset.dart';

import 'Payment _History.dart';
import 'Profile-patient.dart';



class Bottomfour extends StatefulWidget {
  const Bottomfour({Key? key}) : super(key: key);

  @override
  State<Bottomfour> createState() => _BottomfourState();
}

class _BottomfourState extends State<Bottomfour> {
  List<String> Exploreby = [
    "Prescriptions",
    "Files",
    "Photo",
  ];

  List images = [
    AppAssets.records1,
    AppAssets.records2,
    AppAssets.records3,
  ];

  List<Color> Recordscolor = [
    const Color(0xffEEEEFF),
    const Color(0xffC3EFFF),
    const Color(0xffFEF1ED),
  ];

  List<String> Consultancy = [
    "Previous",
    "Upcoming",
    "Cancelled",
  ];

  List<Color> Consultancycolor = [
    const Color(0xffF2F4F7),
    const Color(0xffECFDF3),
    const Color(0xffFEF3F2),
  ];

  List images1 = [
    AppAssets.Consultancy1,
    AppAssets.Consultancy2,
    AppAssets.Consultancy3,
  ];

  @override
  Widget build(BuildContext context) {
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
                    "Records",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: 3,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisExtent: 150),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        height: 104,
                        width: 104,
                        decoration: BoxDecoration(
                            color: Recordscolor[index],
                            borderRadius: BorderRadius.circular(50)),
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
                  );
                },
              ),
            ),
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.only(top: 0, left: 20),
                  child: Text(
                    "Consultancy",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: 3,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisExtent: 150),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        height: 104,
                        width: 104,
                        decoration: BoxDecoration(
                            color: Consultancycolor[index],
                            borderRadius: BorderRadius.circular(50)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: Image(
                            image: AssetImage(images1[index].toString()),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: Text(Consultancy[index],
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 14)),
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              height: 350,
              width: 335,
              decoration: BoxDecoration(
                  color: const Color(0xff1C208F),
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const SizedBox(height: 10,),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                       // Get.to(const Profilepatient(),transition: Transition.rightToLeft);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  Profile()),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xffEEEEFF).withOpacity(0.8),
                            child:
                                const Icon(Icons.access_time_outlined, color: Colors.white),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 120),
                            child: Text(
                              "Profile",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    indent: 20,
                    endIndent: 20,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xffEEEEFF).withOpacity(0.8),
                          child: const Text(
                            "\%",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 130),
                          child: Text(
                            "Other",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    indent: 20,
                    endIndent: 20,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                       // Get.to(const PaymentHistory(),transition: Transition.rightToLeft);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PaymentHistory()),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xffEEEEFF).withOpacity(0.8),
                            child: const Text(
                              "\$",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 110),
                            child: Text(
                              "Payments",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    indent: 20,
                    endIndent: 20,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                       // Get.to(Appointments(),transition: Transition.rightToLeft);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AppointmentsUi()),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xffEEEEFF).withOpacity(0.8),
                            child:
                            const Icon(Icons.calendar_month_sharp, color: Colors.white),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 80),
                            child: Text(
                              "Appointments",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                ],
              ),
            ),
            const SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
}
