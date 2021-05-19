import 'dart:convert';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/constants.dart';
import 'package:orderista/Module/http.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistory extends StatefulWidget {
  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  var res;
  var completedOrders = [];
  var orders = [];
  bool isDarkMode = false;
  bool isHistoryChanged = false;

  @override
  void initState() {
    super.initState();

    getTheme();
    getUserOrders();
  }

  void getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isDarkMode") == null) {
      prefs.setBool("isDarkMode", false);
    }
    if (this.mounted) {
      setState(() {
        isDarkMode = prefs.getBool("isDarkMode");
      });
    }
  }

  void getUserOrders() async {
    if (!this.mounted) return;

    if (this.mounted) {
      setState(() {
        isHistoryChanged = true;
      });
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString("userID");
    var data = {"userid": userid};
    res = await httpPost('api/v1/order/completed-orders', data);
    completedOrders = res["order"];

    if (this.mounted) {
      setState(() {
        isHistoryChanged = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderText(
                  headerTitle: "Order History",
                  color: isDarkMode ? textColorDark : textColorLight,
                ),
                Divider(),
                !isHistoryChanged
                    ? completedOrders == null
                        ? Center(
                            child: Text(
                              "No Order History",
                              style: TextStyle(
                                color:
                                    isDarkMode ? textColorDark : textColorLight,
                                fontSize: textBodySize,
                              ),
                            ),
                          )
                        : Expanded(
                            child: Container(
                              width: size.width,
                              height: size.height,
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: completedOrders.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: EdgeInsets.all(12.0),
                                    margin:
                                        EdgeInsets.symmetric(vertical: 10.0),
                                    width: size.width,
                                    decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? cardColorDark
                                            : cardColorLight,
                                        borderRadius: BorderRadius.circular(9)),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Order ID: " +
                                                completedOrders[index]
                                                        ["orderid"]
                                                    .split("_")[1]
                                                    .toString(),
                                            style: TextStyle(
                                                fontSize: textBodySize,
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
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: completedOrders[index]
                                                      ["orders"]
                                                  .length,
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
                                                        json.decode(
                                                            completedOrders[
                                                                        index]
                                                                    ["orders"]
                                                                [i])["name"],
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
                                                                    .withOpacity(
                                                                        .2)
                                                                : Colors
                                                                    .blueGrey
                                                                    .withOpacity(
                                                                        .2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6)),
                                                        child: Center(
                                                          child: Text(
                                                            "x" +
                                                                json
                                                                    .decode(
                                                                        completedOrders[index]["orders"]
                                                                            [
                                                                            i])[
                                                                        "quantity"]
                                                                    .toString(),
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: isDarkMode
                                                                    ? textColorDark
                                                                    : textColorLight),
                                                            textAlign: TextAlign
                                                                .center,
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
                                                        ? Colors.black
                                                            .withOpacity(.2)
                                                        : Colors.blueGrey
                                                            .withOpacity(.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9)),
                                                child: Text(
                                                  "\u20B9" +
                                                      completedOrders[index]
                                                              ["cost"]
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
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Status",
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    color: isDarkMode
                                                        ? textColorDark
                                                        : textColorLight),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(2.5),
                                                decoration: BoxDecoration(
                                                    color:
                                                        completedOrders[index]
                                                                ["completed"]
                                                            ? Colors.green
                                                            : Colors.redAccent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9)),
                                                child: Text(
                                                  completedOrders[index]
                                                          ["completed"]
                                                      ? "Completed"
                                                      : "Pending",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]),
                                  );
                                },
                              ),
                            ),
                          )
                    : isDarkMode
                        ? spinkit
                        : spinkitDark
              ],
            ),
          ),
        ],
      ),
    );
  }
}
