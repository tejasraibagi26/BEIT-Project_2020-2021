import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:orderista/Module/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class FoodRatingsFeedback extends StatefulWidget {
  @override
  _FoodRatingsFeedbackState createState() => _FoodRatingsFeedbackState();
}

class _FoodRatingsFeedbackState extends State<FoodRatingsFeedback> {
  var result;
  var ratingList = [];
  bool isFetching = false;
  bool isDarkMode = false;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    getTheme();
    getFeedbacks();
  }

  void getTheme() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isDarkMode") == null) {
      prefs.setBool("isDarkMode", false);
    }
    if (this.mounted) {
      setState(() {
        isDarkMode = prefs.getBool("isDarkMode");
      });
    }
  }

  void getFeedbacks() async {
    setState(() {
      isFetching = true;
    });
    result = await httpGet("api/v1/feedback/get-all-ratings");
    ratingList = result["feedback"];
    if (this.mounted) {
      setState(() {
        isFetching = false;
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !isFetching
                  ? Expanded(
                      child: Container(
                        width: size.width,
                        height: size.height,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount: ratingList != null ? ratingList.length : 0,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(vertical: 10),
                              width: size.width,
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode ? cardColorDark : cardColorLight,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LimitedBox(
                                    maxHeight: 75,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Order ID:  ${ratingList[index]["orderid"].split("_")[1]}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? textColorDark
                                                : textColorLight,
                                            fontSize: textBodySize - 2,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  SFSymbols.person_2_fill,
                                                  color: isDarkMode
                                                      ? subTitleDark
                                                      : subTitleLight,
                                                  size: 14,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  ratingList[index]["userid"]
                                                      .toString(),
                                                  style: TextStyle(
                                                    color: isDarkMode
                                                        ? subTitleDark
                                                        : subTitleLight,
                                                    fontSize: 14,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  SFSymbols.clock_fill,
                                                  color: isDarkMode
                                                      ? subTitleDark
                                                      : subTitleLight,
                                                  size: 14,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  ratingList[index]
                                                              ["time_stamp"]
                                                          .split('T')[0] +
                                                      " " +
                                                      ratingList[index]
                                                              ["time_stamp"]
                                                          .split('T')[1]
                                                          .split(".")[0],
                                                  style: TextStyle(
                                                    color: isDarkMode
                                                        ? subTitleDark
                                                        : subTitleLight,
                                                    fontSize: 14,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  LimitedBox(
                                    maxHeight: 500,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount:
                                            ratingList[index]["orders"].length,
                                        itemBuilder: (context, i) {
                                          return Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  json.decode(ratingList[index]
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
                                                  child: Text(
                                                    "x" +
                                                        json
                                                            .decode(ratingList[
                                                                        index]
                                                                    ["orders"]
                                                                [i])["quantity"]
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
                                          );
                                        }),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total Cost",
                                        style: TextStyle(
                                          fontSize: textBodySize,
                                          color: isDarkMode
                                              ? textColorDark
                                              : textColorLight,
                                        ),
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
                                              ratingList[index]["cost"]
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
                                        "Rating",
                                        style: TextStyle(
                                          fontSize: textBodySize,
                                          color: isDarkMode
                                              ? textColorDark
                                              : textColorLight,
                                        ),
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
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Icon(
                                              SFSymbols.star_fill,
                                              size: textBodySize,
                                              color: isDarkMode
                                                  ? iconColorDark
                                                  : iconColorLight,
                                            ),
                                            Text(
                                              ratingList[index]["feedback"]
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: isDarkMode
                                                      ? textColorDark
                                                      : textColorLight),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isDarkMode ? spinkit : spinkitDark,
                          Text(
                            "Loading Ratings...",
                            style: TextStyle(
                                color:
                                    isDarkMode ? textColorDark : textColorLight,
                                fontSize: 22),
                          )
                        ],
                      ),
                    )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDarkMode ? cardColorDark : Colors.black,
        icon: Icon(
          SFSymbols.arrow_counterclockwise,
          color: Colors.white,
        ),
        label: Text(
          "REFRESH",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          getFeedbacks();
        },
      ),
    );
  }
}
