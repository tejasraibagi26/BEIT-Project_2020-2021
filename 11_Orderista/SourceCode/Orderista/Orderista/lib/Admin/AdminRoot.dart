import 'package:orderista/Admin/AdminAnalytics.dart';
import 'package:orderista/Admin/AdminFeedback.dart';
import 'package:orderista/Admin/AdminProfile.dart';
import 'package:orderista/Admin/Admin_ServerMsgs.dart';
import 'package:orderista/Common/welcome_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class AdminRoot extends StatefulWidget {
  AdminRoot({Key key}) : super(key: key);

  @override
  _AdminRootState createState() => _AdminRootState();
}

class _AdminRootState extends State<AdminRoot> {
  int _currentIndex = 0;
  bool isDarkMode = false;
  SharedPreferences prefs;

  final List<Widget> pages = [
    AdminFeedbackViewPage(),
    AdminServerMessaging(),
    AdminAnalytics()
  ];

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

  void clearPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  List activeTabs = [
    SFSymbols.house_fill,
    SFSymbols.bubble_left_bubble_right_fill,
    SFSymbols.chart_bar_alt_fill,
  ];

  onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      appBar: AppBar(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => AdminProfile()));
            },
            icon: Icon(
              SFSymbols.person_fill,
              color: isDarkMode ? iconColorDark : iconColorLight,
            )),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "orderista",
          style: TextStyle(color: isDarkMode ? textColorDark : textColorLight),
        ),
        actions: [
          IconButton(
            icon: Icon(
              SFSymbols.square_arrow_right,
              color: isDarkMode ? iconColorDark : iconColorLight,
            ),
            onPressed: () {
              clearPrefs();
              Navigator.of(context).pushReplacement(CupertinoPageRoute(
                builder: (context) => WelcomeScreen(),
              ));
            },
          )
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 70,
        color: Colors.transparent,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 0, bottom: 10, left: 15, right: 15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.black,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(activeTabs.length, (index) {
                  return IconButton(
                      icon: Icon(
                        activeTabs[index],
                        size: 25,
                        color: _currentIndex == index
                            ? Colors.white
                            : Colors.white38,
                      ),
                      onPressed: () {
                        onTabTapped(index);
                      });
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
