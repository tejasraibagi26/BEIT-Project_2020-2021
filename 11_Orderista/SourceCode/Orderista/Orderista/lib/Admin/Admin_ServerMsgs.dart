import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:orderista/Admin/CreateMessages.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/constants.dart';
import 'package:orderista/Module/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminServerMessaging extends StatefulWidget {
  @override
  _AdminServerMessagingState createState() => _AdminServerMessagingState();
}

class _AdminServerMessagingState extends State<AdminServerMessaging> {
  bool isDarkMode = false;
  bool isFetching = false;

  SharedPreferences prefs;

  var allMessages = [];

  @override
  void initState() {
    super.initState();

    getTheme();
    getMsgs();
  }

  void getTheme() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isDarkMode") == null) {
      prefs.setBool("isDarkMode", false);
    }
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode");
    });
  }

  void getMsgs() async {
    if (this.mounted) {
      setState(() {
        isFetching = true;
      });
    }
    var msgs = await httpGet('api/v1/message/get-all-message');
    allMessages = msgs["data"];
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
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderText(
                    headerTitle: "Server Messages",
                    color: isDarkMode ? textColorDark : textColorLight,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                          color: isDarkMode ? iconColorDark : iconColorLight),
                    ),
                    child: Center(
                      child: Text(
                        "BETA",
                        style: TextStyle(
                          color: isDarkMode ? textColorDark : textColorLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              !isFetching
                  ? Expanded(
                      child: Container(
                        width: size.width,
                        height: size.height,
                        child: ListView.builder(
                            itemCount: allMessages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.all(20),
                                margin: EdgeInsets.symmetric(vertical: 10),
                                width: size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  color: isDarkMode
                                      ? cardColorDark
                                      : cardColorLight,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Message ID: ${allMessages[index]["msg_id"]}",
                                      style: TextStyle(
                                          fontSize: textBodySize - 2,
                                          color: isDarkMode
                                              ? subTitleDark
                                              : subTitleLight),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      allMessages[index]["msg_title"],
                                      style: TextStyle(
                                          fontSize: textBodySize,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? textColorDark
                                              : textColorLight),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    RichText(
                                      text: new TextSpan(
                                        children: [
                                          new TextSpan(
                                            text: allMessages[index]
                                                ["msg_body"],
                                            style: new TextStyle(
                                                fontSize: textBodySize,
                                                color: isDarkMode
                                                    ? textColorDark
                                                    : textColorLight),
                                          ),
                                          new TextSpan(
                                            text:
                                                '\n${allMessages[index]["msg_link"]}'
                                                    .toString(),
                                            style: new TextStyle(
                                                fontSize: textBodySize,
                                                color: isDarkMode
                                                    ? textColorDark
                                                    : textColorLight),
                                            recognizer:
                                                new TapGestureRecognizer()
                                                  ..onTap = () {
                                                    launch(
                                                        '${allMessages[index]["msg_link"]}');
                                                  },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                    )
                  : Center(
                      child: Column(
                        children: [
                          isDarkMode ? spinkit : spinkitDark,
                          Text(
                            "Fetching All...",
                            style: TextStyle(
                                color:
                                    isDarkMode ? textColorDark : textColorLight,
                                fontSize: textBodySize),
                          )
                        ],
                      ),
                    )
            ],
          ),
        ),
      ),
      floatingActionButton: getFAB(context),
    );
  }
}

Widget getFAB(BuildContext context) {
  return FloatingActionButton.extended(
    onPressed: () {
      Navigator.of(context)
          .push(CupertinoPageRoute(builder: (context) => ServerMessages()));
    },
    icon: Icon(
      SFSymbols.plus,
      color: Colors.white,
    ),
    label: Text(
      "MESSAGE",
      // style: TextStyle(letterSpacing: 0),
    ),
    backgroundColor: Colors.black,
  );
}
