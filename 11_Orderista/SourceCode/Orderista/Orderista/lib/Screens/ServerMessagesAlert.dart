import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:orderista/Provider/Cart.dart';
import 'package:orderista/Provider/Menu.dart';
import 'package:orderista/Root/root_app.dart';
import 'package:orderista/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ServerMessagesAlert extends StatefulWidget {
  ServerMessagesAlert(
      {this.msgAuthor, this.msgBody, this.msgID, this.msgLink, this.msgTitle});

  final String msgID, msgTitle, msgBody, msgLink, msgAuthor;

  @override
  _ServerMessagesAlertState createState() => _ServerMessagesAlertState();
}

class _ServerMessagesAlertState extends State<ServerMessagesAlert> {
  bool isDarkMode = false;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    getTheme();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.msgTitle,
                  style: TextStyle(
                    color: isDarkMode ? textColorDark : textColorLight,
                    fontSize: textHeaderSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                      text: widget.msgBody,
                      style: TextStyle(
                        color: isDarkMode ? textColorDark : textColorLight,
                        fontSize: textBodySize,
                      ),
                    ),
                    widget.msgLink != null
                        ? TextSpan(
                            text: "\n\n${widget.msgLink}",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blueAccent,
                              fontSize: textBodySize,
                            ),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                launch(widget.msgLink);
                              },
                          )
                        : TextSpan(text: ""),
                  ]),
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        CupertinoPageRoute(
                            builder: (context) => MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider(
                                      create: (context) => Cart(),
                                    ),
                                    ChangeNotifierProvider(
                                        create: (context) => Menu()),
                                  ],
                                  child: Root(),
                                )),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          color:
                              isDarkMode ? buttonColorDark : buttonColorLight,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(.20),
                                blurRadius: 20,
                                offset: Offset(0, 10))
                          ]),
                      child: Text(
                        "Okay",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: textBodySize,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
