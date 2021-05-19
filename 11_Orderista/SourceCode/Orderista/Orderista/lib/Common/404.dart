import 'package:orderista/Common/welcome_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class NoInternet extends StatefulWidget {
  @override
  _NoInternetState createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    getTheme();
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      appBar: AppBar(
        elevation: 0,
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'orderista',
          style: TextStyle(
            color: isDarkMode ? textColorDark : textColorLight,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: size.width,
                height: size.height * 0.4,
                child: SvgPicture.asset(
                  "images/13.svg",
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                'Uh Oh! No Internet Connection.',
                style: TextStyle(
                  color: isDarkMode ? textColorDark : textColorLight,
                  fontSize: textBodySize,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(CupertinoPageRoute(
                      builder: (context) => WelcomeScreen()));
                },
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    color: isDarkMode ? buttonColorDark : buttonColorLight,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12.withOpacity(.2),
                          blurRadius: 20,
                          offset: Offset(0, 10)),
                    ],
                  ),
                  child: Text(
                    "REFRESH",
                    style: TextStyle(
                        letterSpacing: 2.0,
                        color: Colors.white,
                        fontSize: textBodySize,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
