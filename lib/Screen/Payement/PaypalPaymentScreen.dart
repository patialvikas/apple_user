import 'dart:core';
import 'package:apple_user/Paypal/PaypalServices.dart';
import 'package:apple_user/const/Palette.dart';
import 'package:apple_user/const/prefConstatnt.dart';
import 'package:apple_user/const/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaypalPayment extends StatefulWidget {
  final Function? onFinish;
  final String? total;

  const PaypalPayment({Key? key, this.onFinish, this.total}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState();
  }
}

class PaypalPaymentState extends State<PaypalPayment> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? checkoutUrl;
  String? executeUrl;
  String? accessToken;
  PaypalServices services = PaypalServices();

  Map<dynamic, dynamic> defaultCurrency = {"symbol": SharedPreferenceHelper.getString(Preferences.currency_code), "decimalDigits": 2, "symbolBeforeTheNumber": true, "currency": SharedPreferenceHelper.getString(Preferences.currency_code)};

  bool isEnableShipping = false;
  bool isEnableAddress = false;

  String returnURL = 'return.example.com';
  String cancelURL = 'cancel.example.com';
  String? totalAmount = '';

  void getToken() async {
    Future.delayed(
      const Duration(seconds: 1),
      () async {
        try {
          accessToken = await services.getAccessToken();
          final transactions = getOrderParams();
          final res = await services.createPaypalPayment(transactions, accessToken);
          setState(() {
            checkoutUrl = res["approvalUrl"];
            executeUrl = res["executeUrl"];
          });
        } catch (e) {
          print('exception:  $e');
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    totalAmount = widget.total;

    getToken();
  }

  String itemName = 'Doctro';
  int quantity = 1;

  Map<String, dynamic> getOrderParams() {
    List items = [
      {"name": itemName, "quantity": quantity, "price": totalAmount, "currency": defaultCurrency["currency"]}
    ];

    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": totalAmount,
            "currency": defaultCurrency["currency"],
            "details": {
              "subtotal": totalAmount,
            }
          },
          "description": "The payment transaction description.",
          "payment_options": {"allowed_payment_method": "INSTANT_FUNDING_SOURCE"},
          "item_list": {
            "items": items,
          }
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {"return_url": returnURL, "cancel_url": cancelURL}
    };
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: checkoutUrl != null
          ? WebView(
              initialUrl: checkoutUrl,
              javascriptMode: JavascriptMode.unrestricted,
              debuggingEnabled: true,
              navigationDelegate: (NavigationRequest request) {
                if (request.url.contains(returnURL)) {
                  final uri = Uri.parse(request.url);
                  final payerID = uri.queryParameters['PayerID'];
                  if (payerID != null) {
                    services.executePayment(executeUrl, payerID, accessToken).then((id) {
                      widget.onFinish!(id);
                      Navigator.of(this.context).pop();
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
                  Navigator.of(context).pop();
                }
                if (request.url.contains(cancelURL)) {
                  Navigator.of(context).pop();
                }
                return NavigationDecision.navigate;
              },
            )
          : const Center(
              child: SpinKitPulse(color: Palette.blue),
            ),
    );
  }
}
