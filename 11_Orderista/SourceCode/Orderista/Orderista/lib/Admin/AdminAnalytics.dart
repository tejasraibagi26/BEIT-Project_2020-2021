import 'package:orderista/Common/Analytics/DayAnalytics.dart';
import 'package:orderista/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAnalytics extends StatefulWidget {
  AdminAnalytics({Key key}) : super(key: key);

  @override
  _AdminAnalyticsState createState() => _AdminAnalyticsState();
}

class _AdminAnalyticsState extends State<AdminAnalytics> {
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
    Size size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
        body: SafeArea(
          child: DayAnalytics(
            isDarkMode: isDarkMode,
            size: size,
          ),
        ),
      ),
    );
  }
}
