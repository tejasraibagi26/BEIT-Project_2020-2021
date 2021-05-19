import 'package:orderista/Canteen/CanteenRoot.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/constants.dart';
import 'package:orderista/Module/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderScanner extends StatefulWidget {
  @override
  _OrderScannerState createState() => _OrderScannerState();
}

class _OrderScannerState extends State<OrderScanner> {
  String qrCode, orderid, paymentStatus = "";
  bool isOrderMatching = false;
  bool isWaiting = false;
  bool isDarkMode = false;
  var orderConfirmList = [];

  @override
  void initState() {
    super.initState();
    getTheme();
    scanQR();
  }

  void getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isDarkMode") == null) {
      prefs.setBool("isDarkMode", false);
    }
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode");
    });
  }

  void scanQR() async {
    if (this.mounted) {
      setState(() {
        isWaiting = true;
      });
    }
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        false,
        ScanMode.QR,
      );

      if (!mounted) return;

      setState(() {
        this.qrCode = qrCode;
        orderid = qrCode.split("orderid:")[1].split(",")[0].split(" ")[1];
        paymentStatus = qrCode
            .split("paymentStatus:")[1]
            .split(",")[0]
            .split("}")[0]
            .split(" ")[1];

        checkIfOrderPresent(orderid);
      });
    } on Exception catch (_) {
      qrCode = 'Failed to get platform version.';
    }
  }

  void checkIfOrderPresent(String orderid) async {
    var data = {"orderid": "pay_$orderid"};
    var checkOrder = await httpPost('api/v1/order/check-barcode', data);
    orderConfirmList = checkOrder["orders"];
    if (orderConfirmList == null) {
      if (this.mounted) {
        setState(() {
          isOrderMatching = false;
          isWaiting = false;
        });
      }
      return;
    }
    if ("pay_$orderid" == orderConfirmList[0]["orderid"]) {
      if (this.mounted) {
        setState(() {
          isOrderMatching = true;
          isWaiting = false;
        });
      }
    }
  }

  void confirmOrder() async {
    var data = {"orderid": "pay_" + orderid};
    var result = await httpPost("api/v1/order/confirm-order", data);

    if (result["status"] == 200) {
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
        builder: (context) => CanteenRoot(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderText(
                headerTitle: "Verify Order",
                color: isDarkMode ? textColorDark : textColorLight,
              ),
              SizedBox(
                height: 20,
              ),
              !isWaiting
                  ? !isOrderMatching
                      ? Container(
                          padding: EdgeInsets.all(8.0),
                          width: size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: isDarkMode
                                  ? waringBgColorDark.withOpacity(.3)
                                  : warningBgColorLight.withOpacity(.3)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(
                                SFSymbols.exclamationmark_triangle_fill,
                                color:
                                    isDarkMode ? iconColorDark : iconColorLight,
                              ),
                              Container(
                                width: size.width * .7,
                                child: Text(
                                  "Order Already Confirmed / Not Found. Please Scan Again.",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode
                                          ? textColorDark
                                          : textColorLight,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start,
                                ),
                              )
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "OrderID:",
                                  style: TextStyle(
                                    fontSize: textBodySize,
                                    color: isDarkMode
                                        ? textColorDark
                                        : textColorLight,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(.2),
                                      borderRadius: BorderRadius.circular(9)),
                                  child: Text(
                                    orderConfirmList[0]["orderid"]
                                        .split("_")[1],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDarkMode
                                          ? textColorDark
                                          : textColorLight,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Cost:",
                                  style: TextStyle(
                                    fontSize: textBodySize,
                                    color: isDarkMode
                                        ? textColorDark
                                        : textColorLight,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(.2),
                                      borderRadius: BorderRadius.circular(9)),
                                  child: Text(
                                    "\u20B9 ${orderConfirmList[0]["cost"]}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDarkMode
                                          ? textColorDark
                                          : textColorLight,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Payment Status:",
                                  style: TextStyle(fontSize: 22),
                                ),
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: paymentStatus == "Paid"
                                          ? Colors.green
                                          : Colors.redAccent,
                                      borderRadius: BorderRadius.circular(9)),
                                  child: Text(
                                    paymentStatus,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () {
                                confirmOrder();
                              },
                              child: Container(
                                width: size.width,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? buttonColorDark
                                      : buttonColorLight,
                                  borderRadius: BorderRadius.circular(9),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12.withOpacity(.2),
                                        blurRadius: 20,
                                        offset: Offset(0, 10)),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "Confirm Order",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                  : isDarkMode
                      ? spinkit
                      : spinkitDark,
            ],
          ),
        ),
      ),
    );
  }
}
