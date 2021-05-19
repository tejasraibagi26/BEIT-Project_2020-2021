import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:orderista/Module/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class OverallFeedback extends StatefulWidget {
  @override
  _OverallFeedbackState createState() => _OverallFeedbackState();
}

class _OverallFeedbackState extends State<OverallFeedback> {
  var result;
  var feedbackList = [];
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
    result = await httpGet("api/v1/feedback/get-all");
    feedbackList = result["feedback"];
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !isFetching
                  ? Expanded(
                      child: Container(
                        width: size.width,
                        height: size.height,
                        decoration: BoxDecoration(),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount:
                              feedbackList != null ? feedbackList.length : 0,
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
                                          feedbackList[index]["feedback_title"]
                                              .toUpperCase(),
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
                                                  feedbackList[index]["userid"]
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
                                                  feedbackList[index]
                                                              ["time_stamp"]
                                                          .split('T')[0] +
                                                      " " +
                                                      feedbackList[index]
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
                                  Text(
                                    feedbackList[index]["feedback_body"],
                                    style: TextStyle(
                                        color: isDarkMode
                                            ? subTitleDark
                                            : subTitleLight,
                                        fontSize: 18),
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
                            "Loading Feedbacks...",
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
