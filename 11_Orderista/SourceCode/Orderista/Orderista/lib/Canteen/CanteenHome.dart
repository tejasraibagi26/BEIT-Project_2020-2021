import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orderista/Canteen/Scan.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/constants.dart';
import 'package:orderista/main.dart';
import 'package:orderista/Module/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CanteenHome extends StatefulWidget {
  CanteenHome({Key key}) : super(key: key);

  @override
  _CanteenHomeState createState() => _CanteenHomeState();
}

class _CanteenHomeState extends State<CanteenHome> {
  var orderList = [];
  bool _isFetching = false;
  bool isDarkMode = false;
  SharedPreferences prefs;

  Timer timer;
  @override
  void initState() {
    super.initState();
    getTheme();

    timer = Timer.periodic(Duration(seconds: 60), (Timer t) => fetchOrders());
    fetchOrders();
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

  void fetchOrders() async {
    if (this.mounted) {
      setState(() {
        _isFetching = true;
      });
    }
    var orders = await httpGet('api/v1/order/all-orders');
    orderList = orders["order"];
    if (this.mounted) {
      setState(() {
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderText(
                headerTitle: "Orders",
                color: isDarkMode ? textColorDark : textColorLight,
              ),
              SizedBox(
                height: 20,
              ),
              !_isFetching
                  ? orderList != null
                      ? Container(
                          width: size.width,
                          height: size.height * 0.70,
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: orderList != null ? orderList.length : 0,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 10.0),
                                padding: EdgeInsets.all(10),
                                width: size.width,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9),
                                    color: isDarkMode
                                        ? cardColorDark
                                        : cardColorLight),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order ID: " +
                                          orderList[index]["orderid"]
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
                                                vertical: 5),
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
                                                orderList[0]["cost"].toString(),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Payment Status",
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: isDarkMode
                                                  ? textColorDark
                                                  : textColorLight),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(2.5),
                                          decoration: BoxDecoration(
                                              color: orderList[index]
                                                          ["payment"] ==
                                                      "Paid"
                                                  ? Colors.green
                                                  : Colors.redAccent,
                                              borderRadius:
                                                  BorderRadius.circular(9)),
                                          child: Text(
                                            orderList[index]["payment"],
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    // GestureDetector(
                                    //   onTap: () {
                                    //     setState(() {});
                                    //     Navigator.of(context)
                                    //         .push(CupertinoPageRoute(
                                    //       builder: (context) => OrderScanner(
                                    //         orderID: orderList[index]["orderid"]
                                    //             .split("_")[1]
                                    //             .toString(),
                                    //         paymentStatus: orderList[index]
                                    //             ["payment"],
                                    //         cost:
                                    //             orderList[0]["cost"].toString(),
                                    //       ),
                                    //     ));
                                    //   },
                                    //   child: Container(
                                    //     width: size.width,
                                    //     height: 40,
                                    //     decoration: BoxDecoration(
                                    //       color: Colors.black,
                                    //       borderRadius:
                                    //           BorderRadius.circular(9),
                                    //       boxShadow: [
                                    //         BoxShadow(
                                    //             color: Colors.black12
                                    //                 .withOpacity(.2),
                                    //             blurRadius: 20,
                                    //             offset: Offset(0, 10)),
                                    //       ],
                                    //     ),
                                    //     child: Center(
                                    //       child: Row(
                                    //         crossAxisAlignment:
                                    //             CrossAxisAlignment.center,
                                    //         mainAxisAlignment:
                                    //             MainAxisAlignment.center,
                                    //         children: [
                                    //           Text(
                                    //             "Scan ",
                                    //             style: TextStyle(
                                    //               color: Colors.white,
                                    //               fontSize: 20,
                                    //             ),
                                    //           ),
                                    //           Icon(
                                    //             SFSymbols.barcode_viewfinder,
                                    //             color: Colors.white,
                                    //             size: 24,
                                    //           )
                                    //         ],
                                    //       ),
                                    //     ),
                                    //   ),
                                    // )
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            "No Orders",
                            style: TextStyle(
                                fontSize: 28,
                                color: isDarkMode
                                    ? textColorDark
                                    : textColorLight),
                          ),
                        )
                  : Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isDarkMode ? spinkit : spinkitDark,
                          Text(
                            "Fetching Orders...",
                            style: TextStyle(
                                fontSize: 28,
                                color: isDarkMode
                                    ? textColorDark
                                    : textColorLight),
                          )
                        ],
                      ),
                    )
            ],
          ),
        ),
      ),
      floatingActionButton: getFAB(context, orderList),
    );
  }
}

Widget getFAB(BuildContext context, List orderList) {
  return FloatingActionButton.extended(
    onPressed: () {
      orderList != null
          ? Navigator.of(context)
              .push(CupertinoPageRoute(builder: (context) => OrderScanner()))
          : Fluttertoast.showToast(
              backgroundColor: Colors.black,
              msg: "No Active Orders To Scan.",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 4);
    },
    icon: Icon(
      SFSymbols.barcode_viewfinder,
      color: Colors.white,
    ),
    label: Text(
      "SCAN",
      // style: TextStyle(letterSpacing: 0),
    ),
    backgroundColor: isDarkMode ? cardColorDark : Colors.black,
  );
}
