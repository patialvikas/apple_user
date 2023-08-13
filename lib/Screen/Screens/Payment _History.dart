import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../const/app_asset.dart';
import '../../widgets/intro_button.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({Key? key}) : super(key: key);

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children:  [
              Padding(
                padding: const EdgeInsets.only(top: 60, left: 25),
                child: InkWell(
                  onTap: () {
                    //Get.back();
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
                child: Text("Payment History",
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Image(
                image: AssetImage(AppAssets.PaymentHistory), height: 320),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Text(
              "No data to show here",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Color(0xff667085),
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: IntroButton(
              title: "Go Back",
              height: 56,
              width: 168,
            ),
          ),
        ],
      ),
    );
  }
}
