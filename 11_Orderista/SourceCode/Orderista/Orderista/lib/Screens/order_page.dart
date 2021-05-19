import 'dart:async';
import 'dart:convert';
import 'package:orderista/constants.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/Module/http.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  var order;
  var orderList = [];
  bool isFetching = false;
  bool isDarkMode = false;

  Timer timer;
  @override
  void initState() {
    super.initState();

    getTheme();
    //Call then fucntion to fetch the latest active order
    getActiveOrder();
    timer =
        Timer.periodic(Duration(seconds: 60), (Timer t) => getActiveOrder());
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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  //Function for API call
  void getActiveOrder() async {
    setState(() {
      isFetching = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString("userID");
    var data = {"userID": userID};
    order = await httpPost('api/v1/order/get-order', data);
    orderList = order["order"];
    setState(() {
      isFetching = false;
    });
    if (orderList == null) {
      setState(() {
        isFetching = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          children: [
            HeaderText(
              headerTitle: "Order",
              color: isDarkMode ? textColorDark : textColorLight,
            ),
            Divider(),
            orderList != null
                ? !isFetching
                    ? Container(
                        width: size.width,
                        height: size.height * .7,
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: orderList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.all(12.0),
                              margin: EdgeInsets.symmetric(vertical: 10.0),
                              width: size.width,
                              decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? cardColorDark
                                      : cardColorLight,
                                  borderRadius: BorderRadius.circular(9)),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order ID: " +
                                          order["order"][index]["orderid"]
                                              .split("_")[1]
                                              .toString(),
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: isDarkMode
                                              ? textColorDark
                                              : textColorLight),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    LimitedBox(
                                      maxHeight: 500.0,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount:
                                            orderList[index]["orders"].length,
                                        itemBuilder: (context, i) {
                                          return Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  json.decode(orderList[index]
                                                      ["orders"][i])["name"],
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      color: isDarkMode
                                                          ? textColorDark
                                                          : textColorLight),
                                                ),
                                                Container(
                                                  width: 40,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                      color: isDarkMode
                                                          ? Colors.black
                                                              .withOpacity(.2)
                                                          : Colors.blueGrey
                                                              .withOpacity(.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6)),
                                                  child: Center(
                                                    child: Text(
                                                      "x" +
                                                          json
                                                              .decode(orderList[
                                                                          index]
                                                                      ["orders"]
                                                                  [
                                                                  i])["quantity"]
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: isDarkMode
                                                              ? textColorDark
                                                              : textColorLight),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Cost",
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: isDarkMode
                                                  ? textColorDark
                                                  : textColorLight),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(2.5),
                                          decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Colors.black.withOpacity(.2)
                                                  : Colors.blueGrey
                                                      .withOpacity(.2),
                                              borderRadius:
                                                  BorderRadius.circular(9)),
                                          child: Text(
                                            "\u20B9" +
                                                orderList[index]["cost"]
                                                    .toString(),
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: isDarkMode
                                                    ? textColorDark
                                                    : textColorLight),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                      child: Column(
                                        children: [
                                          QrImage(
                                            data: {
                                              "orderid": order["order"][index]
                                                      ["orderid"]
                                                  .split("_")[1]
                                                  .toString(),
                                              "paymentStatus": orderList[index]
                                                  ["payment"]
                                            }.toString(),
                                            version: QrVersions.auto,
                                            size: 200.0,
                                            foregroundColor: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          Text(
                                            "Ask the canteen to scan the QR",
                                            style: TextStyle(
                                                color: isDarkMode
                                                    ? textColorDark
                                                    : textColorLight),
                                          )
                                        ],
                                      ),
                                    ),
                                  ]),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Column(
                          children: [
                            isDarkMode ? spinkit : spinkitDark,
                            SizedBox(
                              height: 10,
                            ),
                            Text("Fetching Orders...",
                                style: TextStyle(
                                    color: isDarkMode
                                        ? textColorDark
                                        : textColorLight,
                                    fontSize: 26))
                          ],
                        ),
                      )
                : Center(
                    child: Text(
                    "All Orders Completed",
                    style: TextStyle(
                        fontSize: 24,
                        color: isDarkMode ? textColorDark : textColorLight),
                  ))
          ],
        ),
      ),
    );
  }
}
